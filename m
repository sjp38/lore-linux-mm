Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6F72B6B0023
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:47:56 -0500 (EST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:15:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 85CF5394004F
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:52 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlmeW21168290
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:48 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlofk010620
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:51 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 08/21] powerpc: Decode the pte-lp-encoding bits correctly.
Date: Thu, 21 Feb 2013 22:17:15 +0530
Message-Id: <1361465248-10867-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We look at both the segment base page size and actual page size and store
the pte-lp-encodings in an array per base page size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/machdep.h      |    3 +-
 arch/powerpc/include/asm/mmu-hash64.h   |   30 +++++----
 arch/powerpc/kvm/book3s_hv.c            |    7 ++-
 arch/powerpc/mm/hash_low_64.S           |   18 ++++--
 arch/powerpc/mm/hash_native_64.c        |   85 ++++++++++++++++---------
 arch/powerpc/mm/hash_utils_64.c         |  103 +++++++++++++++++++------------
 arch/powerpc/mm/hugetlbpage-hash64.c    |    4 +-
 arch/powerpc/platforms/cell/beat_htab.c |   16 ++---
 arch/powerpc/platforms/ps3/htab.c       |    6 +-
 arch/powerpc/platforms/pseries/lpar.c   |    6 +-
 10 files changed, 174 insertions(+), 104 deletions(-)

diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
index 19d9d96..6cee6e0 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -50,7 +50,8 @@ struct machdep_calls {
 				       unsigned long prpn,
 				       unsigned long rflags,
 				       unsigned long vflags,
-				       int psize, int ssize);
+				       int psize, int apsize,
+				       int ssize);
 	long		(*hpte_remove)(unsigned long hpte_group);
 	void            (*hpte_removebolted)(unsigned long ea,
 					     int psize, int ssize);
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index c3b3518..c7bc181 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -154,7 +154,7 @@ extern unsigned long htab_hash_mask;
 struct mmu_psize_def
 {
 	unsigned int	shift;	/* number of bits */
-	unsigned int	penc;	/* HPTE encoding */
+	unsigned int	penc[MMU_PAGE_COUNT];	/* HPTE encoding */
 	unsigned int	tlbiel;	/* tlbiel supported for that page size */
 	unsigned long	avpnm;	/* bits to mask out in AVPN in the HPTE */
 	unsigned long	sllp;	/* SLB L||LP (exact mask to use in slbmte) */
@@ -181,6 +181,13 @@ struct mmu_psize_def
  */
 #define VPN_SHIFT	12
 
+/*
+ * HPTE LP details
+ */
+#define LP_SHIFT	12
+#define LP_BITS		8
+#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
+
 #ifndef __ASSEMBLY__
 
 static inline int segment_shift(int ssize)
@@ -237,14 +244,14 @@ static inline unsigned long hpte_encode_avpn(unsigned long vpn, int psize,
 
 /*
  * This function sets the AVPN and L fields of the HPTE  appropriately
- * for the page size
+ * using the base page size and actual page size.
  */
-static inline unsigned long hpte_encode_v(unsigned long vpn,
-					  int psize, int ssize)
+static inline unsigned long hpte_encode_v(unsigned long vpn, int base_psize,
+					  int actual_psize, int ssize)
 {
 	unsigned long v;
-	v = hpte_encode_avpn(vpn, psize, ssize);
-	if (psize != MMU_PAGE_4K)
+	v = hpte_encode_avpn(vpn, base_psize, ssize);
+	if (actual_psize != MMU_PAGE_4K)
 		v |= HPTE_V_LARGE;
 	return v;
 }
@@ -254,17 +261,18 @@ static inline unsigned long hpte_encode_v(unsigned long vpn,
  * for the page size. We assume the pa is already "clean" that is properly
  * aligned for the requested page size
  */
-static inline unsigned long hpte_encode_r(unsigned long pa, int psize)
+static inline unsigned long hpte_encode_r(unsigned long pa, int base_psize,
+					  int actual_psize)
 {
 	unsigned long r;
 
 	/* A 4K page needs no special encoding */
-	if (psize == MMU_PAGE_4K)
+	if (actual_psize == MMU_PAGE_4K)
 		return pa & HPTE_R_RPN;
 	else {
-		unsigned int penc = mmu_psize_defs[psize].penc;
-		unsigned int shift = mmu_psize_defs[psize].shift;
-		return (pa & ~((1ul << shift) - 1)) | (penc << 12);
+		unsigned int penc = mmu_psize_defs[base_psize].penc[actual_psize];
+		unsigned int shift = mmu_psize_defs[actual_psize].shift;
+		return (pa & ~((1ul << shift) - 1)) | (penc << LP_SHIFT);
 	}
 	return r;
 }
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 71d0c90..d2c9932 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1515,7 +1515,12 @@ static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
 	(*sps)->page_shift = def->shift;
 	(*sps)->slb_enc = def->sllp;
 	(*sps)->enc[0].page_shift = def->shift;
-	(*sps)->enc[0].pte_enc = def->penc;
+	/*
+	 * FIXME!!
+	 * This is returned to user space. Do we need to
+	 * return details of MPSS here ?
+	 */
+	(*sps)->enc[0].pte_enc = def->penc[linux_psize];
 	(*sps)++;
 }
 
diff --git a/arch/powerpc/mm/hash_low_64.S b/arch/powerpc/mm/hash_low_64.S
index abdd5e2..0e980ac 100644
--- a/arch/powerpc/mm/hash_low_64.S
+++ b/arch/powerpc/mm/hash_low_64.S
@@ -196,7 +196,8 @@ htab_insert_pte:
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,0			/* !bolted, !secondary */
 	li	r8,MMU_PAGE_4K		/* page size */
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_4K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(htab_call_hpte_insert1)
 	bl	.			/* Patched by htab_finish_init() */
 	cmpdi	0,r3,0
@@ -219,7 +220,8 @@ _GLOBAL(htab_call_hpte_insert1)
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
 	li	r8,MMU_PAGE_4K		/* page size */
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_4K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(htab_call_hpte_insert2)
 	bl	.			/* Patched by htab_finish_init() */
 	cmpdi	0,r3,0
@@ -515,7 +517,8 @@ htab_special_pfn:
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,0			/* !bolted, !secondary */
 	li	r8,MMU_PAGE_4K		/* page size */
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_4K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(htab_call_hpte_insert1)
 	bl	.			/* patched by htab_finish_init() */
 	cmpdi	0,r3,0
@@ -542,7 +545,8 @@ _GLOBAL(htab_call_hpte_insert1)
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
 	li	r8,MMU_PAGE_4K		/* page size */
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_4K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(htab_call_hpte_insert2)
 	bl	.			/* patched by htab_finish_init() */
 	cmpdi	0,r3,0
@@ -840,7 +844,8 @@ ht64_insert_pte:
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,0			/* !bolted, !secondary */
 	li	r8,MMU_PAGE_64K
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_64K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(ht64_call_hpte_insert1)
 	bl	.			/* patched by htab_finish_init() */
 	cmpdi	0,r3,0
@@ -863,7 +868,8 @@ _GLOBAL(ht64_call_hpte_insert1)
 	mr	r4,r29			/* Retrieve vpn */
 	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
 	li	r8,MMU_PAGE_64K
-	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
+	li	r9,MMU_PAGE_64K		/* actual page size */
+	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
 _GLOBAL(ht64_call_hpte_insert2)
 	bl	.			/* patched by htab_finish_init() */
 	cmpdi	0,r3,0
diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index 9d8983a..3d30b23 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -39,7 +39,7 @@
 
 DEFINE_RAW_SPINLOCK(native_tlbie_lock);
 
-static inline void __tlbie(unsigned long vpn, int psize, int ssize)
+static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
 {
 	unsigned long va;
 	unsigned int penc;
@@ -68,7 +68,7 @@ static inline void __tlbie(unsigned long vpn, int psize, int ssize)
 		break;
 	default:
 		/* We need 14 to 14 + i bits of va */
-		penc = mmu_psize_defs[psize].penc;
+		penc = mmu_psize_defs[psize].penc[apsize];
 		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
@@ -80,7 +80,7 @@ static inline void __tlbie(unsigned long vpn, int psize, int ssize)
 	}
 }
 
-static inline void __tlbiel(unsigned long vpn, int psize, int ssize)
+static inline void __tlbiel(unsigned long vpn, int psize, int apsize, int ssize)
 {
 	unsigned long va;
 	unsigned int penc;
@@ -102,7 +102,7 @@ static inline void __tlbiel(unsigned long vpn, int psize, int ssize)
 		break;
 	default:
 		/* We need 14 to 14 + i bits of va */
-		penc = mmu_psize_defs[psize].penc;
+		penc = mmu_psize_defs[psize].penc[apsize];
 		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
 		va |= penc << 12;
 		va |= ssize << 8;
@@ -114,7 +114,8 @@ static inline void __tlbiel(unsigned long vpn, int psize, int ssize)
 
 }
 
-static inline void tlbie(unsigned long vpn, int psize, int ssize, int local)
+static inline void tlbie(unsigned long vpn, int psize, int apsize,
+			 int ssize, int local)
 {
 	unsigned int use_local = local && mmu_has_feature(MMU_FTR_TLBIEL);
 	int lock_tlbie = !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
@@ -125,10 +126,10 @@ static inline void tlbie(unsigned long vpn, int psize, int ssize, int local)
 		raw_spin_lock(&native_tlbie_lock);
 	asm volatile("ptesync": : :"memory");
 	if (use_local) {
-		__tlbiel(vpn, psize, ssize);
+		__tlbiel(vpn, psize, apsize, ssize);
 		asm volatile("ptesync": : :"memory");
 	} else {
-		__tlbie(vpn, psize, ssize);
+		__tlbie(vpn, psize, apsize, ssize);
 		asm volatile("eieio; tlbsync; ptesync": : :"memory");
 	}
 	if (lock_tlbie && !use_local)
@@ -156,7 +157,7 @@ static inline void native_unlock_hpte(struct hash_pte *hptep)
 
 static long native_hpte_insert(unsigned long hpte_group, unsigned long vpn,
 			unsigned long pa, unsigned long rflags,
-			unsigned long vflags, int psize, int ssize)
+			unsigned long vflags, int psize, int apsize, int ssize)
 {
 	struct hash_pte *hptep = htab_address + hpte_group;
 	unsigned long hpte_v, hpte_r;
@@ -183,8 +184,8 @@ static long native_hpte_insert(unsigned long hpte_group, unsigned long vpn,
 	if (i == HPTES_PER_GROUP)
 		return -1;
 
-	hpte_v = hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
-	hpte_r = hpte_encode_r(pa, psize) | rflags;
+	hpte_v = hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_VALID;
+	hpte_r = hpte_encode_r(pa, psize, apsize) | rflags;
 
 	if (!(vflags & HPTE_V_BOLTED)) {
 		DBG_LOW(" i=%x hpte_v=%016lx, hpte_r=%016lx\n",
@@ -244,6 +245,30 @@ static long native_hpte_remove(unsigned long hpte_group)
 	return i;
 }
 
+static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
+{
+	unsigned int mask;
+	int i, penc, shift;
+	/* Look at the 8 bit LP value */
+	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << (LP_BITS + 1)) - 1);
+
+	penc = 0;
+	for (i = 0; i < MMU_PAGE_COUNT; i++) {
+		/* valid entries have a shift value */
+		if (!mmu_psize_defs[i].shift)
+			continue;
+
+		/* encoding bits per actual page size */
+		shift = mmu_psize_defs[i].shift - 11;
+		if (shift > 9)
+			shift = 9;
+		mask = (1 << shift) - 1;
+		if ((lp & mask) == mmu_psize_defs[psize].penc[i])
+			return i;
+	}
+	return -1;
+}
+
 static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 				 unsigned long vpn, int psize, int ssize,
 				 int local)
@@ -251,6 +276,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 	struct hash_pte *hptep = htab_address + slot;
 	unsigned long hpte_v, want_v;
 	int ret = 0;
+	int actual_psize;
 
 	want_v = hpte_encode_avpn(vpn, psize, ssize);
 
@@ -260,6 +286,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 	native_lock_hpte(hptep);
 
 	hpte_v = hptep->v;
+	actual_psize = hpte_actual_psize(hptep, psize);
 
 	/* Even if we miss, we need to invalidate the TLB */
 	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID)) {
@@ -274,7 +301,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 	native_unlock_hpte(hptep);
 
 	/* Ensure it is out of the tlb too. */
-	tlbie(vpn, psize, ssize, local);
+	tlbie(vpn, psize, actual_psize, ssize, local);
 
 	return ret;
 }
