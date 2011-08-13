Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2696B00EE
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 12:28:35 -0400 (EDT)
Date: Sat, 13 Aug 2011 18:28:26 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110813162826.GA1646@thinkpad>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312811234.10488.34.camel@twins>
 <20110808142318.GC22080@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808142318.GC22080@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 10:23:18PM +0800, Wu Fengguang wrote:
> On Mon, Aug 08, 2011 at 09:47:14PM +0800, Peter Zijlstra wrote:
> > On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> > > Add two fields to task_struct.
> > > 
> > > 1) account dirtied pages in the individual tasks, for accuracy
> > > 2) per-task balance_dirty_pages() call intervals, for flexibility
> > > 
> > > The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> > > scale near-sqrt to the safety gap between dirty pages and threshold.
> > > 
> > > XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> > > dirtying pages at exactly the same time, each task will be assigned a
> > > large initial nr_dirtied_pause, so that the dirty threshold will be
> > > exceeded long before each task reached its nr_dirtied_pause and hence
> > > call balance_dirty_pages().
> > > 
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  include/linux/sched.h |    7 ++
> > >  mm/memory_hotplug.c   |    3 -
> > >  mm/page-writeback.c   |  106 +++++++++-------------------------------
> > >  3 files changed, 32 insertions(+), 84 deletions(-) 
> > 
> > No fork() hooks? This way tasks inherit their parent's dirty count on
> > clone().
> 
> btw, I do have another patch queued for improving the "leaked dirties
> on exit" case :)
> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: charge leaked page dirties to active tasks
> Date: Tue Apr 05 13:21:19 CST 2011
> 
> It's a years long problem that a large number of short-lived dirtiers
> (eg. gcc instances in a fast kernel build) may starve long-run dirtiers
> (eg. dd) as well as pushing the dirty pages to the global hard limit.
> 
> The solution is to charge the pages dirtied by the exited gcc to the
> other random gcc/dd instances. It sounds not perfect, however should
> behave good enough in practice.
> 
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/writeback.h |    2 ++
>  kernel/exit.c             |    2 ++
>  mm/page-writeback.c       |   11 +++++++++++
>  3 files changed, 15 insertions(+)
> 
> --- linux-next.orig/include/linux/writeback.h	2011-08-08 21:45:58.000000000 +0800
> +++ linux-next/include/linux/writeback.h	2011-08-08 21:45:58.000000000 +0800
> @@ -7,6 +7,8 @@
>  #include <linux/sched.h>
>  #include <linux/fs.h>
>  
> +DECLARE_PER_CPU(int, dirty_leaks);
> +
>  /*
>   * The 1/4 region under the global dirty thresh is for smooth dirty throttling:
>   *
> --- linux-next.orig/mm/page-writeback.c	2011-08-08 21:45:58.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-08-08 22:21:50.000000000 +0800
> @@ -190,6 +190,7 @@ int dirty_ratio_handler(struct ctl_table
>  	return ret;
>  }
>  
> +DEFINE_PER_CPU(int, dirty_leaks) = 0;
>  
>  int dirty_bytes_handler(struct ctl_table *table, int write,
>  		void __user *buffer, size_t *lenp,
> @@ -1150,6 +1151,7 @@ void balance_dirty_pages_ratelimited_nr(
>  {
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  	int ratelimit;
> +	int *p;
>  
>  	if (!bdi_cap_account_dirty(bdi))
>  		return;
> @@ -1158,6 +1160,15 @@ void balance_dirty_pages_ratelimited_nr(
>  	if (bdi->dirty_exceeded)
>  		ratelimit = 8;
>  
> +	preempt_disable();
> +	p = &__get_cpu_var(dirty_leaks);
> +	if (*p > 0 && current->nr_dirtied < ratelimit) {
> +		nr_pages_dirtied = min(*p, ratelimit - current->nr_dirtied);
> +		*p -= nr_pages_dirtied;
> +		current->nr_dirtied += nr_pages_dirtied;
> +	}
> +	preempt_enable();
> +

I think we are still leaking some dirty pages, when the condition is
false nr_pages_dirtied is just ignored.

Why not doing something like this?

	current->nr_dirtied += nr_pages_dirtied;
	if (current->nr_dirtied < ratelimit) {
		p = &get_cpu_var(dirty_leaks);
		if (*p > 0) {
			nr_pages_dirtied = min(*p, ratelimit -
							current->nr_dirtied);
			*p -= nr_pages_dirtied;
		} else
			nr_pages_dirtied = 0;
		put_cpu_var(dirty_leaks);

		current->nr_dirtied += nr_pages_dirtied;
	}

Thanks,
-Andrea

>  	if (unlikely(current->nr_dirtied >= ratelimit))
>  		balance_dirty_pages(mapping, current->nr_dirtied);
>  }
> --- linux-next.orig/kernel/exit.c	2011-08-08 21:43:37.000000000 +0800
> +++ linux-next/kernel/exit.c	2011-08-08 21:45:58.000000000 +0800
> @@ -1039,6 +1039,8 @@ NORET_TYPE void do_exit(long code)
>  	validate_creds_for_do_exit(tsk);
>  
>  	preempt_disable();
> +	if (tsk->nr_dirtied)
> +		__this_cpu_add(dirty_leaks, tsk->nr_dirtied);
>  	exit_rcu();
>  	/* causes final put_task_struct in finish_task_switch(). */
>  	tsk->state = TASK_DEAD;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
