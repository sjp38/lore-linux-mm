Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC4826B0636
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a195so59174737qkb.13
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:16 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id v13si11822576qtg.294.2017.07.15.20.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:16 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id m54so14727655qtb.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:16 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 06/62] powerpc: use helper functions in __hash_page_64K() for 64K PTE
Date: Sat, 15 Jul 2017 20:56:08 -0700
Message-Id: <1500177424-13695-7-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

replace redundant code in __hash_page_64K() with helper
functions pte_get_hash_gslot() and pte_set_hash_slot()

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/hash64_64k.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 0012618..645f621 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -244,7 +244,6 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		    unsigned long flags, int ssize)
 {
 	real_pte_t rpte;
-	unsigned long *hidxp;
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
 	unsigned long old_pte, new_pte;
@@ -289,18 +288,12 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 
 	vpn  = hpt_vpn(ea, vsid, ssize);
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
-		unsigned long hash, slot, hidx;
-
-		hash = hpt_hash(vpn, shift, ssize);
-		hidx = __rpte_to_hidx(rpte, 0);
-		if (hidx & _PTEIDX_SECONDARY)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+		unsigned long gslot;
 		/*
 		 * There MIGHT be an HPTE for this pte
 		 */
-		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_64K,
+		gslot = pte_get_hash_gslot(vpn, shift, ssize, rpte, 0);
+		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, MMU_PAGE_64K,
 					       MMU_PAGE_64K, ssize,
 					       flags) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
@@ -350,17 +343,8 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 			return -1;
 		}
 
-		/*
-		 * Insert slot number & secondary bit in PTE second half.
-		 */
-		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
-		rpte.hidx &= ~(0xfUL);
-		*hidxp = rpte.hidx  | (slot & 0xfUL);
-		/*
-		 * check __real_pte for details on matching smp_rmb()
-		 */
-		smp_wmb();
 		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
+		new_pte |= pte_set_hash_slot(ptep, rpte, 0, slot);
 	}
 	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
