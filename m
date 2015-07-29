Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E202C9003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:05:02 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so212180864wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:05:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pa6si34125389wjb.84.2015.07.29.03.05.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 03:05:01 -0700 (PDT)
Date: Wed, 29 Jul 2015 12:04:57 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 03/14] kthread: Add drain_kthread_worker()
Message-ID: <20150729100457.GI2673@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-4-git-send-email-pmladek@suse.com>
 <20150728171822.GA5322@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728171822.GA5322@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-07-28 13:18:22, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 28, 2015 at 04:39:20PM +0200, Petr Mladek wrote:
> > +/*
> > + * Test whether @work is being queued from another work
> > + * executing on the same kthread.
> > + */
> > +static bool is_chained_work(struct kthread_worker *worker)
> > +{
> > +	struct kthread_worker *current_worker;
> > +
> > +	current_worker = current_kthread_worker();
> > +	/*
> > +	 * Return %true if I'm a kthread worker executing a work item on
> > +	 * the given @worker.
> > +	 */
> > +	return current_worker && current_worker == worker;
> > +}
> 
> I'm not sure full-on chained work detection is necessary here.
> kthread worker's usages tend to be significantly simpler and draining
> is only gonna be used for destruction.

I think that it might be useful to detect bugs when someone
depends on the worker when it is being destroyed. For example,
I tried to convert "khubd" kthread and there was not easy to
double check that this worked as expected.

I actually think about replacing

    WARN_ON_ONCE(!is_chained_work(worker)))

with

    WARN_ON(!is_chained_work(worker)))

in queue_kthread_work, so that we get the warning for all misused
workers.

> > +void drain_kthread_worker(struct kthread_worker *worker)
> > +{
> > +	int flush_cnt = 0;
> > +
> > +	spin_lock_irq(&worker->lock);
> > +	worker->nr_drainers++;
> > +
> > +	while (!list_empty(&worker->work_list)) {
> > +		/*
> > +		 * Unlock, so we could move forward. Note that queuing
> > +		 * is limited by @nr_drainers > 0.
> > +		 */
> > +		spin_unlock_irq(&worker->lock);
> > +
> > +		flush_kthread_worker(worker);
> > +
> > +		if (++flush_cnt == 10 ||
> > +		    (flush_cnt % 100 == 0 && flush_cnt <= 1000))
> > +			pr_warn("kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
> > +				worker->task->comm, flush_cnt);
> > +
> > +		spin_lock_irq(&worker->lock);
> > +	}
> 
> I'd just do something like WARN_ONCE(flush_cnt++ > 10, "kthread worker: ...").

This would print the warning only for one broken worker. But I do not
have strong opinion about it.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
