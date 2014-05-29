Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id B04276B0039
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:40:24 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so1774557qgd.10
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:40:24 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id e67si2391341yhm.158.2014.05.29.09.40.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:40:24 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 29 May 2014 10:40:23 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 22B00C40002
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:40:20 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4TGdOoF5046564
	for <linux-mm@kvack.org>; Thu, 29 May 2014 18:39:24 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4TGiH9o016865
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:44:18 -0600
Date: Thu, 29 May 2014 09:40:18 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V5
Message-ID: <20140529164018.GM22231@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
 <20140528152107.GB6507@localhost.localdomain>
 <alpine.DEB.2.10.1405281110210.22514@gentwo.org>
 <20140529003609.GG6507@localhost.localdomain>
 <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
 <20140529142602.GA20258@localhost.localdomain>
 <alpine.DEB.2.10.1405291121400.12545@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405291121400.12545@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, May 29, 2014 at 11:24:15AM -0500, Christoph Lameter wrote:
> On Thu, 29 May 2014, Frederic Weisbecker wrote:
> 
> > > Well yes and I am tying directly into that scheme there in cpu.c to
> > > display the active vmstat threads in sysfs. so its the same.
> >
> > I don't think so. Or is there something in vmstat that cpumask_var_t
> > definition depends upon?
> 
> This patch definitely ties the vmstat cpumask into the scheme in cpu.c
> 
> > > I would like to have some way to display the activities on cpus in /sysfs
> > > like I have done here with the active vmstat workers.
> > >
> > > What I think we need is display cpumasks for
> > >
> > > 1. Cpus where the tick is currently off
> > > 2. Cpus that have dynticks enabled.
> > > 3. Cpus that are idle
> >
> > You should find all that in /proc/timer_list
> 
> True. I could actually drop the vmstat cpumask support.
> 
> > Now for CPUs that have full dynticks enabled, we probably need something
> > in sysfs. We could dump the nohz cpumask somewhere. For now you can only grep
> > the dmesg
> 
> There is a nohz mode in /proc/timer_list right?
> 
> > > 4. Cpus that are used for RCU.
> >
> > So, you mean those that aren't in extended grace period (between rcu_user_enter()/exit
> > or rcu_idle_enter/exit)?
> 
> No I mean cpus that have their RCU processing directed to another
> processor.

Ah, that is easier!

In kernel/rcu/tree_plugin.c under #ifdef CONFIG_RCU_NOCB_CPU:

cpumask_var_t get_rcu_nocb_mask(void)
{
	return rcu_nocb_mask;
}


In include/linux/rcupdate.h:

#if defined(CONFIG_TINY_RCU) || !defined(CONFIG_RCU_NOCB_CPU)
static inline cpumask_var_t get_rcu_nocb_mask(void)
{
	return NULL;
}
#else
cpumask_var_t get_rcu_nocb_mask(void);
#endif


Then display the mask however you prefer.  Modifying the mask is a very
bad idea, and will void your warranty, etc., etc.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
