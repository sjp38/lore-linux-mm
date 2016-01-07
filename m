Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id ED3946B0025
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:02:13 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id ik10so43615933igb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:02:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id a19si16683966igr.75.2016.01.06.16.01.47
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:47 -0800 (PST)
Subject: [PATCH 30/31] x86, pkeys: create an x86 arch_calc_vm_prot_bits() for VMA flags
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:46 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000146.EB87C6BA@viggo.jf.intel.com>
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
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-78-arch_calc_vm_prot_bits	2016-01-06 15:50:16.387641877 -0800
+++ b/arch/x86/include/uapi/asm/mman.h	2016-01-06 15:50:16.390642013 -0800
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
