Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9C10B6B0257
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:17:12 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id q63so88743809pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:17:12 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id fg8si35393863pad.227.2016.01.25.11.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 11:17:11 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id n128so7187534pfn.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:17:11 -0800 (PST)
Date: Mon, 25 Jan 2016 14:17:09 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 09/22] kthread: Allow to cancel kthread work
Message-ID: <20160125191709.GE3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-10-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-10-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Jan 25, 2016 at 04:44:58PM +0100, Petr Mladek wrote:
> @@ -574,6 +575,7 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
>  static inline bool kthread_work_pending(const struct kthread_work *work)
>  {
>  	return !list_empty(&work->node) ||
> +	       work->canceling ||
>  	       (work->timer && timer_active(work->timer));
>  }

So, the reason ->canceling test is necessary is to ensure that
self-requeueing work items can be canceled reliably.  It's not to
block "further queueing" in general.  It's probably worthwhile to
clear that up in the description and comment.

> +/*
> + * Get the worker lock if any worker is associated with the work.
> + * Depending on @check_canceling, it might need to give up the busy
> + * wait when work->canceling gets set.
> + */

While mentioning @check_canceling, the above doesn't actually explain
what it does.

> +static bool try_lock_kthread_work(struct kthread_work *work,
> +				  bool check_canceling)
>  {
>  	struct kthread_worker *worker;
>  	int ret = false;
> @@ -790,7 +798,24 @@ try_again:
>  	if (!worker)
>  		goto out;
>  
> -	spin_lock(&worker->lock);
> +	if (check_canceling) {
> +		if (!spin_trylock(&worker->lock)) {
> +			/*
> +			 * Busy wait with spin_is_locked() to avoid
> +			 * cache bouncing. Break when canceling
> +			 * is set to avoid a deadlock.
> +			 */
> +			do {
> +				if (READ_ONCE(work->canceling))
> +					goto out;

Why READ_ONCE?

> +				cpu_relax();
> +			} while (spin_is_locked(&worker->lock));
> +			goto try_again;
> +		}
> +	} else {
> +		spin_lock(&worker->lock);
> +	}
> +
>  	if (worker != work->worker) {
>  		spin_unlock(&worker->lock);
>  		goto try_again;
> @@ -820,10 +845,13 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
>  		(struct delayed_kthread_work *)__data;
>  	struct kthread_work *work = &dwork->work;
>  
> -	if (!try_lock_kthread_work(work))
> +	/* Give up when the work is being canceled. */
> +	if (!try_lock_kthread_work(work, true))

Again, this is the trickest part of the whole thing.  Please add a
comment explaining why this is necessary.

>  		return;
>  
> -	__queue_kthread_work(work->worker, work);
> +	if (!work->canceling)
> +		__queue_kthread_work(work->worker, work);
> +
...
> +static int
> +try_to_cancel_kthread_work(struct kthread_work *work,
> +				   spinlock_t *lock,
> +				   unsigned long *flags)

bool?

> +{
> +	int ret = 0;
> +
> +	/* Try to cancel the timer if pending. */
> +	if (work->timer && del_timer_sync(work->timer)) {
> +		ret = 1;
> +		goto out;
> +	}
> +
> +	/* Try to remove queued work before it is being executed. */
> +	if (!list_empty(&work->node)) {
> +		list_del_init(&work->node);
> +		ret = 1;
> +	}
> +
> +out:
> +	return ret;

Again, what's up with unnecessary goto exits?

> +static bool __cancel_kthread_work_sync(struct kthread_work *work)
> +{
> +	struct kthread_worker *worker;
> +	unsigned long flags;
> +	int ret;
> +
> +	local_irq_save(flags);
> +	if (!try_lock_kthread_work(work, false)) {
> +		local_irq_restore(flags);

Can't try_lock_kthread_work() take &flags?

> +		ret = 0;
> +		goto out;
> +	}
> +	worker = work->worker;
> +
> +	/*
> +	 * Block further queueing. It must be set before trying to cancel
> +	 * the kthread work. It avoids a possible deadlock between
> +	 * del_timer_sync() and the timer callback.
> +	 */

So, "blocking further queueing" and "a possible deadlock between
del_timer_sync() and the timer callback" don't have anything to do
with each other, do they?  Those are two separate things.  You need
the former to guarantee cancelation of self-requeueing work items and
the latter for deadlock avoidance, no?

> +	work->canceling++;
> +	ret = try_to_cancel_kthread_work(work, &worker->lock, &flags);
> +
> +	if (worker->current_work != work)
> +		goto out_fast;

If there are two racing cancellers, wouldn't this allow the losing one
to return while the work item is still running?

> +	spin_unlock_irqrestore(&worker->lock, flags);
> +	flush_kthread_work(work);
> +	/*
> +	 * Nobody is allowed to switch the worker or queue the work
> +	 * when .canceling is set.
> +	 */
> +	spin_lock_irqsave(&worker->lock, flags);
> +
> +out_fast:
> +	work->canceling--;
> +	spin_unlock_irqrestore(&worker->lock, flags);
> +out:
> +	return ret;
> +}

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
