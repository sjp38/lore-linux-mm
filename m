Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 5F1D26B00DA
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:56:39 -0500 (EST)
Message-ID: <50B8F327.4030703@parallels.com>
Date: Fri, 30 Nov 2012 21:55:51 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm: Generate events when tasks change their memory
References: <50B8F2F4.6000508@parallels.com>
In-Reply-To: <50B8F2F4.6000508@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

When vma tracing is ON, the vma memory is remaped to read-only
state. Later in the pagefault handlers the event is sent via
tracing engine.

With the existing on/off events this makes it possible to monitor
how processes modify their memory contents.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/mm.h         |    3 +++
 include/trace/events/mmu.h |   18 ++++++++++++++++++
 mm/huge_memory.c           |    4 ++++
 mm/madvise.c               |   11 +++++++++++
 mm/memory.c                |    2 ++
 mm/mprotect.c              |    2 +-
 6 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c7fad8d..7e5fe10 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1082,6 +1082,9 @@ extern unsigned long do_mremap(unsigned long addr,
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
+void change_protection(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable);
 
 /*
  * doesn't attempt to fault and will return short.
diff --git a/include/trace/events/mmu.h b/include/trace/events/mmu.h
index 71b1ba6..d1bff37 100644
--- a/include/trace/events/mmu.h
+++ b/include/trace/events/mmu.h
@@ -24,6 +24,24 @@ TRACE_EVENT_CONDITION(mmu_trace_on,
 		TP_printk("start %#lx", __entry->start)
 );
 
+TRACE_EVENT_CONDITION(mmu_page_mod,
+		TP_PROTO(struct vm_area_struct *vma, unsigned long vaddr),
+
+		TP_ARGS(vma, vaddr),
+
+		TP_CONDITION(vma->vm_flags & VM_TRACE),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, vaddr)
+		),
+
+		TP_fast_assign(
+			__entry->vaddr = vaddr;
+		),
+
+		TP_printk("vaddr %#lx", __entry->vaddr)
+);
+
 TRACE_EVENT_CONDITION(mmu_trace_off,
 		TP_PROTO(struct vm_area_struct *vma),
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..7a93683 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -22,6 +22,8 @@
 #include <asm/pgalloc.h>
 #include "internal.h"
 
+#include <trace/events/mmu.h>
+
 /*
  * By default transparent hugepage support is enabled for all mappings
  * and khugepaged scans all mappings. Defrag is only invoked by
@@ -888,6 +890,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
+	trace_mmu_page_mod(vma, address);
+
 	VM_BUG_ON(!vma->anon_vma);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
diff --git a/mm/madvise.c b/mm/madvise.c
index 65633e9..05361c2 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -64,6 +64,17 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		new_flags |= VM_DONTCOPY;
 		break;
 	case MADV_DOTRACE:
+		/*
+		 * Protect pages to be read-only and force tasks to generate
+		 * #PFs on modification.
+		 *
+		 * It should be done before issuing trace-on event. Otherwise
+		 * we're leaving a short window after the 'on' event when tasks
+		 * can still modify pages.
+		 */
+		change_protection(vma, start, end,
+				vm_get_page_prot(vma->vm_flags & ~VM_READ),
+				vma_wants_writenotify(vma));
 		trace_mmu_trace_on(vma);
 		new_flags |= VM_TRACE;
 		break;
diff --git a/mm/memory.c b/mm/memory.c
index a6f5951..1dd30ae 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2533,6 +2533,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 
+	trace_mmu_page_mod(vma, address);
+
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
 		/*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..91c2266 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -119,7 +119,7 @@ static inline void change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 	} while (pud++, addr = next, addr != end);
 }
 
-static void change_protection(struct vm_area_struct *vma,
+void change_protection(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
