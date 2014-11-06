Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id AE5226B00C0
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 12:49:15 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id t59so1598155yho.8
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 09:49:15 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id f21si6781336yhf.11.2014.11.06.09.49.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 09:49:14 -0800 (PST)
From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH RFC] x86,mm: use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA
Date: Thu, 6 Nov 2014 17:48:16 +0000
Message-ID: <1415296096-22873-1-git-send-email-wei.liu2@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: Wei Liu <wei.liu2@citrix.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

In b38af4721 ("x86,mm: fix pte_special versus pte_numa") pte_special()
(SPECIAL with PRESENT or PROTNONE) was made to complement pte_numa()
(SPECIAL with neither PRESENT nor PROTNONE). That broke Xen PV guest
with NUMA balancing support.

That's because Xen hypervisor sets _PAGE_GLOBAL (_PAGE_GLOBAL /
_PAGE_PROTNONE in Linux) for guest user space mapping. So in a Xen PV
guest, when NUMA balancing is enabled, a NUMA hinted PTE ends up
"SPECIAL (in fact NUMA) with PROTNONE but not PRESENT", which makes
pte_special() returns true when it shouldn't.

Fundamentally we only need _PAGE_NUMA and _PAGE_PRESENT to tell
difference between an unmapped entry and an entry protected for NUMA
hinting fault. So use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA, adjust
_PAGE_NUMA_MASK and SWP_OFFSET_SHIFT as needed.

Suggested-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org
---
 arch/x86/include/asm/pgtable.h       |    5 -----
 arch/x86/include/asm/pgtable_64.h    |    2 +-
 arch/x86/include/asm/pgtable_types.h |    8 ++++----
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index aa97a07..8dee3ed 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -131,11 +131,6 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	/*
-	 * See CONFIG_NUMA_BALANCING pte_numa in include/asm-generic/pgtable.h.
-	 * On x86 we have _PAGE_BIT_NUMA == _PAGE_BIT_GLOBAL+1 ==
-	 * __PAGE_BIT_SOFTW1 == _PAGE_BIT_SPECIAL.
-	 */
 	return (pte_flags(pte) & _PAGE_SPECIAL) &&
 		(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_PROTNONE));
 }
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 4572b2f..26f2ade 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -148,7 +148,7 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
 #ifdef CONFIG_NUMA_BALANCING
 /* Automatic NUMA balancing needs to be distinguishable from swap entries */
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
+#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 3)
 #else
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
 #endif
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 0778964..bc82d6b 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -31,9 +31,9 @@
  * Swap offsets on configurations that allow automatic NUMA balancing use the
  * bits after _PAGE_BIT_GLOBAL. To uniquely distinguish NUMA hinting PTEs from
  * swap entries, we use the first bit after _PAGE_BIT_GLOBAL and shrink the
- * maximum possible swap space from 16TB to 8TB.
+ * maximum possible swap space from 16TB to 4TB.
  */
-#define _PAGE_BIT_NUMA		(_PAGE_BIT_GLOBAL+1)
+#define _PAGE_BIT_NUMA		_PAGE_BIT_SOFTW2
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -325,8 +325,8 @@ static inline pteval_t pte_flags(pte_t pte)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-/* Set of bits that distinguishes present, prot_none and numa ptes */
-#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)
+/* Set of bits that distinguishes present and numa ptes */
+#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PRESENT)
 static inline pteval_t ptenuma_flags(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_NUMA_MASK;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
