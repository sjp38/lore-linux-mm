Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7DAEB6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 07:45:04 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1291289bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 04:45:02 -0800 (PST)
Date: Mon, 10 Dec 2012 13:44:58 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] sched: Fix task_numa_fault() + KSM crash
Message-ID: <20121210124458.GA10252@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210050710.GC22164@linux.vnet.ibm.com>
 <20121210062857.GA6348@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121210062857.GA6348@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Srikar Dronamraju reported that the following assert triggers on 
his box:

   kernel BUG at ../kernel/sched/fair.c:2371!

   Call Trace:
     [<ffffffff8113cd0e>] __do_numa_page+0xde/0x160
     [<ffffffff8113de9e>] handle_pte_fault+0x32e/0xcd0
     [<ffffffffa01c22c0>] ? drop_large_spte+0x30/0x30 [kvm]
     [<ffffffffa01bf215>] ? kvm_set_spte_hva+0x25/0x30 [kvm]
     [<ffffffff8113eab9>] handle_mm_fault+0x279/0x760
     [<ffffffff8115c024>] break_ksm+0x74/0xa0
     [<ffffffff8115c222>] break_cow+0xa2/0xb0
     [<ffffffff8115e38c>] ksm_scan_thread+0xb5c/0xd50
     [<ffffffff810771c0>] ? wake_up_bit+0x40/0x40
     [<ffffffff8115d830>] ? run_store+0x340/0x340
     [<ffffffff8107692e>] kthread+0xce/0xe0

This means that task_numa_fault() was called for a kernel thread
which has no fault tracking.

This scenario is actually possible if a kernel thread does
fault processing on behalf of a user-space task - ignore
the page fault in that case.

Also remove the (now never triggering) assert and robustify
a nearby assert.

Reported-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9d11a8a..61c7a10 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2351,6 +2351,13 @@ void task_numa_fault(unsigned long addr, int node, int last_cpupid, int pages, b
 	int priv;
 	int idx;
 
+	/*
+	 * Kernel threads might not have an mm but might still
+	 * do fault processing (such as KSM):
+	 */
+	if (!p->numa_faults)
+		return;
+
 	if (last_cpupid != cpu_pid_to_cpupid(-1, -1)) {
 		/* Did we access it last time around? */
 		if (last_pid == this_pid) {
@@ -2367,8 +2374,8 @@ void task_numa_fault(unsigned long addr, int node, int last_cpupid, int pages, b
 
 	idx = 2*node + priv;
 
-	WARN_ON_ONCE(last_cpu == -1 || node == -1);
-	BUG_ON(!p->numa_faults);
+	if (WARN_ON_ONCE(last_cpu == -1 || node == -1))
+		return;
 
 	p->numa_faults_curr[idx] += pages;
 	shared_fault_tick(p, node, last_cpu, pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
