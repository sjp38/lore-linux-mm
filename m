Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02CB16B5229
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:43:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t4-v6so4066085plo.0
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:43:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t2-v6si6809115pge.64.2018.08.30.07.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:43:45 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 08/24] mm: Introduce VM_SHSTK for shadow stack memory
Date: Thu, 30 Aug 2018 07:38:48 -0700
Message-Id: <20180830143904.3168-9-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

VM_SHSTK indicates a shadow stack memory area.
The shadow stack is implemented only for the 64-bit kernel.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 include/linux/mm.h | 8 ++++++++
 mm/internal.h      | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..f40387ecd920 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -224,11 +224,13 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -266,6 +268,12 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_MPX		VM_NONE
 #endif
 
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+# define VM_SHSTK	VM_HIGH_ARCH_5
+#else
+# define VM_SHSTK	VM_NONE
+#endif
+
 #ifndef VM_GROWSUP
 # define VM_GROWSUP	VM_NONE
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index 87256ae1bef8..d5ee0c04a6c4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -280,6 +280,14 @@ static inline bool is_data_mapping(vm_flags_t flags)
 	return (flags & (VM_WRITE | VM_SHARED | VM_STACK)) == VM_WRITE;
 }
 
+/*
+ * Shadow stack area
+ */
+static inline bool is_shstk_mapping(vm_flags_t flags)
+{
+	return (flags & VM_SHSTK);
+}
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
-- 
2.17.1
