Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14303831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 02:59:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y43so3165087wrc.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 23:59:52 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::180])
        by mx.google.com with ESMTPS id i1si3880294ljd.166.2017.05.18.23.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 23:59:50 -0700 (PDT)
Subject: [PATCH] mm/vmstat: add oom_kill counter
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 19 May 2017 09:59:45 +0300
Message-ID: <149517718482.32770.939520643229572472.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Show count of global oom killer invocations in /proc/vmstat

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/vm_event_item.h |    1 +
 mm/oom_kill.c                 |    1 +
 mm/vmstat.c                   |    1 +
 3 files changed, 3 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d84ae90ccd5c..1707e0a7d943 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		PAGEOUTRUN, PGROTATED,
 		DROP_PAGECACHE, DROP_SLAB,
+		OOM_KILL,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
 		NUMA_HUGE_PTE_UPDATES,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..c734c42826cf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -883,6 +883,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
+	count_vm_event(OOM_KILL);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f73670200a..fe80b81a86e0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1018,6 +1018,7 @@ const char * const vmstat_text[] = {
 
 	"drop_pagecache",
 	"drop_slab",
+	"oom_kill",
 
 #ifdef CONFIG_NUMA_BALANCING
 	"numa_pte_updates",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
