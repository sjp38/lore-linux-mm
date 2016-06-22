Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62AA66B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:54:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so128993712pfa.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:54:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b8si1858149paz.190.2016.06.22.13.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 13:54:49 -0700 (PDT)
Date: Wed, 22 Jun 2016 22:54:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160622205445.GV30909@twins.programming.kicks-ass.net>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-7-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:25PM +0200, Petr Mladek wrote:
> +/**
> + * kthread_drain_worker - drain a kthread worker
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

This, I really dislike that. And it makes the kthread_destroy_worker()
from the next patch unnecessarily fragile.

Why not add a kthread_worker::blocked flag somewhere and refuse/WARN
kthread_queue_work() when that is set.

> + */
> +void kthread_drain_worker(struct kthread_worker *worker)
> +{
> +	int flush_cnt = 0;
> +
> +	spin_lock_irq(&worker->lock);
> +
> +	while (!list_empty(&worker->work_list)) {
> +		spin_unlock_irq(&worker->lock);
> +
> +		kthread_flush_worker(worker);
> +		WARN_ONCE(flush_cnt++ > 10,
> +			  "kthread worker %s: kthread_drain_worker() isn't complete after %u tries\n",
> +			  worker->task->comm, flush_cnt);
> +
> +		spin_lock_irq(&worker->lock);
> +	}
> +
> +	spin_unlock_irq(&worker->lock);
> +}
> +EXPORT_SYMBOL(kthread_drain_worker);
> -- 
> 1.8.5.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
