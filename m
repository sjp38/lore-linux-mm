Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id ED8126B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:49:46 -0500 (EST)
Received: by ykdr82 with SMTP id r82so20640616ykd.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:49:46 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id x7si11177339ywa.302.2015.11.24.06.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 06:49:46 -0800 (PST)
Received: by ykba77 with SMTP id a77so20692932ykb.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:49:45 -0800 (PST)
Date: Tue, 24 Nov 2015 09:49:42 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 07/22] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20151124144942.GC17033@mtj.duckdns.org>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-8-git-send-email-pmladek@suse.com>
 <20151123222703.GH19072@mtj.duckdns.org>
 <20151124100650.GF10750@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124100650.GF10750@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Petr.

On Tue, Nov 24, 2015 at 11:06:50AM +0100, Petr Mladek wrote:
> > > @@ -610,6 +625,12 @@ repeat:
> > >  	if (work) {
> > >  		__set_current_state(TASK_RUNNING);
> > >  		work->func(work);
> > > +
> > > +		spin_lock_irq(&worker->lock);
> > > +		/* Allow to queue the work into another worker */
> > > +		if (!kthread_work_pending(work))
> > > +			work->worker = NULL;
> > > +		spin_unlock_irq(&worker->lock);
> > 
> > Doesn't this mean that the work item can't be freed from its callback?
> > That pattern tends to happen regularly.
> 
> I am not sure if I understand your question. Do you mean switching
> work->func during the life time of the struct kthread_work? This
> should not be affected by the above code.

So, something like the following.

void my_work_fn(work)
{
	struct my_struct *s = container_of(work, ...);

	do something with s;
	kfree(s);
}

and the queuer does

	struct my_struct *s = kmalloc(sizeof(*s));

	init s and s->work;
	queue(&s->work);

expecting s to be freed on completion.  IOW, you can't expect the work
item to remain accessible once the work function starts executing.

> The above code allows to queue an _unused_ kthread_work into any
> kthread_worker. For example, it is needed for khugepaged,
> see http://marc.info/?l=linux-kernel&m=144785344924871&w=2
> The work is static but the worker can be started/stopped
> (allocated/freed) repeatedly. It means that the work need
> to be usable with many workers. But it is associated only
> with one worker when being used.

It can just re-init work items when it restarts workers, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
