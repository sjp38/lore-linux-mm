Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 04B846B0034
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:26:27 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:26:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] mm: memcontrol: sanity check memcg OOM context unwind
Message-ID: <20130719042623.GH17812@cmpxchg.org>
References: <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
 <20130719042124.GC17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719042124.GC17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

Catch the cases where a memcg OOM context is set up in the failed
charge path but the fault handler is not actually returning
VM_FAULT_ERROR, which would be required to properly finalize the OOM.

Example output: the first trace shows the stack at the end of
handle_mm_fault() where an unexpected memcg OOM context is detected.
The subsequent trace is of whoever set up that OOM context.  In this
case it was the charging of readahead pages in a file fault, which
does not propagate VM_FAULT_OOM on failure and should disable OOM:

[   27.805359] WARNING: at /home/hannes/src/linux/linux/mm/memory.c:3523 handle_mm_fault+0x1fb/0x3f0()
[   27.805360] Hardware name: PowerEdge 1950
[   27.805361] Fixing unhandled memcg OOM context, set up from:
[   27.805362] Pid: 1599, comm: file Tainted: G        W    3.2.0-00005-g6d10010 #97
[   27.805363] Call Trace:
[   27.805365]  [<ffffffff8103dcea>] warn_slowpath_common+0x6a/0xa0
[   27.805367]  [<ffffffff8103dd91>] warn_slowpath_fmt+0x41/0x50
[   27.805369]  [<ffffffff810c8ffb>] handle_mm_fault+0x1fb/0x3f0
[   27.805371]  [<ffffffff81024fa0>] do_page_fault+0x140/0x4a0
[   27.805373]  [<ffffffff810cdbfb>] ? do_mmap_pgoff+0x34b/0x360
[   27.805376]  [<ffffffff813cbc6f>] page_fault+0x1f/0x30
[   27.805377] ---[ end trace 305ec584fba81649 ]---
[   27.805378]  [<ffffffff810f2418>] __mem_cgroup_try_charge+0x5c8/0x7e0
[   27.805380]  [<ffffffff810f38fc>] mem_cgroup_cache_charge+0xac/0x110
[   27.805381]  [<ffffffff810a528e>] add_to_page_cache_locked+0x3e/0x120
[   27.805383]  [<ffffffff810a5385>] add_to_page_cache_lru+0x15/0x40
[   27.805385]  [<ffffffff8112dfa3>] mpage_readpages+0xc3/0x150
[   27.805387]  [<ffffffff8115c6d8>] ext4_readpages+0x18/0x20
[   27.805388]  [<ffffffff810afbe1>] __do_page_cache_readahead+0x1c1/0x270
[   27.805390]  [<ffffffff810b023c>] ra_submit+0x1c/0x20
[   27.805392]  [<ffffffff810a5eb4>] filemap_fault+0x3f4/0x450
[   27.805394]  [<ffffffff810c4a2d>] __do_fault+0x6d/0x510
[   27.805395]  [<ffffffff810c741a>] handle_pte_fault+0x8a/0x920
[   27.805397]  [<ffffffff810c8f9c>] handle_mm_fault+0x19c/0x3f0
[   27.805398]  [<ffffffff81024fa0>] do_page_fault+0x140/0x4a0
[   27.805400]  [<ffffffff813cbc6f>] page_fault+0x1f/0x30
[   27.805401]  [<ffffffffffffffff>] 0xffffffffffffffff

Debug patch only.

Not-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/sched.h | 3 +++
 mm/memcontrol.c       | 7 +++++++
 mm/memory.c           | 9 +++++++++
 3 files changed, 19 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7e6c9e9..a77d198 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -91,6 +91,7 @@ struct sched_param {
 #include <linux/latencytop.h>
 #include <linux/cred.h>
 #include <linux/llist.h>
+#include <linux/stacktrace.h>
 
 #include <asm/processor.h>
 
@@ -1571,6 +1572,8 @@ struct task_struct {
 	struct memcg_oom_info {
 		unsigned int may_oom:1;
 		unsigned int in_memcg_oom:1;
+		struct stack_trace trace;
+		unsigned long trace_entries[16];
 		int wakeups;
 		struct mem_cgroup *wait_on_memcg;
 	} memcg_oom;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 99b0101..c47c77e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/stacktrace.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -1870,6 +1871,12 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
 
 	current->memcg_oom.in_memcg_oom = 1;
 
+	current->memcg_oom.trace.nr_entries = 0;
+	current->memcg_oom.trace.max_entries = 16;
+	current->memcg_oom.trace.entries = current->memcg_oom.trace_entries;
+	current->memcg_oom.trace.skip = 1;
+	save_stack_trace(&current->memcg_oom.trace);
+
 	/* At first, try to OOM lock hierarchy under memcg.*/
 	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(memcg);
diff --git a/mm/memory.c b/mm/memory.c
index 2be02b7..fc6d741 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/stacktrace.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3517,6 +3518,14 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (userfault)
 		WARN_ON(mem_cgroup_xchg_may_oom(current, 0) == 0);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	if (WARN(!(ret & VM_FAULT_OOM) && current->memcg_oom.in_memcg_oom,
+		 "Fixing unhandled memcg OOM context, set up from:\n")) {
+		print_stack_trace(&current->memcg_oom.trace, 0);
+		mem_cgroup_oom_synchronize();
+	}
+#endif
+
 	return ret;
 }
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
