Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 57F0582F82
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 12:33:51 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so91520494ioi.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 09:33:51 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id r25si5533924ioi.8.2015.10.01.09.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Oct 2015 09:33:50 -0700 (PDT)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Oct 2015 10:33:49 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4F01519D8040
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 10:21:59 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t91GUcSP10551778
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 09:30:38 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t91GXkt7032430
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 10:33:46 -0600
Date: Thu, 1 Oct 2015 09:33:46 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v2 17/18] rcu: Convert RCU gp kthreads into kthread worker
 API
Message-ID: <20151001163346.GF4043@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-18-git-send-email-pmladek@suse.com>
 <20150928171437.GB5182@linux.vnet.ibm.com>
 <20151001154300.GD9603@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151001154300.GD9603@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 01, 2015 at 05:43:00PM +0200, Petr Mladek wrote:
> On Mon 2015-09-28 10:14:37, Paul E. McKenney wrote:
> > On Mon, Sep 21, 2015 at 03:03:58PM +0200, Petr Mladek wrote:
> > > Kthreads are currently implemented as an infinite loop. Each
> > > has its own variant of checks for terminating, freezing,
> > > awakening. In many cases it is unclear to say in which state
> > > it is and sometimes it is done a wrong way.
> > > 
> > > The plan is to convert kthreads into kthread_worker or workqueues
> > > API. It allows to split the functionality into separate operations.
> > > It helps to make a better structure. Also it defines a clean state
> > > where no locks are taken, IRQs blocked, the kthread might sleep
> > > or even be safely migrated.
> > > 
> > > The kthread worker API is useful when we want to have a dedicated
> > > single kthread for the work. It helps to make sure that it is
> > > available when needed. Also it allows a better control, e.g.
> > > define a scheduling priority.
> > > 
> > > This patch converts RCU gp threads into the kthread worker API.
> > > They modify the scheduling, have their own logic to bind the process.
> > > They provide functions that are critical for the system to work
> > > and thus deserve a dedicated kthread.
> > > 
> > > This patch tries to split start of the grace period and the quiescent
> > > state handling into separate works. The motivation is to avoid
> > > wait_events inside the work. Instead it queues the works when
> > > appropriate which is more typical for this API.
> > > 
> > > On one hand, it should reduce spurious wakeups where the condition
> > > in the wait_event failed and the kthread went to sleep again.
> > > 
> > > On the other hand, there is a small race window when the other
> > > work might get queued. We could detect and fix this situation
> > > at the beginning of the work but it is a bit ugly.
> > > 
> > > The patch renames the functions kthread_wake() to kthread_worker_poke()
> > > that sounds more appropriate.
> > > 
> > > Otherwise, the logic should stay the same. I did a lot of torturing
> > > and I did not see any problem with the current patch. But of course,
> > > it would deserve much more testing and reviewing before applying.
> > 
> > Suppose I later need to add helper kthreads to parallelize grace-period
> > initialization.  How would I implement that in a freeze-friendly way?
> 
> I have been convinced that there only few kthreads that really need
> freezing. See the discussion around my first attempt at
> https://lkml.org/lkml/2015/6/13/190
> 
> In fact, RCU is a good example of kthreads that should not get
> frozen because they are needed even later when the system
> is suspended.
> 
> If I understand it correctly, they will do the job until most devices
> and all non-boot CPUs are disabled. Then the task doing the suspend
> will get scheduled. It will write the image and stop the machine.
> RCU should not be needed by this very last step.
> 
> By other words. RCU should not be much concerned about freezing.
> 
> If you are concerned about adding more kthreads, it should be
> possible to just add more workers if we agree on using the
> kthreads worker API.

OK, I will bite.  If RCU should not be much concerned about freezing,
why can't it retain its current simpler implementation using the current
kthread APIs?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
