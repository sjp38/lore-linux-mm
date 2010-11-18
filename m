Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 830C06B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:26:26 -0500 (EST)
Date: Thu, 18 Nov 2010 21:26:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-ID: <20101118132617.GA9307@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.410279291@intel.com>
 <1290085474.2109.1480.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290085474.2109.1480.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, tglx <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 09:04:34PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > - avoid too small pause time (less than  10ms, which burns CPU power)
> > - avoid too large pause time (more than 100ms, which hurts responsiveness)
> > - avoid big fluctuations of pause times 
> 
> If you feel like playing with sub-jiffies timeouts (a way to avoid that
> HZ=>100 assumption), the below (totally untested) patch might be of
> help..

Assuming there are HZ=10 users.

- when choosing such a coarse granularity, do they really care about
  responsiveness? :)

- will the use of hrtimer add a little code size and/or runtime
  overheads, and hence hurt the majority HZ=100 users?

Thanks,
Fengguang

> 
> ---
> Subject: hrtimer: Provide io_schedule_timeout*() functions
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/hrtimer.h |    7 +++++++
>  kernel/hrtimer.c        |   15 +++++++++++++++
>  kernel/sched.c          |   17 +++++++++++++++++
>  3 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
> index dd9954b..9e0f67e 100644
> --- a/include/linux/hrtimer.h
> +++ b/include/linux/hrtimer.h
> @@ -419,6 +419,13 @@ extern long hrtimer_nanosleep_restart(struct restart_block *restart_block);
>  extern void hrtimer_init_sleeper(struct hrtimer_sleeper *sl,
>  				 struct task_struct *tsk);
>  
> +extern int io_schedule_hrtimeout_range(ktime_t *expires, unsigned long delta,
> +						const enum hrtimer_mode mode);
> +extern int io_schedule_hrtimeout_range_clock(ktime_t *expires,
> +		unsigned long delta, const enum hrtimer_mode mode, int clock);
> +extern int io_schedule_hrtimeout(ktime_t *expires, const enum hrtimer_mode mode);
> +
> +
>  extern int schedule_hrtimeout_range(ktime_t *expires, unsigned long delta,
>  						const enum hrtimer_mode mode);
>  extern int schedule_hrtimeout_range_clock(ktime_t *expires,
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index 72206cf..ef2d93c 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -1838,6 +1838,14 @@ int __sched schedule_hrtimeout_range(ktime_t *expires, unsigned long delta,
>  }
>  EXPORT_SYMBOL_GPL(schedule_hrtimeout_range);
>  
> +int __sched io_schedule_hrtimeout_range(ktime_t *expires, unsigned long delta,
> +				     const enum hrtimer_mode mode)
> +{
> +	return io_schedule_hrtimeout_range_clock(expires, delta, mode,
> +					      CLOCK_MONOTONIC);
> +}
> +EXPORT_SYMBOL_GPL(io_schedule_hrtimeout_range);
> +
>  /**
>   * schedule_hrtimeout - sleep until timeout
>   * @expires:	timeout value (ktime_t)
> @@ -1866,3 +1874,10 @@ int __sched schedule_hrtimeout(ktime_t *expires,
>  	return schedule_hrtimeout_range(expires, 0, mode);
>  }
>  EXPORT_SYMBOL_GPL(schedule_hrtimeout);
> +
> +int __sched io_schedule_hrtimeout(ktime_t *expires,
> +			       const enum hrtimer_mode mode)
> +{
> +	return io_schedule_hrtimeout_range(expires, 0, mode);
> +}
> +EXPORT_SYMBOL_GPL(io_schedule_hrtimeout);
> diff --git a/kernel/sched.c b/kernel/sched.c
> index d5564a8..ac84455 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -5303,6 +5303,23 @@ long __sched io_schedule_timeout(long timeout)
>  	return ret;
>  }
>  
> +int __sched
> +io_schedule_hrtimeout_range_clock(ktime_t *expires, unsigned long delta,
> +			       const enum hrtimer_mode mode, int clock)
> +{
> +	struct rq *rq = raw_rq();
> +	long ret;
> +
> +	delayacct_blkio_start();
> +	atomic_inc(&rq->nr_iowait);
> +	current->in_iowait = 1;
> +	ret = schedule_hrtimeout_range_clock(expires, delta, mode, clock);
> +	current->in_iowait = 0;
> +	atomic_dec(&rq->nr_iowait);
> +	delayacct_blkio_end();
> +	return ret;
> +}
> +
>  /**
>   * sys_sched_get_priority_max - return maximum RT priority.
>   * @policy: scheduling class.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
