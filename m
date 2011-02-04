Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7714B8D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:15:58 -0500 (EST)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLVz-0003cM-5g
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:15:55 +0000
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1296783534-11585-4-git-send-email-jack@suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
	 <1296783534-11585-4-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 14:09:16 +0100
Message-ID: <1296824956.26581.649.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> +void distribute_page_completions(struct work_struct *work)
> +{
> +       struct backing_dev_info *bdi =
> +               container_of(work, struct backing_dev_info, balance_work.work);
> +       unsigned long written = bdi_stat_sum(bdi, BDI_WRITTEN);
> +       unsigned long pages_per_waiter, remainder_pages;
> +       struct balance_waiter *waiter, *tmpw;
> +       struct dirty_limit_state st;
> +       int dirty_exceeded;
> +
> +       trace_writeback_distribute_page_completions(bdi, bdi->written_start,
> +                                         written - bdi->written_start);

So in fact you only need to pass bdi and written :-)

> +       dirty_exceeded = check_dirty_limits(bdi, &st);
> +       if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
> +               /* Wakeup everybody */
> +               trace_writeback_distribute_page_completions_wakeall(bdi);
> +               spin_lock(&bdi->balance_lock);
> +               list_for_each_entry_safe(
> +                               waiter, tmpw, &bdi->balance_list, bw_list)
> +                       balance_waiter_done(bdi, waiter);
> +               spin_unlock(&bdi->balance_lock);
> +               return;
> +       }
> +
> +       spin_lock(&bdi->balance_lock);

is there any reason this is a spinlock and not a mutex?

> +       /*
> +        * Note: This loop can have quadratic complexity in the number of
> +        * waiters. It can be changed to a linear one if we also maintained a
> +        * list sorted by number of pages. But for now that does not seem to be
> +        * worth the effort.
> +        */

That doesn't seem to explain much :/

> +       remainder_pages = written - bdi->written_start;
> +       bdi->written_start = written;
> +       while (!list_empty(&bdi->balance_list)) {
> +               pages_per_waiter = remainder_pages / bdi->balance_waiters;
> +               if (!pages_per_waiter)
> +                       break;

if remainder_pages < balance_waiters you just lost you delta, its best
to not set bdi->written_start until the end and leave everything not
processed for the next round.

> +               remainder_pages %= bdi->balance_waiters;
> +               list_for_each_entry_safe(
> +                               waiter, tmpw, &bdi->balance_list, bw_list) {
> +                       if (waiter->bw_to_write <= pages_per_waiter) {
> +                               remainder_pages += pages_per_waiter -
> +                                                  waiter->bw_to_write;
> +                               balance_waiter_done(bdi, waiter);
> +                               continue;
> +                       }
> +                       waiter->bw_to_write -= pages_per_waiter;
>                 }
> +       }
> +       /* Distribute remaining pages */
> +       list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list) {
> +               if (remainder_pages > 0) {
> +                       waiter->bw_to_write--;
> +                       remainder_pages--;
> +               }
> +               if (waiter->bw_to_write == 0 ||
> +                   (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> +                    !bdi_task_limit_exceeded(&st, waiter->bw_task)))
> +                       balance_waiter_done(bdi, waiter);
> +       }

OK, I see what you're doing, but I'm not quite sure it makes complete
sense yet.

  mutex_lock(&bdi->balance_mutex);
  for (;;) {
    unsigned long pages = written - bdi->written_start;
    unsigned long pages_per_waiter = pages / bdi->balance_waiters;
    if (!pages_per_waiter)
      break;
    list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list){
      unsigned long delta = min(pages_per_waiter, waiter->bw_to_write);

      bdi->written_start += delta;
      waiter->bw_to_write -= delta;
      if (!waiter->bw_to_write)
        balance_waiter_done(bdi, waiter);
    }
  }
  mutex_unlock(&bdi->balance_mutex);

Comes close to what you wrote I think.

One of the problems I have with it is that min(), it means that that
waiter waited too long, but will not be compensated for this by reducing
its next wait. Instead you give it away to other waiters which preserves
fairness on the bdi level, but not for tasks.

You can do that by keeping ->bw_to_write in task_struct and normalize it
by the estimated bdi bandwidth (patch 5), that way, when you next
increment it it will turn out to be lower and the wait will be shorter.

That also removes the need to loop over the waiters.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
