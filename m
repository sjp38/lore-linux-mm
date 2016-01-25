Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 672AE6B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:57:50 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id uo6so86613402pac.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:57:50 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 28si35285886pfo.212.2016.01.25.10.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:57:49 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id e65so7271607pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:57:49 -0800 (PST)
Date: Mon, 25 Jan 2016 13:57:47 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 07/22] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20160125185747.GC3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-8-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-8-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 25, 2016 at 04:44:56PM +0100, Petr Mladek wrote:
> +static void insert_kthread_work_sanity_check(struct kthread_worker *worker,
> +					       struct kthread_work *work)
> +{
> +	lockdep_assert_held(&worker->lock);
> +	WARN_ON_ONCE(!irqs_disabled());

Isn't worker->lock gonna be a irq-safe lock?  If so, why would this
need to be tested separately?

> +	WARN_ON_ONCE(!list_empty(&work->node));
> +	/* Do not use a work with more workers, see queue_kthread_work() */
> +	WARN_ON_ONCE(work->worker && work->worker != worker);
> +}

Is this sanity check function gonna be used from multiple places?

>  /* insert @work before @pos in @worker */
>  static void insert_kthread_work(struct kthread_worker *worker,
> -			       struct kthread_work *work,
> -			       struct list_head *pos)
> +				struct kthread_work *work,
> +				struct list_head *pos)
>  {
> -	lockdep_assert_held(&worker->lock);
> +	insert_kthread_work_sanity_check(worker, work);
>  
>  	list_add_tail(&work->node, pos);
>  	work->worker = worker;
> @@ -717,6 +730,15 @@ static void insert_kthread_work(struct kthread_worker *worker,
>   * Queue @work to work processor @task for async execution.  @task
>   * must have been created with kthread_worker_create().  Returns %true
>   * if @work was successfully queued, %false if it was already pending.
> + *
> + * Never queue a work into a worker when it is being processed by another
> + * one. Otherwise, some operations, e.g. cancel or flush, will not work
> + * correctly or the work might run in parallel. This is not enforced
> + * because it would make the code too complex. There are only warnings
> + * printed when such a situation is detected.

I'm not sure the above paragraph adds much.  It isn't that accurate to
begin with as what's being disallowed is larger scope than the above.
Isn't the paragraph below enough?

> + * Reinitialize the work if it needs to be used by another worker.
> + * For example, when the worker was stopped and started again.
>   */
>  bool queue_kthread_work(struct kthread_worker *worker,
>  			struct kthread_work *work)
> -- 
> 1.8.5.6
> 

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
