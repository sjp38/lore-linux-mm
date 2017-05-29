Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C73F6B02F3
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:41:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a77so12955965wma.12
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:41:53 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id i141si11757426wmf.141.2017.05.29.04.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 04:41:51 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d127so17077256wmf.1
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:41:51 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm, memory_hotplug: move movable_node to the hotplug proper
Date: Mon, 29 May 2017 13:41:41 +0200
Message-Id: <20170529114141.536-4-mhocko@kernel.org>
In-Reply-To: <20170529114141.536-1-mhocko@kernel.org>
References: <20170529114141.536-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

movable_node_is_enabled is defined in memblock proper while it
is initialized from the memory hotplug proper. This is quite messy
and it makes a dependency between the two so move movable_node along
with the helper functions to memory_hotplug.

To make it more entertaining the kernel parameter is ignored unless
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y because we do not have the node
information for each memblock otherwise. So let's warn when the option
is disabled.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memblock.h       |  7 -------
 include/linux/memory_hotplug.h | 10 ++++++++++
 mm/memblock.c                  |  1 -
 mm/memory_hotplug.c            |  6 ++++++
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 9622fb8c101b..071692894254 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -57,8 +57,6 @@ struct memblock {
 
 extern struct memblock memblock;
 extern int memblock_debug;
-/* If movable_node boot option specified */
-extern bool movable_node_enabled;
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 #define __init_memblock __meminit
@@ -171,11 +169,6 @@ static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 	return m->flags & MEMBLOCK_HOTPLUG;
 }
 
-static inline bool __init_memblock movable_node_is_enabled(void)
-{
-	return movable_node_enabled;
-}
-
 static inline bool memblock_is_mirror(struct memblock_region *m)
 {
 	return m->flags & MEMBLOCK_MIRROR;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 9e0249d0f5e4..d6e5e63b31d5 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -115,6 +115,12 @@ extern void __online_page_free(struct page *page);
 extern int try_online_node(int nid);
 
 extern bool memhp_auto_online;
+/* If movable_node boot option specified */
+extern bool movable_node_enabled;
+static inline bool movable_node_is_enabled(void)
+{
+	return movable_node_enabled;
+}
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
@@ -266,6 +272,10 @@ static inline void put_online_mems(void) {}
 static inline void mem_hotplug_begin(void) {}
 static inline void mem_hotplug_done(void) {}
 
+static inline bool movable_node_is_enabled(void)
+{
+	return false;
+}
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/memblock.c b/mm/memblock.c
index 4895f5a6cf7e..8c52fb11510c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -54,7 +54,6 @@ struct memblock memblock __initdata_memblock = {
 };
 
 int memblock_debug __initdata_memblock;
-bool movable_node_enabled __initdata_memblock = false;
 static bool system_has_some_mirror __initdata_memblock = false;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2a14f8c18a22..1a148b35e8a3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -79,6 +79,8 @@ static struct {
 #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
 #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
 
+bool movable_node_enabled = false;
+
 #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
 #else
@@ -1561,7 +1563,11 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 
 static int __init cmdline_parse_movable_node(char *p)
 {
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	movable_node_enabled = true;
+#else
+	pr_warn("movable_node parameter depends on CONFIG_HAVE_MEMBLOCK_NODE_MAP to work properly\n");
+#endif
 	return 0;
 }
 early_param("movable_node", cmdline_parse_movable_node);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
