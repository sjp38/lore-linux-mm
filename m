Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7F45482A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:37:44 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so992276pab.8
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:37:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id el7si774336pdb.295.2014.07.11.00.37.42
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:37:43 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 26/30] mm, x86, perf: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:43 +0800
Message-Id: <1405064267-11678-27-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/kernel/cpu/perf_event_amd.c          |    2 +-
 arch/x86/kernel/cpu/perf_event_amd_uncore.c   |    2 +-
 arch/x86/kernel/cpu/perf_event_intel.c        |    2 +-
 arch/x86/kernel/cpu/perf_event_intel_ds.c     |    6 +++---
 arch/x86/kernel/cpu/perf_event_intel_rapl.c   |    2 +-
 arch/x86/kernel/cpu/perf_event_intel_uncore.c |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/cpu/perf_event_amd.c b/arch/x86/kernel/cpu/perf_event_amd.c
index beeb7cc07044..ee5120ce3e98 100644
--- a/arch/x86/kernel/cpu/perf_event_amd.c
+++ b/arch/x86/kernel/cpu/perf_event_amd.c
@@ -347,7 +347,7 @@ static struct amd_nb *amd_alloc_nb(int cpu)
 	struct amd_nb *nb;
 	int i;
 
-	nb = kzalloc_node(sizeof(struct amd_nb), GFP_KERNEL, cpu_to_node(cpu));
+	nb = kzalloc_node(sizeof(struct amd_nb), GFP_KERNEL, cpu_to_mem(cpu));
 	if (!nb)
 		return NULL;
 
diff --git a/arch/x86/kernel/cpu/perf_event_amd_uncore.c b/arch/x86/kernel/cpu/perf_event_amd_uncore.c
index 3bbdf4cd38b9..1a7f4129bf4c 100644
--- a/arch/x86/kernel/cpu/perf_event_amd_uncore.c
+++ b/arch/x86/kernel/cpu/perf_event_amd_uncore.c
@@ -291,7 +291,7 @@ static struct pmu amd_l2_pmu = {
 static struct amd_uncore *amd_uncore_alloc(unsigned int cpu)
 {
 	return kzalloc_node(sizeof(struct amd_uncore), GFP_KERNEL,
-			cpu_to_node(cpu));
+			cpu_to_mem(cpu));
 }
 
 static void amd_uncore_cpu_up_prepare(unsigned int cpu)
diff --git a/arch/x86/kernel/cpu/perf_event_intel.c b/arch/x86/kernel/cpu/perf_event_intel.c
index adb02aa62af5..4f48d1bb7608 100644
--- a/arch/x86/kernel/cpu/perf_event_intel.c
+++ b/arch/x86/kernel/cpu/perf_event_intel.c
@@ -1957,7 +1957,7 @@ struct intel_shared_regs *allocate_shared_regs(int cpu)
 	int i;
 
 	regs = kzalloc_node(sizeof(struct intel_shared_regs),
-			    GFP_KERNEL, cpu_to_node(cpu));
+			    GFP_KERNEL, cpu_to_mem(cpu));
 	if (regs) {
 		/*
 		 * initialize the locks to keep lockdep happy
diff --git a/arch/x86/kernel/cpu/perf_event_intel_ds.c b/arch/x86/kernel/cpu/perf_event_intel_ds.c
index 980970cb744d..bb0327411bf1 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_ds.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_ds.c
@@ -250,7 +250,7 @@ static DEFINE_PER_CPU(void *, insn_buffer);
 static int alloc_pebs_buffer(int cpu)
 {
 	struct debug_store *ds = per_cpu(cpu_hw_events, cpu).ds;
-	int node = cpu_to_node(cpu);
+	int node = cpu_to_mem(cpu);
 	int max, thresh = 1; /* always use a single PEBS record */
 	void *buffer, *ibuffer;
 
@@ -304,7 +304,7 @@ static void release_pebs_buffer(int cpu)
 static int alloc_bts_buffer(int cpu)
 {
 	struct debug_store *ds = per_cpu(cpu_hw_events, cpu).ds;
-	int node = cpu_to_node(cpu);
+	int node = cpu_to_mem(cpu);
 	int max, thresh;
 	void *buffer;
 
@@ -341,7 +341,7 @@ static void release_bts_buffer(int cpu)
 
 static int alloc_ds_buffer(int cpu)
 {
-	int node = cpu_to_node(cpu);
+	int node = cpu_to_mem(cpu);
 	struct debug_store *ds;
 
 	ds = kzalloc_node(sizeof(*ds), GFP_KERNEL, node);
diff --git a/arch/x86/kernel/cpu/perf_event_intel_rapl.c b/arch/x86/kernel/cpu/perf_event_intel_rapl.c
index 619f7699487a..9df1ec3b505d 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_rapl.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_rapl.c
@@ -547,7 +547,7 @@ static int rapl_cpu_prepare(int cpu)
 	if (rdmsrl_safe(MSR_RAPL_POWER_UNIT, &msr_rapl_power_unit_bits))
 		return -1;
 
-	pmu = kzalloc_node(sizeof(*pmu), GFP_KERNEL, cpu_to_node(cpu));
+	pmu = kzalloc_node(sizeof(*pmu), GFP_KERNEL, cpu_to_mem(cpu));
 	if (!pmu)
 		return -1;
 
diff --git a/arch/x86/kernel/cpu/perf_event_intel_uncore.c b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
index 65bbbea38b9c..4b77ba4b4e36 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_uncore.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_uncore.c
@@ -4011,7 +4011,7 @@ static int uncore_cpu_prepare(int cpu, int phys_id)
 			if (pmu->func_id < 0)
 				pmu->func_id = j;
 
-			box = uncore_alloc_box(type, cpu_to_node(cpu));
+			box = uncore_alloc_box(type, cpu_to_mem(cpu));
 			if (!box)
 				return -ENOMEM;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
