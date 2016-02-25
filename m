Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE9E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 07:35:57 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so31685826pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:35:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z10si12355499pfi.50.2016.02.25.04.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 04:35:56 -0800 (PST)
Date: Thu, 25 Feb 2016 13:35:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 04/20] kthread: Add drain_kthread_worker()
Message-ID: <20160225123551.GG6357@twins.programming.kicks-ass.net>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-5-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456153030-12400-5-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 03:56:54PM +0100, Petr Mladek wrote:
> +/**
> + * drain_kthread_worker - drain a kthread worker
> + * @worker: worker to be drained
> + *
> + * Wait until there is no work queued for the given kthread worker.
> + * @worker is flushed repeatedly until it becomes empty.  The number
> + * of flushing is determined by the depth of chaining and should
> + * be relatively short.  Whine if it takes too long.
> + *
> + * The caller is responsible for blocking all users of this kthread
> + * worker from queuing new works. Also it is responsible for blocking
> + * the already queued works from an infinite re-queuing!
> + */
> +void drain_kthread_worker(struct kthread_worker *worker)
> +{
> +	int flush_cnt = 0;
> +
> +	spin_lock_irq(&worker->lock);

Would it not make sense to set a flag here that inhibits (or warns)
queueing new work?

Otherwise this can, as you point out, last forever.

And I think its a logic fail if you both want to drain it and keeping
adding new work.

> +	while (!list_empty(&worker->work_list)) {
> +		spin_unlock_irq(&worker->lock);
> +
> +		flush_kthread_worker(worker);
> +		WARN_ONCE(flush_cnt++ > 10,
> +			  "kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
> +			  worker->task->comm, flush_cnt);
> +
> +		spin_lock_irq(&worker->lock);
> +	}
> +
> +	spin_unlock_irq(&worker->lock);
> +}
> +EXPORT_SYMBOL(drain_kthread_worker);
> -- 
> 1.8.5.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
