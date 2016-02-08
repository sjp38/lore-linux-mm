Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id B300C8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:00 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wb13so146200672obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:00 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id sc8si15281159obb.67.2016.02.08.01.20.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:00 -0800 (PST)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:20:59 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id F12073E40047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:20:56 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189KuQa27328672
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:20:56 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189Ks0V015554
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:20:56 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 01/29] powerpc/mm: add _PAGE_HASHPTE similar to 4K hash
Date: Mon,  8 Feb 2016 14:50:13 +0530
Message-Id: <1454923241-6681-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Not really needed. But this brings it back to as it was before

Check this
41743a4e34f0777f51c1cf0675b91508ba143050

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash64_64k.c         | 4 ++--
 arch/powerpc/mm/hugepage-hash64.c    | 2 +-
 arch/powerpc/mm/hugetlbpage-hash64.c | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 0762c1e08c88..3c417f9099f9 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -76,7 +76,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * a write access. Since this is 4K insert of 64K page size
 		 * also add _PAGE_COMBO
 		 */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_COMBO;
+		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_COMBO | _PAGE_HASHPTE;
 		if (access & _PAGE_RW)
 			new_pte |= _PAGE_DIRTY;
 	} while (old_pte != __cmpxchg_u64((unsigned long *)ptep,
@@ -246,7 +246,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		 * a write access. Since this is 4K insert of 64K page size
 		 * also add _PAGE_COMBO
 		 */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED;
+		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
 		if (access & _PAGE_RW)
 			new_pte |= _PAGE_DIRTY;
 	} while (old_pte != __cmpxchg_u64((unsigned long *)ptep,
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index 49b152b0f926..3c4bd4c0ade9 100644
--- a/arch/powerpc/mm/hugepage-hash64.c
+++ b/arch/powerpc/mm/hugepage-hash64.c
@@ -46,7 +46,7 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * Try to lock the PTE, add ACCESSED and DIRTY if it was
 		 * a write access
 		 */
-		new_pmd = old_pmd | _PAGE_BUSY | _PAGE_ACCESSED;
+		new_pmd = old_pmd | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
 		if (access & _PAGE_RW)
 			new_pmd |= _PAGE_DIRTY;
 	} while (old_pmd != __cmpxchg_u64((unsigned long *)pmdp,
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index e2138c7ae70f..9c224b012d62 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -54,7 +54,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 			return 1;
 		/* Try to lock the PTE, add ACCESSED and DIRTY if it was
 		 * a write access */
-		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED;
+		new_pte = old_pte | _PAGE_BUSY | _PAGE_ACCESSED | _PAGE_HASHPTE;
 		if (access & _PAGE_RW)
 			new_pte |= _PAGE_DIRTY;
 	} while(old_pte != __cmpxchg_u64((unsigned long *)ptep,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
