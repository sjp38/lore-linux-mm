Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6963F6B0085
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:20:07 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o1FMKDFj031021
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:20:13 GMT
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz37.hot.corp.google.com with ESMTP id o1FMK9Ql012111
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:12 -0800
Received: by pxi5 with SMTP id 5so3411124pxi.12
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:12 -0800 (PST)
Date: Mon, 15 Feb 2010 14:20:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If /proc/sys/vm/panic_on_oom is set to 2, the kernel will panic
regardless of whether the memory allocation is constrained by either a
mempolicy or cpuset.

Since mempolicy-constrained out of memory conditions now iterate through
the tasklist and select a task to kill, it is possible to panic the
machine if all tasks sharing the same mempolicy nodes (including those
with default policy, they may allocate anywhere) or cpuset mems have
/proc/pid/oom_adj values of OOM_DISABLE.  This is functionally equivalent
to the compulsory panic_on_oom setting of 2, so the mode is removed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |   20 ++++----------------
 mm/oom_kill.c               |    5 -----
 2 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -559,25 +559,13 @@ swap-intensive.
 
 panic_on_oom
 
-This enables or disables panic on out-of-memory feature.
+If this is set to zero, the oom killer will be invoked when the kernel is out of
+memory and direct reclaim cannot free any pages.  It will select a memory-
+hogging task that frees up a large amount of memory to kill.
 
-If this is set to 0, the kernel will kill some rogue process,
-called oom_killer.  Usually, oom_killer can kill rogue processes and
-system will survive.
-
-If this is set to 1, the kernel panics when out-of-memory happens.
-However, if a process limits using nodes by mempolicy/cpusets,
-and those nodes become memory exhaustion status, one process
-may be killed by oom-killer. No panic occurs in this case.
-Because other nodes' memory may be free. This means system total status
-may be not fatal yet.
-
-If this is set to 2, the kernel panics compulsorily even on the
-above-mentioned.
+If this is set to non-zero, the machine will panic when out of memory.
 
 The default value is 0.
-1 and 2 are for failover of clustering. Please select either
-according to your policy of failover.
 
 =============================================================
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -672,11 +672,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		/* Got some memory back in the last second. */
 		return;
 
-	if (sysctl_panic_on_oom == 2) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		panic("out of memory. Compulsory panic_on_oom is selected.\n");
-	}
-
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
