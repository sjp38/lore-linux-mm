In-reply-to: <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Mon, 19 Feb 2007 18:11:55 +0100)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HJHgV-0007UQ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 20 Feb 2007 00:12:39 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Solves the FUSE deadlock, but not the throttle_vm_writeout() one.
> I'll try to tackle that one as well.
> 
> If the per-bdi dirty counter goes below 16, balance_dirty_pages()
> returns.
> 
> Does the constant need to tunable?  If it's too large, then the global
> threshold is more easily exceeded.  If it's too small, then in a tight
> situation progress will be slower.

Similar in spirit, this should solve the deadlock on throttle_vm_writeout().
Totally untested.

Does this approach look workable?

Thanks,
Miklos


Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2007-02-19 23:39:36.000000000 +0100
+++ linux/include/linux/swap.h	2007-02-20 00:03:38.000000000 +0100
@@ -277,10 +277,14 @@ static inline void disable_swap_token(vo
 	put_swap_token(swap_token_mm);
 }
 
+#define nr_swap_writeback \
+	atomic_long_read(&swapper_space.backing_dev_info->nr_writeback)
+
 #else /* CONFIG_SWAP */
 
 #define total_swap_pages			0
 #define total_swapcache_pages			0UL
+#define nr_swap_writeback			0UL
 
 #define si_swapinfo(val) \
 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2007-02-19 23:43:03.000000000 +0100
+++ linux/mm/page-writeback.c	2007-02-20 00:03:49.000000000 +0100
@@ -33,6 +33,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/swap.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -332,6 +333,9 @@ void throttle_vm_writeout(void)
                 if (global_page_state(NR_UNSTABLE_NFS) +
 			global_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
+
+		if (nr_swap_writeback < 16)
+			break;
                 congestion_wait(WRITE, HZ/10);
         }
 }
Index: linux/mm/page_io.c
===================================================================
--- linux.orig/mm/page_io.c	2007-02-19 23:24:23.000000000 +0100
+++ linux/mm/page_io.c	2007-02-19 23:42:21.000000000 +0100
@@ -70,6 +70,7 @@ static int end_swap_bio_write(struct bio
 		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
+	atomic_long_dec(&swapper_space.backing_dev_info->nr_writeback);
 	bio_put(bio);
 	return 0;
 }
@@ -121,6 +122,7 @@ int swap_writepage(struct page *page, st
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		rw |= (1 << BIO_RW_SYNC);
 	count_vm_event(PSWPOUT);
+	atomic_long_inc(&swapper_space.backing_dev_info->nr_writeback);
 	set_page_writeback(page);
 	unlock_page(page);
 	submit_bio(rw, bio);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
