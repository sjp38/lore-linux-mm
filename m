Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 926206B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 10:26:10 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so478492wes.41
        for <linux-mm@kvack.org>; Thu, 29 May 2014 07:26:09 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id qb2si2469322wic.31.2014.05.29.07.26.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 07:26:09 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id u56so478018wes.23
        for <linux-mm@kvack.org>; Thu, 29 May 2014 07:26:08 -0700 (PDT)
Date: Thu, 29 May 2014 16:26:05 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: vmstat: On demand vmstat workers V5
Message-ID: <20140529142602.GA20258@localhost.localdomain>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
 <20140528152107.GB6507@localhost.localdomain>
 <alpine.DEB.2.10.1405281110210.22514@gentwo.org>
 <20140529003609.GG6507@localhost.localdomain>
 <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405290902180.11514@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Thu, May 29, 2014 at 09:07:44AM -0500, Christoph Lameter wrote:
> On Thu, 29 May 2014, Frederic Weisbecker wrote:
> 
> > The cpumasks in cpu.c are special as they are the base of the cpumask_var_t
> > definition. They are necessary to define nr_cpu_bits which is the base of
> > cpumask_var_t allocations. As such they must stay lower level and defined
> > on top of NR_CPUS.
> >
> > But most other cases don't need that huge static bitmap. I actually haven't
> > seen any other struct cpumask than isn't based on cpumask_var_t.
> 
> Well yes and I am tying directly into that scheme there in cpu.c to
> display the active vmstat threads in sysfs. so its the same.

I don't think so. Or is there something in vmstat that cpumask_var_t
definition depends upon?

> 
> > Please post it on a new thread so it gets noticed by others.
> 
> Ok. Will do when we got agreement on the cpumask issue.
> 
> I would like to have some way to display the activities on cpus in /sysfs
> like I have done here with the active vmstat workers.
> 
> What I think we need is display cpumasks for
> 
> 1. Cpus where the tick is currently off
> 2. Cpus that have dynticks enabled.
> 3. Cpus that are idle

You should find all that in /proc/timer_list

Now for CPUs that have full dynticks enabled, we probably need something
in sysfs. We could dump the nohz cpumask somewhere. For now you can only grep
the dmesg

> 4. Cpus that are used for RCU.

So, you mean those that aren't in extended grace period (between rcu_user_enter()/exit
or rcu_idle_enter/exit)?

Paul?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
