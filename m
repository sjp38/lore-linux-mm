Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1B76B0630
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:04 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w12so57053034qta.8
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:04 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id q88si12674698qkq.130.2017.07.15.20.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:02 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id m54so14727395qtb.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:02 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 01/62] powerpc: Free up four 64K PTE bits in 4K backed HPTE pages
Date: Sat, 15 Jul 2017 20:56:03 -0700
Message-Id: <1500177424-13695-2-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6,
in the 4K backed HPTE pages.These bits continue to be used
for 64K backed HPTE pages in this patch, but will be freed
up in the next patch. The  bit  numbers are big-endian  as
defined in the ISA3.0

The patch does the following change to the 4k htpe backed
64K PTE's format.

H_PAGE_BUSY moves from bit 3 to bit 9 (B bit in the figure
		below)
V0 which occupied bit 4 is not used anymore.
V1 which occupied bit 5 is not used anymore.
V2 which occupied bit 6 is not used anymore.
V3 which occupied bit 7 is not used anymore.

Before the patch, the 4k backed 64k PTE format was as follows

 0 1 2 3 4  5  6  7  8 9 10...........................63
 : : : : :  :  :  :  : : :                            :
 v v v v v  v  v  v  v v v                            v

,-,-,-,-,--,--,--,--,-,-,-,-,-,------------------,-,-,-,
|x|x|x|B|V0|V1|V2|V3|x| | |x|x|................|x|x|x|x| <- primary pte
'_'_'_'_'__'__'__'__'_'_'_'_'_'________________'_'_'_'_'
|S|G|I|X|S |G |I |X |S|G|I|X|..................|S|G|I|X| <- secondary pte
'_'_'_'_'__'__'__'__'_'_'_'_'__________________'_'_'_'_'

After the patch, the 4k backed 64k PTE format is as follows

 0 1 2 3 4  5  6  7  8 9 10...........................63
 : : : : :  :  :  :  : : :                            :
 v v v v v  v  v  v  v v v                            v

,-,-,-,-,--,--,--,--,-,-,-,-,-,------------------,-,-,-,
|x|x|x| |  |  |  |  |x|B| |x|x|................|.|.|.|.| <- primary pte
'_'_'_'_'__'__'__'__'_'_'_'_'_'________________'_'_'_'_'
|S|G|I|X|S |G |I |X |S|G|I|X|..................|S|G|I|X| <- secondary pte
'_'_'_'_'__'__'__'__'_'_'_'_'__________________'_'_'_'_'

the four  bits S,G,I,X (one quadruplet per 4k HPTE) that
cache  the  hash-bucket  slot  value, is initialized  to
1,1,1,1 indicating -- an invalid slot.   If  a HPTE gets
cached in a 1111  slot(i.e 7th  slot  of  secondary hash
bucket), it is  released  immediately. In  other  words,
even  though 1111   is   a valid slot  value in the hash
bucket, we consider it invalid and  release the slot and
the HPTE.  This  gives  us  the opportunity to determine
the validity of S,G,I,X  bits  based on its contents and
not on any of the bits V0,V1,V2 or V3 in the primary PTE

When   we  release  a    HPTE    cached in the 1111 slot
we also    release  a  legitimate   slot  in the primary
hash bucket  and  unmap  its  corresponding  HPTE.  This
is  to  ensure   that  we do get a HPTE cached in a slot
of the primary hash bucket, the next time we retry.

Though  treating  1111  slot  as  invalid,  reduces  the
number of  available  slots  in the hash bucket and  may
have  an  effect   on the performance, the probabilty of
hitting a 1111 slot is extermely low.

Compared  to  the  current   scheme, the above described
scheme  reduces  the  number of false hash table updates
significantly   and    has  the   added   advantage   of
releasing  four  valuable  PTE bits for other purpose.

NOTE:even though bits 3, 4, 5, 6, 7 are  not  used  when
the  64K  PTE is backed by 4k HPTE,  they continue to be
used  if  the  PTE  gets  backed  by 64k HPTE.  The next
patch will decouple that aswell, and truely  release the
bits.

This idea was jointly developed by Paul Mackerras,
Aneesh, Michael Ellermen and myself.

4K PTE format remains unchanged currently.

