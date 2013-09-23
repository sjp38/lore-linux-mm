Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id D3BFC6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 14:30:25 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id j1so924800oag.23
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:30:25 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 23 Sep 2013 11:11:56 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 25C701FF0062
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:11:13 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8NHAfMd196412
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:10:42 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8NHCJHB018254
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:12:20 -0600
Date: Mon, 23 Sep 2013 10:04:00 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923170400.GA1390@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923105017.030e0aef@gandalf.local.home>
 <20130923145446.GX9326@twins.programming.kicks-ass.net>
 <20130923111303.04b99db8@gandalf.local.home>
 <20130923155059.GO9093@linux.vnet.ibm.com>
 <20130923160130.GC9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923160130.GC9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 23, 2013 at 06:01:30PM +0200, Peter Zijlstra wrote:
> On Mon, Sep 23, 2013 at 08:50:59AM -0700, Paul E. McKenney wrote:
> > Not a problem, just stuff the idx into some per-task thing.  Either
> > task_struct or taskinfo will work fine.
> 
> Still not seeing the point of using srcu though..
> 
> srcu_read_lock() vs synchronize_srcu() is the same but far more
> expensive than preempt_disable() vs synchronize_sched().

Heh!  You want the old-style SRCU.  ;-)

> > Or to put it another way, if the underlying slow-path mutex is
> > reader-preference, then the whole thing will be reader-preference.
> 
> Right, so 1) we have no such mutex so we're going to have to open-code
> that anyway, and 2) like I just explained in the other email, I want the
> pending writer case to be _fast_ as well.

At some point I suspect that we will want some form of fairness, but in
the meantime, good point.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
