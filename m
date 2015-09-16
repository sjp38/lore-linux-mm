Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 828866B0260
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:32 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so215098427pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rb8si42266970pbb.243.2015.09.16.10.49.11
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:12 -0700 (PDT)
Subject: [PATCH 21/26] [NEWSYSCALL] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:11 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174911.BB286A08@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This is all that we need to get the new system call itself
working on x86.

---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 b/arch/x86/include/uapi/asm/mman.h       |    7 +++++++
 b/mm/Kconfig                             |    1 +
 4 files changed, 10 insertions(+)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key	2015-09-16 10:48:20.711394295 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2015-09-16 10:48:20.719394658 -0700
@@ -382,3 +382,4 @@
 373	i386	shutdown		sys_shutdown
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
+394	i386	mprotect_key		sys_mprotect_key
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key	2015-09-16 10:48:20.712394341 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2015-09-16 10:48:20.719394658 -0700
@@ -331,6 +331,7 @@
 322	64	execveat		stub_execveat
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
+394	common	mprotect_key		sys_mprotect_key
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key	2015-09-16 10:48:20.714394431 -0700
+++ b/arch/x86/include/uapi/asm/mman.h	2015-09-16 10:48:20.720394703 -0700
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
--- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-09-16 10:48:20.716394522 -0700
+++ b/mm/Kconfig	2015-09-16 10:48:20.720394703 -0700
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
