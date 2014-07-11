Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 826C5900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:17:46 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so1113813qcy.3
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:17:46 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id k7si3867781qat.26.2014.07.11.08.17.44
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 08:17:45 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:17:41 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <20140711135854.GD26045@localhost.localdomain>
Message-ID: <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <20140711132032.GB26045@localhost.localdomain> <alpine.DEB.2.11.1407110855030.25432@gentwo.org> <20140711135854.GD26045@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Fri, 11 Jul 2014, Frederic Weisbecker wrote:

> > Converted what? We still need to keep a cpumask around that tells us which
> > processor have vmstat running and which do not.
> >
>
> Converted to cpumask_var_t.
>
> I mean we spent dozens emails on that...


Oh there is this outstanding fix, right.


Subject: on demand vmstat: Do not open code alloc_cpumask_var

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-07-11 10:15:55.356856916 -0500
+++ linux/mm/vmstat.c	2014-07-11 10:15:55.352856994 -0500
@@ -1244,7 +1244,7 @@
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
-struct cpumask *cpu_stat_off;
+cpumask_var_t cpu_stat_off;

 static void vmstat_update(struct work_struct *w)
 {
@@ -1338,7 +1338,8 @@
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
