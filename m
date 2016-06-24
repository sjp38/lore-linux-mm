Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD496B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:05:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x68so206720200ioi.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 00:05:24 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id j135si1886412itj.27.2016.06.24.00.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 00:05:23 -0700 (PDT)
Date: Fri, 24 Jun 2016 09:05:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160624070515.GU30154@twins.programming.kicks-ass.net>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
 <20160622205445.GV30909@twins.programming.kicks-ass.net>
 <20160623213258.GO3262@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160623213258.GO3262@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 23, 2016 at 05:32:58PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Wed, Jun 22, 2016 at 10:54:45PM +0200, Peter Zijlstra wrote:
> > > + * The caller is responsible for blocking all users of this kthread
> > > + * worker from queuing new works. Also it is responsible for blocking
> > > + * the already queued works from an infinite re-queuing!
> > 
> > This, I really dislike that. And it makes the kthread_destroy_worker()
> > from the next patch unnecessarily fragile.
> > 
> > Why not add a kthread_worker::blocked flag somewhere and refuse/WARN
> > kthread_queue_work() when that is set.
> 
> It's the same logic from workqueue counterpart.

So ? Clearly it (the kthread workqueue) can be improved here.

> For workqueue, nothing can make it less fragile as the workqueue
> struct itself is freed on destruction.  If its users fail to stop
> issuing work items, it'll lead to use-after-free.

Right, but this kthread thingy does not, so why not add a failsafe?

> IIRC, the draining of self-requeueing work items is a specific
> requirement from some edge use case which used workqueue to implement
> multi-step state machine. 

Right, that might be an issue,

> Given how rare that is 

Could you then not remove/rework these few cases for workqueue as well
and make that 'better' too?

> and the extra
> complexity of identifying self-requeueing cases, let's forget about
> draining and on destruction clear the worker pointer to block further
> queueing and then flush whatever is in flight.

You're talking about regular workqueues here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
