Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA94F6B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:22:25 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id x22so1214378uaj.12
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:22:25 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y184si3980380vke.119.2018.02.21.09.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:22:24 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v12 08/11] mm: Clear arch specific VM flags on protection change
Date: Wed, 21 Feb 2018 10:15:50 -0700
Message-Id: <f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, willy@infradead.org, hughd@google.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, jglisse@redhat.com, dave.jiang@intel.com, dan.j.williams@intel.com, anthony.yznaga@oracle.com, nadav.amit@gmail.com, zi.yan@cs.rutgers.edu, aarcange@redhat.com, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, henry.willard@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

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
index ad06d42adb1a..ae806dbc63ee 100644
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
index 088ea9c08678..c1d6af7455da 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -475,7 +475,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
