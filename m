Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E4F216B0277
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:48 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so108039782pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 1si18742744pfc.3.2015.12.14.11.06.31
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:32 -0800 (PST)
Subject: [PATCH 30/32] x86, pkeys: create an x86 arch_calc_vm_prot_bits() for VMA flags
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:31 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190631.049133CC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

calc_vm_prot_bits() takes PROT_{READ,WRITE,EXECUTE} bits and
turns them in to the vma->vm_flags/VM_* bits.  We need to do a
similar thing for protection keys.

We take a protection key (4 bits) and encode it in to the 4
VM_PKEY_* bits.

Note: this code is not new.  It was simply a part of the
mprotect_pkey() patch in the past.  I broke it out for use
in the execute-only support.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/uapi/asm/mman.h |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-78-arch_calc_vm_prot_bits arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-78-arch_calc_vm_prot_bits	2015-12-14 10:42:52.450235349 -0800
+++ b/arch/x86/include/uapi/asm/mman.h	2015-12-14 10:42:52.453235484 -0800
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
