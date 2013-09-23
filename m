Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C7A6D6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:13:29 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so3410401pdj.17
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:13:29 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 23 Sep 2013 09:52:53 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id F28611FF0021
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:52:44 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8NFqmuC298576
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:52:49 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8NFsFfm022390
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:54:16 -0600
Date: Mon, 23 Sep 2013 08:50:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923155059.GO9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923105017.030e0aef@gandalf.local.home>
 <20130923145446.GX9326@twins.programming.kicks-ass.net>
 <20130923111303.04b99db8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923111303.04b99db8@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 23, 2013 at 11:13:03AM -0400, Steven Rostedt wrote:
> On Mon, 23 Sep 2013 16:54:46 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Mon, Sep 23, 2013 at 10:50:17AM -0400, Steven Rostedt wrote:

[ . . . ]

> ?? I'm not sure I understand this. The online_cpus_held++ was there for
> recursion. Can't get_online_cpus() nest? I was thinking it can. If so,
> once the "__cpuhp_writer" is set, we need to do __put_online_cpus() as
> many times as we did a __get_online_cpus(). I don't know where the
> O(nr_tasks) comes from. The ref here was just to account for doing the
> old "get_online_cpus" instead of a srcu_read_lock().
> 
> > 
> > > static inline void put_online_cpus(void)
> > > {
> > > 	if (unlikely(current->online_cpus_held)) {
> > > 		current->online_cpus_held--;
> > > 		__put_online_cpus();
> > > 		return;
> > > 	}
> > > 
> > > 	srcu_read_unlock(&cpuhp_srcu);
> > > }
> > 
> > Also, you might not have noticed but, srcu_read_{,un}lock() have an
> > extra idx thing to pass about. That doesn't fit with the hotplug api.
> 
> I'll have to look a that, as I'm not exactly sure about the idx thing.

Not a problem, just stuff the idx into some per-task thing.  Either
task_struct or taskinfo will work fine.

> > > 
> > > Then have the writer simply do:
> > > 
> > > 	__cpuhp_write = current;
> > > 	synchronize_srcu(&cpuhp_srcu);
> > > 
> > > 	<grab the mutex here>
> > 
> > How does that do reader preference?
> 
> Well, the point I was trying to do was to let readers go very fast
> (well, with a mb instead of a mutex), and then when the CPU hotplug
> happens, it goes back to the current method.
> 
> That is, once we set __cpuhp_write, and then run synchronize_srcu(),
> the system will be in a state that does what it does today (grabbing
> mutexes, and upping refcounts).
> 
> I thought the whole point was to speed up the get_online_cpus() when no
> hotplug is happening. This does that, and is rather simple. It only
> gets slow when hotplug is in effect.

Or to put it another way, if the underlying slow-path mutex is
reader-preference, then the whole thing will be reader-preference.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
