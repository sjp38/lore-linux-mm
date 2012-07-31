Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B73586B0068
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:34:34 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4878076lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:34:34 -0700 (PDT)
Subject: [PATCH v3 04/10] mm: introduce arch-specific vma flag VM_ARCH_1
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:34:28 +0400
Message-ID: <20120731103428.20182.21122.stgit@zurg>
In-Reply-To: <20120731102546.20182.8450.stgit@zurg>
References: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patch combines several arch-specific vma flags into one.

before patch:

        0x00000200      0x01000000      0x20000000      0x40000000
x86     VM_NOHUGEPAGE   VM_HUGEPAGE     -               VM_PAT
powerpc -               -               VM_SAO          -
parisc  VM_GROWSUP      -               -               -
ia64    VM_GROWSUP      -               -               -
nommu   -               VM_MAPPED_COPY  -               -
others  -               -               -               -

after patch:

        0x00000200      0x01000000      0x20000000      0x40000000
x86     -               VM_PAT          VM_HUGEPAGE     VM_NOHUGEPAGE
powerpc -               VM_SAO          -               -
parisc  -               VM_GROWSUP      -               -
ia64    -               VM_GROWSUP      -               -
nommu   -               VM_MAPPED_COPY  -               -
others  -               VM_ARCH_1       -               -

And voila! One completely free bit.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h |   34 +++++++++++++++++++++-------------
 mm/huge_memory.c   |    2 +-
 mm/ksm.c           |    7 ++++++-
 3 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c5db955..22c945b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -70,6 +70,8 @@ extern unsigned int kobjsize(const void *objp);
 /*
  * vm_flags in vm_area_struct, see mm_types.h.
  */
+#define VM_NONE		0x00000000
+
 #define VM_READ		0x00000001	/* currently active flags */
 #define VM_WRITE	0x00000002
 #define VM_EXEC		0x00000004
@@ -82,12 +84,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
-#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
-#define VM_GROWSUP	0x00000200
-#else
-#define VM_GROWSUP	0x00000000
-#define VM_NOHUGEPAGE	0x00000200	/* MADV_NOHUGEPAGE marked this vma */
-#endif
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
@@ -106,20 +102,32 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
-#ifndef CONFIG_TRANSPARENT_HUGEPAGE
-#define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
-#else
-#define VM_HUGEPAGE	0x01000000	/* MADV_HUGEPAGE marked this vma */
-#endif
+#define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_NODUMP	0x04000000	/* Do not include in the core dump */
 
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
-#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PAT		0x40000000	/* PAT reserves whole VMA at once (x86) */
+#define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
+#define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
+#if defined(CONFIG_X86)
+# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
+#elif defined(CONFIG_PPC)
+# define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
+#elif defined(CONFIG_PARISC)
+# define VM_GROWSUP	VM_ARCH_1
+#elif defined(CONFIG_IA64)
+# define VM_GROWSUP	VM_ARCH_1
+#elif !defined(CONFIG_MMU)
+# define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
+#endif
+
+#ifndef VM_GROWSUP
+# define VM_GROWSUP	VM_NONE
+#endif
+
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5b31652..67721f8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1491,7 +1491,7 @@ out:
 	return ret;
 }
 
-#define VM_NO_THP (VM_SPECIAL|VM_INSERTPAGE|VM_MIXEDMAP|VM_SAO| \
+#define VM_NO_THP (VM_SPECIAL|VM_INSERTPAGE|VM_MIXEDMAP| \
 		   VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..d1cbe2a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1470,9 +1470,14 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
 				 VM_RESERVED  | VM_HUGETLB | VM_INSERTPAGE |
-				 VM_NONLINEAR | VM_MIXEDMAP | VM_SAO))
+				 VM_NONLINEAR | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
+#ifdef VM_SAO
+		if (*vm_flags & VM_SAO)
+			return 0;
+#endif
+
 		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
 			err = __ksm_enter(mm);
 			if (err)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
