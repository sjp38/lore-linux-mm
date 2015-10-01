Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 851E482F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:03:22 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so71199798pab.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:03:22 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id gm2si8204891pbb.125.2015.10.01.04.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:03:21 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVJ01NMZG1JV410@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 01 Oct 2015 20:03:19 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Thu, 01 Oct 2015 16:18:43 +0530
Message-id: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, pintu.k@samsung.com, mhocko@suse.cz, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

This patch maintains number of oom calls and number of oom kill
count in /proc/vmstat.
It is helpful during sluggish, aging or long duration tests.
Currently if the OOM happens, it can be only seen in kernel ring buffer.
But during long duration tests, all the dmesg and /var/log/messages* could
be overwritten.
So, just like other counters, the oom can also be maintained in
/proc/vmstat.
It can be also seen if all logs are disabled in kernel.

A snapshot of the result of over night test is shown below:
$ cat /proc/vmstat
oom_stall 610
oom_kill_count 1763

Here, oom_stall indicates that there are 610 times, kernel entered into OOM
cases. However, there were around 1763 oom killing happens.
The OOM is bad for the any system. So, this counter can help the developer
in tuning the memory requirement at least during initial bringup.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 include/linux/vm_event_item.h |    2 ++
 mm/oom_kill.c                 |    2 ++
 mm/page_alloc.c               |    2 +-
 mm/vmstat.c                   |    2 ++
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 2b1cef8..ade0851 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -57,6 +57,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
+		OOM_STALL,
+		OOM_KILL_COUNT,
 		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
 		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
 		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 03b612b..e79caed 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -570,6 +570,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	count_vm_event(OOM_KILL_COUNT);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -600,6 +601,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+			count_vm_event(OOM_KILL_COUNT);
 		}
 	rcu_read_unlock();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9bcfd70..1d82210 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2761,7 +2761,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
-
+	count_vm_event(OOM_STALL);
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1fd0886..f054265 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -808,6 +808,8 @@ const char * const vmstat_text[] = {
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
+	"oom_stall",
+	"oom_kill_count",
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
