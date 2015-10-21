Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3B82C82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:16:08 -0400 (EDT)
Received: by qgem9 with SMTP id m9so33239344qge.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:16:08 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id y94si8935785qge.48.2015.10.21.10.16.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 10:16:07 -0700 (PDT)
Date: Wed, 21 Oct 2015 12:16:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151021145505.GE8805@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Wed, 21 Oct 2015, Michal Hocko wrote:

> I am not sure how to achieve that. Requiring non-sleeping worker would
> work out but do we have enough users to add such an API?
>
> I would rather see vmstat using dedicated kernel thread(s) for this this
> purpose. We have discussed that in the past but it hasn't led anywhere.

How about this one? I really would like to have the vm statistics work as
designed and apparently they no longer work right with the existing
workqueue mechanism.


From: Christoph Lameter <cl@linux.com>
Subject: vmstat: Create our own workqueue

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
@@ -1357,6 +1357,8 @@ static const struct file_operations proc
 #endif /* CONFIG_PROC_FS */

 #ifdef CONFIG_SMP
+static struct workqueue_struct *vmstat_wq;
+
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 static cpumask_var_t cpu_stat_off;
@@ -1369,7 +1371,7 @@ static void vmstat_update(struct work_st
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work_on(smp_processor_id(),
+		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	} else {
@@ -1438,7 +1440,7 @@ static void vmstat_shepherd(struct work_
 		if (need_update(cpu) &&
 			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))

-			schedule_delayed_work_on(cpu,
+			queue_delayed_work_on(cpu, vmstat_wq,
 				&per_cpu(vmstat_work, cpu), 0);

 	put_online_cpus();
@@ -1534,6 +1536,7 @@ static int __init setup_vmstat(void)
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
+	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 	return 0;
 }
 module_init(setup_vmstat)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
