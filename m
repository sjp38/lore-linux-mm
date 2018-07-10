Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7AD6B0010
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u8-v6so7428573pfn.18
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z10-v6si17009124pgo.412.2018.07.10.15.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:12 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 07/27] x86/cet/shstk: Add Kconfig option for user-mode shadow stack
Date: Tue, 10 Jul 2018 15:26:19 -0700
Message-Id: <20180710222639.8241-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Introduce Kconfig option X86_INTEL_SHADOW_STACK_USER.

An application has shadow stack protection when all the following are
true:

  (1) The kernel has X86_INTEL_SHADOW_STACK_USER enabled,
  (2) The running processor supports the shadow stack,
  (3) The application is built with shadow stack enabled tools & libs
      and, and at runtime, all dependent shared libs can support shadow
      stack.

If this kernel config option is enabled, but (2) or (3) above is not
true, the application runs without the shadow stack protection.
Existing legacy applications will continue to work without the shadow
stack protection.

The user-mode shadow stack protection is only implemented for the
64-bit kernel.  Thirty-two bit applications are supported under the
compatibility mode.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig  | 24 ++++++++++++++++++++++++
 arch/x86/Makefile |  7 +++++++
 2 files changed, 31 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f1dbb4ee19d7..44af5e1aaa4a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1917,6 +1917,30 @@ config X86_INTEL_MEMORY_PROTECTION_KEYS
 
 	  If unsure, say y.
 
+config X86_INTEL_CET
+	def_bool n
+
+config ARCH_HAS_SHSTK
+	def_bool n
+
+config X86_INTEL_SHADOW_STACK_USER
+	prompt "Intel Shadow Stack for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select X86_INTEL_CET
+	select ARCH_HAS_SHSTK
+	---help---
+	  Shadow stack provides hardware protection against program stack
+	  corruption.  Only when all the following are true will an application
+	  have the shadow stack protection: the kernel supports it (i.e. this
+	  feature is enabled), the application is compiled and linked with
+	  shadow stack enabled, and the processor supports this feature.
+	  When the kernel has this configuration enabled, existing non shadow
+	  stack applications will continue to work, but without shadow stack
+	  protection.
+
+	  If unsure, say y.
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index a08e82856563..ad1314e5ef65 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -157,6 +157,13 @@ ifdef CONFIG_X86_X32
 endif
 export CONFIG_X86_X32_ABI
 
+# Check assembler shadow stack suppot
+ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+  ifeq ($(call as-instr, saveprevssp, y),)
+      $(error CONFIG_X86_INTEL_SHADOW_STACK_USER not supported by the assembler)
+  endif
+endif
+
 #
 # If the function graph tracer is used with mcount instead of fentry,
 # '-maccumulate-outgoing-args' is needed to prevent a GCC bug
-- 
2.17.1
