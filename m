Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 037CB6B5243
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:44:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bg5-v6so4055383plb.20
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:44:45 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id m13-v6si6713043pgk.251.2018.08.30.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:44:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 6/8] mm/mmap: Add IBT bitmap size to address space limit check
Date: Thu, 30 Aug 2018 07:40:07 -0700
Message-Id: <20180830144009.3314-7-yu-cheng.yu@intel.com>
In-Reply-To: <20180830144009.3314-1-yu-cheng.yu@intel.com>
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The indirect branch tracking legacy bitmap takes a large address
space.  This causes may_expand_vm() failure on the address limit
check.  For a IBT-enabled task, add the bitmap size to the
address limit.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/resource.h |  5 +++++
 arch/x86/kernel/cet.c                | 10 ++++++++--
 include/uapi/asm-generic/resource.h  |  3 +++
 mm/mmap.c                            | 12 +++++++++++-
 4 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/uapi/asm/resource.h b/arch/x86/include/uapi/asm/resource.h
index 04bc4db8921b..0741b2a6101a 100644
--- a/arch/x86/include/uapi/asm/resource.h
+++ b/arch/x86/include/uapi/asm/resource.h
@@ -1 +1,6 @@
+/* SPDX-License-Identifier: GPL-2.0+ WITH Linux-syscall-note */
+#ifdef CONFIG_X86_INTEL_CET
+#define rlimit_as_extra() current->thread.cet.ibt_bitmap_size
+#endif
+
 #include <asm-generic/resource.h>
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 071b9dd5bc5c..f700743f6f48 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -295,20 +295,26 @@ int cet_setup_ibt(void)
 	if (!cpu_feature_enabled(X86_FEATURE_IBT))
 		return -EOPNOTSUPP;
 
+	/*
+	 * Calculate size and put in thread header.
+	 * may_expand_vm() needs this information.
+	 */
 	size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
+	current->thread.cet.ibt_bitmap_size = size;
 	bitmap = do_mmap_locked(0, size, PROT_READ | PROT_WRITE,
 				MAP_ANONYMOUS | MAP_PRIVATE,
 				VM_DONTDUMP);
 
-	if (bitmap >= TASK_SIZE)
+	if (bitmap >= TASK_SIZE) {
+		current->thread.cet.ibt_bitmap_size = 0;
 		return -ENOMEM;
+	}
 
 	rdmsrl(MSR_IA32_U_CET, r);
 	r |= (MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_NO_TRACK_EN);
 	wrmsrl(MSR_IA32_U_CET, r);
 
 	current->thread.cet.ibt_bitmap_addr = bitmap;
-	current->thread.cet.ibt_bitmap_size = size;
 	current->thread.cet.ibt_enabled = 1;
 	return 0;
 }
diff --git a/include/uapi/asm-generic/resource.h b/include/uapi/asm-generic/resource.h
index f12db7a0da64..8a7608a09700 100644
--- a/include/uapi/asm-generic/resource.h
+++ b/include/uapi/asm-generic/resource.h
@@ -58,5 +58,8 @@
 # define RLIM_INFINITY		(~0UL)
 #endif
 
+#ifndef rlimit_as_extra
+#define rlimit_as_extra() 0
+#endif
 
 #endif /* _UAPI_ASM_GENERIC_RESOURCE_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b184c60..6f6c722c1484 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3228,7 +3228,17 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
  */
 bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 {
-	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
+	unsigned long as_limit = rlimit(RLIMIT_AS);
+	unsigned long as_limit_plus = as_limit + rlimit_as_extra();
+
+	/* as_limit_plus overflowed */
+	if (as_limit_plus < as_limit)
+		as_limit_plus = RLIM_INFINITY;
+
+	if (as_limit_plus > as_limit)
+		as_limit = as_limit_plus;
+
+	if (mm->total_vm + npages > as_limit >> PAGE_SHIFT)
 		return false;
 
 	if (is_data_mapping(flags) &&
-- 
2.17.1