@@ -315,6 +342,7 @@ static long native_hpte_find(unsigned long vpn, int psize, int ssize)
 static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
 				       int psize, int ssize)
 {
+	int actual_psize;
 	unsigned long vpn;
 	unsigned long vsid;
 	long slot;
@@ -327,13 +355,14 @@ static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
 	if (slot == -1)
 		panic("could not find page to bolt\n");
 	hptep = htab_address + slot;
+	actual_psize = hpte_actual_psize(hptep, psize);
 
 	/* Update the HPTE */
 	hptep->r = (hptep->r & ~(HPTE_R_PP | HPTE_R_N)) |
 		(newpp & (HPTE_R_PP | HPTE_R_N));
 
 	/* Ensure it is out of the tlb too. */
-	tlbie(vpn, psize, ssize, 0);
+	tlbie(vpn, psize, actual_psize, ssize, 0);
 }
 
 static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
@@ -343,6 +372,7 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
 	unsigned long hpte_v;
 	unsigned long want_v;
 	unsigned long flags;
+	int actual_psize;
 
 	local_irq_save(flags);
 
@@ -352,6 +382,7 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
 	native_lock_hpte(hptep);
 	hpte_v = hptep->v;
 
+	actual_psize = hpte_actual_psize(hptep, psize);
 	/* Even if we miss, we need to invalidate the TLB */
 	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID))
 		native_unlock_hpte(hptep);
