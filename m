Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1E96B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:06:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so131220709wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:06:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df7si25591136wjc.222.2015.11.24.02.06.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 02:06:51 -0800 (PST)
Date: Tue, 24 Nov 2015 11:06:50 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3 07/22] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20151124100650.GF10750@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-8-git-send-email-pmladek@suse.com>
 <20151123222703.GH19072@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123222703.GH19072@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-11-23 17:27:03, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 18, 2015 at 02:25:12PM +0100, Petr Mladek wrote:
> > @@ -610,6 +625,12 @@ repeat:
> >  	if (work) {
> >  		__set_current_state(TASK_RUNNING);
> >  		work->func(work);
> > +
> > +		spin_lock_irq(&worker->lock);
> > +		/* Allow to queue the work into another worker */
> > +		if (!kthread_work_pending(work))
> > +			work->worker = NULL;
> > +		spin_unlock_irq(&worker->lock);
> 
> Doesn't this mean that the work item can't be freed from its callback?
> That pattern tends to happen regularly.

I am not sure if I understand your question. Do you mean switching
work->func during the life time of the struct kthread_work? This
should not be affected by the above code.

The above code allows to queue an _unused_ kthread_work into any
kthread_worker. For example, it is needed for khugepaged,
see http://marc.info/?l=linux-kernel&m=144785344924871&w=2
The work is static but the worker can be started/stopped
(allocated/freed) repeatedly. It means that the work need
to be usable with many workers. But it is associated only
with one worker when being used.

If the work is in use (pending or being proceed), we must not
touch work->worker. Otherwise there might be a race. Because
all the operations with the work are synchronized using
work->worker->lock.

I hope that it makes sense.

Thanks a lot for feedback,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
