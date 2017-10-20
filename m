Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA7DA6B0260
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:59:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k123so11219942qke.10
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:59:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w21si1097175qtk.212.2017.10.20.09.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 09:59:11 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v8 08/10] mm: Clear arch specific VM flags on protection change
Date: Fri, 20 Oct 2017 10:58:01 -0600
Message-Id: <3ae25964cdf6f3638ddf72268377736b0b03e8c2.1508364660.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1508364660.git.khalid.aziz@oracle.com>
References: <cover.1508364660.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1508364660.git.khalid.aziz@oracle.com>
References: <cover.1508364660.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, mhocko@suse.com, davem@davemloft.net, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, lstoakes@gmail.com, dave.jiang@intel.com, willy@infradead.org, hughd@google.com, ying.huang@intel.com, n-horiguchi@ah.jp.nec.com, heiko.carstens@de.ibm.com, mgorman@suse.de, aarcange@redhat.com, ak@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

When protection bits are changed on a VMA, some of the architecture
specific flags should be cleared as well. An examples of this are the
PKEY flags on x86. This patch expands the current code that clears
PKEY flags for x86, to support similar functionality for other
architectures as well.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v7:
	- new patch

 include/linux/mm.h | 6 ++++++
 mm/mprotect.c      | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1f6c95f3496..cbb21facce6b 100644
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
index 4f0e46bb1797..85b65b3a823d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -453,7 +453,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
