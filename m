Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 849A86B03D0
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:22:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n43so571717qtc.13
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:46 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id 25si44847qky.318.2017.07.05.14.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:22:45 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id p21so203582qke.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:45 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 07/38] powerpc: use helper functions in __hash_page_huge() for 64K PTE
Date: Wed,  5 Jul 2017 14:21:44 -0700
Message-Id: <1499289735-14220-8-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

replace redundant code in __hash_page_huge() with helper
functions pte_get_hash_gslot() and pte_set_hash_slot()

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/hugetlbpage-hash64.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 6f7aee3..e6dcd50 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -23,7 +23,6 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     int ssize, unsigned int shift, unsigned int mmu_psize)
 {
 	real_pte_t rpte;
-	unsigned long *hidxp;
 	unsigned long vpn;
 	unsigned long old_pte, new_pte;
 	unsigned long rflags, pa, sz;
@@ -74,16 +73,10 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	/* Check if pte already has an hpte (case 2) */
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/* There MIGHT be an HPTE for this pte */
-		unsigned long hash, slot, hidx;
+		unsigned long gslot;
 
-		hash = hpt_hash(vpn, shift, ssize);
-		hidx = __rpte_to_hidx(rpte, 0);
-		if (hidx & _PTEIDX_SECONDARY)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
-
-		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, mmu_psize,
+		gslot = pte_get_hash_gslot(vpn, shift, ssize, rpte, 0);
+		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, mmu_psize,
 					       mmu_psize, ssize, flags) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
 	}
@@ -110,16 +103,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
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
+		new_pte |= pte_set_hash_slot(ptep, rpte, 0, slot);
 	}
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
