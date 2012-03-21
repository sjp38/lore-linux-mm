Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D3F426B00F4
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:21 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:21 -0700 (PDT)
Subject: [PATCH 16/16] mm: vm_flags_t strict type checking
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:57:18 +0400
Message-ID: <20120321065718.13852.29789.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Now nobody uses VM_* constants in macro-expressions, so we can add type to them.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h       |  138 ++++++++++++++++++++++++++++++++--------------
 include/linux/mm_types.h |    4 +
 2 files changed, 97 insertions(+), 45 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index be35c2f..b432c28 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -74,59 +74,111 @@ extern unsigned int kobjsize(const void *objp);
  * vm_flags in vm_area_struct, see mm_types.h.
  */
 
-#define VM_NONE		0x00000000
+enum {
+	__VM_READ,
+	__VM_WRITE,
+	__VM_EXEC,
+	__VM_SHARED,
+
+	__VM_MAYREAD,
+	__VM_MAYWRITE,
+	__VM_MAYEXEC,
+	__VM_MAYSHARE,
+
+	__VM_GROWSDOWN,
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
+	__VM_GROWSUP,
+#else
+	__VM_NOHUGEPAGE,
+#endif
+	__VM_PFNMAP,
+	__VM_DENYWRITE,
+
+	__VM_EXECUTABLE,
+	__VM_LOCKED,
+	__VM_IO,
+	__VM_SEQ_READ,
+
+	__VM_RAND_READ,
+	__VM_DONTCOPY,
+	__VM_DONTEXPAND,
+	__VM_RESERVED,
 
-#define VM_READ		0x00000001	/* currently active flags */
-#define VM_WRITE	0x00000002
-#define VM_EXEC		0x00000004
-#define VM_SHARED	0x00000008
+	__VM_ACCOUNT,
+	__VM_NORESERVE,
+	__VM_HUGETLB,
+	__VM_NONLINEAR,
+
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+	__VM_MAPPED_COPY,
+#else
+	__VM_HUGEPAGE,
+#endif
+	__VM_INSERTPAGE,
+	__VM_ALWAYSDUMP,
+	__VM_CAN_NONLINEAR,
+
+	__VM_MIXEDMAP,
+	__VM_SAO,
+	__VM_PFN_AT_MMAP,
+	__VM_MERGEABLE,
+
+	__NR_VMA_FLAGS
+};
+
+#define VM_NONE		((__force vm_flags_t)0)
+
+#define	__VMF(name)	((__force vm_flags_t)(1ull << (__VM_##name)))
+
+#define VM_READ		__VMF(READ) /* currently active flags */
+#define VM_WRITE	__VMF(WRITE)
+#define VM_EXEC		__VMF(EXEC)
+#define VM_SHARED	__VMF(SHARED)
 
 /* mprotect() hardcodes VM_MAYREAD >> 4 == VM_READ, and so for r/w/x bits. */
-#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
-#define VM_MAYWRITE	0x00000020
-#define VM_MAYEXEC	0x00000040
-#define VM_MAYSHARE	0x00000080
+#define VM_MAYREAD	__VMF(MAYREAD) /* limits for mprotect() etc */
+#define VM_MAYWRITE	__VMF(MAYWRITE)
+#define VM_MAYEXEC	__VMF(MAYEXEC)
+#define VM_MAYSHARE	__VMF(MAYSHARE)
 
-#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_GROWSDOWN	__VMF(GROWSDOWN) /* general info on the segment */
 #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
-#define VM_GROWSUP	0x00000200
+#define VM_GROWSUP	__VMF(GROWSUP)
 #else
-#define VM_GROWSUP	0x00000000
-#define VM_NOHUGEPAGE	0x00000200	/* MADV_NOHUGEPAGE marked this vma */
+#define VM_GROWSUP	VM_NONE
+#define VM_NOHUGEPAGE	__VMF(NOHUGEPAGE) /* MADV_NOHUGEPAGE marked this vma */
 #endif
-#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
-#define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
-
-#define VM_EXECUTABLE	0x00001000
-#define VM_LOCKED	0x00002000
-#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
-
-					/* Used by sys_madvise() */
-#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
-#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
-
-#define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
-#define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
-#define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
-#define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
-#define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
-#define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
-#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
+#define VM_PFNMAP	__VMF(PFNMAP) /* Page-ranges managed without "struct page", just pure PFN */
+#define VM_DENYWRITE	__VMF(DENYWRITE) /* ETXTBSY on write attempts.. */
+
+#define VM_EXECUTABLE	__VMF(EXECUTABLE)
+#define VM_LOCKED	__VMF(LOCKED)
+#define VM_IO		__VMF(IO) /* Memory mapped I/O or similar */
+
+					  /* Used by sys_madvise() */
+#define VM_SEQ_READ	__VMF(SEQ_READ) /* App will access data sequentially */
+#define VM_RAND_READ	__VMF(RAND_READ) /* App will not benefit from clustered reads */
+
+#define VM_DONTCOPY	__VMF(DONTCOPY) /* Do not copy this vma on fork */
+#define VM_DONTEXPAND	__VMF(DONTEXPAND) /* Cannot expand with mremap() */
+#define VM_RESERVED	__VMF(RESERVED) /* Count as reserved_vm like IO */
+#define VM_ACCOUNT	__VMF(ACCOUNT) /* Is a VM accounted object */
+#define VM_NORESERVE	__VMF(NORESERVE) /* should the VM suppress accounting */
+#define VM_HUGETLB	__VMF(HUGETLB) /* Huge TLB Page VM */
+#define VM_NONLINEAR	__VMF(NONLINEAR) /* Is non-linear (remap_file_pages) */
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
-#define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
+#define VM_MAPPED_COPY	__VMF(MAPPED_COPY) /* T if mapped copy of data (nommu mmap) */
 #else
-#define VM_HUGEPAGE	0x01000000	/* MADV_HUGEPAGE marked this vma */
+#define VM_HUGEPAGE	__VMF(HUGEPAGE) /* MADV_HUGEPAGE marked this vma */
 #endif
-#define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
-#define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
-
-#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
-#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
-#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
-#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
-
-#define __NR_VMA_FLAGS	32
+#define VM_INSERTPAGE	__VMF(INSERTPAGE) /* The vma has had "vm_insert_page()" done on it */
+#define VM_ALWAYSDUMP	__VMF(ALWAYSDUMP) /* Always include in core dumps */
+
+#define VM_CAN_NONLINEAR __VMF(CAN_NONLINEAR) /* Has ->fault & does nonlinear pages */
+#define VM_MIXEDMAP	__VMF(MIXEDMAP) /* Can contain "struct page" and pure PFN pages */
+#define VM_SAO		__VMF(SAO) /* Strong Access Ordering (powerpc) */
+#define VM_PFN_AT_MMAP	__VMF(PFN_AT_MMAP) /* PFNMAP vma that is fully mapped at mmap time */
+#define VM_MERGEABLE	__VMF(MERGEABLE) /* KSM may merge identical pages */
 
 #ifndef __GENERATING_BOUNDS_H
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d57e764..f14cc5e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -172,9 +172,9 @@ struct page_frag {
 };
 
 #if (NR_VMA_FLAGS > 32)
-typedef unsigned long long __nocast vm_flags_t;
+typedef unsigned long long __bitwise__ vm_flags_t;
 #else
-typedef unsigned long __nocast vm_flags_t;
+typedef unsigned long __bitwise__ vm_flags_t;
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