The patch does the following code changes
a) PTE flags are split between 64k and 4k  header files.
b) __hash_page_4K()  is  reimplemented   to reflect the
   above logic.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |    2 +
 arch/powerpc/include/asm/book3s/64/hash-64k.h |    8 +--
 arch/powerpc/include/asm/book3s/64/hash.h     |    1 -
 arch/powerpc/mm/hash64_64k.c                  |   78 ++++++++++++++++---------
 arch/powerpc/mm/hash_utils_64.c               |    4 +-
 5 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index 0c4e470..f959c00 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -16,6 +16,8 @@
 #define H_PUD_TABLE_SIZE	(sizeof(pud_t) << H_PUD_INDEX_SIZE)
 #define H_PGD_TABLE_SIZE	(sizeof(pgd_t) << H_PGD_INDEX_SIZE)
 
+#define H_PAGE_BUSY	_RPAGE_RSV1     /* software: PTE & hash are busy */
+
 /* PTE flags to conserve for HPTE identification */
 #define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_HASHPTE | \
 			 H_PAGE_F_SECOND | H_PAGE_F_GIX)
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 9732837..62e580c 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -12,18 +12,14 @@
  */
 #define H_PAGE_COMBO	_RPAGE_RPN0 /* this is a combo 4k page */
 #define H_PAGE_4K_PFN	_RPAGE_RPN1 /* PFN is for a single 4k page */
+#define H_PAGE_BUSY	_RPAGE_RPN42     /* software: PTE & hash are busy */
+
 /*
  * We need to differentiate between explicit huge page and THP huge
  * page, since THP huge page also need to track real subpage details
  */
 #define H_PAGE_THP_HUGE  H_PAGE_4K_PFN
 
-/*
- * Used to track subpage group valid if H_PAGE_COMBO is set
- * This overloads H_PAGE_F_GIX and H_PAGE_F_SECOND
- */
-#define H_PAGE_COMBO_VALID	(H_PAGE_F_GIX | H_PAGE_F_SECOND)
-
 /* PTE flags to conserve for HPTE identification */
 #define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_F_SECOND | \
 			 H_PAGE_F_GIX | H_PAGE_HASHPTE | H_PAGE_COMBO)
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 4e957b0..2d72964 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -9,7 +9,6 @@
  */
 #define H_PTE_NONE_MASK		_PAGE_HPTEFLAGS
 #define H_PAGE_F_GIX_SHIFT	56
-#define H_PAGE_BUSY		_RPAGE_RSV1 /* software: PTE & hash are busy */
 #define H_PAGE_F_SECOND		_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
 #define H_PAGE_F_GIX		(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
 #define H_PAGE_HASHPTE		_RPAGE_RPN43	/* PTE has associated HPTE */
diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
index 1a68cb1..e573bd3 100644
--- a/arch/powerpc/mm/hash64_64k.c
+++ b/arch/powerpc/mm/hash64_64k.c
@@ -15,34 +15,22 @@
 #include <linux/mm.h>
 #include <asm/machdep.h>
 #include <asm/mmu.h>
+
 /*
- * index from 0 - 15
+ * return true, if the entry has a slot value which
+ * the software considers as invalid.
  */
-bool __rpte_sub_valid(real_pte_t rpte, unsigned long index)
+static inline bool hpte_soft_invalid(unsigned long slot)
 {
-	unsigned long g_idx;
-	unsigned long ptev = pte_val(rpte.pte);
-
-	g_idx = (ptev & H_PAGE_COMBO_VALID) >> H_PAGE_F_GIX_SHIFT;
-	index = index >> 2;
-	if (g_idx & (0x1 << index))
-		return true;
-	else
-		return false;
+	return ((slot & 0xfUL) == 0xfUL);
 }
+
 /*
  * index from 0 - 15
  */
-static unsigned long mark_subptegroup_valid(unsigned long ptev, unsigned long index)
+bool __rpte_sub_valid(real_pte_t rpte, unsigned long index)
 {
-	unsigned long g_idx;
-
-	if (!(ptev & H_PAGE_COMBO))
-		return ptev;
-	index = index >> 2;
-	g_idx = 0x1 << index;
-
-	return ptev | (g_idx << H_PAGE_F_GIX_SHIFT);
+	return !(hpte_soft_invalid(rpte.hidx >> (index << 2)));
 }
 
 int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
