Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43A426B026B
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:50:54 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215676404pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:50:54 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ds2si26230965pbb.16.2015.09.16.10.50.48
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:50:48 -0700 (PDT)
Subject: [PATCH 22/26] [HIJACKPROT] mm: Pass the 4-bit protection key in via PROT_ bits to syscalls
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:11 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174911.CAF51C0E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


If a system call takes a PROT_{NONE,EXEC,WRITE,...} argument,
this adds support to it to take a protection key.

	mmap()
	mrprotect()
	drivers/char/agp/frontend.c's ioctl(AGPIOC_RESERVE)

This does not include direct support for shmat() since it uses
a different set of permission bits.  You can use mprotect()
after the attach to assign an attched SHM segment a protection
key.

---

 b/arch/x86/include/uapi/asm/mman.h       |    6 ++++++
 b/include/uapi/asm-generic/mman-common.h |    4 ++++
 2 files changed, 10 insertions(+)

diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-80-user-abi-bits arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-80-user-abi-bits	2015-09-16 09:45:54.123412488 -0700
+++ b/arch/x86/include/uapi/asm/mman.h	2015-09-16 09:45:54.129412761 -0700
@@ -20,6 +20,12 @@
 		((vm_flags) & VM_PKEY_BIT1 ? _PAGE_PKEY_BIT1 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT2 ? _PAGE_PKEY_BIT2 : 0) |	\
 		((vm_flags) & VM_PKEY_BIT3 ? _PAGE_PKEY_BIT3 : 0))
+
+#define arch_calc_vm_prot_bits(prot) (	\
+		((prot) & PROT_PKEY0 ? VM_PKEY_BIT0 : 0) |	\
+		((prot) & PROT_PKEY1 ? VM_PKEY_BIT1 : 0) |	\
+		((prot) & PROT_PKEY2 ? VM_PKEY_BIT2 : 0) |	\
+		((prot) & PROT_PKEY3 ? VM_PKEY_BIT3 : 0))
 #endif
 
 #include <asm-generic/mman.h>
diff -puN include/uapi/asm-generic/mman-common.h~pkeys-80-user-abi-bits include/uapi/asm-generic/mman-common.h
--- a/include/uapi/asm-generic/mman-common.h~pkeys-80-user-abi-bits	2015-09-16 09:45:54.125412579 -0700
+++ b/include/uapi/asm-generic/mman-common.h	2015-09-16 09:45:54.128412715 -0700
@@ -10,6 +10,10 @@
 #define PROT_WRITE	0x2		/* page can be written */
 #define PROT_EXEC	0x4		/* page can be executed */
 #define PROT_SEM	0x8		/* page may be used for atomic ops */
+#define PROT_PKEY0	0x10		/* protection key value (bit 0) */
+#define PROT_PKEY1	0x20		/* protection key value (bit 1) */
+#define PROT_PKEY2	0x40		/* protection key value (bit 2) */
+#define PROT_PKEY3	0x80		/* protection key value (bit 3) */
 #define PROT_NONE	0x0		/* page can not be accessed */
 #define PROT_GROWSDOWN	0x01000000	/* mprotect flag: extend change to start of growsdown vma */
 #define PROT_GROWSUP	0x02000000	/* mprotect flag: extend change to end of growsup vma */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
