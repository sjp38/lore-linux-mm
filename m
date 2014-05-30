Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 720216B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:00:15 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so2151533veb.2
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:00:15 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id to8si3104636vdb.2.2014.05.30.07.00.14
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:00:14 -0700 (PDT)
Date: Fri, 30 May 2014 09:00:11 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
In-Reply-To: <20140529235530.GA25555@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1405300859290.8240@gentwo.org>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org> <20140529235530.GA25555@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Fri, 30 May 2014, Frederic Weisbecker wrote:

> On Thu, May 29, 2014 at 02:56:15PM -0500, Christoph Lameter wrote:
> > -static void start_cpu_timer(int cpu)
> > +static void __init start_shepherd_timer(void)
> >  {
> > -	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
> > +	int cpu;
> > +
> > +	for_each_possible_cpu(cpu)
> > +		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
> > +			vmstat_update);
> > +
> > +	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
>
> Now you're open coding alloc_cpumask_var() ?

Subject: on demand vmstat: Do not open code alloc_cpumask_var

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-05-29 14:43:26.439163942 -0500
+++ linux/mm/vmstat.c	2014-05-30 08:58:42.909697898 -0500
@@ -1238,7 +1238,7 @@
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
-struct cpumask *cpu_stat_off;
+cpumask_var_t cpu_stat_off;

 static void vmstat_update(struct work_struct *w)
 {
@@ -1332,7 +1332,8 @@
 		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);

-	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
+	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
+		BUG();
 	cpumask_copy(cpu_stat_off, cpu_online_mask);

 	schedule_delayed_work(&shepherd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
