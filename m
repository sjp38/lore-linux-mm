Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 14F386B0099
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:32:48 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 27 of 32] madvise(MADV_HUGEPAGE)
Message-Id: <94aa71f2e1861fee02fe.1264969658@v2.random>
In-Reply-To: <patchbomb.1264969631@v2.random>
References: <patchbomb.1264969631@v2.random>
Date: Sun, 31 Jan 2010 21:27:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add madvise MADV_HUGEPAGE to mark regions that are important to be hugepage
backed. Return -EINVAL if the vma is not of an anonymous type, or the feature
isn't built into the kernel. Never silently return success.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -107,6 +107,7 @@ extern int split_huge_page(struct page *
 #endif
 
 extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
+extern int hugepage_madvise(unsigned long *vm_flags);
 static inline int PageTransHuge(struct page *page)
 {
 	VM_BUG_ON(PageTail(page));
@@ -133,6 +134,11 @@ static inline int split_huge_page(struct
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
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -462,9 +462,11 @@ int do_huge_pmd_wp_page(struct mm_struct
 		put_page(new_page);
 		new_page = NULL;
 	}
-	if (unlikely(!new_page))
-		return do_huge_pmd_wp_page_fallback(mm, vma, address,
-						    pmd, orig_pmd, page, haddr);
+	if (unlikely(!new_page)) {
+		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
+						   pmd, orig_pmd, page, haddr);
+		goto out;
+	}
 
 	copy_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
@@ -487,6 +489,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 	}
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
+out:
 	return ret;
 }
 
@@ -837,3 +840,19 @@ out_unlock:
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
diff --git a/mm/madvise.c b/mm/madvise.c
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
