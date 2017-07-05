Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFF416B03D1
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:22:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h47so580718qta.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:48 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id b187si38204qkd.256.2017.07.05.14.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:22:48 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id 16so186593qkg.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:48 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 08/38] powerpc: use helper functions in __hash_page_4K() for 64K PTE
Date: Wed,  5 Jul 2017 14:21:45 -0700
Message-Id: <1499289735-14220-9-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

replace redundant code in __hash_page_4K() with helper
functions pte_get_hash_gslot() and pte_set_hash_slot()

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/hash64_64k.c |   34 +++++++++-------------------------
 1 files changed, 9 insertions(+), 25 deletions(-)

diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 645f621..c658cb5 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -39,9 +39,8 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 {
 	real_pte_t rpte;
 	unsigned long hpte_group;
-	unsigned long *hidxp;
 	unsigned int subpg_index;
-	unsigned long rflags, pa, hidx;
+	unsigned long rflags, pa;
 	unsigned long old_pte, new_pte, subpg_pte;
 	unsigned long vpn, hash, slot, gslot;
 	unsigned long shift = mmu_psize_defs[MMU_PAGE_4K].shift;
@@ -114,18 +113,13 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	if (__rpte_sub_valid(rpte, subpg_index)) {
 		int ret;
 
-		hash = hpt_hash(vpn, shift, ssize);
-		hidx = __rpte_to_hidx(rpte, subpg_index);
-		if (hidx & _PTEIDX_SECONDARY)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
-
-		ret = mmu_hash_ops.hpte_updatepp(slot, rflags, vpn,
+		gslot = pte_get_hash_gslot(vpn, shift, ssize, rpte,
+				subpg_index);
+		ret = mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn,
 						 MMU_PAGE_4K, MMU_PAGE_4K,
 						 ssize, flags);
 		/*
-		 *if we failed because typically the HPTE wasn't really here
+		 * if we failed because typically the HPTE wasn't really here
 		 * we try an insertion.
 		 */
 		if (ret == -1)
@@ -221,20 +215,10 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 				   MMU_PAGE_4K, MMU_PAGE_4K, old_pte);
 		return -1;
 	}
-	/*
-	 * Insert slot number & secondary bit in PTE second half,
-	 * clear H_PAGE_BUSY and set appropriate HPTE slot bit
-	 * Since we have H_PAGE_BUSY set on ptep, we can be sure
-	 * nobody is undating hidx.
-	 */
-	hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
-	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
-	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
-	/*
-	 * check __real_pte for details on matching smp_rmb()
-	 */
-	smp_wmb();
-	new_pte |=  H_PAGE_HASHPTE;
+
+	new_pte |= pte_set_hash_slot(ptep, rpte, subpg_index, slot);
+	new_pte |= H_PAGE_HASHPTE;
+
 	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
