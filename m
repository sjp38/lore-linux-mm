Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39AED6B02F4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 17:28:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p135so36110454qke.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 14:28:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f17si4202608qkh.507.2017.08.09.14.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 14:28:26 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v7 8/9] mm: Clear arch specific VM flags on protection change
Date: Wed,  9 Aug 2017 15:26:01 -0600
Message-Id: <8474c263daa5c8f7c72eb24dda0014bacb11f81c.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, mhocko@suse.com, davem@davemloft.net, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, lstoakes@gmail.com, dave.jiang@intel.com, willy@infradead.org, hughd@google.com, ying.huang@intel.com, tglx@linutronix.de, mgorman@suse.de, aarcange@redhat.com, ak@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

When protection bits are changed on a VMA, some of the architecture
specific flags should be cleared as well. An examples of this are the
PKEY flags on x86.  This patch expands the current code that clears PKEY
flags for x86, to support similar functionality for other architectures
as well.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v7:
	- new patch

 include/linux/mm.h | 6 ++++++
 mm/mprotect.c      | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6f543a47fc92..b7aa3932e6d4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -271,6 +271,12 @@ extern unsigned int kobjsize(const void *objp);
 /* This mask is used to clear all the VMA flags used by mlock */
 #define VM_LOCKED_CLEAR_MASK	(~(VM_LOCKED | VM_LOCKONFAULT))
 
+/* Arch-specific flags to clear when updating VM flags on protection change */
+#ifndef VM_ARCH_CLEAR
+# define VM_ARCH_CLEAR	VM_NONE
+#endif
+#define VM_FLAGS_CLEAR	(ARCH_VM_PKEY_FLAGS | VM_ARCH_CLEAR)
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
diff --git a/mm/mprotect.c b/mm/mprotect.c
index beac2dfbb5fa..b1ec9902dcd6 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -454,7 +454,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		 * cleared from the VMA.
 		 */
 		mask_off_old_flags = VM_READ | VM_WRITE | VM_EXEC |
-					ARCH_VM_PKEY_FLAGS;
+					VM_FLAGS_CLEAR;
 
 		new_vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
 		newflags = calc_vm_prot_bits(prot, new_vma_pkey);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
