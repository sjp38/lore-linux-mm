Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f179.google.com (mail-gg0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id 156CA6B00A3
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:23:01 -0500 (EST)
Received: by mail-gg0-f179.google.com with SMTP id e5so2800377ggh.38
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:23:00 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id g10si7735152yhn.209.2014.01.21.14.22.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 14:22:44 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 7/9] numa,sched: do statistics calculation using local variables only
Date: Tue, 21 Jan 2014 17:20:09 -0500
Message-Id: <1390342811-11769-8-git-send-email-riel@redhat.com>
In-Reply-To: <1390342811-11769-1-git-send-email-riel@redhat.com>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

From: Rik van Riel <riel@redhat.com>

The current code in task_numa_placement calculates the difference
between the old and the new value, but also temporarily stores half
of the old value in the per-process variables.

The NUMA balancing code looks at those per-process variables, and
having other tasks temporarily see halved statistics could lead to
unwanted numa migrations. This can be avoided by doing all the math
in local variables.

This change also simplifies the code a little.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index bd2100c..f713f3a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1518,12 +1518,9 @@ static void task_numa_placement(struct task_struct *p)
 			long diff, f_diff, f_weight;
 
 			i = task_faults_idx(nid, priv);
-			diff = -p->numa_faults_memory[i];
-			f_diff = -p->numa_faults_cpu[i];
 
 			/* Decay existing window, copy faults since last scan */
-			p->numa_faults_memory[i] >>= 1;
-			p->numa_faults_memory[i] += p->numa_faults_buffer_memory[i];
+			diff = p->numa_faults_buffer_memory[i] - p->numa_faults_memory[i] / 2;
 			fault_types[priv] += p->numa_faults_buffer_memory[i];
 			p->numa_faults_buffer_memory[i] = 0;
 
@@ -1537,13 +1534,12 @@ static void task_numa_placement(struct task_struct *p)
 			f_weight = (16384 * runtime *
 				   p->numa_faults_buffer_cpu[i]) /
 				   (total_faults * period + 1);
-			p->numa_faults_cpu[i] >>= 1;
-			p->numa_faults_cpu[i] += f_weight;
+			f_diff = f_weight - p->numa_faults_cpu[i] / 2;
 			p->numa_faults_buffer_cpu[i] = 0;
 
+			p->numa_faults_memory[i] += diff;
+			p->numa_faults_cpu[i] += f_diff;
 			faults += p->numa_faults_memory[i];
-			diff += p->numa_faults_memory[i];
-			f_diff += p->numa_faults_cpu[i];
 			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
