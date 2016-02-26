Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 37AE16B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:23:12 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id c200so76939591wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:23:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d62si4655038wmf.64.2016.02.26.07.23.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 07:23:11 -0800 (PST)
Date: Fri, 26 Feb 2016 16:23:09 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 04/20] kthread: Add drain_kthread_worker()
Message-ID: <20160226152309.GH3305@pathway.suse.cz>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-5-git-send-email-pmladek@suse.com>
 <20160225123551.GG6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225123551.GG6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 2016-02-25 13:35:51, Peter Zijlstra wrote:
> On Mon, Feb 22, 2016 at 03:56:54PM +0100, Petr Mladek wrote:
> > +/**
> > + * drain_kthread_worker - drain a kthread worker
> > + * @worker: worker to be drained
> > + *
> > + * Wait until there is no work queued for the given kthread worker.
> > + * @worker is flushed repeatedly until it becomes empty.  The number
> > + * of flushing is determined by the depth of chaining and should
> > + * be relatively short.  Whine if it takes too long.
> > + *
> > + * The caller is responsible for blocking all users of this kthread
> > + * worker from queuing new works. Also it is responsible for blocking
> > + * the already queued works from an infinite re-queuing!
> > + */
> > +void drain_kthread_worker(struct kthread_worker *worker)
> > +{
> > +	int flush_cnt = 0;
> > +
> > +	spin_lock_irq(&worker->lock);
> 
> Would it not make sense to set a flag here that inhibits (or warns)
> queueing new work?
> 
> Otherwise this can, as you point out, last forever.
> 
> And I think its a logic fail if you both want to drain it and keeping
> adding new work.

We must allow self-queuing because it might be needed to finish
the processing. We would need to detect it. Tejun suggested
to avoid this and make the code simple.

I do not have a strong opinion here. On one hand, such a check might
help with debugging. On the other hand, workqueues have happily lived
without it for years.

Thanks a lot for review,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
