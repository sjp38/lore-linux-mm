Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 667236B0639
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h15so57260511qte.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:24 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id p8si2802572qkh.213.2017.07.15.20.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:23 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id j25so997908qtf.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:23 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 09/62] powerpc: use helper functions in __hash_page_4K() for 4K PTE
Date: Sat, 15 Jul 2017 20:56:11 -0700
Message-Id: <1500177424-13695-10-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

replace redundant code with helper functions
pte_get_hash_gslot() and pte_set_hash_slot()

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/hash64_4k.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/mm/hash64_4k.c b/arch/powerpc/mm/hash64_4k.c
index 6fa450c..a1eebc1 100644
--- a/arch/powerpc/mm/hash64_4k.c
+++ b/arch/powerpc/mm/hash64_4k.c
@@ -20,6 +20,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		   pte_t *ptep, unsigned long trap, unsigned long flags,
 		   int ssize, int subpg_prot)
 {
+	real_pte_t rpte;
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
 	unsigned long old_pte, new_pte;
@@ -54,6 +55,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	 * need to add in 0x1 if it's a read-only user page
 	 */
 	rflags = htab_convert_pte_flags(new_pte);
+	rpte = __real_pte(__pte(old_pte), ptep);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
@@ -64,13 +66,10 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		/*
 		 * There MIGHT be an HPTE for this pte
 		 */
-		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & H_PAGE_F_SECOND)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
+		unsigned long gslot = pte_get_hash_gslot(vpn, shift,
+						ssize, rpte, 0);
 
-		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_4K,
+		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, MMU_PAGE_4K,
 					       MMU_PAGE_4K, ssize, flags) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
 	}
@@ -118,8 +117,7 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 			return -1;
 		}
 		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
-		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
-			(H_PAGE_F_SECOND | H_PAGE_F_GIX);
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
