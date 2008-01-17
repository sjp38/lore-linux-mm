In-reply-to: <4df4ef0c0801170540p36d3c566w973251527fc3bca1@mail.gmail.com>
	(salikhmetov@gmail.com)
Subject: Re: [PATCH -v5 2/2] Updating ctime and mtime at syncing
References: <12005314662518-git-send-email-salikhmetov@gmail.com>
	 <1200531471556-git-send-email-salikhmetov@gmail.com>
	 <E1JFSgG-0006G1-6V@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170416s5581ae28h90d91578baa77738@mail.gmail.com>
	 <E1JFU7r-0006PK-So@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170516k3f82dc69ieee836b5633378a@mail.gmail.com>
	 <E1JFUrm-0006XG-SB@pomaz-ex.szeredi.hu> <4df4ef0c0801170540p36d3c566w973251527fc3bca1@mail.gmail.com>
Message-Id: <E1JFWvy-0006kJ-I2@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 17 Jan 2008 16:45:38 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: miklos@szeredi.hu, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> > I'm not sure this auto-updating is really needed (POSIX doesn't
> > mandate it).
> 
> Peter Shtaubach, author of the first solution for this bug,
> and Jacob Ostergaard, the reporter of this bug, insist the "auto-update"
> feature to be implemented.

Can they state their reasons for the insistence?

>  1) a base patch: update time just from fsync() and remove_vma()
>  2) update time on sync(2) as well
>  3) update time on MS_ASYNC as well

Oh, and the four-liner I posted the other day will give you 1) + 2) +
even more at a small fraction of the complexity.  And tacking on the
reprotect code will solve the MS_ASYNC issue just the same.

I agree, that having the timestamp updated on sync() is nice, and that
trivial patch will give you that, and will also update the timestamp
at least each 30 seconds if the file is being constantly modified,
even if no explicit syncing is done.

So maybe it's worth a little effort benchmarking how much that patch
affects the cost of writing to a page.

You could write a little test program like this (if somebody hasn't
yet done so):

 - do some preparation:

   echo 80 > dirty_ratio
   echo 80 > dirty_background_ratio
   echo 30000 > dirty_expire_centisecs
   sync

 - map a large file, one that fits comfortably into free memory
 - bring the whole file in, by reading a byte from each page
 - start the timer
 - write a byte to each page
 - stop the timer

It would be most interesting to try this on a filesystem supporting
nanosecond timestamps.  Anyone know which these are?

Miklos
----

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2008-01-09 21:16:30.000000000 +0100
+++ linux/mm/memory.c	2008-01-15 21:16:14.000000000 +0100
@@ -1680,6 +1680,8 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
 		/*
 		 * Yes, Virginia, this is actually required to prevent a race
 		 * with clear_page_dirty_for_io() from clearing the page dirty
@@ -2313,6 +2315,8 @@ out_unlocked:
 	if (anon)
 		page_cache_release(vmf.page);
 	else if (dirty_page) {
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
