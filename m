Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB26D6B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:33:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b66so79689398pfe.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:33:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 7si1237038ple.661.2017.08.09.18.33.29
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 18:33:30 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:32:16 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170810013216.GX20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170809141605.7r3cldc4na3skcnp@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809141605.7r3cldc4na3skcnp@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 09, 2017 at 04:16:05PM +0200, Peter Zijlstra wrote:
> Hehe, _another_ scheme...
> 
> Yes I think this works.. but I had just sort of understood the last one.
> 
> How about I do this on top? That I think is a combination of what I
> proposed last and your single invalidate thing. Combined they solve the
> problem with the least amount of extra storage (a single int).

I'm sorry for saying that.. I'm not sure if this works well.

> ---
> Subject: lockdep: Simplify xhlock ring buffer invalidation
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed Aug 9 15:31:27 CEST 2017
> 
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  include/linux/lockdep.h  |   20 -----------
>  include/linux/sched.h    |    4 --
>  kernel/locking/lockdep.c |   82 ++++++++++++++++++++++++++++++-----------------
>  3 files changed, 54 insertions(+), 52 deletions(-)
> 
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -284,26 +284,6 @@ struct held_lock {
>   */
>  struct hist_lock {
>  	/*
> -	 * Id for each entry in the ring buffer. This is used to
> -	 * decide whether the ring buffer was overwritten or not.
> -	 *
> -	 * For example,
> -	 *
> -	 *           |<----------- hist_lock ring buffer size ------->|
> -	 *           pppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> -	 * wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiii.......................
> -	 *
> -	 *           where 'p' represents an acquisition in process
> -	 *           context, 'i' represents an acquisition in irq
> -	 *           context.
> -	 *
> -	 * In this example, the ring buffer was overwritten by
> -	 * acquisitions in irq context, that should be detected on
> -	 * rollback or commit.
> -	 */
> -	unsigned int hist_id;
> -
> -	/*
>  	 * Seperate stack_trace data. This will be used at commit step.
>  	 */
>  	struct stack_trace	trace;
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -855,9 +855,7 @@ struct task_struct {
>  	unsigned int xhlock_idx;
>  	/* For restoring at history boundaries */
>  	unsigned int xhlock_idx_hist[XHLOCK_NR];
> -	unsigned int hist_id;
> -	/* For overwrite check at each context exit */
> -	unsigned int hist_id_save[XHLOCK_NR];
> +	unsigned int xhlock_idx_max;
>  #endif
>  
>  #ifdef CONFIG_UBSAN
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -4818,26 +4818,65 @@ void crossrelease_hist_start(enum contex
>  {
>  	struct task_struct *cur = current;
>  
> -	if (cur->xhlocks) {
> +	if (cur->xhlocks)
>  		cur->xhlock_idx_hist[c] = cur->xhlock_idx;
> -		cur->hist_id_save[c] = cur->hist_id;
> -	}
>  }
>  
>  void crossrelease_hist_end(enum context_t c)
>  {
>  	struct task_struct *cur = current;
> +	unsigned int idx;
>  
> -	if (cur->xhlocks) {
> -		unsigned int idx = cur->xhlock_idx_hist[c];
> -		struct hist_lock *h = &xhlock(idx);
> -
> -		cur->xhlock_idx = idx;
> -
> -		/* Check if the ring was overwritten. */
> -		if (h->hist_id != cur->hist_id_save[c])
> -			invalidate_xhlock(h);
> -	}
> +	if (!cur->xhlocks)
> +		return;
> +
> +	idx = cur->xhlock_idx_hist[c];
> +	cur->xhlock_idx = idx;
> +
> +	/*
> +	 * A bit of magic here.. this deals with rewinding the (cyclic) history
> +	 * array further than its size. IOW. looses the complete history.
> +	 *
> +	 * We detect this by tracking the previous oldest entry we've (over)
> +	 * written in @xhlock_idx_max, this means the next entry is the oldest
> +	 * entry still in the buffer, ie. its tail.
> +	 *
> +	 * So when we restore an @xhlock_idx that is at least MAX_XHLOCKS_NR
> +	 * older than @xhlock_idx_max we know we've just wiped the entire
> +	 * history.
> +	 */
> +	if ((cur->xhlock_idx_max - idx) < MAX_XHLOCKS_NR)
> +		return;
> +
> +	/*
> +	 * Now that we know the buffer is effectively empty, reset our state
> +	 * such that it appears empty (without in fact clearing the entire
> +	 * buffer).
> +	 *
> +	 * Pick @idx as the 'new' beginning, (re)set all save-points to not
> +	 * rewind past it and reset the max. Then invalidate this idx such that
> +	 * commit_xhlocks() will never rewind past it. Since xhlock_idx_inc()
> +	 * will return the _next_ entry, we'll not overwrite this invalid entry
> +	 * until the entire buffer is full again.
> +	 */
> +	for (c = 0; c < XHLOCK_NR; c++)
> +		cur->xhlock_idx_hist[c] = idx;
> +	cur->xhlock_idx_max = idx;
> +	invalidate_xhlock(&xhlock(idx));
> +}
> +
> +static inline unsigned int xhlock_idx_inc(void)
> +{
> +	struct task_struct *cur = current;
> +	unsigned int idx = ++cur->xhlock_idx;
> +
> +	/*
> +	 * As per the requirement in crossrelease_hist_end(), track the tail.
> +	 */
> +	if ((int)(cur->xhlock_idx_max - idx) < 0)
> +		cur->xhlock_idx_max = idx;
> +
> +	return idx;
>  }
>  
>  static int cross_lock(struct lockdep_map *lock)
> @@ -4902,7 +4941,7 @@ static inline int xhlock_valid(struct hi
>   */
>  static void add_xhlock(struct held_lock *hlock)
>  {
> -	unsigned int idx = ++current->xhlock_idx;
> +	unsigned int idx = xhlock_idx_inc();
>  	struct hist_lock *xhlock = &xhlock(idx);
>  
>  #ifdef CONFIG_DEBUG_LOCKDEP
> @@ -4915,7 +4954,6 @@ static void add_xhlock(struct held_lock
>  
>  	/* Initialize hist_lock's members */
>  	xhlock->hlock = *hlock;
> -	xhlock->hist_id = current->hist_id++;
>  
>  	xhlock->trace.nr_entries = 0;
>  	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> @@ -5071,7 +5109,6 @@ static int commit_xhlock(struct cross_lo
>  static void commit_xhlocks(struct cross_lock *xlock)
>  {
>  	unsigned int cur = current->xhlock_idx;
> -	unsigned int prev_hist_id = xhlock(cur).hist_id;
>  	unsigned int i;
>  
>  	if (!graph_lock())
> @@ -5091,17 +5128,6 @@ static void commit_xhlocks(struct cross_
>  				break;
>  
>  			/*
> -			 * Filter out the cases that the ring buffer was
> -			 * overwritten and the previous entry has a bigger
> -			 * hist_id than the following one, which is impossible
> -			 * otherwise.
> -			 */
> -			if (unlikely(before(xhlock->hist_id, prev_hist_id)))
> -				break;
> -
> -			prev_hist_id = xhlock->hist_id;
> -
> -			/*
>  			 * commit_xhlock() returns 0 with graph_lock already
>  			 * released if fail.
>  			 */
> @@ -5186,11 +5212,9 @@ void lockdep_init_task(struct task_struc
>  	int i;
>  
>  	task->xhlock_idx = UINT_MAX;
> -	task->hist_id = 0;
>  
>  	for (i = 0; i < XHLOCK_NR; i++) {
>  		task->xhlock_idx_hist[i] = UINT_MAX;
> -		task->hist_id_save[i] = 0;
>  	}
>  
>  	task->xhlocks = kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
