Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7E89D6B0092
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:20:31 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 19so6112489ykq.8
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:20:31 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id f67si7758510yhd.82.2014.01.21.14.20.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 14:20:27 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 8/9] numa,sched: rename variables in task_numa_fault
Date: Tue, 21 Jan 2014 17:20:10 -0500
Message-Id: <1390342811-11769-9-git-send-email-riel@redhat.com>
In-Reply-To: <1390342811-11769-1-git-send-email-riel@redhat.com>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

From: Rik van Riel <riel@redhat.com>

We track both the node of the memory after a NUMA fault, and the node
of the CPU on which the fault happened. Rename the local variables in
task_numa_fault to make things more explicit.

Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f713f3a..43ca8c4 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1747,11 +1747,11 @@ void task_numa_free(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_cpupid, int node, int pages, int flags)
+void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 {
 	struct task_struct *p = current;
 	bool migrated = flags & TNF_MIGRATED;
-	int this_node = task_node(current);
+	int cpu_node = task_node(current);
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1806,8 +1806,8 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	if (migrated)
 		p->numa_pages_migrated += pages;
 
-	p->numa_faults_buffer_memory[task_faults_idx(node, priv)] += pages;
-	p->numa_faults_buffer_cpu[task_faults_idx(this_node, priv)] += pages;
+	p->numa_faults_buffer_memory[task_faults_idx(mem_node, priv)] += pages;
+	p->numa_faults_buffer_cpu[task_faults_idx(cpu_node, priv)] += pages;
 	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
