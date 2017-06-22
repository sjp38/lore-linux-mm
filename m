Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 966996B02FA
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:40:01 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d4so1149473qte.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:01 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id j81si65423qke.146.2017.06.21.18.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:40:00 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id d14so365978qkb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:00 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 04/23] powerpc: Free up four 64K PTE bits in 64K backed HPTE pages
Date: Wed, 21 Jun 2017 18:39:20 -0700
Message-Id: <1498095579-6790-5-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6
in the 64K backed HPTE pages. This along with the earlier
patch will entirely free up the four bits from 64K PTE.
The bit numbers are big-endian as defined in the ISA3.0

This patch does the following change to 64K PTE that is
backed by 64K HPTE.

H_PAGE_F_SECOND which occupied bit 4 moves to the second part
        of the pte.
H_PAGE_F_GIX which  occupied bit 5, 6 and 7 also moves to the
        second part of the pte.

since bit 7 is now freed up, we move H_PAGE_BUSY from bit 9
to bit 7. Trying to minimize gaps so that contiguous bits
can be allocated if needed in the future.

The second part of the PTE will hold
(H_PAGE_F_SECOND|H_PAGE_F_GIX) at bit 60,61,62,63.

The above PTE changes is applicable to hugetlbpages aswell.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-64k.h | 28 +++++++++------------------
 arch/powerpc/mm/hash64_64k.c                  | 17 ++++++++--------
 arch/powerpc/mm/hugetlbpage-hash64.c          | 16 ++++++---------
 3 files changed, 23 insertions(+), 38 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 4bac70a..7b5dbf3 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -12,11 +12,8 @@
  */
 #define H_PAGE_COMBO   _RPAGE_RPN0 /* this is a combo 4k page */
 #define H_PAGE_4K_PFN  _RPAGE_RPN1 /* PFN is for a single 4k page */
-#define H_PAGE_F_SECOND	_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
-#define H_PAGE_F_GIX	(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
-#define H_PAGE_F_GIX_SHIFT	56
 
-#define H_PAGE_BUSY	_RPAGE_RPN42     /* software: PTE & hash are busy */
+#define H_PAGE_BUSY	_RPAGE_RPN44     /* software: PTE & hash are busy */
 #define H_PAGE_HASHPTE	_RPAGE_RPN43    /* PTE has associated HPTE */
 
 /*
@@ -26,8 +23,7 @@
 #define H_PAGE_THP_HUGE  H_PAGE_4K_PFN
 
 /* PTE flags to conserve for HPTE identification */
-#define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_F_SECOND | \
-			 H_PAGE_F_GIX | H_PAGE_HASHPTE | H_PAGE_COMBO)
+#define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_HASHPTE | H_PAGE_COMBO)
 /*
  * we support 16 fragments per PTE page of 64K size.
  */
@@ -55,24 +51,18 @@ static inline real_pte_t __real_pte(pte_t pte, pte_t *ptep)
 	unsigned long *hidxp;
 
 	rpte.pte = pte;
-	rpte.hidx = 0;
-	if (pte_val(pte) & H_PAGE_COMBO) {
-		/*
-		 * Make sure we order the hidx load against the H_PAGE_COMBO
-		 * check. The store side ordering is done in __hash_page_4K
-		 */
-		smp_rmb();
-		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
-		rpte.hidx = *hidxp;
-	}
+	/*
+	 * The store side ordering is done in set_hidx_slot()
+	 */
+	smp_rmb();
+	hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+	rpte.hidx = *hidxp;
 	return rpte;
 }
 
 static inline unsigned long __rpte_to_hidx(real_pte_t rpte, unsigned long index)
 {
-	if ((pte_val(rpte.pte) & H_PAGE_COMBO))
-		return (rpte.hidx >> (index<<2)) & 0xf;
-	return (pte_val(rpte.pte) >> H_PAGE_F_GIX_SHIFT) & 0xf;
+	return ((rpte.hidx >> (index<<2)) & 0xfUL);
 }
 
 static inline unsigned long set_hidx_slot(pte_t *ptep, real_pte_t rpte,
diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index a16cd28..5cbdaa9 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -231,6 +231,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		    unsigned long vsid, pte_t *ptep, unsigned long trap,
 		    unsigned long flags, int ssize)
 {
+	real_pte_t rpte;
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
 	unsigned long old_pte, new_pte;
@@ -267,6 +268,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 	} while (!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
 	rflags = htab_convert_pte_flags(new_pte);
+	rpte = __real_pte(__pte(old_pte), ptep);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
@@ -274,16 +276,13 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 
 	vpn  = hpt_vpn(ea, vsid, ssize);
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
+		unsigned long gslot;
+
 		/*
 		 * There MIGHT be an HPTE for this pte
 		 */
-		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & H_PAGE_F_SECOND)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
-
-		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_64K,
+		gslot = get_hidx_gslot(vpn, shift, ssize, rpte, 0);
+		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, MMU_PAGE_64K,
 					       MMU_PAGE_64K, ssize,
 					       flags) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
@@ -332,9 +331,9 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 					   MMU_PAGE_64K, MMU_PAGE_64K, old_pte);
 			return -1;
 		}
+
 		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
-		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
-			(H_PAGE_F_SECOND | H_PAGE_F_GIX);
+		new_pte |= set_hidx_slot(ptep, rpte, 0, slot);
 	}
 	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index a84bb44..239ca86 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -22,6 +22,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     pte_t *ptep, unsigned long trap, unsigned long flags,
 		     int ssize, unsigned int shift, unsigned int mmu_psize)
 {
+	real_pte_t rpte;
 	unsigned long vpn;
 	unsigned long old_pte, new_pte;
 	unsigned long rflags, pa, sz;
@@ -61,6 +62,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	} while(!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
 	rflags = htab_convert_pte_flags(new_pte);
+	rpte = __real_pte(__pte(old_pte), ptep);
 
 	sz = ((1UL) << shift);
 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
@@ -71,15 +73,10 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	/* Check if pte already has an hpte (case 2) */
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/* There MIGHT be an HPTE for this pte */
-		unsigned long hash, slot;
+		unsigned long gslot;
 
-		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & H_PAGE_F_SECOND)
-			hash = ~hash;
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
-
-		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, mmu_psize,
+		gslot = get_hidx_gslot(vpn, shift, ssize, rpte, 0);
+		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, mmu_psize,
 					       mmu_psize, ssize, flags) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
 	}
@@ -106,8 +103,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 			return -1;
 		}
 
-		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
-			(H_PAGE_F_SECOND | H_PAGE_F_GIX);
+		new_pte |= set_hidx_slot(ptep, rpte, 0, slot);
 	}
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
