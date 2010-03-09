Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2D04E6B0089
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:19 -0500 (EST)
Message-Id: <20100309194316.499805857@redhat.com>
Date: Tue, 09 Mar 2010 20:39:31 +0100
From: aarcange@redhat.com
Subject: [patch 30/35] madvise(MADV_HUGEPAGE)
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=madv_hugepage
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add madvise MADV_HUGEPAGE to mark regions that are important to be hugepage
backed. Return -EINVAL if the vma is not of an anonymous type, or the feature
isn't built into the kernel. Never silently return success.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/huge_mm.h |    6 ++++++
 mm/huge_memory.c        |   16 ++++++++++++++++
 mm/madvise.c            |    8 ++++++++
 3 files changed, 30 insertions(+)

--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -107,6 +107,7 @@ extern int split_huge_page(struct page *
 #endif
 
 extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
+extern int hugepage_madvise(unsigned long *vm_flags);
 static inline int PageTransHuge(struct page *page)
 {
 	VM_BUG_ON(PageTail(page));
@@ -131,6 +132,11 @@ static inline int split_huge_page(struct
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
 #define PageTransHuge(page) 0
+static inline int hugepage_madvise(unsigned long *vm_flags)
+{
+	BUG_ON(0);
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -856,3 +856,19 @@ out_unlock:
 out:
 	return ret;
 }
+
+int hugepage_madvise(unsigned long *vm_flags)
+{
+	/*
+	 * Be somewhat over-protective like KSM for now!
+	 */
+	if (*vm_flags & (VM_HUGEPAGE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP   | VM_IO      | VM_DONTEXPAND |
+			 VM_RESERVED | VM_HUGETLB | VM_INSERTPAGE |
+			 VM_MIXEDMAP | VM_SAO))
+		return -EINVAL;
+
+	*vm_flags |= VM_HUGEPAGE;
+
+	return 0;
+}
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -71,6 +71,11 @@ static long madvise_behavior(struct vm_a
 		if (error)
 			goto out;
 		break;
+	case MADV_HUGEPAGE:
+		error = hugepage_madvise(&new_flags);
+		if (error)
+			goto out;
+		break;
 	}
 
 	if (new_flags == vma->vm_flags) {
@@ -283,6 +288,9 @@ madvise_behavior_valid(int behavior)
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	case MADV_HUGEPAGE:
+#endif
 		return 1;
 
 	default:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
