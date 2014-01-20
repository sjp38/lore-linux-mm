Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id CD9E06B003A
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:21:29 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so6317753qcq.32
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:21:29 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id p70si1307417qga.95.2014.01.20.11.21.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 11:21:27 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 6/6] numa,sched: do statistics calculation using local variables only
Date: Mon, 20 Jan 2014 14:21:07 -0500
Message-Id: <1390245667-24193-7-git-send-email-riel@redhat.com>
In-Reply-To: <1390245667-24193-1-git-send-email-riel@redhat.com>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
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
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 203877d..ad30d14 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1456,12 +1456,9 @@ static void task_numa_placement(struct task_struct *p)
 			long diff, f_diff, f_weight;
 
 			i = task_faults_idx(nid, priv);
-			diff = -p->numa_faults[i];
-			f_diff = -p->numa_faults_from[i];
 
 			/* Decay existing window, copy faults since last scan */
-			p->numa_faults[i] >>= 1;
-			p->numa_faults[i] += p->numa_faults_buffer[i];
+			diff = p->numa_faults_buffer[i] - p->numa_faults[i] / 2;
 			fault_types[priv] += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
@@ -1475,13 +1472,12 @@ static void task_numa_placement(struct task_struct *p)
 			f_weight = (16384 * runtime *
 				   p->numa_faults_from_buffer[i]) /
 				   (total_faults * period + 1);
-			p->numa_faults_from[i] >>= 1;
-			p->numa_faults_from[i] += f_weight;
+			f_diff = f_weight - p->numa_faults_from[i] / 2;
 			p->numa_faults_from_buffer[i] = 0;
 
+			p->numa_faults[i] += diff;
+			p->numa_faults_from[i] += f_diff;
 			faults += p->numa_faults[i];
-			diff += p->numa_faults[i];
-			f_diff += p->numa_faults_from[i];
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
