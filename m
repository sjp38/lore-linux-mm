Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 746B66B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:03:38 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so9906017ykd.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:03:38 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id z126si18763695ywe.152.2015.07.29.08.03.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:03:36 -0700 (PDT)
Received: by ykax123 with SMTP id x123so9953527yka.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:03:36 -0700 (PDT)
Date: Wed, 29 Jul 2015 11:03:33 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 03/14] kthread: Add drain_kthread_worker()
Message-ID: <20150729150333.GA3504@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-4-git-send-email-pmladek@suse.com>
 <20150728171822.GA5322@mtj.duckdns.org>
 <20150729100457.GI2673@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729100457.GI2673@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Petr.

On Wed, Jul 29, 2015 at 12:04:57PM +0200, Petr Mladek wrote:
> > I'm not sure full-on chained work detection is necessary here.
> > kthread worker's usages tend to be significantly simpler and draining
> > is only gonna be used for destruction.
> 
> I think that it might be useful to detect bugs when someone
> depends on the worker when it is being destroyed. For example,
> I tried to convert "khubd" kthread and there was not easy to
> double check that this worked as expected.
> 
> I actually think about replacing
> 
>     WARN_ON_ONCE(!is_chained_work(worker)))
> 
> with
> 
>     WARN_ON(!is_chained_work(worker)))
> 
> in queue_kthread_work, so that we get the warning for all misused
> workers.

This is a partial soluation no matter what you do especially for
destruction path as there's nothing which prevents draining and
destruction winning the race and then external queueing coming in
afterwards.  For use-after-free, slab debug should work pretty well.
I really don't think we need anything special here.

> > > +	while (!list_empty(&worker->work_list)) {
> > > +		/*
> > > +		 * Unlock, so we could move forward. Note that queuing
> > > +		 * is limited by @nr_drainers > 0.
> > > +		 */
> > > +		spin_unlock_irq(&worker->lock);
> > > +
> > > +		flush_kthread_worker(worker);
> > > +
> > > +		if (++flush_cnt == 10 ||
> > > +		    (flush_cnt % 100 == 0 && flush_cnt <= 1000))
> > > +			pr_warn("kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
> > > +				worker->task->comm, flush_cnt);
> > > +
> > > +		spin_lock_irq(&worker->lock);
> > > +	}
> > 
> > I'd just do something like WARN_ONCE(flush_cnt++ > 10, "kthread worker: ...").
> 
> This would print the warning only for one broken worker. But I do not
> have strong opinion about it.

I really think that'd be a good enough protection here.  It's
indicative an outright kernel bug and things tend to go awry and/or
badly reported after the initial failure anyway.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
