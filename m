Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 718FD6B0008
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 06:17:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c4-v6so1228404plz.20
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 03:17:40 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id n59-v6si12753006plb.437.2018.10.02.03.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 03:17:39 -0700 (PDT)
Date: Tue, 2 Oct 2018 03:17:34 -0700
From: tip-bot for Mel Gorman <tipbot@zytor.com>
Message-ID: <tip-37355bdc5a129899f6b245900a8eb944a092f7fd@git.kernel.org>
Reply-To: a.p.zijlstra@chello.nl, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, hpa@zytor.com, srikar@linux.vnet.ibm.com,
        torvalds@linux-foundation.org, riel@surriel.com,
        mgorman@techsingularity.net, jhladky@redhat.com, tglx@linutronix.de,
        mingo@kernel.org
In-Reply-To: <20181001100525.29789-3-mgorman@techsingularity.net>
References: <20181001100525.29789-3-mgorman@techsingularity.net>
Subject: [tip:sched/urgent] sched/numa: Migrate pages to local nodes quicker
 early in the lifetime of a task
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: torvalds@linux-foundation.org, srikar@linux.vnet.ibm.com, mgorman@techsingularity.net, riel@surriel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, a.p.zijlstra@chello.nl, mingo@kernel.org, tglx@linutronix.de, jhladky@redhat.com

Commit-ID:  37355bdc5a129899f6b245900a8eb944a092f7fd
Gitweb:     https://git.kernel.org/tip/37355bdc5a129899f6b245900a8eb944a092f7fd
Author:     Mel Gorman <mgorman@techsingularity.net>
AuthorDate: Mon, 1 Oct 2018 11:05:25 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Tue, 2 Oct 2018 11:31:33 +0200

sched/numa: Migrate pages to local nodes quicker early in the lifetime of a task

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
Reviewed-by: Rik van Riel <riel@surriel.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jirka Hladky <jhladky@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/20181001100525.29789-3-mgorman@techsingularity.net
Signed-off-by: Ingo Molnar <mingo@kernel.org>
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