@@ -360,23 +391,19 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
 		hptep->v = 0;
 
 	/* Invalidate the TLB */
-	tlbie(vpn, psize, ssize, local);
+	tlbie(vpn, psize, actual_psize, ssize, local);
 
 	local_irq_restore(flags);
 }
 
-#define LP_SHIFT	12
-#define LP_BITS		8
-#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
-
 static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
-			int *psize, int *ssize, unsigned long *vpn)
+			int *psize, int *apsize, int *ssize, unsigned long *vpn)
 {
 	unsigned long avpn, pteg, vpi;
 	unsigned long hpte_r = hpte->r;
 	unsigned long hpte_v = hpte->v;
 	unsigned long vsid, seg_off;
-	int i, size, shift, penc;
+	int i, size, a_size = MMU_PAGE_4K, shift, penc;
 
 	if (!(hpte_v & HPTE_V_LARGE))
 		size = MMU_PAGE_4K;
@@ -395,12 +422,13 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 			/* valid entries have a shift value */
 			if (!mmu_psize_defs[size].shift)
 				continue;
-
-			if (penc == mmu_psize_defs[size].penc)
-				break;
+			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++)
+				if (penc == mmu_psize_defs[size].penc[a_size])
+					goto out;
 		}
 	}
 
+out:
 	/* This works for all page sizes, and for 256M and 1T segments */
 	*ssize = hpte_v >> HPTE_V_SSIZE_SHIFT;
 	shift = mmu_psize_defs[size].shift;
@@ -433,7 +461,8 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 	default:
 		*vpn = size = 0;
 	}
-	*psize = size;
+	*psize  = size;
+	*apsize = a_size;
 }
 
 /*
@@ -451,7 +480,7 @@ static void native_hpte_clear(void)
 	struct hash_pte *hptep = htab_address;
 	unsigned long hpte_v;
 	unsigned long pteg_count;
-	int psize, ssize;
+	int psize, apsize, ssize;
 
 	pteg_count = htab_hash_mask + 1;
 
@@ -477,9 +506,9 @@ static void native_hpte_clear(void)
 		 * already hold the native_tlbie_lock.
 		 */
 		if (hpte_v & HPTE_V_VALID) {
-			hpte_decode(hptep, slot, &psize, &ssize, &vpn);
+			hpte_decode(hptep, slot, &psize, &apsize, &ssize, &vpn);
 			hptep->v = 0;
-			__tlbie(vpn, psize, ssize);
+			__tlbie(vpn, psize, apsize, ssize);
 		}
 	}
 
@@ -540,7 +569,7 @@ static void native_flush_hash_range(unsigned long number, int local)
 
 			pte_iterate_hashed_subpages(pte, psize,
 						    vpn, index, shift) {
-				__tlbiel(vpn, psize, ssize);
+				__tlbiel(vpn, psize, psize, ssize);
 			} pte_iterate_hashed_end();
 		}
 		asm volatile("ptesync":::"memory");
