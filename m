Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D97C082F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:49 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so182144321pad.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.27
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:27 -0700 (PDT)
Subject: [PATCH 22/25] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:26 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191826.0F8DA9A7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This is all that we need to get the new system call itself
working on x86.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 b/arch/x86/include/uapi/asm/mman.h       |    7 +++++++
 b/mm/Kconfig                             |    1 +
 4 files changed, 10 insertions(+)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key	2015-09-28 11:39:50.964411042 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2015-09-28 11:39:50.972411406 -0700
@@ -382,3 +382,4 @@
 373	i386	shutdown		sys_shutdown
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
+376	i386	mprotect_key		sys_mprotect_key
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key	2015-09-28 11:39:50.965411087 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2015-09-28 11:39:50.972411406 -0700
@@ -331,6 +331,7 @@
 322	64	execveat		stub_execveat
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
+325	common	mprotect_key		sys_mprotect_key
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key	2015-09-28 11:39:50.967411179 -0700
+++ b/arch/x86/include/uapi/asm/mman.h	2015-09-28 11:39:50.973411451 -0700
@@ -20,6 +20,13 @@
 		((vm_flags) & VM_PKEY_BIT1 ? _PAGE_PKEY_BIT1 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT2 ? _PAGE_PKEY_BIT2 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT3 ? _PAGE_PKEY_BIT3 : 0))
+
+#define arch_calc_vm_prot_bits(prot, key) ( 		\
+		((key) & 0x1 ? VM_PKEY_BIT0 : 0) |      \
+		((key) & 0x2 ? VM_PKEY_BIT1 : 0) |      \
+		((key) & 0x4 ? VM_PKEY_BIT2 : 0) |      \
+		((key) & 0x8 ? VM_PKEY_BIT3 : 0))
+
 #endif
 
 #include <asm-generic/mman.h>
diff -puN mm/Kconfig~pkeys-16-x86-mprotect_key mm/Kconfig
--- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-09-28 11:39:50.969411269 -0700
+++ b/mm/Kconfig	2015-09-28 11:39:50.973411451 -0700
@@ -689,4 +689,5 @@ config NR_PROTECTION_KEYS
 	# Everything supports a _single_ key, so allow folks to
 	# at least call APIs that take keys, but require that the
 	# key be 0.
+	default 16 if X86_INTEL_MEMORY_PROTECTION_KEYS
 	default 1
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
