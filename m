Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC5766B5244
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:44:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v195-v6so5167925pgb.0
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:44:45 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id m13-v6si6713043pgk.251.2018.08.30.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:44:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 7/8] x86: Insert endbr32/endbr64 to vDSO
Date: Thu, 30 Aug 2018 07:40:08 -0700
Message-Id: <20180830144009.3314-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180830144009.3314-1-yu-cheng.yu@intel.com>
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

From: "H.J. Lu" <hjl.tools@gmail.com>

When Intel indirect branch tracking is enabled, functions in vDSO which
may be called indirectly must have endbr32 or endbr64 as the first
instruction.  Compiler must support -fcf-protection=branch so that it
can be used to compile vDSO.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 arch/x86/entry/vdso/.gitignore        |  4 ++++
 arch/x86/entry/vdso/Makefile          | 12 +++++++++++-
 arch/x86/entry/vdso/vdso-layout.lds.S |  1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/vdso/.gitignore b/arch/x86/entry/vdso/.gitignore
index aae8ffdd5880..552941fdfae0 100644
--- a/arch/x86/entry/vdso/.gitignore
+++ b/arch/x86/entry/vdso/.gitignore
@@ -5,3 +5,7 @@ vdso32-sysenter-syms.lds
 vdso32-int80-syms.lds
 vdso-image-*.c
 vdso2c
+vclock_gettime.S
+vgetcpu.S
+vclock_gettime.asm
+vgetcpu.asm
diff --git a/arch/x86/entry/vdso/Makefile b/arch/x86/entry/vdso/Makefile
index fa3f439f0a92..8694f70c08e6 100644
--- a/arch/x86/entry/vdso/Makefile
+++ b/arch/x86/entry/vdso/Makefile
@@ -102,13 +102,17 @@ vobjx32s := $(foreach F,$(vobjx32s-y),$(obj)/$F)
 
 # Convert 64bit object file to x32 for x32 vDSO.
 quiet_cmd_x32 = X32     $@
-      cmd_x32 = $(OBJCOPY) -O elf32-x86-64 $< $@
+      cmd_x32 = $(OBJCOPY) -R .note.gnu.property -O elf32-x86-64 $< $@
 
 $(obj)/%-x32.o: $(obj)/%.o FORCE
 	$(call if_changed,x32)
 
 targets += vdsox32.lds $(vobjx32s-y)
 
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+    $(obj)/vclock_gettime.o $(obj)/vgetcpu.o $(obj)/vdso32/vclock_gettime.o: KBUILD_CFLAGS += -fcf-protection=branch
+endif
+
 $(obj)/%.so: OBJCOPYFLAGS := -S
 $(obj)/%.so: $(obj)/%.so.dbg
 	$(call if_changed,objcopy)
@@ -160,6 +164,12 @@ quiet_cmd_vdso = VDSO    $@
 
 VDSO_LDFLAGS = -shared $(call ld-option, --hash-style=both) \
 	$(call ld-option, --build-id) -Bsymbolic
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+  VDSO_LDFLAGS += $(call ldoption, -z$(comma)ibt)
+endif
+ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+  VDSO_LDFLAGS += $(call ldoption, -z$(comma)shstk)
+endif
 GCOV_PROFILE := n
 
 #
diff --git a/arch/x86/entry/vdso/vdso-layout.lds.S b/arch/x86/entry/vdso/vdso-layout.lds.S
index acfd5ba7d943..cabaeedfed78 100644
--- a/arch/x86/entry/vdso/vdso-layout.lds.S
+++ b/arch/x86/entry/vdso/vdso-layout.lds.S
@@ -74,6 +74,7 @@ SECTIONS
 	.fake_shstrtab	: { *(.fake_shstrtab) }		:text
 
 
+	.note.gnu.property : { *(.note.gnu.property) }	:text	:note
 	.note		: { *(.note.*) }		:text	:note
 
 	.eh_frame_hdr	: { *(.eh_frame_hdr) }		:text	:eh_frame_hdr
-- 
2.17.1