@@ -557,7 +586,7 @@ static void native_flush_hash_range(unsigned long number, int local)
 
 			pte_iterate_hashed_subpages(pte, psize,
 						    vpn, index, shift) {
-				__tlbie(vpn, psize, ssize);
+				__tlbie(vpn, psize, psize, ssize);
 			} pte_iterate_hashed_end();
 		}
 		asm volatile("eieio; tlbsync; ptesync":::"memory");
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index bfeab83..48edb46 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -125,7 +125,7 @@ static struct mmu_psize_def mmu_psize_defaults_old[] = {
 	[MMU_PAGE_4K] = {
 		.shift	= 12,
 		.sllp	= 0,
-		.penc	= 0,
+		.penc[MMU_PAGE_4K] = 0,
 		.avpnm	= 0,
 		.tlbiel = 0,
 	},
@@ -139,14 +139,14 @@ static struct mmu_psize_def mmu_psize_defaults_gp[] = {
 	[MMU_PAGE_4K] = {
 		.shift	= 12,
 		.sllp	= 0,
-		.penc	= 0,
+		.penc[MMU_PAGE_4K] = 0,
 		.avpnm	= 0,
 		.tlbiel = 1,
 	},
 	[MMU_PAGE_16M] = {
 		.shift	= 24,
 		.sllp	= SLB_VSID_L,
-		.penc	= 0,
+		.penc[MMU_PAGE_16M] = 0,
 		.avpnm	= 0x1UL,
 		.tlbiel = 0,
 	},
@@ -208,7 +208,7 @@ int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
 
 		BUG_ON(!ppc_md.hpte_insert);
 		ret = ppc_md.hpte_insert(hpteg, vpn, paddr, tprot,
-					 HPTE_V_BOLTED, psize, ssize);
+					 HPTE_V_BOLTED, psize, psize, ssize);
 
 		if (ret < 0)
 			break;
@@ -275,6 +275,30 @@ static void __init htab_init_seg_sizes(void)
 	of_scan_flat_dt(htab_dt_scan_seg_sizes, NULL);
 }
 
+static int __init get_idx_from_shift(unsigned int shift)
+{
+	int idx = -1;
+
+	switch (shift) {
+	case 0xc:
+		idx = MMU_PAGE_4K;
+		break;
+	case 0x10:
+		idx = MMU_PAGE_64K;
+		break;
+	case 0x14:
+		idx = MMU_PAGE_1M;
+		break;
+	case 0x18:
+		idx = MMU_PAGE_16M;
+		break;
+	case 0x22:
+		idx = MMU_PAGE_16G;
+		break;
+	}
+	return idx;
+}
+
 static int __init htab_dt_scan_page_sizes(unsigned long node,
 					  const char *uname, int depth,
 					  void *data)
