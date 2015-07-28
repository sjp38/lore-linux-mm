Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id C146E6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:18:26 -0400 (EDT)
Received: by ykay190 with SMTP id y190so101182551yka.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:18:26 -0700 (PDT)
Received: from mail-yk0-x242.google.com (mail-yk0-x242.google.com. [2607:f8b0:4002:c07::242])
        by mx.google.com with ESMTPS id x188si15971690ywd.77.2015.07.28.10.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:18:25 -0700 (PDT)
Received: by ykek23 with SMTP id k23so6277342yke.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:18:25 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:18:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 03/14] kthread: Add drain_kthread_worker()
Message-ID: <20150728171822.GA5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-4-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-4-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Jul 28, 2015 at 04:39:20PM +0200, Petr Mladek wrote:
> +/*
> + * Test whether @work is being queued from another work
> + * executing on the same kthread.
> + */
> +static bool is_chained_work(struct kthread_worker *worker)
> +{
> +	struct kthread_worker *current_worker;
> +
> +	current_worker = current_kthread_worker();
> +	/*
> +	 * Return %true if I'm a kthread worker executing a work item on
> +	 * the given @worker.
> +	 */
> +	return current_worker && current_worker == worker;
> +}

I'm not sure full-on chained work detection is necessary here.
kthread worker's usages tend to be significantly simpler and draining
is only gonna be used for destruction.

> +void drain_kthread_worker(struct kthread_worker *worker)
> +{
> +	int flush_cnt = 0;
> +
> +	spin_lock_irq(&worker->lock);
> +	worker->nr_drainers++;
> +
> +	while (!list_empty(&worker->work_list)) {
> +		/*
> +		 * Unlock, so we could move forward. Note that queuing
> +		 * is limited by @nr_drainers > 0.
> +		 */
> +		spin_unlock_irq(&worker->lock);
> +
> +		flush_kthread_worker(worker);
> +
> +		if (++flush_cnt == 10 ||
> +		    (flush_cnt % 100 == 0 && flush_cnt <= 1000))
> +			pr_warn("kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
> +				worker->task->comm, flush_cnt);
> +
> +		spin_lock_irq(&worker->lock);
> +	}

I'd just do something like WARN_ONCE(flush_cnt++ > 10, "kthread worker: ...").

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
