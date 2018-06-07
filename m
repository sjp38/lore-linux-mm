Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0B26B0293
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:42:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v133-v6so3575091pgb.10
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:42:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l22-v6si26243115pgu.353.2018.06.07.07.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:42:30 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 3/7] mm/mmap: Add IBT bitmap size to address space limit check
Date: Thu,  7 Jun 2018 07:38:51 -0700
Message-Id: <20180607143855.3681-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143855.3681-1-yu-cheng.yu@intel.com>
References: <20180607143855.3681-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The indirect branch tracking legacy bitmap takes a large address
space.  This causes may_expand_vm() failure on the address limit
check.  For a IBT-enabled task, add the bitmap size to the
address limit.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/resource.h | 5 +++++
 include/uapi/asm-generic/resource.h  | 3 +++
 mm/mmap.c                            | 8 +++++++-
 3 files changed, 15 insertions(+), 1 deletion(-)

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
index e7d1fcb7ec58..5c07f052bed7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3255,7 +3255,13 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
  */
 bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 {
-	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
+	unsigned long as_limit = rlimit(RLIMIT_AS);
+	unsigned long as_limit_plus = as_limit + rlimit_as_extra();
+
+	if (as_limit_plus > as_limit)
+		as_limit = as_limit_plus;
+
+	if (mm->total_vm + npages > as_limit >> PAGE_SHIFT)
 		return false;
 
 	if (is_data_mapping(flags) &&
-- 
2.15.1
