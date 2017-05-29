Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED8A6B02C3
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:41:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g13so12918805wmd.9
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:41:52 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 190si23372823wmr.108.2017.05.29.04.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 04:41:50 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id k15so17110581wmh.3
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:41:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
Date: Mon, 29 May 2017 13:41:40 +0200
Message-Id: <20170529114141.536-3-mhocko@kernel.org>
In-Reply-To: <20170529114141.536-1-mhocko@kernel.org>
References: <20170529114141.536-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

20b2f52b73fe ("numa: add CONFIG_MOVABLE_NODE for movable-dedicated
node") has introduced CONFIG_MOVABLE_NODE without a good explanation on
why it is actually useful. It makes a lot of sense to make movable node
semantic opt in but we already have that because the feature has to be
explicitly enabled on the kernel command line. A config option on top
only makes the configuration space larger without a good reason. It also
adds an additional ifdefery that pollutes the code. Just drop the config
option and make it de-facto always enabled. This shouldn't introduce any
change to the semantic.

Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  7 +++++--
 drivers/base/node.c                             |  4 ----
 include/linux/memblock.h                        | 18 -----------------
 include/linux/nodemask.h                        |  4 ----
 mm/Kconfig                                      | 26 -------------------------
 mm/memblock.c                                   |  2 --
 mm/memory_hotplug.c                             |  4 ----
 mm/page_alloc.c                                 |  2 --
 8 files changed, 5 insertions(+), 62 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index facc20a3f962..64aed7386fe4 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2246,8 +2246,11 @@
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movable_node	[KNL] Boot-time switch to enable the effects
-			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
+	movable_node	[KNL] Boot-time switch to make hotplugable memory
+			NUMA nodes to be movable. This means that the memory
+			of such nodes will be usable only for movable
+			allocations which rules out almost all kernel
+			allocations. Use with caution!
 
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
diff --git a/drivers/base/node.c b/drivers/base/node.c
index dff5b53f7905..26f4b9c02f2c 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -639,9 +639,7 @@ static struct node_attr node_state_attr[] = {
 #ifdef CONFIG_HIGHMEM
 	[N_HIGH_MEMORY] = _NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
 #endif
-#ifdef CONFIG_MOVABLE_NODE
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
-#endif
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
 };
 
@@ -652,9 +650,7 @@ static struct attribute *node_state_attrs[] = {
 #ifdef CONFIG_HIGHMEM
 	&node_state_attr[N_HIGH_MEMORY].attr.attr,
 #endif
-#ifdef CONFIG_MOVABLE_NODE
 	&node_state_attr[N_MEMORY].attr.attr,
-#endif
 	&node_state_attr[N_CPU].attr.attr,
 	NULL
 };
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bdfc65af4152..9622fb8c101b 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -57,10 +57,8 @@ struct memblock {
 
 extern struct memblock memblock;
 extern int memblock_debug;
-#ifdef CONFIG_MOVABLE_NODE
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
-#endif /* CONFIG_MOVABLE_NODE */
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 #define __init_memblock __meminit
@@ -168,7 +166,6 @@ void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
 	     i != (u64)ULLONG_MAX;					\
 	     __next_reserved_mem_region(&i, p_start, p_end))
 
-#ifdef CONFIG_MOVABLE_NODE
 static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 {
 	return m->flags & MEMBLOCK_HOTPLUG;
@@ -178,16 +175,6 @@ static inline bool __init_memblock movable_node_is_enabled(void)
 {
 	return movable_node_enabled;
 }
-#else
-static inline bool memblock_is_hotpluggable(struct memblock_region *m)
-{
-	return false;
-}
-static inline bool movable_node_is_enabled(void)
-{
-	return false;
-}
-#endif
 
 static inline bool memblock_is_mirror(struct memblock_region *m)
 {
@@ -295,7 +282,6 @@ phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 
 phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
 
-#ifdef CONFIG_MOVABLE_NODE
 /*
  * Set the allocation direction to bottom-up or top-down.
  */
@@ -313,10 +299,6 @@ static inline bool memblock_bottom_up(void)
 {
 	return memblock.bottom_up;
 }
-#else
-static inline void __init memblock_set_bottom_up(bool enable) {}
-static inline bool memblock_bottom_up(void) { return false; }
-#endif
 
 /* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
 #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44d4046..cf0b91c3ec12 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -387,11 +387,7 @@ enum node_states {
 #else
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
-#ifdef CONFIG_MOVABLE_NODE
 	N_MEMORY,		/* The node has memory(regular, high, movable) */
-#else
-	N_MEMORY = N_HIGH_MEMORY,
-#endif
 	N_CPU,		/* The node has one or more cpus */
 	NR_NODE_STATES
 };
diff --git a/mm/Kconfig b/mm/Kconfig
index 0354a4be5a55..99645f42dc62 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -149,32 +149,6 @@ config NO_BOOTMEM
 config MEMORY_ISOLATION
 	bool
 
-config MOVABLE_NODE
-	bool "Enable to assign a node which has only movable memory"
-	depends on HAVE_MEMBLOCK
-	depends on NO_BOOTMEM
-	depends on X86_64 || OF_EARLY_FLATTREE || MEMORY_HOTPLUG
-	depends on NUMA
-	default n
-	help
-	  Allow a node to have only movable memory.  Pages used by the kernel,
-	  such as direct mapping pages cannot be migrated.  So the corresponding
-	  memory device cannot be hotplugged.  This option allows the following
-	  two things:
-	  - When the system is booting, node full of hotpluggable memory can
-	  be arranged to have only movable memory so that the whole node can
-	  be hot-removed. (need movable_node boot option specified).
-	  - After the system is up, the option allows users to online all the
-	  memory of a node as movable memory so that the whole node can be
-	  hot-removed.
-
-	  Users who don't use the memory hotplug feature are fine with this
-	  option on since they don't specify movable_node boot option or they
-	  don't online memory as movable.
-
-	  Say Y here if you want to hotplug a whole node.
-	  Say N here if you want kernel to use memory on all nodes evenly.
-
 #
 # Only be set on architectures that have completely implemented memory hotplug
 # feature. If you are not sure, don't touch it.
diff --git a/mm/memblock.c b/mm/memblock.c
index 696f06d17c4e..4895f5a6cf7e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -54,9 +54,7 @@ struct memblock memblock __initdata_memblock = {
 };
 
 int memblock_debug __initdata_memblock;
-#ifdef CONFIG_MOVABLE_NODE
 bool movable_node_enabled __initdata_memblock = false;
-#endif
 static bool system_has_some_mirror __initdata_memblock = false;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 10052c2fd400..2a14f8c18a22 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1561,11 +1561,7 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 
 static int __init cmdline_parse_movable_node(char *p)
 {
-#ifdef CONFIG_MOVABLE_NODE
 	movable_node_enabled = true;
-#else
-	pr_warn("movable_node option not supported\n");
-#endif
 	return 0;
 }
 early_param("movable_node", cmdline_parse_movable_node);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a26e19c3e1ff..02f5757bf253 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -112,9 +112,7 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
 #ifdef CONFIG_HIGHMEM
 	[N_HIGH_MEMORY] = { { [0] = 1UL } },
 #endif
-#ifdef CONFIG_MOVABLE_NODE
 	[N_MEMORY] = { { [0] = 1UL } },
-#endif
 	[N_CPU] = { { [0] = 1UL } },
 #endif	/* NUMA */
 };
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
