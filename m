Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 464406B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 11:22:42 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so75735037wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:22:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si13749981wmd.47.2016.02.19.08.22.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 08:22:41 -0800 (PST)
Date: Fri, 19 Feb 2016 17:22:39 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4 09/22] kthread: Allow to cancel kthread work
Message-ID: <20160219162239.GT3305@pathway.suse.cz>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-10-git-send-email-pmladek@suse.com>
 <20160125191709.GE3628@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160125191709.GE3628@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2016-01-25 14:17:09, Tejun Heo wrote:
> On Mon, Jan 25, 2016 at 04:44:58PM +0100, Petr Mladek wrote:
> > +static bool __cancel_kthread_work_sync(struct kthread_work *work)
[...]
 > > +	work->canceling++;
> > +	ret = try_to_cancel_kthread_work(work, &worker->lock, &flags);
> > +
> > +	if (worker->current_work != work)
> > +		goto out_fast;
> 
> If there are two racing cancellers, wouldn't this allow the losing one
> to return while the work item is still running?

If the work is running, worker->current_work must point to it.
All cancelers will see it and queue its own kthread_flush_work.
It is a bit sub-optimal but it is trivial. I doubt that there
will be many parallel cancelers in practice.

> > +	spin_unlock_irqrestore(&worker->lock, flags);
> > +	flush_kthread_work(work);
> > +	/*
> > +	 * Nobody is allowed to switch the worker or queue the work
> > +	 * when .canceling is set.
> > +	 */
> > +	spin_lock_irqsave(&worker->lock, flags);
> > +
> > +out_fast:
> > +	work->canceling--;
> > +	spin_unlock_irqrestore(&worker->lock, flags);
> > +out:
> > +	return ret;

Best Regards,
Petr

PS: I have updated the patchset according to your other comments.
In addition, I got rid of many try_lock games. We do not allow
to queue the same work to different workers. Therefore it should
be enough to warn if the worker changes unexpectedly. It makes
the code even more simple. I still need to do some testing.
I will send it next week, hopefully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