@@ -294,60 +318,57 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
 		size /= 4;
 		cur_cpu_spec->mmu_features &= ~(MMU_FTR_16M_PAGE);
 		while(size > 0) {
-			unsigned int shift = prop[0];
+			unsigned int base_shift = prop[0];
 			unsigned int slbenc = prop[1];
 			unsigned int lpnum = prop[2];
-			unsigned int lpenc = 0;
 			struct mmu_psize_def *def;
-			int idx = -1;
+			int idx, base_idx;
 
 			size -= 3; prop += 3;
-			while(size > 0 && lpnum) {
-				if (prop[0] == shift)
-					lpenc = prop[1];
+			base_idx = get_idx_from_shift(base_shift);
+			if (base_idx < 0) {
+				/*
+				 * skip the pte encoding also
+				 */
 				prop += 2; size -= 2;
-				lpnum--;
+				continue;
 			}
-			switch(shift) {
-			case 0xc:
-				idx = MMU_PAGE_4K;
-				break;
-			case 0x10:
-				idx = MMU_PAGE_64K;
-				break;
-			case 0x14:
-				idx = MMU_PAGE_1M;
-				break;
-			case 0x18:
-				idx = MMU_PAGE_16M;
+			def = &mmu_psize_defs[base_idx];
+			if (base_idx == MMU_PAGE_16M)
 				cur_cpu_spec->mmu_features |= MMU_FTR_16M_PAGE;
-				break;
-			case 0x22:
-				idx = MMU_PAGE_16G;
-				break;
-			}
-			if (idx < 0)
-				continue;
-			def = &mmu_psize_defs[idx];
-			def->shift = shift;
-			if (shift <= 23)
+
+			def->shift = base_shift;
+			if (base_shift <= 23)
 				def->avpnm = 0;
 			else
-				def->avpnm = (1 << (shift - 23)) - 1;
+				def->avpnm = (1 << (base_shift - 23)) - 1;
 			def->sllp = slbenc;
-			def->penc = lpenc;
-			/* We don't know for sure what's up with tlbiel, so
+			/*
+			 * We don't know for sure what's up with tlbiel, so
 			 * for now we only set it for 4K and 64K pages
 			 */
-			if (idx == MMU_PAGE_4K || idx == MMU_PAGE_64K)
+			if (base_idx == MMU_PAGE_4K || base_idx == MMU_PAGE_64K)
 				def->tlbiel = 1;
 			else
 				def->tlbiel = 0;
 
-			DBG(" %d: shift=%02x, sllp=%04lx, avpnm=%08lx, "
-			    "tlbiel=%d, penc=%d\n",
-			    idx, shift, def->sllp, def->avpnm, def->tlbiel,
-			    def->penc);
+			while (size > 0 && lpnum) {
+				unsigned int shift = prop[0];
+				unsigned int penc  = prop[1];
+
+				prop += 2; size -= 2;
+				lpnum--;
+
+				idx = get_idx_from_shift(shift);
+				if (idx < 0)
+					continue;
+
+				def->penc[idx] = penc;
+				DBG(" %d: shift=%02x, sllp=%04lx, "
+				    "avpnm=%08lx, tlbiel=%d, penc=%d\n",
+				    idx, shift, def->sllp, def->avpnm,
+				    def->tlbiel, def->penc[idx]);
+			}
 		}
 		return 1;
 	}
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index cecad34..e0d52ee 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -103,7 +103,7 @@ repeat:
 
 		/* Insert into the hash table, primary slot */
 		slot = ppc_md.hpte_insert(hpte_group, vpn, pa, rflags, 0,
-					  mmu_psize, ssize);
+					  mmu_psize, mmu_psize, ssize);
 
 		/* Primary is full, try the secondary */
 		if (unlikely(slot == -1)) {
@@ -111,7 +111,7 @@ repeat:
 				      HPTES_PER_GROUP) & ~0x7UL;
 			slot = ppc_md.hpte_insert(hpte_group, vpn, pa, rflags,
 						  HPTE_V_SECONDARY,
-						  mmu_psize, ssize);
+						  mmu_psize, mmu_psize, ssize);
 			if (slot == -1) {
 				if (mftb() & 0x1)
 					hpte_group = ((hash & htab_hash_mask) *
diff --git a/arch/powerpc/platforms/cell/beat_htab.c b/arch/powerpc/platforms/cell/beat_htab.c
index 472f9a7..246e1d8 100644
--- a/arch/powerpc/platforms/cell/beat_htab.c
+++ b/arch/powerpc/platforms/cell/beat_htab.c
@@ -90,7 +90,7 @@ static inline unsigned int beat_read_mask(unsigned hpte_group)
 static long beat_lpar_hpte_insert(unsigned long hpte_group,
 				  unsigned long vpn, unsigned long pa,
 				  unsigned long rflags, unsigned long vflags,
-				  int psize, int ssize)
+				  int psize, int apsize, int ssize)
 {
 	unsigned long lpar_rc;
 	u64 hpte_v, hpte_r, slot;
@@ -103,9 +103,9 @@ static long beat_lpar_hpte_insert(unsigned long hpte_group,
 			"rflags=%lx, vflags=%lx, psize=%d)\n",
 		hpte_group, va, pa, rflags, vflags, psize);
 
-	hpte_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M) |
+	hpte_v = hpte_encode_v(vpn, psize, apsize, MMU_SEGSIZE_256M) |
 		vflags | HPTE_V_VALID;
-	hpte_r = hpte_encode_r(pa, psize) | rflags;
+	hpte_r = hpte_encode_r(pa, psize, apsize) | rflags;
 
 	if (!(vflags & HPTE_V_BOLTED))
 		DBG_LOW(" hpte_v=%016lx, hpte_r=%016lx\n", hpte_v, hpte_r);
@@ -314,7 +314,7 @@ void __init hpte_init_beat(void)
 static long beat_lpar_hpte_insert_v3(unsigned long hpte_group,
 				  unsigned long vpn, unsigned long pa,
 				  unsigned long rflags, unsigned long vflags,
-				  int psize, int ssize)
+				  int psize, int apsize, int ssize)
 {
 	unsigned long lpar_rc;
 	u64 hpte_v, hpte_r, slot;
@@ -327,9 +327,9 @@ static long beat_lpar_hpte_insert_v3(unsigned long hpte_group,
 			"rflags=%lx, vflags=%lx, psize=%d)\n",
 		hpte_group, vpn, pa, rflags, vflags, psize);
 
-	hpte_v = hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M) |
+	hpte_v = hpte_encode_v(vpn, psize, apsize, MMU_SEGSIZE_256M) |
 		vflags | HPTE_V_VALID;
