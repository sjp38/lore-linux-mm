Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F10B09000C5
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:45 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8H3dhhx013309
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:43 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq13.eem.corp.google.com with ESMTP id p8H3dax1016686
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:41 -0700
Received: by pzk2 with SMTP id 2so3558363pzk.6
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:41 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/8] kstaled: skip non-RAM regions.
Date: Fri, 16 Sep 2011 20:39:10 -0700
Message-Id: <1316230753-8693-6-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

Add a pfn_skip_hole function that shrinks the passed input range in order to
skip over pfn ranges that are known not bo be RAM backed. The x86
implementation achieves this using e820 tables; other architectures
use a generic no-op implementation.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/include/asm/page_types.h |    8 ++++++
 arch/x86/kernel/e820.c            |   45 +++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h            |    6 +++++
 mm/memcontrol.c                   |   41 +++++++++++++++++++--------------
 4 files changed, 83 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index bce688d..b0676c2 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -57,6 +57,14 @@ extern unsigned long init_memory_mapping(unsigned long start,
 extern void initmem_init(void);
 extern void free_initmem(void);
 
+extern void e820_skip_hole(unsigned long *start_pfn, unsigned long *end_pfn);
+
+#define ARCH_HAVE_PFN_SKIP_HOLE 1
+static inline void pfn_skip_hole(unsigned long *start, unsigned long *end)
+{
+	e820_skip_hole(start, end);
+}
+
 #endif	/* !__ASSEMBLY__ */
 
 #endif	/* _ASM_X86_PAGE_DEFS_H */
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 3e2ef84..0677873 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1123,3 +1123,48 @@ void __init memblock_find_dma_reserve(void)
 	set_dma_reserve(mem_size_pfn - free_size_pfn);
 #endif
 }
+
+/*
+ * The caller wants to skip pfns that are guaranteed to not be valid
+ * memory. Find a stretch of ram between [start_pfn, end_pfn) and
+ * return its pfn range back through start_pfn and end_pfn.
+ */
+
+void e820_skip_hole(unsigned long *start_pfn, unsigned long *end_pfn)
+{
+	unsigned long start = *start_pfn << PAGE_SHIFT;
+	unsigned long end = *end_pfn << PAGE_SHIFT;
+	int i;
+
+	if (start >= end)
+		goto fail;		/* short-circuit e820 checks */
+
+	for (i = 0; i < e820.nr_map; i++) {
+		struct e820entry *ei = &e820.map[i];
+		unsigned long last, addr;
+
+		addr = round_up(ei->addr, PAGE_SIZE);
+		last = round_down(ei->addr + ei->size, PAGE_SIZE);
+
+		if (addr >= end)
+			goto fail;	/* We're done, not found */
+		if (last <= start)
+			continue;	/* Not at start yet, move on */
+		if (ei->type != E820_RAM)
+			continue;	/* Not RAM, move on */
+
+		/*
+		 * We've found RAM. If start is in this e820 range, return
+		 * it, otherwise return the start of this e820 range.
+		 */
+
+		if (addr > start)
+			*start_pfn = addr >> PAGE_SHIFT;
+		if (last < end)
+			*end_pfn = last >> PAGE_SHIFT;
+		return;
+	}
+fail:
+	*start_pfn = *end_pfn;
+	return;				/* No luck, return failure */
+}
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9f7c3eb..6657106 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -930,6 +930,12 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define pfn_to_nid(pfn)		(0)
 #endif
 
+#ifndef ARCH_HAVE_PFN_SKIP_HOLE
+static inline void pfn_skip_hole(unsigned long *start, unsigned long *end)
+{
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM
 
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aebd45a..0fdc278 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5731,32 +5731,39 @@ static inline void kstaled_scan_page(struct page *page)
 static void kstaled_scan_node(pg_data_t *pgdat)
 {
 	unsigned long flags;
-	unsigned long start, end, pfn;
+	unsigned long pfn, end;
 
 	pgdat_resize_lock(pgdat, &flags);
 
-	start = pgdat->node_start_pfn;
-	end = start + pgdat->node_spanned_pages;
+	pfn = pgdat->node_start_pfn;
+	end = pfn + pgdat->node_spanned_pages;
 
-	for (pfn = start; pfn < end; pfn++) {
-		if (need_resched()) {
-			pgdat_resize_unlock(pgdat, &flags);
-			cond_resched();
-			pgdat_resize_lock(pgdat, &flags);
+	while (pfn < end) {
+		unsigned long contiguous = end;
+
+		/* restrict pfn..contiguous to be a RAM backed range */
+		pfn_skip_hole(&pfn, &contiguous);
+
+		for (; pfn < contiguous; pfn++) {
+			if (need_resched()) {
+				pgdat_resize_unlock(pgdat, &flags);
+				cond_resched();
+				pgdat_resize_lock(pgdat, &flags);
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-			/* abort if the node got resized */
-			if (pfn < pgdat->node_start_pfn ||
-			    end > (pgdat->node_start_pfn +
-				   pgdat->node_spanned_pages))
-				goto abort;
+				/* abort if the node got resized */
+				if (pfn < pgdat->node_start_pfn ||
+				    end > (pgdat->node_start_pfn +
+					   pgdat->node_spanned_pages))
+					goto abort;
 #endif
-		}
+			}
 
-		if (!pfn_valid(pfn))
-			continue;
+			if (!pfn_valid(pfn))
+				continue;
 
-		kstaled_scan_page(pfn_to_page(pfn));
+			kstaled_scan_page(pfn_to_page(pfn));
+		}
 	}
 
 abort:
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
