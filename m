Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BD7FC6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 09:47:53 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so948328pac.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:47:53 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id tg4si14005838pab.100.2015.10.12.06.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 06:47:52 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NW4035W50ZQH610@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 12 Oct 2015 22:47:50 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat counter
Date: Mon, 12 Oct 2015 19:03:20 +0530
Message-id: <1444656800-29915-1-git-send-email-pintu.k@samsung.com>
In-reply-to: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, pintu.k@samsung.com, mhocko@suse.cz, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

This patch maintains the number of oom victims kill count in
/proc/vmstat.
Currently, we are dependent upon kernel logs when the kernel OOM occurs.
But kernel OOM can went passed unnoticed by the developer as it can
silently kill some background applications/services.
In some small embedded system, it might be possible that OOM is captured
in the logs but it was over-written due to ring-buffer.
Thus this interface can quickly help the user in analyzing, whether there
were any OOM kill happened in the past, or whether the system have ever
entered the oom kill stage till date.

Thus, it can be beneficial under following cases:
1. User can monitor kernel oom kill scenario without looking into the
   kernel logs.
2. It can help in tuning the watermark level in the system.
3. It can help in tuning the low memory killer behavior in user space.
4. It can be helpful on a logless system or if klogd logging
   (/var/log/messages) are disabled.

A snapshot of the result of 3 days of over night test is shown below:
System: ARM Cortex A7, 1GB RAM, 8GB EMMC
Linux: 3.10.xx
Category: reference smart phone device
Loglevel: 7
Conditions: Fully loaded, BT/WiFi/GPS ON
Tests: auto launching of ~30+ apps using test scripts, in a loop for
3 days.
At the end of tests, check:
$ cat /proc/vmstat
nr_oom_victims 6

As we noticed, there were around 6 oom kill victims.

The OOM is bad for any system. So, this counter can help in quickly
tuning the OOM behavior of the system, without depending on the logs.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 include/linux/vm_event_item.h |    1 +
 mm/oom_kill.c                 |    2 ++
 mm/page_alloc.c               |    1 -
 mm/vmstat.c                   |    1 +
 4 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 2b1cef8..dd2600d 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -57,6 +57,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
+		NR_OOM_VICTIMS,
 		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
 		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
 		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 03b612b..802b8a1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -570,6 +570,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	count_vm_event(NR_OOM_VICTIMS);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -600,6 +601,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+			count_vm_event(NR_OOM_VICTIMS);
 		}
 	rcu_read_unlock();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9bcfd70..fafb09d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2761,7 +2761,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
-
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1fd0886..8503a2e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -808,6 +808,7 @@ const char * const vmstat_text[] = {
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
+	"nr_oom_victims",
 	"unevictable_pgs_culled",
 	"unevictable_pgs_scanned",
 	"unevictable_pgs_rescued",
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
