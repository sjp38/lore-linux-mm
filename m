Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8482A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:38:07 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so1004512pad.10
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:38:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bc4si1566498pbb.71.2014.07.11.00.38.05
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:38:06 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 24/30] mm, x86/platform/uv: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:41 +0800
Message-Id: <1405064267-11678-25-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, cpw <cpw@sgi.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/platform/uv/tlb_uv.c  |    2 +-
 arch/x86/platform/uv/uv_nmi.c  |    3 ++-
 arch/x86/platform/uv/uv_time.c |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/platform/uv/tlb_uv.c b/arch/x86/platform/uv/tlb_uv.c
index dfe605ac1bcd..4612b4396004 100644
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -2116,7 +2116,7 @@ static int __init uv_bau_init(void)
 
 	for_each_possible_cpu(cur_cpu) {
 		mask = &per_cpu(uv_flush_tlb_mask, cur_cpu);
-		zalloc_cpumask_var_node(mask, GFP_KERNEL, cpu_to_node(cur_cpu));
+		zalloc_cpumask_var_node(mask, GFP_KERNEL, cpu_to_mem(cur_cpu));
 	}
 
 	nuvhubs = uv_num_possible_blades();
diff --git a/arch/x86/platform/uv/uv_nmi.c b/arch/x86/platform/uv/uv_nmi.c
index c89c93320c12..d17758215a61 100644
--- a/arch/x86/platform/uv/uv_nmi.c
+++ b/arch/x86/platform/uv/uv_nmi.c
@@ -715,7 +715,8 @@ void uv_nmi_setup(void)
 		nid = cpu_to_node(cpu);
 		if (uv_hub_nmi_list[nid] == NULL) {
 			uv_hub_nmi_list[nid] = kzalloc_node(size,
-							    GFP_KERNEL, nid);
+							    GFP_KERNEL,
+							    cpu_to_mem(cpu));
 			BUG_ON(!uv_hub_nmi_list[nid]);
 			raw_spin_lock_init(&(uv_hub_nmi_list[nid]->nmi_lock));
 			atomic_set(&uv_hub_nmi_list[nid]->cpu_owner, -1);
diff --git a/arch/x86/platform/uv/uv_time.c b/arch/x86/platform/uv/uv_time.c
index 5c86786bbfd2..c369fb2eb7d3 100644
--- a/arch/x86/platform/uv/uv_time.c
+++ b/arch/x86/platform/uv/uv_time.c
@@ -164,7 +164,7 @@ static __init int uv_rtc_allocate_timers(void)
 		return -ENOMEM;
 
 	for_each_present_cpu(cpu) {
-		int nid = cpu_to_node(cpu);
+		int nid = cpu_to_mem(cpu);
 		int bid = uv_cpu_to_blade_id(cpu);
 		int bcpu = uv_cpu_hub_info(cpu)->blade_processor_id;
 		struct uv_rtc_timer_head *head = blade_info[bid];
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
