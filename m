Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 805C46B027A
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:14:45 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l4so5315079wre.10
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 01:14:45 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v22si9385250wrd.388.2017.11.21.01.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 01:14:43 -0800 (PST)
Date: Tue, 21 Nov 2017 10:14:41 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC v4] It is common for services to be stateless around their
 main event loop. If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then
 it signals to the kernel that epoll_wait() and friends may not complete,
 and the kernel may send SIGKILL if resources get tight.
In-Reply-To: <20171121051639.1228-1-slandden@gmail.com>
Message-ID: <alpine.DEB.2.20.1711210948530.1782@nanos>
References: <20171121044947.18479-1-slandden@gmail.com> <20171121051639.1228-1-slandden@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@kernel.org, willy@infradead.org

On Mon, 20 Nov 2017, Shawn Landden wrote:

Please use a short and comprehensible subject line and do not pack a full
sentence into it. The sentence wants to be in the change log body.

> +static DECLARE_WAIT_QUEUE_HEAD(oom_target);
> +
> +/* Clean up after a EPOLL_KILLME process quits.
> + * Called by kernel/exit.c.

It's hardly called by kernel/exit.c and aside of that multi line comments
are formatted like this:

/*
 * ....
 * ....
 */

> + */
> +void exit_oom_target(void)
> +{
> +	DECLARE_WAITQUEUE(wait, current);
> +
> +	remove_wait_queue(&oom_target, &wait);

This is completely pointless, really. It does:

     	INIT_LIST_HEAD(&wait.entry);

	spin_lock_irqsave(&oom_target->lock, flags);
	list_del(&wait->entry);
	spin_lock_irqrestore(&oom_target->lock, flags);

IOW. It's a NOOP. What are you trying to achieve?

> +}
> +
> +inline struct wait_queue_head *oom_target_get_wait()
> +{
> +	return &oom_target;

This wrapper is useless.

> +}
> +
>  #ifdef CONFIG_NUMA
>  /**
>   * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -994,6 +1013,18 @@ int unregister_oom_notifier(struct notifier_block *nb)
>  }
>  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>  
> +int oom_target_callback(wait_queue_entry_t *wait, unsigned mode, int sync, void *key)
> +{
> +	struct task_struct *ts = wait->private;
> +
> +	/* We use SIGKILL instead of the oom killer
> +	 * so as to cleanly interrupt ep_poll()

Huch? oom_killer uses SIGKILL as well, it just does it correctly.

> +	 */
> +	pr_debug("Killing pid %u from prctl(PR_SET_IDLE) death row.\n", ts->pid);
> +	send_sig(SIGKILL, ts, 1);
> +	return 0;
> +}
> +
>  /**
>   * out_of_memory - kill the "best" process when we run out of memory
>   * @oc: pointer to struct oom_control
> @@ -1007,6 +1038,7 @@ bool out_of_memory(struct oom_control *oc)
>  {
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
> +	wait_queue_head_t *w;
>  
>  	if (oom_killer_disabled)
>  		return false;
> @@ -1056,6 +1088,17 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  	}
>  
> +	/*
> +	 * Check death row for current memcg or global.
> +	 */
> +	if (!is_memcg_oom(oc)) {
> +		w = oom_target_get_wait();
> +		if (waitqueue_active(w)) {
> +			wake_up(w);
> +			return true;
> +		}
> +	}

Why on earth do you need that extra wait_queue magic?

You completely fail to explain in your empty changelog why the existing
oom hinting infrastructure is not sufficient.

If you can explain why, then there is no reason to have this side
channel. Extend/fix the current hinting mechanism and be done with it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