@@ -50,12 +38,12 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		   int ssize, int subpg_prot)
 {
 	real_pte_t rpte;
-	unsigned long *hidxp;
 	unsigned long hpte_group;
+	unsigned long *hidxp;
 	unsigned int subpg_index;
 	unsigned long rflags, pa, hidx;
 	unsigned long old_pte, new_pte, subpg_pte;
-	unsigned long vpn, hash, slot;
+	unsigned long vpn, hash, slot, gslot;
 	unsigned long shift = mmu_psize_defs[MMU_PAGE_4K].shift;
 
 	/*
@@ -116,8 +104,8 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 		 * On hash insert failure we use old pte value and we don't
 		 * want slot information there if we have a insert failure.
 		 */
-		old_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
-		new_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
+		old_pte &= ~(H_PAGE_HASHPTE);
+		new_pte &= ~(H_PAGE_HASHPTE);
 		goto htab_insert_hpte;
 	}
 	/*
@@ -148,6 +136,15 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	}
 
 htab_insert_hpte:
+
+	/*
+	 * initialize all hidx entries to invalid value,
+	 * the first time the PTE is about to allocate
+	 * a 4K hpte
+	 */
+	if (!(old_pte & H_PAGE_COMBO))
+		rpte.hidx = ~0x0UL;
+
 	/*
 	 * handle H_PAGE_4K_PFN case
 	 */
@@ -172,15 +169,41 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	 * Primary is full, try the secondary
 	 */
 	if (unlikely(slot == -1)) {
+		bool soft_invalid;
+
 		hpte_group = ((~hash & htab_hash_mask) * HPTES_PER_GROUP) & ~0x7UL;
 		slot = mmu_hash_ops.hpte_insert(hpte_group, vpn, pa,
 						rflags, HPTE_V_SECONDARY,
 						MMU_PAGE_4K, MMU_PAGE_4K,
 						ssize);
-		if (slot == -1) {
-			if (mftb() & 0x1)
+
+		soft_invalid = hpte_soft_invalid(slot);
+		if (unlikely(soft_invalid)) {
+			/*
+			 * we got a valid slot from a hardware point of view.
+			 * but we cannot use it, because we use this special
+			 * value; as     defined   by    hpte_soft_invalid(),
+			 * to  track    invalid  slots.  We  cannot  use  it.
+			 * So invalidate it.
+			 */
+			gslot = slot & _PTEIDX_GROUP_IX;
+			mmu_hash_ops.hpte_invalidate(hpte_group+gslot, vpn,
+				MMU_PAGE_4K, MMU_PAGE_4K,
+				ssize, 0);
+		}
+
+		if (unlikely(slot == -1 || soft_invalid)) {
+			/*
+			 * for soft invalid slot, lets   ensure that we
+			 * release a slot from  the primary,   with the
+			 * hope that we  will  acquire that slot   next
+			 * time we try. This will ensure that we do not
+			 * get the same soft-invalid slot.
+			 */
+			if (soft_invalid || (mftb() & 0x1))
 				hpte_group = ((hash & htab_hash_mask) *
 					      HPTES_PER_GROUP) & ~0x7UL;
+
 			mmu_hash_ops.hpte_remove(hpte_group);
 			/*
 			 * FIXME!! Should be try the group from which we removed ?
@@ -207,12 +230,11 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
 	hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
 	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
 	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
-	new_pte = mark_subptegroup_valid(new_pte, subpg_index);
-	new_pte |=  H_PAGE_HASHPTE;
 	/*
 	 * check __real_pte for details on matching smp_rmb()
 	 */
 	smp_wmb();
+	new_pte |=  H_PAGE_HASHPTE;
 	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
 	return 0;
 }
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index f2095ce..1b494d0 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -975,8 +975,9 @@ void __init hash__early_init_devtree(void)
 
 void __init hash__early_init_mmu(void)
 {
+#ifndef CONFIG_PPC_64K_PAGES
 	/*
-	 * We have code in __hash_page_64K() and elsewhere, which assumes it can
+	 * We have code in __hash_page_4K() and elsewhere, which assumes it can
 	 * do the following:
 	 *   new_pte |= (slot << H_PAGE_F_GIX_SHIFT) & (H_PAGE_F_SECOND | H_PAGE_F_GIX);
 	 *
@@ -987,6 +988,7 @@ void __init hash__early_init_mmu(void)
 	 * with a BUILD_BUG_ON().
 	 */
 	BUILD_BUG_ON(H_PAGE_F_SECOND != (1ul  << (H_PAGE_F_GIX_SHIFT + 3)));
+#endif /* CONFIG_PPC_64K_PAGES */
 
 	htab_init_page_sizes();
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
