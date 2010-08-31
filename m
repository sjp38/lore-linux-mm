Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C8A06B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 03:48:45 -0400 (EDT)
Date: Tue, 31 Aug 2010 15:48:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_cleaned in
 /proc/vmstat
Message-ID: <20100831074825.GA19358@localhost>
References: <1282963227-31867-1-git-send-email-mrubin@google.com>
 <1282963227-31867-4-git-send-email-mrubin@google.com>
 <20100828235029.GA7071@localhost>
 <AANLkTi=KjbfqzZsD6MOQG+4i7vHj6ZEh1_nF7DpwqeLV@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=KjbfqzZsD6MOQG+4i7vHj6ZEh1_nF7DpwqeLV@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

> > The output format is quite different from /proc/vmstat.
> > Do we really need to "Node X", ":" and "times" decorations?
> 
> Node X is based on the meminfo file but I agree it's redundant information.

Thanks. In the same directory you can find a different style example
/sys/devices/system/node/node0/numastat :) If ever the file was named
vmstat! In the other hand, shall we put the numbers there? I'm confused..

> > And the "_PAGES" in NR_FILE_PAGES_DIRTIED looks redundant to
> > the "_page" in node_page_state(). It's a bit long to be a pleasant
> > name. NR_FILE_DIRTIED/NR_CLEANED looks nicer.
> 
> Yeah. Will fix.

Thanks. This is kind of nitpick, however here is another name by
Jan Kara: BDI_WRITTEN. BDI_WRITTEN may not be a lot better than
BDI_CLEANED, but here is a patch based on Jan's code. I'm cooking
more patches that make use of this per-bdi counter to estimate the
bdi's write bandwidth, and to further decide the optimal (large)
writeback chunk size as well as to do IO-less balance_dirty_pages().

Basically BDI_WRITTEN and NR_CLEANED are accounting for the same
thing in different dimensions. So it would be good if we can use
the same naming scheme to avoid confusing users: either to use
BDI_WRITTEN and NR_WRITTEN, or use BDI_CLEANED and NR_CLEANED.
What's your opinion?

Thanks,
Fengguang

---
writeback: account per-bdi accumulated written pages

This steals code from Jan's balance_dirty_pages() patch.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |    6 ++++--
 mm/page-writeback.c         |    1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2010-08-29 23:32:46.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-08-29 23:52:50.000000000 +0800
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
 
--- linux-next.orig/mm/backing-dev.c	2010-08-29 23:32:46.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-08-29 23:52:50.000000000 +0800
@@ -91,6 +91,7 @@ static int bdi_debug_stats_show(struct s
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
+		   "BdiWritten:       %8lu kB\n"
 		   "b_dirty:          %8lu\n"
 		   "b_io:             %8lu\n"
 		   "b_more_io:        %8lu\n"
@@ -98,8 +99,9 @@ static int bdi_debug_stats_show(struct s
 		   "state:            %8lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
-		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
+		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
+		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
 
--- linux-next.orig/mm/page-writeback.c	2010-08-29 23:52:47.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-29 23:52:50.000000000 +0800
@@ -1305,6 +1305,7 @@ int test_clear_page_writeback(struct pag
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
+				__inc_bdi_stat(bdi, BDI_WRITTEN);
 				__bdi_writeout_inc(bdi);
 			}
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
