Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7F986B5240
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:44:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x85-v6so4877531pfe.13
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:44:44 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t10-v6si6980653pgn.667.2018.08.30.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:44:43 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 1/8] x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
Date: Thu, 30 Aug 2018 07:40:02 -0700
Message-Id: <20180830144009.3314-2-yu-cheng.yu@intel.com>
In-Reply-To: <20180830144009.3314-1-yu-cheng.yu@intel.com>
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The user-mode indirect branch tracking support is done mostly by
GCC to insert ENDBR64/ENDBR32 instructions at branch targets.
The kernel provides CPUID enumeration, feature MSR setup and
the allocation of legacy bitmap.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig  | 12 ++++++++++++
 arch/x86/Makefile |  7 +++++++
 2 files changed, 19 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2cfe11e1cf7f..0d97b03f35f6 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1941,6 +1941,18 @@ config X86_INTEL_SHADOW_STACK_USER
 
 	  If unsure, say y.
 
+config X86_INTEL_BRANCH_TRACKING_USER
+	prompt "Intel Indirect Branch Tracking for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select X86_INTEL_CET
+	select ARCH_HAS_PROGRAM_PROPERTIES
+	---help---
+	  Indirect Branch Tracking provides hardware protection against return-/jmp-
+	  oriented programing attacks.
+
+	  If unsure, say y
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 00927853e409..0da5121c30db 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -159,6 +159,13 @@ ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
   endif
 endif
 
+# Check compiler ibt support
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+  ifeq ($(call cc-option-yn, -fcf-protection=branch), n)
+      $(error CONFIG_X86_INTEL_BRANCH_TRACKING_USER not supported by compiler)
+  endif
+endif
+
 #
 # If the function graph tracer is used with mcount instead of fentry,
 # '-maccumulate-outgoing-args' is needed to prevent a GCC bug
-- 
2.17.1