-	hpte_r = hpte_encode_r(pa, psize) | rflags;
+	hpte_r = hpte_encode_r(pa, psize, apsize) | rflags;
 
 	if (!(vflags & HPTE_V_BOLTED))
 		DBG_LOW(" hpte_v=%016lx, hpte_r=%016lx\n", hpte_v, hpte_r);
@@ -373,7 +373,7 @@ static long beat_lpar_hpte_updatepp_v3(unsigned long slot,
 	unsigned long pss;
 
 	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
-	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
+	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc[psize];
 
 	DBG_LOW("    update: "
 		"avpnv=%016lx, slot=%016lx, psize: %d, newpp %016lx ... ",
@@ -403,7 +403,7 @@ static void beat_lpar_hpte_invalidate_v3(unsigned long slot, unsigned long vpn,
 	DBG_LOW("    inval : slot=%lx, vpn=%016lx, psize: %d, local: %d\n",
 		slot, vpn, psize, local);
 	want_v = hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
-	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
+	pss = (psize == MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc[psize];
 
 	lpar_rc = beat_invalidate_htab_entry3(0, slot, want_v, pss);
 
diff --git a/arch/powerpc/platforms/ps3/htab.c b/arch/powerpc/platforms/ps3/htab.c
index 07a4bba..44f06d2 100644
--- a/arch/powerpc/platforms/ps3/htab.c
+++ b/arch/powerpc/platforms/ps3/htab.c
@@ -45,7 +45,7 @@ static DEFINE_SPINLOCK(ps3_htab_lock);
 
 static long ps3_hpte_insert(unsigned long hpte_group, unsigned long vpn,
 	unsigned long pa, unsigned long rflags, unsigned long vflags,
-	int psize, int ssize)
+	int psize, int apsize, int ssize)
 {
 	int result;
 	u64 hpte_v, hpte_r;
@@ -61,8 +61,8 @@ static long ps3_hpte_insert(unsigned long hpte_group, unsigned long vpn,
 	 */
 	vflags &= ~HPTE_V_SECONDARY;
 
-	hpte_v = hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
-	hpte_r = hpte_encode_r(ps3_mm_phys_to_lpar(pa), psize) | rflags;
+	hpte_v = hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_VALID;
+	hpte_r = hpte_encode_r(ps3_mm_phys_to_lpar(pa), psize, apsize) | rflags;
 
 	spin_lock_irqsave(&ps3_htab_lock, flags);
 
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index a77c35b..3daced3 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -109,7 +109,7 @@ void vpa_init(int cpu)
 static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 				     unsigned long vpn, unsigned long pa,
 				     unsigned long rflags, unsigned long vflags,
-				     int psize, int ssize)
+				     int psize, int apsize, int ssize)
 {
 	unsigned long lpar_rc;
 	unsigned long flags;
@@ -121,8 +121,8 @@ static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 			 "pa=%016lx, rflags=%lx, vflags=%lx, psize=%d)\n",
 			 hpte_group, vpn,  pa, rflags, vflags, psize);
 
-	hpte_v = hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
-	hpte_r = hpte_encode_r(pa, psize) | rflags;
+	hpte_v = hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_VALID;
+	hpte_r = hpte_encode_r(pa, psize, apsize) | rflags;
 
 	if (!(vflags & HPTE_V_BOLTED))
 		pr_devel(" hpte_v=%016lx, hpte_r=%016lx\n", hpte_v, hpte_r);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
