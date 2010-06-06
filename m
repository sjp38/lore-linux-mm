Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 923AB6B01B8
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 00:51:51 -0400 (EDT)
Date: Sun, 6 Jun 2010 12:08:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/2 RFC v3] Livelock avoidance for data integrity
 writeback
Message-ID: <20100606040819.GA16293@localhost>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <20100605011447.GF26335@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100605011447.GF26335@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 05, 2010 at 11:14:47AM +1000, Nick Piggin wrote:
> On Fri, Jun 04, 2010 at 08:47:09PM +0200, Jan Kara wrote:
> > 
> >   Hi,
> > 
> >   I've revived my patches to implement livelock avoidance for data integrity
> > writes. Due to some concerns whether tagging of pages before writeout cannot
> > be too costly to use for WB_SYNC_NONE mode (where we stop after nr_to_write
> > pages) I've changed the patch to use page tagging only in WB_SYNC_ALL mode
> > where we are sure that we write out all the tagged pages. Later, we can think
> > about using tagging for livelock avoidance for WB_SYNC_NONE mode as well...
> 
> Hmm what concerns? Do you have any numbers?

sync() is performed in two stages: the WB_SYNC_NONE run and the
WB_SYNC_ALL run. The WB_SYNC_NONE stage can still be livelocked.

We may switch to wbc.for_sync (instead of testing WB_SYNC_ALL only)
provided by the following patch. Jan, would you add it to your series
(with necessary improvements)?

Thanks,
Fengguang
---
introduce wbc.for_sync to cover the two sync() stages

The sync() is performed in two stages: the WB_SYNC_NONE sync and
the WB_SYNC_ALL sync. It is necessary to tag both stages with
wbc.for_sync, so as to prevent either of them being livelocked.

The next patch will utilize this flag to do the livelock prevention.

btw, the nr_pages param in bdi_start_writeback() is dropped:

1) better livelock prevention will be used. Limiting nr_to_write was
   inferior in that it may miss some pages to sync. And it does not
   really avoid livelock for single huge file: write_cache_pages()
   ignores nr_to_write for WB_SYNC_NONE at all.

2) It is very unlikely to impact some not-for-sync existing users.
   For example the ubifs call writeback_inodes_sb() to writeback some
   pages. And the ext4 also intents to write somehow enough pages with
   writeback_inodes_sb_if_idle().  However they seem not really care to
   write more pages.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |   28 ++++++++--------------------
 include/linux/backing-dev.h |    2 +-
 include/linux/writeback.h   |    8 ++++++++
 mm/page-writeback.c         |    2 +-
 4 files changed, 18 insertions(+), 22 deletions(-)

--- linux.orig/fs/fs-writeback.c	2010-06-06 11:16:42.000000000 +0800
+++ linux/fs/fs-writeback.c	2010-06-06 11:21:13.000000000 +0800
@@ -42,6 +42,7 @@ struct wb_writeback_args {
 	long nr_pages;
 	struct super_block *sb;
 	enum writeback_sync_modes sync_mode;
+	int for_sync:1;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
@@ -228,6 +229,7 @@ static void bdi_sync_writeback(struct ba
 	struct wb_writeback_args args = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_ALL,
+		.for_sync	= 1,
 		.nr_pages	= LONG_MAX,
 		.range_cyclic	= 0,
 	};
@@ -244,7 +246,6 @@ static void bdi_sync_writeback(struct ba
  * bdi_start_writeback - start writeback
  * @bdi: the backing device to write from
  * @sb: write inodes from this super_block
- * @nr_pages: the number of pages to write
  *
  * Description:
  *   This does WB_SYNC_NONE opportunistic writeback. The IO is only
@@ -253,24 +254,17 @@ static void bdi_sync_writeback(struct ba
  *
  */
 void bdi_start_writeback(struct backing_dev_info *bdi, struct super_block *sb,
-			 long nr_pages)
+			 long mission)
 {
 	struct wb_writeback_args args = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_NONE,
-		.nr_pages	= nr_pages,
+		.nr_pages	= LONG_MAX,
+		.for_background	= mission == WB_FOR_BACKGROUND,
+		.for_sync	= mission == WB_FOR_SYNC,
 		.range_cyclic	= 1,
 	};
 
-	/*
-	 * We treat @nr_pages=0 as the special case to do background writeback,
-	 * ie. to sync pages until the background dirty threshold is reached.
-	 */
-	if (!nr_pages) {
-		args.nr_pages = LONG_MAX;
-		args.for_background = 1;
-	}
-
 	bdi_alloc_queue_work(bdi, &args);
 }
 
@@ -757,6 +751,7 @@ static long wb_writeback(struct bdi_writ
 		.older_than_this	= NULL,
 		.for_kupdate		= args->for_kupdate,
 		.for_background		= args->for_background,
+		.for_sync		= args->for_sync,
 		.range_cyclic		= args->range_cyclic,
 	};
 	unsigned long oldest_jif;
@@ -1216,14 +1211,7 @@ static void wait_sb_inodes(struct super_
  */
 void writeback_inodes_sb(struct super_block *sb)
 {
-	unsigned long nr_dirty = global_page_state(NR_FILE_DIRTY);
-	unsigned long nr_unstable = global_page_state(NR_UNSTABLE_NFS);
-	long nr_to_write;
-
-	nr_to_write = nr_dirty + nr_unstable +
-			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
-
-	bdi_start_writeback(sb->s_bdi, sb, nr_to_write);
+	bdi_start_writeback(sb->s_bdi, sb, WB_FOR_SYNC);
 }
 EXPORT_SYMBOL(writeback_inodes_sb);
 
--- linux.orig/include/linux/backing-dev.h	2010-06-06 11:16:42.000000000 +0800
+++ linux/include/linux/backing-dev.h	2010-06-06 11:21:13.000000000 +0800
@@ -106,7 +106,7 @@ int bdi_register_dev(struct backing_dev_
 void bdi_unregister(struct backing_dev_info *bdi);
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, struct super_block *sb,
-				long nr_pages);
+				long mission);
 int bdi_writeback_task(struct bdi_writeback *wb);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);
--- linux.orig/include/linux/writeback.h	2010-06-06 11:16:42.000000000 +0800
+++ linux/include/linux/writeback.h	2010-06-06 11:58:58.000000000 +0800
@@ -21,6 +21,13 @@ enum writeback_sync_modes {
 	WB_SYNC_ALL,	/* Wait on every mapping */
 };
 
+enum writeback_mission {
+	WB_FOR_BACKGROUND,	/* stop on hitting background threshold */
+	WB_FOR_SYNC,		/* write all now-dirty inodes/pages,
+				 * but take care not to live lock
+				 */
+};
+
 /*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
@@ -53,6 +60,7 @@ struct writeback_control {
 	unsigned encountered_congestion:1; /* An output: a queue is full */
 	unsigned for_kupdate:1;		/* A kupdate writeback */
 	unsigned for_background:1;	/* A background writeback */
+	unsigned for_sync:1;		/* A writeback for sync */
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
 	unsigned more_io:1;		/* more io to be dispatched */
--- linux.orig/mm/page-writeback.c	2010-06-06 11:16:42.000000000 +0800
+++ linux/mm/page-writeback.c	2010-06-06 11:21:13.000000000 +0800
@@ -597,7 +597,7 @@ static void balance_dirty_pages(struct a
 	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
 			       + global_page_state(NR_UNSTABLE_NFS))
 					  > background_thresh)))
-		bdi_start_writeback(bdi, NULL, 0);
+		bdi_start_writeback(bdi, NULL, WB_FOR_BACKGROUND);
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
