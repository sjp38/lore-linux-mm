Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFDA6B0005
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 17:33:01 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v77so204644479ywg.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 14:33:01 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id l3si715639ywf.101.2016.06.23.14.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 14:33:00 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id l125so12546755ywb.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 14:33:00 -0700 (PDT)
Date: Thu, 23 Jun 2016 17:32:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160623213258.GO3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
 <20160622205445.GV30909@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622205445.GV30909@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jun 22, 2016 at 10:54:45PM +0200, Peter Zijlstra wrote:
> > + * The caller is responsible for blocking all users of this kthread
> > + * worker from queuing new works. Also it is responsible for blocking
> > + * the already queued works from an infinite re-queuing!
> 
> This, I really dislike that. And it makes the kthread_destroy_worker()
> from the next patch unnecessarily fragile.
> 
> Why not add a kthread_worker::blocked flag somewhere and refuse/WARN
> kthread_queue_work() when that is set.

It's the same logic from workqueue counterpart.  For workqueue,
nothing can make it less fragile as the workqueue struct itself is
freed on destruction.  If its users fail to stop issuing work items,
it'll lead to use-after-free.

IIRC, the draining of self-requeueing work items is a specific
requirement from some edge use case which used workqueue to implement
multi-step state machine.  Given how rare that is and the extra
complexity of identifying self-requeueing cases, let's forget about
draining and on destruction clear the worker pointer to block further
queueing and then flush whatever is in flight.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
