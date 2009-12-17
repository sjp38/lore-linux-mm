Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE9616B0047
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:18:16 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 26 of 28] madvise(MADV_HUGEPAGE)
Message-Id: <cd97d9c01e12da96ec5a.1261076429@v2.random>
In-Reply-To: <patchbomb.1261076403@v2.random>
References: <patchbomb.1261076403@v2.random>
Date: Thu, 17 Dec 2009 19:00:29 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add madvise MADV_HUGEPAGE to mark regions that are important to be hugepage
backed. Return -EINVAL if the vma is not of an anonymous type, or the feature
isn't built into the kernel. Never silently return success.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -45,6 +45,8 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -93,6 +93,7 @@ extern pmd_t *page_check_address_pmd(str
 				     unsigned long address,
 				     enum page_check_address_pmd_flag flag);
 extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
+extern int hugepage_madvise(unsigned long *vm_flags);
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define transparent_hugepage_flags 0UL
 static inline int split_huge_page(struct page *page)
@@ -105,6 +106,11 @@ static inline int split_huge_page(struct
 	do { }  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
+static inline int hugepage_madvise(unsigned long *vm_flags)
+{
+	BUG_ON(0);
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -106,6 +106,9 @@ extern unsigned int kobjsize(const void 
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
+#if BITS_PER_LONG > 32
+#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
+#endif
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -790,3 +790,19 @@ out_unlock:
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
