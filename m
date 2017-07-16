Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3E76B0632
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h15so57259042qte.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:07 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id u66si11870687qkd.138.2017.07.15.20.58.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:05 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id j25so997619qtf.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:05 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 02/62] powerpc: Free up four 64K PTE bits in 64K backed HPTE pages
Date: Sat, 15 Jul 2017 20:56:04 -0700
Message-Id: <1500177424-13695-3-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6
in the 64K backed HPTE pages. This along with the earlier
patch will  entirely free  up the four bits from 64K PTE.
The bit numbers are  big-endian as defined in the  ISA3.0

This patch  does  the  following change to 64K PTE backed
by 64K HPTE.

H_PAGE_F_SECOND (S) which  occupied  bit  4  moves to the
	second part of the pte to bit 60.
H_PAGE_F_GIX (G,I,X) which  occupied  bit 5, 6 and 7 also
	moves  to  the   second part of the pte to bit 61,
       	62, 63, 64 respectively

since bit 7 is now freed up, we move H_PAGE_BUSY (B) from
bit  9  to  bit  7.

The second part of the PTE will hold
(H_PAGE_F_SECOND|H_PAGE_F_GIX) at bit 60,61,62,63.
NOTE: None of the bits in the secondary PTE were not used
by 64k-HPTE backed PTE.

Before the patch, the 64K HPTE backed 64k PTE format was
as follows

 0 1 2 3 4  5  6  7  8 9 10...........................63
 : : : : :  :  :  :  : : :                            :
 v v v v v  v  v  v  v v v                            v

,-,-,-,-,--,--,--,--,-,-,-,-,-,------------------,-,-,-,
|x|x|x| |S |G |I |X |x|B| |x|x|................|x|x|x|x| <- primary pte
'_'_'_'_'__'__'__'__'_'_'_'_'_'________________'_'_'_'_'
| | | | |  |  |  |  | | | | |..................| | | | | <- secondary pte
'_'_'_'_'__'__'__'__'_'_'_'_'__________________'_'_'_'_'

After the patch, the 64k HPTE backed 64k PTE format is
as follows

 0 1 2 3 4  5  6  7  8 9 10...........................63
 : : : : :  :  :  :  : : :                            :
 v v v v v  v  v  v  v v v                            v

,-,-,-,-,--,--,--,--,-,-,-,-,-,------------------,-,-,-,
|x|x|x| |  |  |  |B |x| | |x|x|................|.|.|.|.| <- primary pte
'_'_'_'_'__'__'__'__'_'_'_'_'_'________________'_'_'_'_'
| | | | |  |  |  |  | | | | |..................|S|G|I|X| <- secondary pte
'_'_'_'_'__'__'__'__'_'_'_'_'__________________'_'_'_'_'

The above PTE changes is applicable to hugetlbpages aswell.

The patch does the following code changes:

a) moves  the  H_PAGE_F_SECOND and  H_PAGE_F_GIX to 4k PTE
	header   since it is no more needed b the 64k PTEs.
b) abstracts  out __real_pte() and __rpte_to_hidx() so the
	caller  need not know the bit location of the slot.
c) moves the slot bits the secondary pte.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |    3 ++
 arch/powerpc/include/asm/book3s/64/hash-64k.h |   29 ++++++++++-------------
 arch/powerpc/include/asm/book3s/64/hash.h     |    3 --
 arch/powerpc/mm/hash64_64k.c                  |   30 ++++++++++++++++++------
 arch/powerpc/mm/hugetlbpage-hash64.c          |   22 ++++++++++++++----
 5 files changed, 55 insertions(+), 32 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index f959c00..d2cf949 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -16,6 +16,9 @@
 #define H_PUD_TABLE_SIZE	(sizeof(pud_t) << H_PUD_INDEX_SIZE)
 #define H_PGD_TABLE_SIZE	(sizeof(pgd_t) << H_PGD_INDEX_SIZE)
 
+#define H_PAGE_F_GIX_SHIFT	56
+#define H_PAGE_F_SECOND	_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
+#define H_PAGE_F_GIX	(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
 #define H_PAGE_BUSY	_RPAGE_RSV1     /* software: PTE & hash are busy */
 
 /* PTE flags to conserve for HPTE identification */
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 62e580c..c281f18 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -12,7 +12,7 @@
  */
 #define H_PAGE_COMBO	_RPAGE_RPN0 /* this is a combo 4k page */
 #define H_PAGE_4K_PFN	_RPAGE_RPN1 /* PFN is for a single 4k page */
-#define H_PAGE_BUSY	_RPAGE_RPN42     /* software: PTE & hash are busy */
+#define H_PAGE_BUSY	_RPAGE_RPN44     /* software: PTE & hash are busy */
 
 /*
  * We need to differentiate between explicit huge page and THP huge
@@ -21,8 +21,7 @@
 #define H_PAGE_THP_HUGE  H_PAGE_4K_PFN
 
 /* PTE flags to conserve for HPTE identification */
