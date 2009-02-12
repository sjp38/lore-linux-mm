Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 777B66B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 02:23:21 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1C7NI4C027382
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Feb 2009 16:23:18 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 338FD45DE55
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:23:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACF6C45DE53
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:23:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B5401DB803C
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:23:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6D91DB8041
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:23:16 +0900 (JST)
Date: Thu, 12 Feb 2009 16:22:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] clean up for early_pfn_to_nid
Message-Id: <20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, davem@davemlloft.net, heiko.carstens@de.ibm.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Declaration of early_pfn_to_nid() is scattered over per-arch include files,
and it seems it's complicated to know when the declaration is used.
I think it makes fix-for-memmap-init not easy.

This patch moves all declaration to include/linux/mm.h

After this,
  if !CONFIG_NODES_POPULATES_NODE_MAP && !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
     -> Use static definition in include/linux/mm.h
  else if !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
     -> Use generic definition in mm/page_alloc.c
  else
     -> per-arch back end function will be called.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/include/asm/mmzone.h   |    4 ----
 arch/ia64/mm/numa.c              |    2 +-
 arch/x86/include/asm/mmzone_32.h |    2 --
 arch/x86/include/asm/mmzone_64.h |    2 --
 arch/x86/mm/numa_64.c            |    2 +-
 include/linux/mm.h               |   19 ++++++++++++++++---
 mm/page_alloc.c                  |    8 +++++++-
 7 files changed, 25 insertions(+), 14 deletions(-)

Index: mmotm-2.6.29-Feb11/include/linux/mm.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/include/linux/mm.h
+++ mmotm-2.6.29-Feb11/include/linux/mm.h
@@ -1047,10 +1047,23 @@ extern void free_bootmem_with_active_reg
 typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
 extern void work_with_active_regions(int nid, work_fn_t work_fn, void *data);
 extern void sparse_memory_present_with_active_regions(int nid);
-#ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
-extern int early_pfn_to_nid(unsigned long pfn);
-#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
+
+#if !defined(CONFIG_ARCH_POPULATES_NODE_MAP) && \
+    !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
+static inline int __early_pfn_to_nid(unsigned long pfn)
+{
+	return 0;
+}
+#else
+/* please see mm/page_alloc.c */
+extern int __meminit early_pfn_to_nid(unsigned long pfn);
+#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
+/* there is a per-arch backend function. */
+extern int __meminit __early_pfn_to_nid(unsigned long pfn);
+#endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
+#endif
+
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
Index: mmotm-2.6.29-Feb11/arch/x86/include/asm/mmzone_32.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/x86/include/asm/mmzone_32.h
+++ mmotm-2.6.29-Feb11/arch/x86/include/asm/mmzone_32.h
@@ -32,8 +32,6 @@ static inline void get_memcfg_numa(void)
 	get_memcfg_numa_flat();
 }
 
-extern int early_pfn_to_nid(unsigned long pfn);
-
 extern void resume_map_numa_kva(pgd_t *pgd);
 
 #else /* !CONFIG_NUMA */
Index: mmotm-2.6.29-Feb11/arch/x86/include/asm/mmzone_64.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/x86/include/asm/mmzone_64.h
+++ mmotm-2.6.29-Feb11/arch/x86/include/asm/mmzone_64.h
@@ -40,8 +40,6 @@ static inline __attribute__((pure)) int 
 #define node_end_pfn(nid)       (NODE_DATA(nid)->node_start_pfn +	\
 				 NODE_DATA(nid)->node_spanned_pages)
 
-extern int early_pfn_to_nid(unsigned long pfn);
-
 #ifdef CONFIG_NUMA_EMU
 #define FAKE_NODE_MIN_SIZE	(64 * 1024 * 1024)
 #define FAKE_NODE_MIN_HASH_MASK	(~(FAKE_NODE_MIN_SIZE - 1UL))
Index: mmotm-2.6.29-Feb11/arch/ia64/include/asm/mmzone.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/ia64/include/asm/mmzone.h
+++ mmotm-2.6.29-Feb11/arch/ia64/include/asm/mmzone.h
@@ -31,10 +31,6 @@ static inline int pfn_to_nid(unsigned lo
 #endif
 }
 
-#ifdef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
-extern int early_pfn_to_nid(unsigned long pfn);
-#endif
-
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
 # define MAX_PHYSNODE_ID	8
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 8)
Index: mmotm-2.6.29-Feb11/arch/ia64/mm/numa.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/ia64/mm/numa.c
+++ mmotm-2.6.29-Feb11/arch/ia64/mm/numa.c
@@ -58,7 +58,7 @@ paddr_to_nid(unsigned long paddr)
  * SPARSEMEM to allocate the SPARSEMEM sectionmap on the NUMA node where
  * the section resides.
  */
-int early_pfn_to_nid(unsigned long pfn)
+int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
 	int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
 
Index: mmotm-2.6.29-Feb11/arch/x86/mm/numa_64.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/x86/mm/numa_64.c
+++ mmotm-2.6.29-Feb11/arch/x86/mm/numa_64.c
@@ -166,7 +166,7 @@ int __init compute_hash_shift(struct boo
 	return shift;
 }
 
-int early_pfn_to_nid(unsigned long pfn)
+int __meminit  __early_pfn_to_nid(unsigned long pfn)
 {
 	return phys_to_nid(pfn << PAGE_SHIFT);
 }
Index: mmotm-2.6.29-Feb11/mm/page_alloc.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/mm/page_alloc.c
+++ mmotm-2.6.29-Feb11/mm/page_alloc.c
@@ -2974,7 +2974,7 @@ static int __meminit next_active_region_
  * was used and there are no special requirements, this is a convenient
  * alternative
  */
-int __meminit early_pfn_to_nid(unsigned long pfn)
+int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
 	int i;
 
@@ -2990,6 +2990,12 @@ int __meminit early_pfn_to_nid(unsigned 
 }
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 
+int __meminit early_pfn_to_nid(unsigned long pfn)
+{
+	return __early_pfn_to_nid(pfn);
+}
+
+
 /* Basic iterator support to walk early_node_map[] */
 #define for_each_active_range_index_in_nid(i, nid) \
 	for (i = first_active_region_index_in_nid(nid); i != -1; \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
