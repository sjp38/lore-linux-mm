Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 157936B0033
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 10:02:46 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id l10so1699946eei.18
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 07:02:44 -0700 (PDT)
Date: Fri, 26 Apr 2013 16:02:40 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [fuse-devel] [PATCH 14/14] mm: Account for WRITEBACK_TEMP in
 balance_dirty_pages
Message-ID: <20130426140240.GC16238@tucsk.piliscsaba.szeredi.hu>
References: <20130401103749.19027.89833.stgit@maximpc.sw.ru>
 <20130401104250.19027.27795.stgit@maximpc.sw.ru>
 <51793DE6.3000503@parallels.com>
 <CAJfpegv1zc4oeE=YXrQd0jmzVXB8jjvXkz-_4Nv_ELcvfsa74Q@mail.gmail.com>
 <517956ED.7060102@parallels.com>
 <20130425204331.GB16238@tucsk.piliscsaba.szeredi.hu>
 <517A3B98.807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517A3B98.807@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Maxim V. Patlasov" <mpatlasov@parallels.com>
Cc: Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, mgorman@suse.de, riel@redhat.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org

On Fri, Apr 26, 2013 at 12:32:24PM +0400, Maxim V. Patlasov wrote:

> > The idea is that fuse filesystems should not go over the bdi limit even if
> > the global limit hasn't been reached.
> 
> This might work, but kicking flusher every time someone write to
> fuse mount and dives into balance_dirty_pages looks fishy.

Yeah.  Fixed patch attached.

> Let's combine
> our suggestions: mark fuse inodes with AS_FUSE_WRITEBACK flag and
> convert what you strongly dislike above to:
> 
> if (test_bit(AS_FUSE_WRITEBACK, &mapping->flags))
> nr_dirty += global_page_state(NR_WRITEBACK_TEMP);

I don't think this is right.  The fuse daemon could itself be writing to another
fuse filesystem, in which case blocking because of NR_WRITEBACK_TEMP being high
isn't a smart strategy.

Furthermore it isn't enough.  Becuase the root problem, I think, is that we
allow fuse filesystems to grow a large number of dirty pages before throttling.
This was never intended and it may actually have worked properly at a point in
time but broke by some change to the dirty throttling algorithm.

Thanks,
Miklos


diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 137185c..195ee45 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -291,6 +291,7 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
 		inode->i_flags |= S_NOATIME|S_NOCMTIME;
 		inode->i_generation = generation;
 		inode->i_data.backing_dev_info = &fc->bdi;
+		set_bit(AS_STRICTLIMIT, &inode->i_data.flags);
 		fuse_init_inode(inode, attr);
 		unlock_new_inode(inode);
 	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0e38e13..97f6a0c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,7 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
+	AS_STRICTLIMIT	= __GFP_BITS_SHIFT + 5, /* strict dirty limit */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index efe6814..b6db421 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1226,6 +1226,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	int strictlimit = test_bit(AS_STRICTLIMIT, &mapping->flags);
 	unsigned long start_time = jiffies;
 
 	for (;;) {
@@ -1250,7 +1251,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		freerun = dirty_freerun_ceiling(dirty_thresh,
 						background_thresh);
-		if (nr_dirty <= freerun) {
+		if (nr_dirty <= freerun && !strictlimit) {
 			current->dirty_paused_when = now;
 			current->nr_dirtied = 0;
 			current->nr_dirtied_pause =
@@ -1258,7 +1259,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 		}
 
-		if (unlikely(!writeback_in_progress(bdi)))
+		if (unlikely(!writeback_in_progress(bdi)) && !strictlimit)
 			bdi_start_background_writeback(bdi);
 
 		/*
@@ -1296,8 +1297,12 @@ static void balance_dirty_pages(struct address_space *mapping,
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		if (unlikely(!writeback_in_progress(bdi)) &&
+		    bdi_dirty > bdi_thresh / 2)
+			bdi_start_background_writeback(bdi);
+
 		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
-				  (nr_dirty > dirty_thresh);
+				  ((nr_dirty > dirty_thresh) || strictlimit);
 		if (dirty_exceeded && !bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
