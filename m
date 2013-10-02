Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 394346B0037
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 13:52:24 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1255203pdi.5
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 10:52:22 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 2 Oct 2013 11:52:19 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D3D6E1FF0021
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:52:08 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r92HqF0S294090
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 11:52:15 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r92HtKZd008556
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 11:55:20 -0600
Date: Wed, 2 Oct 2013 10:52:13 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131002175213.GR5790@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <7632387.20FXkuCITr@vostro.rjw.lan>
 <524B0233.8070203@linux.vnet.ibm.com>
 <20131001173615.GW3657@laptop.programming.kicks-ass.net>
 <20131001174508.GA17411@redhat.com>
 <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
 <20131001180750.GA18261@redhat.com>
 <20131002090859.GE12926@twins.programming.kicks-ass.net>
 <20131002121356.GA21581@redhat.com>
 <20131002133137.GG28601@twins.programming.kicks-ass.net>
 <20131002140020.GA25256@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131002140020.GA25256@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On Wed, Oct 02, 2013 at 04:00:20PM +0200, Oleg Nesterov wrote:
> On 10/02, Peter Zijlstra wrote:
> >
> > On Wed, Oct 02, 2013 at 02:13:56PM +0200, Oleg Nesterov wrote:
> > > In short: unless a gp elapses between _exit() and _enter(), the next
> > > _enter() does nothing and avoids synchronize_sched().
> >
> > That does however make the entire scheme entirely writer biased;
> 
> Well, this makes the scheme "a bit more" writer biased, but this is
> exactly what we want in this case.
> 
> We do not block the readers after xxx_exit() entirely, but we do want
> to keep them in SLOW state and avoid the costly SLOW -> FAST -> SLOW
> transitions.

Yes -- should help -a- -lot- for bulk write-side operations, such as
onlining all CPUs at boot time.  ;-)

							Thanx, Paul

> Lets even forget about disable_nonboot_cpus(), lets consider
> percpu_rwsem-like logic "in general".
> 
> Yes, it is heavily optimizied for readers. But if the writers come in
> a batch, or the same writer does down_write + up_write twice or more,
> I think state == FAST is pointless in between (if we can avoid it).
> This is the rare case (the writers should be rare), but if it happens
> it makes sense to optimize the writers too. And again, even
> 
> 	for (;;) {
> 		percpu_down_write();
> 		percpu_up_write();
> 	}
> 
> should not completely block the readers.
> 
> IOW. "turn sync_sched() into call_rcu_sched() in up_write()" is obviously
> a win. If the next down_write/xxx_enter "knows" that the readers are
> still in SLOW mode because gp was not completed yet, why should we
> add the artificial delay?
> 
> As for disable_nonboot_cpus(). You are going to move cpu_hotplug_begin()
> outside of the loop, this is the same thing.
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
