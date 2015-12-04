Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 87DA582F76
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:26 -0500 (EST)
Received: by pacej9 with SMTP id ej9so78051843pac.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:26 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id iw2si15475147pac.46.2015.12.03.17.15.04
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:04 -0800 (PST)
Subject: [PATCH 28/34] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:03 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011503.2A095839@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This is all that we need to get the new system call itself
working on x86.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 b/arch/x86/include/uapi/asm/mman.h       |    6 ++++++
 b/mm/Kconfig                             |    1 +
 4 files changed, 9 insertions(+)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.109919982 -0800
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2015-12-03 16:21:31.118920390 -0800
@@ -383,3 +383,4 @@
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
+377	i386	pkey_mprotect		sys_pkey_mprotect
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.111920072 -0800
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2015-12-03 16:21:31.118920390 -0800
@@ -332,6 +332,7 @@
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
+326	common	pkey_mprotect		sys_pkey_mprotect
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.113920163 -0800
+++ b/arch/x86/include/uapi/asm/mman.h	2015-12-03 16:21:31.118920390 -0800
@@ -20,6 +20,12 @@
 		((vm_flags) & VM_PKEY_BIT1 ? _PAGE_PKEY_BIT1 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT2 ? _PAGE_PKEY_BIT2 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT3 ? _PAGE_PKEY_BIT3 : 0))
+
+#define arch_calc_vm_prot_bits(prot, key) (		\
+		((key) & 0x1 ? VM_PKEY_BIT0 : 0) |      \
+		((key) & 0x2 ? VM_PKEY_BIT1 : 0) |      \
+		((key) & 0x4 ? VM_PKEY_BIT2 : 0) |      \
+		((key) & 0x8 ? VM_PKEY_BIT3 : 0))
 #endif
 
 #include <asm-generic/mman.h>
diff -puN mm/Kconfig~pkeys-16-x86-mprotect_key mm/Kconfig
--- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.114920208 -0800
+++ b/mm/Kconfig	2015-12-03 16:21:31.119920435 -0800
@@ -679,4 +679,5 @@ config NR_PROTECTION_KEYS
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
