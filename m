Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CAB846B016C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:46:22 -0400 (EDT)
Date: Wed, 7 Sep 2011 10:46:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/18] writeback: IO-less balance_dirty_pages()
Message-ID: <20110907024618.GD13755@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.383842632@intel.com>
 <1315311233.12533.3.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315311233.12533.3.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 06, 2011 at 08:13:53PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > -static inline void task_dirties_fraction(struct task_struct *tsk,
> > -               long *numerator, long *denominator)
> > -{
> > -       prop_fraction_single(&vm_dirties, &tsk->dirties,
> > -                               numerator, denominator);
> > -} 
> 
> it looks like this patch removes all users of tsk->dirties, but doesn't
> in fact remove the data member from task_struct.

Good catch! This incremental patch will remove all references to
vm_dirties and tsk->dirties. Hmm, it may look more clean to make it a
standalone patch together with the chunk to remove
task_dirty_limit()/task_dirties_fraction().

Thanks,
Fengguang
---
 include/linux/sched.h |    1 -
 mm/page-writeback.c   |    9 ---------
 2 files changed, 10 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-09-07 10:42:55.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-09-07 10:43:06.000000000 +0800
@@ -1520,7 +1520,6 @@ struct task_struct {
 #ifdef CONFIG_FAULT_INJECTION
 	int make_it_fail;
 #endif
-	struct prop_local_single dirties;
 	/*
 	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
 	 * balance_dirty_pages() for some dirty throttling pause
--- linux-next.orig/mm/page-writeback.c	2011-09-07 10:43:04.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-09-07 10:43:06.000000000 +0800
@@ -128,7 +128,6 @@ unsigned long global_dirty_limit;
  *
  */
 static struct prop_descriptor vm_completions;
-static struct prop_descriptor vm_dirties;
 
 /*
  * Work out the current dirty-memory clamping and background writeout
@@ -214,7 +213,6 @@ static void update_completion_period(voi
 {
 	int shift = calc_period_shift();
 	prop_change_shift(&vm_completions, shift);
-	prop_change_shift(&vm_dirties, shift);
 
 	writeback_set_ratelimit();
 }
@@ -294,11 +292,6 @@ void bdi_writeout_inc(struct backing_dev
 }
 EXPORT_SYMBOL_GPL(bdi_writeout_inc);
 
-void task_dirty_inc(struct task_struct *tsk)
-{
-	prop_inc_single(&vm_dirties, &tsk->dirties);
-}
-
 /*
  * Obtain an accurate fraction of the BDI's portion.
  */
@@ -1286,7 +1279,6 @@ void __init page_writeback_init(void)
 
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
-	prop_descriptor_init(&vm_dirties, shift);
 }
 
 /**
@@ -1615,7 +1607,6 @@ void account_page_dirtied(struct page *p
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
-		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
