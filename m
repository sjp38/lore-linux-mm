Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3276D6B0256
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:22:56 -0400 (EDT)
Received: by oies66 with SMTP id s66so48274364oie.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:22:56 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id z9si8929510obk.9.2015.10.22.07.22.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 07:22:55 -0700 (PDT)
Date: Thu, 22 Oct 2015 09:22:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151022140944.GA30579@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510220918370.18860@east.gentwo.org>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org> <20151022140944.GA30579@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, 22 Oct 2015, Tejun Heo wrote:

> > Yuck. Can someone please get this major screwup out of the work queue
> > subsystem? Tejun?
>
> Hmmm?  Just use a dedicated workqueue with WQ_MEM_RECLAIM.  If
> concurrency management is a problem and there's something live-locking
> for that work item (really?), WQ_CPU_INTENSIVE escapes it.  If this is
> a common occurrence that it makes sense to give vmstat higher
> priority, set WQ_HIGHPRI.

I did. Check the thread. The result was that other tasks were still
blocking the thread. Ok I did not use HIGHPRI here is a newer version:


From: Christoph Lameter <cl@linux.com>
Subject: vmstat: Create our own workqueue V2

V1->V2:
   - Add a couple of workqueue flags that may fix things.

Seems that vmstat needs its own workqueue now since the general
workqueue mechanism has been *enhanced* which means that the
vmstat_updates cannot run reliably but are being blocked by
work requests doing memory allocation. Which causes vmstat
to be unable to keep the counters up to date.

Bad. Fix this by creating our own workqueue.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1382,6 +1382,8 @@ static const struct file_operations proc
 #endif /* CONFIG_PROC_FS */

 #ifdef CONFIG_SMP
+static struct workqueue_struct *vmstat_wq;
+
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 static cpumask_var_t cpu_stat_off;
@@ -1394,7 +1396,7 @@ static void vmstat_update(struct work_st
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work_on(smp_processor_id(),
+		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	} else {
@@ -1463,7 +1465,7 @@ static void vmstat_shepherd(struct work_
 		if (need_update(cpu) &&
 			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))

-			schedule_delayed_work_on(cpu,
+			queue_delayed_work_on(cpu, vmstat_wq,
 				&per_cpu(vmstat_work, cpu), 0);

 	put_online_cpus();
@@ -1552,6 +1554,12 @@ static int __init setup_vmstat(void)

 	start_shepherd_timer();
 	cpu_notifier_register_done();
+	vmstat_wq = alloc_workqueue("vmstat",
+		WQ_FREEZABLE|
+		WQ_SYSFS|
+		WQ_MEM_RECLAIM|
+		WQ_HIGHPRI|
+		WQ_CPU_INTENSIVE, 0);
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
