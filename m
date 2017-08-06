Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54ECD6B0292
	for <linux-mm@kvack.org>; Sun,  6 Aug 2017 10:04:43 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 6so31170690qts.7
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 07:04:43 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id q24si5620223qtb.129.2017.08.06.07.04.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Aug 2017 07:04:42 -0700 (PDT)
From: riel@redhat.com
Subject: [PATCH 1/2] x86,mpx: make mpx depend on x86-64 to free up VMA flag
Date: Sun,  6 Aug 2017 10:04:24 -0400
Message-Id: <20170806140425.20937-2-riel@redhat.com>
In-Reply-To: <20170806140425.20937-1-riel@redhat.com>
References: <20170806140425.20937-1-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

From: Rik van Riel <riel@redhat.com>

MPX only seems to be available on 64 bit CPUs, starting with Skylake
and Goldmont. Move VM_MPX into the 64 bit only portion of vma->vm_flags,
in order to free up a VMA flag.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/Kconfig   | 4 +++-
 include/linux/mm.h | 8 ++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 781521b7cf9e..6dff14fadc6f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1756,7 +1756,9 @@ config X86_SMAP
 config X86_INTEL_MPX
 	prompt "Intel MPX (Memory Protection Extensions)"
 	def_bool n
-	depends on CPU_SUP_INTEL
+	# Note: only available in 64-bit mode due to VMA flags shortage
+	depends on CPU_SUP_INTEL && X86_64
+	select ARCH_USES_HIGH_VMA_FLAGS
 	---help---
 	  MPX provides hardware features that can be used in
 	  conjunction with compiler-instrumented code to check
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..7550eeb06ccf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -208,10 +208,12 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_1	33	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
+#define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #if defined(CONFIG_X86)
@@ -235,9 +237,11 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
 #endif
 
-#if defined(CONFIG_X86)
+#if defined(CONFIG_X86_INTEL_MPX)
 /* MPX specific bounds table or bounds directory */
-# define VM_MPX		VM_ARCH_2
+# define VM_MPX		VM_HIGH_ARCH_BIT_4
+#else
+# define VM_MPX		VM_NONE
 #endif
 
 #ifndef VM_GROWSUP
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
