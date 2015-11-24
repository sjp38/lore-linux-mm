Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AE6A16B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:56:48 -0500 (EST)
Received: by pacej9 with SMTP id ej9so24687537pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:56:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id zz9si26922172pac.245.2015.11.24.06.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 06:56:47 -0800 (PST)
Date: Tue, 24 Nov 2015 15:56:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/22] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20151124145641.GV17308@twins.programming.kicks-ass.net>
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
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 11:06:50AM +0100, Petr Mladek wrote:
> On Mon 2015-11-23 17:27:03, Tejun Heo wrote:
> > Hello,
> > 
> > On Wed, Nov 18, 2015 at 02:25:12PM +0100, Petr Mladek wrote:
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

No, work->func(work) doing: kfree(work).

That is indeed something quite frequently done, and since you now have
references to work after calling func, things would go *boom* rather
quickly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
