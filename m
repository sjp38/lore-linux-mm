Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id A3FFD6B0069
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:48:49 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 1/6] THP: Use real address for NUMA policy
Date: Fri, 20 Jul 2012 15:50:17 +0300
Message-Id: <1342788622-10290-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Use the fault address, not the rounded down hpage address for NUMA
policy purposes. In some circumstances this can give more exact
NUMA policy.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b93..70737ec 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -681,11 +681,11 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 
 static inline struct page *alloc_hugepage_vma(int defrag,
 					      struct vm_area_struct *vma,
-					      unsigned long haddr, int nd,
+					      unsigned long address, int nd,
 					      gfp_t extra_gfp)
 {
 	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
-			       HPAGE_PMD_ORDER, vma, haddr, nd);
+			       HPAGE_PMD_ORDER, vma, address, nd);
 }
 
 #ifndef CONFIG_NUMA
@@ -710,7 +710,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					  vma, haddr, numa_node_id(), 0);
+					  vma, address, numa_node_id(), 0);
 		if (unlikely(!page)) {
 			count_vm_event(THP_FAULT_FALLBACK);
 			goto out;
@@ -944,7 +944,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					      vma, haddr, numa_node_id(), 0);
+					      vma, address, numa_node_id(), 0);
 	else
 		new_page = NULL;
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
