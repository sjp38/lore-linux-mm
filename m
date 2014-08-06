Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5C78E6B00A0
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 10:12:46 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so2696001qgd.37
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 07:12:46 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id hl16si1771727qcb.1.2014.08.06.07.12.45
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 07:12:45 -0700 (PDT)
Date: Wed, 6 Aug 2014 09:12:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <53E159F6.7080603@oracle.com>
Message-ID: <alpine.DEB.2.11.1408060908580.4346@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <53DFFD28.2030502@oracle.com> <alpine.DEB.2.11.1408050950390.16902@gentwo.org> <53E159F6.7080603@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Tue, 5 Aug 2014, Sasha Levin wrote:

> I can easily trigger it by cranking up the cpu hotplug code. Just try to
> frequently offline and online cpus, it should reproduce quickly.

Thats what I thought.

The test was done with this fix applied right?


Subject: vmstat ondemand: Fix online/offline races

Do not allow onlining/offlining while the shepherd task is checking
for vmstat threads.

On offlining a processor do the right thing cancelling the vmstat
worker thread if it exista and also exclude it from the shepherd
process checks.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-07-30 09:35:54.602662306 -0500
+++ linux/mm/vmstat.c	2014-07-30 09:43:07.109037043 -0500
@@ -1317,6 +1317,7 @@ static void vmstat_shepherd(struct work_
 {
 	int cpu;

+	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
 	for_each_cpu(cpu, cpu_stat_off)
 		if (need_update(cpu) &&
@@ -1325,6 +1326,7 @@ static void vmstat_shepherd(struct work_
 			schedule_delayed_work_on(cpu, &per_cpu(vmstat_work, cpu),
 				__round_jiffies_relative(sysctl_stat_interval, cpu));

+	put_online_cpus();

 	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
@@ -1380,8 +1382,8 @@ static int vmstat_cpuup_callback(struct
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		if (!cpumask_test_and_set_cpu(cpu, cpu_stat_off))
-			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+		cpumask_clear_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
