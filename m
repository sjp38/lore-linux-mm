Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B3D3B6B0036
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:23:34 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2479156pab.26
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:23:34 -0700 (PDT)
Date: Mon, 23 Sep 2013 18:01:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923160130.GC9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923105017.030e0aef@gandalf.local.home>
 <20130923145446.GX9326@twins.programming.kicks-ass.net>
 <20130923111303.04b99db8@gandalf.local.home>
 <20130923155059.GO9093@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923155059.GO9093@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 23, 2013 at 08:50:59AM -0700, Paul E. McKenney wrote:
> Not a problem, just stuff the idx into some per-task thing.  Either
> task_struct or taskinfo will work fine.

Still not seeing the point of using srcu though..

srcu_read_lock() vs synchronize_srcu() is the same but far more
expensive than preempt_disable() vs synchronize_sched().

> Or to put it another way, if the underlying slow-path mutex is
> reader-preference, then the whole thing will be reader-preference.

Right, so 1) we have no such mutex so we're going to have to open-code
that anyway, and 2) like I just explained in the other email, I want the
pending writer case to be _fast_ as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
