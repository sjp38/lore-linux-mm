Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9156B04C4
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:57:21 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id p138so54184662vkp.8
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:57:21 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k8si10855570uaa.77.2017.07.31.11.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 11:57:19 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/3] mm: arch: Consolidate mmap hugetlb size encodings
Date: Mon, 31 Jul 2017 11:56:25 -0700
Message-Id: <1501527386-10736-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
References: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

A non-default huge page size can be encoded in the flags argument
of the mmap system call.  The definitions for these encodings are
in arch specific header files.  However, all architectures use the
same values.

Consolidate all the definitions in the primary user header file
(uapi/linux/mman.h).  Include definitions for all known huge page
sizes.  Use the generic encoding definitions in hugetlb_encode.h
as the basis for these definitions.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/alpha/include/uapi/asm/mman.h     | 11 -----------
 arch/mips/include/uapi/asm/mman.h      | 11 -----------
 arch/parisc/include/uapi/asm/mman.h    | 11 -----------
 arch/powerpc/include/uapi/asm/mman.h   | 16 ----------------
 arch/x86/include/uapi/asm/mman.h       |  3 ---
 arch/xtensa/include/uapi/asm/mman.h    | 11 -----------
 include/uapi/asm-generic/mman-common.h | 11 -----------
 include/uapi/linux/mman.h              | 22 ++++++++++++++++++++++
 8 files changed, 22 insertions(+), 74 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 02760f6..13b52aa 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -67,17 +67,6 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
-/*
- * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define MAP_HUGE_SHIFT	26
-#define MAP_HUGE_MASK	0x3f
-
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 655e2fb..398eebc 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -94,17 +94,6 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
-/*
- * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define MAP_HUGE_SHIFT	26
-#define MAP_HUGE_MASK	0x3f
-
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 5979745..9cd0e8c 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -64,17 +64,6 @@
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
 
-/*
- * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define MAP_HUGE_SHIFT	26
-#define MAP_HUGE_MASK	0x3f
-
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index ab45cc2..03c06ba 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -29,20 +29,4 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
-/*
- * When MAP_HUGETLB is set, bits [26:31] of the flags argument to mmap(2),
- * encode the log2 of the huge page size. A value of zero indicates that the
- * default huge page size should be used. To use a non-default huge page size,
- * one of these defines can be used, or the size can be encoded by hand. Note
- * that on most systems only a subset, or possibly none, of these sizes will be
- * available.
- */
-#define MAP_HUGE_512KB	(19 << MAP_HUGE_SHIFT)	/* 512KB HugeTLB Page */
-#define MAP_HUGE_1MB	(20 << MAP_HUGE_SHIFT)	/* 1MB   HugeTLB Page */
-#define MAP_HUGE_2MB	(21 << MAP_HUGE_SHIFT)	/* 2MB   HugeTLB Page */
-#define MAP_HUGE_8MB	(23 << MAP_HUGE_SHIFT)	/* 8MB   HugeTLB Page */
-#define MAP_HUGE_16MB	(24 << MAP_HUGE_SHIFT)	/* 16MB  HugeTLB Page */
-#define MAP_HUGE_1GB	(30 << MAP_HUGE_SHIFT)	/* 1GB   HugeTLB Page */
-#define MAP_HUGE_16GB	(34 << MAP_HUGE_SHIFT)	/* 16GB  HugeTLB Page */
-
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/x86/include/uapi/asm/mman.h b/arch/x86/include/uapi/asm/mman.h
index 39bca7f..3be08f0 100644
--- a/arch/x86/include/uapi/asm/mman.h
+++ b/arch/x86/include/uapi/asm/mman.h
@@ -3,9 +3,6 @@
 
 #define MAP_32BIT	0x40		/* only give out 32bit addresses */
 
-#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
-#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
-
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 /*
  * Take the 4 protection key bits out of the vma->vm_flags
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 24365b3..8ce77a2 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -106,17 +106,6 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
-/*
- * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define MAP_HUGE_SHIFT	26
-#define MAP_HUGE_MASK	0x3f
-
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0..d248f3c 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -61,17 +61,6 @@
 /* compatibility flags */
 #define MAP_FILE	0
 
-/*
- * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define MAP_HUGE_SHIFT	26
-#define MAP_HUGE_MASK	0x3f
-
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
index ade4acd..a937480 100644
--- a/include/uapi/linux/mman.h
+++ b/include/uapi/linux/mman.h
@@ -2,6 +2,7 @@
 #define _UAPI_LINUX_MMAN_H
 
 #include <asm/mman.h>
+#include <asm-generic/hugetlb_encode.h>
 
 #define MREMAP_MAYMOVE	1
 #define MREMAP_FIXED	2
@@ -10,4 +11,25 @@
 #define OVERCOMMIT_ALWAYS		1
 #define OVERCOMMIT_NEVER		2
 
+/*
+ * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
+ * size other than the default is desired.  See hugetlb_encode.h.
+ * All known huge page size encodings are provided here.  It is the
+ * responsibility of the application to know which sizes are supported on
+ * the running system.  See mmap(2) man page for details.
+ */
+#define MAP_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
+#define MAP_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
+
+#define MAP_HUGE_64KB	HUGETLB_FLAG_ENCODE_64KB
+#define MAP_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
+#define MAP_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
+#define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
+#define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
+#define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
+#define MAP_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
+#define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
+#define MAP_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
+#define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
+
 #endif /* _UAPI_LINUX_MMAN_H */
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
