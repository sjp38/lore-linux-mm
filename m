Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 457AC6B0266
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 06:05:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w44-v6so9943113edb.16
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 03:05:29 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id q48-v6si1379674eda.413.2018.10.01.03.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 03:05:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 8F2931C289E
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:05:26 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early in the lifetime of a task
Date: Mon,  1 Oct 2018 11:05:25 +0100
Message-Id: <20181001100525.29789-3-mgorman@techsingularity.net>
In-Reply-To: <20181001100525.29789-1-mgorman@techsingularity.net>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Automatic NUMA Balancing uses a multi-stage pass to decide whether a page
should migrate to a local node. This filter avoids excessive ping-ponging
if a page is shared or used by threads that migrate cross-node frequently.

Threads inherit both page tables and the preferred node ID from the
parent. This means that threads can trigger hinting faults earlier than
a new task which delays scanning for a number of seconds. As it can be
load balanced very early in its lifetime there can be an unnecessary delay
before it starts migrating thread-local data. This patch migrates private
pages faster early in the lifetime of a thread using the sequence counter
as an identifier of new tasks.

With this patch applied, STREAM performance is the same as 4.17 even though
processes are not spread cross-node prematurely. Other workloads showed
a mix of minor gains and losses. This is somewhat expected most workloads
are not very sensitive to the starting conditions of a process.

                         4.19.0-rc5             4.19.0-rc5                 4.17.0
                         numab-v1r1       fastmigrate-v1r1                vanilla
MB/sec copy     43298.52 (   0.00%)    47335.46 (   9.32%)    47219.24 (   9.06%)
MB/sec scale    30115.06 (   0.00%)    32568.12 (   8.15%)    32527.56 (   8.01%)
MB/sec add      32825.12 (   0.00%)    36078.94 (   9.91%)    35928.02 (   9.45%)
MB/sec triad    32549.52 (   0.00%)    35935.94 (  10.40%)    35969.88 (  10.51%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 kernel/sched/fair.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 25c7c7e09cbd..7fc4a371bdd2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1392,6 +1392,17 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
 	int last_cpupid, this_cpupid;
 
 	this_cpupid = cpu_pid_to_cpupid(dst_cpu, current->pid);
+	last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
+
+	/*
+	 * Allow first faults or private faults to migrate immediately early in
+	 * the lifetime of a task. The magic number 4 is based on waiting for
+	 * two full passes of the "multi-stage node selection" test that is
+	 * executed below.
+	 */
+	if ((p->numa_preferred_nid == -1 || p->numa_scan_seq <= 4) &&
+	    (cpupid_pid_unset(last_cpupid) || cpupid_match_pid(p, last_cpupid)))
+		return true;
 
 	/*
 	 * Multi-stage node selection is used in conjunction with a periodic
@@ -1410,7 +1421,6 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
 	 * This quadric squishes small probabilities, making it less likely we
 	 * act on an unlikely task<->page relation.
 	 */
-	last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
 	if (!cpupid_pid_unset(last_cpupid) &&
 				cpupid_to_nid(last_cpupid) != dst_nid)
 		return false;
-- 
2.16.4
