Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id DFE5B6B0039
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:29:24 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id 29so489336yhl.9
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:29:24 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id v62si2367979yha.102.2014.05.29.09.29.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:29:24 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 29 May 2014 10:29:23 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A671119D8051
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:29:13 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4TEQ0rf11796916
	for <linux-mm@kvack.org>; Thu, 29 May 2014 16:26:00 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4TGXILM008917
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:33:19 -0600
Date: Thu, 29 May 2014 09:29:19 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V5
Message-ID: <20140529162918.GK22231@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
 <20140528152107.GB6507@localhost.localdomain>
 <alpine.DEB.2.10.1405281110210.22514@gentwo.org>
 <20140529003609.GG6507@localhost.localdomain>
 <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
 <20140529142602.GA20258@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529142602.GA20258@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, May 29, 2014 at 04:26:05PM +0200, Frederic Weisbecker wrote:
> On Thu, May 29, 2014 at 09:07:44AM -0500, Christoph Lameter wrote:
> > On Thu, 29 May 2014, Frederic Weisbecker wrote:
> > 
> > > The cpumasks in cpu.c are special as they are the base of the cpumask_var_t
> > > definition. They are necessary to define nr_cpu_bits which is the base of
> > > cpumask_var_t allocations. As such they must stay lower level and defined
> > > on top of NR_CPUS.
> > >
> > > But most other cases don't need that huge static bitmap. I actually haven't
> > > seen any other struct cpumask than isn't based on cpumask_var_t.
> > 
> > Well yes and I am tying directly into that scheme there in cpu.c to
> > display the active vmstat threads in sysfs. so its the same.
> 
> I don't think so. Or is there something in vmstat that cpumask_var_t
> definition depends upon?
> 
> > 
> > > Please post it on a new thread so it gets noticed by others.
> > 
> > Ok. Will do when we got agreement on the cpumask issue.
> > 
> > I would like to have some way to display the activities on cpus in /sysfs
> > like I have done here with the active vmstat workers.
> > 
> > What I think we need is display cpumasks for
> > 
> > 1. Cpus where the tick is currently off
> > 2. Cpus that have dynticks enabled.
> > 3. Cpus that are idle
> 
> You should find all that in /proc/timer_list
> 
> Now for CPUs that have full dynticks enabled, we probably need something
> in sysfs. We could dump the nohz cpumask somewhere. For now you can only grep
> the dmesg
> 
> > 4. Cpus that are used for RCU.
> 
> So, you mean those that aren't in extended grace period (between rcu_user_enter()/exit
> or rcu_idle_enter/exit)?
> 
> Paul?

We are clearly going to have to be very careful to avoid cache thrashing,
so methods that update a CPU mask on each transition, as the saying goes,
"need not apply".

So we need a function like __rcu_is_watching(), but that takes the
CPU number as an argument.  Something like the following:

include/linux/rcutree.h:

	bool rcu_is_watching_cpu(int cpu);

kernel/rcu/tree.c:

	bool rcu_is_watching_cpu(int cpu)
	{
		return atomic_read(per_cpu(&rcu_dynticks.dynticks), cpu) & 0x1;
	}

include/linux/rcutiny.h:

	static inline bool rcu_is_watching_cpu(int cpu)
	{
		return true;
	}

This could then be invoked from the appropriate sysfs or /proc setup.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
