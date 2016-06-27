Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2A7C6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 10:33:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so121356274lfa.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:33:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si26814810wjm.20.2016.06.27.07.33.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 07:33:52 -0700 (PDT)
Date: Mon, 27 Jun 2016 16:33:50 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160627143350.GA3313@pathway.suse.cz>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
 <20160622205445.GV30909@twins.programming.kicks-ass.net>
 <20160623213258.GO3262@mtj.duckdns.org>
 <20160624070515.GU30154@twins.programming.kicks-ass.net>
 <20160624155447.GY3262@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624155447.GY3262@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On Fri 2016-06-24 11:54:47, Tejun Heo wrote:
> On Fri, Jun 24, 2016 at 09:05:15AM +0200, Peter Zijlstra wrote:
> > > Given how rare that is 
> > 
> > Could you then not remove/rework these few cases for workqueue as well
> > and make that 'better' too?
> 
> Usage of draining is rare for workqueue but that still means several
> legitimate users.  With draining there, it's logical to use it during
> shutdown.  I don't think it makes sense to change it on workqueue
> side.
> 
> > > and the extra
> > > complexity of identifying self-requeueing cases, let's forget about
> > > draining and on destruction clear the worker pointer to block further
> > > queueing and then flush whatever is in flight.
> > 
> > You're talking about regular workqueues here?
> 
> No, kthread worker.  It's unlikely that kthread worker is gonna need
> chained draining especially given that most of its usages are gonna be
> conversions from raw kthread usages.  We won't lose much if anything
> by just ignoring draining and making the code simpler.

OK, so you suggest to do the following:

  1. Add a flag into struct kthread_worker that will prevent
     from further queuing.

  2. kthread_create_worker()/kthread_destroy_worker() will
     not longer dynamically allocate struct kthread_worker.
     They will just start/stop the kthread.


The result will be:

  a. User will not need the strict synchronization between
     the queue and create/destroy operations.

  b. We could get rid of drain_kthread_worker() because
     flush_kthread_worker() will be enough.


IMHO, the 1st change does not make sense without the 2nd one.
Otherwise, users could do an out-of-memory access when testing
the freed kthread_worker flag.

Do I get this correctly please?

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
