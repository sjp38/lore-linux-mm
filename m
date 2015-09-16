Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 943186B0272
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:55:55 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215780824pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:55:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id cj4si42289090pbc.126.2015.09.16.10.49.12
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:13 -0700 (PDT)
Subject: [PATCH 23/26] [HIJACKPROT] x86, pkeys: add x86 version of arch_validate_prot()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:12 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174912.F07EE9C1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This allows more than just the traditional PROT_* flags to
be passed in to mprotect(), etc... on x86.

---

 b/arch/x86/include/uapi/asm/mman.h |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-81-arch_validate_prot arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-81-arch_validate_prot	2015-09-16 09:45:54.564432490 -0700
+++ b/arch/x86/include/uapi/asm/mman.h	2015-09-16 09:45:54.567432626 -0700
@@ -6,6 +6,8 @@
 #define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
 #define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
 
+#include <asm-generic/mman.h>
+
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 /*
  * Take the 4 protection key bits out of the vma->vm_flags
@@ -26,8 +28,20 @@
 		((prot) & PROT_PKEY1 ? VM_PKEY_BIT1 : 0) |	\
 		((prot) & PROT_PKEY2 ? VM_PKEY_BIT2 : 0) |	\
 		((prot) & PROT_PKEY3 ? VM_PKEY_BIT3 : 0))
-#endif
 
-#include <asm-generic/mman.h>
+#ifndef arch_validate_prot
+/*
+ * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
+ * already been masked out.
+ *
+ * Returns true if the prot flags are valid
+ */
+#define arch_validate_prot(prot) (\
+	(prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM |	\
+	 PROT_PKEY0 | PROT_PKEY1 | PROT_PKEY2 | PROT_PKEY3)) == 0)	\
+
+#endif /* arch_validate_prot */
+
+#endif /* CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS */
 
 #endif /* _ASM_X86_MMAN_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
