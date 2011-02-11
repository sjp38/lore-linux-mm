Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E7D198D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 10:47:13 -0500 (EST)
Date: Fri, 11 Feb 2011 16:46:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110211154616.GK5187@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
 <1296783534-11585-4-git-send-email-jack@suse.cz>
 <1296824956.26581.649.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296824956.26581.649.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri 04-02-11 14:09:16, Peter Zijlstra wrote:
> On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> > +       dirty_exceeded = check_dirty_limits(bdi, &st);
> > +       if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
> > +               /* Wakeup everybody */
> > +               trace_writeback_distribute_page_completions_wakeall(bdi);
> > +               spin_lock(&bdi->balance_lock);
> > +               list_for_each_entry_safe(
> > +                               waiter, tmpw, &bdi->balance_list, bw_list)
> > +                       balance_waiter_done(bdi, waiter);
> > +               spin_unlock(&bdi->balance_lock);
> > +               return;
> > +       }
> > +
> > +       spin_lock(&bdi->balance_lock);
> is there any reason this is a spinlock and not a mutex?
  No. Is mutex preferable?

> > +       /*
> > +        * Note: This loop can have quadratic complexity in the number of
> > +        * waiters. It can be changed to a linear one if we also maintained a
> > +        * list sorted by number of pages. But for now that does not seem to be
> > +        * worth the effort.
> > +        */
> 
> That doesn't seem to explain much :/
> 
> > +       remainder_pages = written - bdi->written_start;
> > +       bdi->written_start = written;
> > +       while (!list_empty(&bdi->balance_list)) {
> > +               pages_per_waiter = remainder_pages / bdi->balance_waiters;
> > +               if (!pages_per_waiter)
> > +                       break;
> 
> if remainder_pages < balance_waiters you just lost you delta, its best
> to not set bdi->written_start until the end and leave everything not
> processed for the next round.
  I haven't lost it, it will be distributed in the second loop.

> > +               remainder_pages %= bdi->balance_waiters;
> > +               list_for_each_entry_safe(
> > +                               waiter, tmpw, &bdi->balance_list, bw_list) {
> > +                       if (waiter->bw_to_write <= pages_per_waiter) {
> > +                               remainder_pages += pages_per_waiter -
> > +                                                  waiter->bw_to_write;
> > +                               balance_waiter_done(bdi, waiter);
> > +                               continue;
> > +                       }
> > +                       waiter->bw_to_write -= pages_per_waiter;
> >                 }
> > +       }
> > +       /* Distribute remaining pages */
> > +       list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list) {
> > +               if (remainder_pages > 0) {
> > +                       waiter->bw_to_write--;
> > +                       remainder_pages--;
> > +               }
> > +               if (waiter->bw_to_write == 0 ||
> > +                   (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> > +                    !bdi_task_limit_exceeded(&st, waiter->bw_task)))
> > +                       balance_waiter_done(bdi, waiter);
> > +       }
> 
> OK, I see what you're doing, but I'm not quite sure it makes complete
> sense yet.
> 
>   mutex_lock(&bdi->balance_mutex);
>   for (;;) {
>     unsigned long pages = written - bdi->written_start;
>     unsigned long pages_per_waiter = pages / bdi->balance_waiters;
>     if (!pages_per_waiter)
>       break;
>     list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list){
>       unsigned long delta = min(pages_per_waiter, waiter->bw_to_write);
> 
>       bdi->written_start += delta;
>       waiter->bw_to_write -= delta;
>       if (!waiter->bw_to_write)
>         balance_waiter_done(bdi, waiter);
>     }
>   }
>   mutex_unlock(&bdi->balance_mutex);
> 
> Comes close to what you wrote I think.
  Yes, quite close. Only if we wake up and there are not enough pages for
all waiters. We at least "help" waiters in the beginning of the queue. That
could have some impact when the queue grows quickly on a slow device
(something like write fork bomb) but given we need only one page written per
waiter it would be really horrible situation when this triggers anyway...

> One of the problems I have with it is that min(), it means that that
> waiter waited too long, but will not be compensated for this by reducing
> its next wait. Instead you give it away to other waiters which preserves
> fairness on the bdi level, but not for tasks.
> 
> You can do that by keeping ->bw_to_write in task_struct and normalize it
> by the estimated bdi bandwidth (patch 5), that way, when you next
> increment it it will turn out to be lower and the wait will be shorter.
> 
> That also removes the need to loop over the waiters.
  Umm, interesting idea! Just the implication "pages_per_waiter >
->bw_to_write => we waited for too long" isn't completely right. In fact,
each waiter entered the queue sometime between the first waiter entered it
and the time timer triggered. It might have been just shortly before the
timer triggered and thus it will be in fact delayed for too short time. So
this problem is somehow the other side of the problem you describe and so
far I just ignored this problem in a hope that it just levels out in the
long term.

The trouble I see with storing remaining written pages with each task is
that we can accumulate significant amount of pages in that - from what I
see e.g. with my SATA drive the writeback completion seems to be rather
bumpy (and it's even worse over NFS). If we then get below dirty limit,
process can carry over a lot of written pages to the time when dirty limit
gets exceeded again which reduces the effect of throttling at that time
and we can exceed dirty limits by more than we'd wish. We could solve this
by somehow invalidating the written pages when we stop throttling on that
bdi but that would mean to track something like pairs <bonus pages, bdi>
with each task - not sure we want to do that...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
