Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 050CA82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 22:41:38 -0400 (EDT)
Received: by ioll68 with SMTP id l68so244035155iol.3
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:41:37 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id z42si31725819ioi.36.2015.10.27.19.41.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Oct 2015 19:41:36 -0700 (PDT)
Message-Id: <20151028024131.719968999@linux.com>
Date: Tue, 27 Oct 2015 21:41:17 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [patch 3/3] vmstat: Create our own workqueue
References: <20151028024114.370693277@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=vmstat_add_workqueue
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

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
@@ -1359,6 +1359,8 @@ static const struct file_operations proc
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_SMP
+static struct workqueue_struct *vmstat_wq;
+
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 static cpumask_var_t cpu_stat_off;
@@ -1371,7 +1373,7 @@ static void vmstat_update(struct work_st
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work_on(smp_processor_id(),
+		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	} else {
@@ -1454,7 +1456,7 @@ static void vmstat_shepherd(struct work_
 		if (need_update(cpu) &&
 			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
 
-			schedule_delayed_work_on(cpu,
+			queue_delayed_work_on(cpu, vmstat_wq,
 				&per_cpu(vmstat_work, cpu), 0);
 
 	put_online_cpus();
@@ -1543,6 +1545,10 @@ static int __init setup_vmstat(void)
 
 	start_shepherd_timer();
 	cpu_notifier_register_done();
+	vmstat_wq = alloc_workqueue("vmstat",
+		WQ_FREEZABLE|
+		WQ_SYSFS|
+		WQ_MEM_RECLAIM, 0);
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
