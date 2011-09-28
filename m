Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE3529000CD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:44 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p8S0naS0004158
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:36 -0700
Received: from iaqq3 (iaqq3.prod.google.com [10.12.43.3])
	by hpaq5.eem.corp.google.com with ESMTP id p8S0mcmo024013
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:35 -0700
Received: by iaqq3 with SMTP id q3so8865973iaq.5
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:35 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/9] kstaled: skip non-RAM regions.
Date: Tue, 27 Sep 2011 17:49:03 -0700
Message-Id: <1317170947-17074-6-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

Add a pfn_skip_hole function that shrinks the passed input range in order to
skip over pfn ranges that are known not bo be RAM backed. The x86
implementation achieves this using e820 tables; other architectures
use a generic no-op implementation.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/include/asm/page_types.h |    8 ++++++
 arch/x86/kernel/e820.c            |   45 +++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h            |    6 +++++
 mm/memcontrol.c                   |   31 +++++++++++++++----------
 4 files changed, 78 insertions(+), 12 deletions(-)

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
index e55056f..b75d41f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5747,22 +5747,29 @@ static void kstaled_scan_node(pg_data_t *pgdat)
 	end = pfn + pgdat->node_spanned_pages;
 
 	while (pfn < end) {
-		if (need_resched()) {
-			pgdat_resize_unlock(pgdat, &flags);
-			cond_resched();
-			pgdat_resize_lock(pgdat, &flags);
+		unsigned long contiguous = end;
+
+		/* restrict pfn..contiguous to be a RAM backed range */
+		pfn_skip_hole(&pfn, &contiguous);
+
+		while (pfn < contiguous) {
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
 
-		pfn += pfn_valid(pfn) ?
-			kstaled_scan_page(pfn_to_page(pfn)) : 1;
+			pfn += pfn_valid(pfn) ?
+				kstaled_scan_page(pfn_to_page(pfn)) : 1;
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
