Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 806FB6B0255
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:04:57 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e65so86597794pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:04:57 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id iv8si35393327pac.104.2016.01.25.11.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 11:04:56 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 65so7214655pff.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:04:56 -0800 (PST)
Date: Mon, 25 Jan 2016 14:04:54 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 08/22] kthread: Initial support for delayed kthread
 work
Message-ID: <20160125190454.GD3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-9-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-9-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Jan 25, 2016 at 04:44:57PM +0100, Petr Mladek wrote:
> +/*
> + * Returns true when there is a pending operation for this work.
> + * In particular, it checks if the work is:
> + *	- queued
> + *	- a timer is running to queue this delayed work
> + *
> + * This function must be called with locked work.
> + */
> +static inline bool kthread_work_pending(const struct kthread_work *work)
> +{
> +	return !list_empty(&work->node) ||
> +	       (work->timer && timer_active(work->timer));
> +}

Why not just put the work item on a separate list so that
lits_empty(&work->node) is always enough?  IOW, put delayed work items
on timers on worker->delayed or sth.

> +/*
> + * Queue @work right into the worker queue.
> + */
> +static void __queue_kthread_work(struct kthread_worker *worker,
> +			  struct kthread_work *work)
> +{
> +	insert_kthread_work(worker, work, &worker->work_list);
> +}

Does this really need to be an inline function?  This sort of one
liner helpers tend to be obfuscating more than anything else.

> @@ -756,6 +779,121 @@ bool queue_kthread_work(struct kthread_worker *worker,
>  }
>  EXPORT_SYMBOL_GPL(queue_kthread_work);
>  
> +static bool try_lock_kthread_work(struct kthread_work *work)
> +{
> +	struct kthread_worker *worker;
> +	int ret = false;
> +
> +try_again:
> +	worker = work->worker;
> +
> +	if (!worker)
> +		goto out;

		return false;

> +
> +	spin_lock(&worker->lock);
> +	if (worker != work->worker) {
> +		spin_unlock(&worker->lock);
> +		goto try_again;
> +	}

	return true;

> +	ret = true;
> +
> +out:
> +	return ret;
> +}

Stop building unnecessary structures.  Keep it simple.

> +static inline void unlock_kthread_work(struct kthread_work *work)
> +{
> +	spin_unlock(&work->worker->lock);
> +}

Ditto.  Just open code it.  It doesn't add anything.

> +/**
> + * delayed_kthread_work_timer_fn - callback that queues the associated delayed
> + *	kthread work when the timer expires.
> + * @__data: pointer to the data associated with the timer
> + *
> + * The format of the function is defined by struct timer_list.
> + * It should have been called from irqsafe timer with irq already off.
> + */
> +void delayed_kthread_work_timer_fn(unsigned long __data)
> +{
> +	struct delayed_kthread_work *dwork =
> +		(struct delayed_kthread_work *)__data;
> +	struct kthread_work *work = &dwork->work;
> +
> +	if (!try_lock_kthread_work(work))

Can you please explain why try_lock is necessary here?  That's the
most important and non-obvious thing going on here and there's no
explanation of that at all.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
