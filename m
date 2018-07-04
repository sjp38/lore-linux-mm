Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 771D26B0284
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:23:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m197-v6so3703851oig.18
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:23:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j22-v6si1296897oiy.162.2018.07.04.08.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 08:23:35 -0700 (PDT)
From: Rodrigo Freire <rfreire@redhat.com>
Subject: [PATCH v2] mm, oom: Describe task memory unit, larger PID pad
Date: Wed,  4 Jul 2018 12:23:18 -0300
Message-Id: <c795eb5129149ed8a6345c273aba167ff1bbd388.1530715938.git.rfreire@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, aquini@redhat.com, rientjes@google.com

The default page memory unit of OOM task dump events might not be
intuitive and potentially misleading for the non-initiated when
debugging OOM events: These are pages and not kBs. Add a small
printk prior to the task dump informing that the memory units are
actually memory _pages_.

Also extends PID field to align on up to 7 characters.
References: https://lkml.org/lkml/2018/7/3/1201

Signed-off-by: Rodrigo Freire <rfreire@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
---
 mm/oom_kill.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e7..520a483 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -392,7 +392,8 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
+	pr_info("Tasks state (memory values in pages):\n");
+	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
 		if (oom_unkillable_task(p, memcg, nodemask))
@@ -408,7 +409,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
+		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
 			mm_pgtables_bytes(task->mm),
-- 
1.8.3.1
