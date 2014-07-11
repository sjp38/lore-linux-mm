Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0386B0037
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:35:38 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so942060pde.20
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:35:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dn2si756915pdb.500.2014.07.11.00.35.37
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:35:37 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 05/30] mm, perf: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:22 +0800
Message-Id: <1405064267-11678-6-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>
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
 kernel/events/callchain.c   |    2 +-
 kernel/events/core.c        |    2 +-
 kernel/events/ring_buffer.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/events/callchain.c b/kernel/events/callchain.c
index 97b67df8fbfe..09f470a9262e 100644
--- a/kernel/events/callchain.c
+++ b/kernel/events/callchain.c
@@ -77,7 +77,7 @@ static int alloc_callchain_buffers(void)
 
 	for_each_possible_cpu(cpu) {
 		entries->cpu_entries[cpu] = kmalloc_node(size, GFP_KERNEL,
-							 cpu_to_node(cpu));
+							 cpu_to_mem(cpu));
 		if (!entries->cpu_entries[cpu])
 			goto fail;
 	}
diff --git a/kernel/events/core.c b/kernel/events/core.c
index a33d9a2bcbd7..bb1a5f326309 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7911,7 +7911,7 @@ static void perf_event_init_cpu(int cpu)
 	if (swhash->hlist_refcount > 0) {
 		struct swevent_hlist *hlist;
 
-		hlist = kzalloc_node(sizeof(*hlist), GFP_KERNEL, cpu_to_node(cpu));
+		hlist = kzalloc_node(sizeof(*hlist), GFP_KERNEL, cpu_to_mem(cpu));
 		WARN_ON(!hlist);
 		rcu_assign_pointer(swhash->swevent_hlist, hlist);
 	}
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index 146a5792b1d2..22128f58aa0b 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -265,7 +265,7 @@ static void *perf_mmap_alloc_page(int cpu)
 	struct page *page;
 	int node;
 
-	node = (cpu == -1) ? cpu : cpu_to_node(cpu);
+	node = (cpu == -1) ? NUMA_NO_NODE : cpu_to_mem(cpu);
 	page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
 	if (!page)
 		return NULL;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