-#define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_F_SECOND | \
-			 H_PAGE_F_GIX | H_PAGE_HASHPTE | H_PAGE_COMBO)
+#define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_HASHPTE | H_PAGE_COMBO)
 /*
  * we support 16 fragments per PTE page of 64K size.
  */
@@ -50,24 +49,22 @@ static inline real_pte_t __real_pte(pte_t pte, pte_t *ptep)
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
+	 * Ensure that we do not read the hidx before we read
+	 * the pte. Because the writer side is  expected
+	 * to finish writing the hidx first followed by the pte,
+	 * by using smp_wmb().
+	 * pte_set_hash_slot() ensures that.
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
 
 #define __rpte_to_pte(r)	((r).pte)
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 2d72964..d27f885 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -8,9 +8,6 @@
  *
  */
 #define H_PTE_NONE_MASK		_PAGE_HPTEFLAGS
-#define H_PAGE_F_GIX_SHIFT	56
-#define H_PAGE_F_SECOND		_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
-#define H_PAGE_F_GIX		(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
 #define H_PAGE_HASHPTE		_RPAGE_RPN43	/* PTE has associated HPTE */
 
 #ifdef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index e573bd3..0012618 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -243,6 +243,8 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 		    unsigned long vsid, pte_t *ptep, unsigned long trap,
 		    unsigned long flags, int ssize)
 {
+	real_pte_t rpte;
+	unsigned long *hidxp;
 	unsigned long hpte_group;
 	unsigned long rflags, pa;
 	unsigned long old_pte, new_pte;
@@ -279,6 +281,7 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 	} while (!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
 	rflags = htab_convert_pte_flags(new_pte);
+	rpte = __real_pte(__pte(old_pte), ptep);
 
 	if (cpu_has_feature(CPU_FTR_NOEXECUTE) &&
 	    !cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
@@ -286,15 +289,17 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 
 	vpn  = hpt_vpn(ea, vsid, ssize);
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
-		/*
-		 * There MIGHT be an HPTE for this pte
-		 */
+		unsigned long hash, slot, hidx;
+
 		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & H_PAGE_F_SECOND)
+		hidx = __rpte_to_hidx(rpte, 0);
+		if (hidx & _PTEIDX_SECONDARY)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
-
+		slot += hidx & _PTEIDX_GROUP_IX;
+		/*
+		 * There MIGHT be an HPTE for this pte
+		 */
 		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_64K,
 					       MMU_PAGE_64K, ssize,
 					       flags) == -1)
@@ -344,9 +349,18 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
 					   MMU_PAGE_64K, MMU_PAGE_64K, old_pte);
 			return -1;
 		}
+
+		/*
+		 * Insert slot number & secondary bit in PTE second half.
+		 */
+		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+		rpte.hidx &= ~(0xfUL);
+		*hidxp = rpte.hidx  | (slot & 0xfUL);
+		/*
+		 * check __real_pte for details on matching smp_rmb()
+		 */
+		smp_wmb();
 		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
-		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
-			(H_PAGE_F_SECOND | H_PAGE_F_GIX);
 	}
 	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index a84bb44..6f7aee3 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -22,6 +22,8 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     pte_t *ptep, unsigned long trap, unsigned long flags,
 		     int ssize, unsigned int shift, unsigned int mmu_psize)
 {
+	real_pte_t rpte;
+	unsigned long *hidxp;
 	unsigned long vpn;
 	unsigned long old_pte, new_pte;
 	unsigned long rflags, pa, sz;
@@ -61,6 +63,7 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	} while(!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
 
 	rflags = htab_convert_pte_flags(new_pte);
+	rpte = __real_pte(__pte(old_pte), ptep);
 
 	sz = ((1UL) << shift);
 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
@@ -71,13 +74,14 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 	/* Check if pte already has an hpte (case 2) */
 	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
 		/* There MIGHT be an HPTE for this pte */
-		unsigned long hash, slot;
+		unsigned long hash, slot, hidx;
 
 		hash = hpt_hash(vpn, shift, ssize);
-		if (old_pte & H_PAGE_F_SECOND)
+		hidx = __rpte_to_hidx(rpte, 0);
+		if (hidx & _PTEIDX_SECONDARY)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += (old_pte & H_PAGE_F_GIX) >> H_PAGE_F_GIX_SHIFT;
+		slot += hidx & _PTEIDX_GROUP_IX;
 
 		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, mmu_psize,
 					       mmu_psize, ssize, flags) == -1)
@@ -106,8 +110,16 @@ int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 			return -1;
 		}
 
-		new_pte |= (slot << H_PAGE_F_GIX_SHIFT) &
-			(H_PAGE_F_SECOND | H_PAGE_F_GIX);
+		/*
+		 * Insert slot number & secondary bit in PTE second half.
+		 */
+		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+		rpte.hidx &= ~(0xfUL);
+		*hidxp = rpte.hidx  | (slot & 0xfUL);
+		/*
+		 * check __real_pte for details on matching smp_rmb()
+		 */
+		smp_wmb();
 	}
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
