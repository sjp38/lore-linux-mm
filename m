Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1CB6B0007
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 13:02:31 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y84so13590714qkb.16
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 10:02:31 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w68si128980qkc.143.2018.02.01.10.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 10:02:30 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v11 08/10] mm: Clear arch specific VM flags on protection change
Date: Thu,  1 Feb 2018 11:01:16 -0700
Message-Id: <c917985f8eacf4647a135df1b223739ef62a5501.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, willy@infradead.org, hughd@google.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, jglisse@redhat.com, dave.jiang@intel.com, dan.j.williams@intel.com, anthony.yznaga@oracle.com, nadav.amit@gmail.com, zi.yan@cs.rutgers.edu, aarcange@redhat.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

When protection bits are changed on a VMA, some of the architecture
specific flags should be cleared as well. An examples of this are the
PKEY flags on x86. This patch expands the current code that clears
PKEY flags for x86, to support similar functionality for other
architectures as well.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
---
v7:
	- new patch

 include/linux/mm.h | 6 ++++++
 mm/mprotect.c      | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..1931c93fb063 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -287,6 +287,12 @@ extern unsigned int kobjsize(const void *objp);
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
index 80243e0166a7..8b24b9fa2f4f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -470,7 +470,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
