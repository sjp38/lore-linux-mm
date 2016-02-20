Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 19C9B6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 20:39:52 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id y8so51573275igp.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 17:39:52 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id rp4si16733540igb.66.2016.02.19.17.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 17:39:51 -0800 (PST)
Date: Sat, 20 Feb 2016 12:39:42 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Problems with THP in v4.5-rc4 on POWER
Message-ID: <20160220013942.GA16191@fergus.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org

It seems there's something wrong with our transparent hugepage
implementation on POWER server processors as of v4.5-rc4.  I have seen
the email thread on "[BUG] random kernel crashes after THP rework on
s390 (maybe also on PowerPC and ARM)", but this doesn't seem exactly
the same as that (though it may of course be related).

I have been testing v4.5-rc4 with Aneesh's patch "powerpc/mm/hash:
Clear the invalid slot information correctly" on top, on a KVM guest
with 160 vcpus (threads=8) and 32GB of memory backed by 16MB large
pages, running on a POWER8 machine running a 4.4.1 host kernel (20
cores * 8 threads, 128GB of RAM).  The guest kernel is compiled with
THP enabled and set to "always" (i.e. not "madvise").

On this setup, when doing something like a large kernel compile, I see
random segfaults happening (in gcc, cc1, sh, etc.).  I also see bursts
of messages like this on the host console:

[50957.570859] Harmless Hypervisor Maintenance interrupt [Recovered]
[50957.570864]  Error detail: Processor Recovery done
[50957.570869]  HMER: 2040000000000000

and once I saw an unrecoverable HMI that crashed the host.  I don't
see anything like this with a 4.3.0 kernel, and the same kernel
compile proceeds flawlessly.

One thing I discovered when debugging is that we are getting to
flush_hash_hugepage() with no slot array available
(i.e. get_hpte_slot_array(pmdp) returns NULL).  So I added code to do
an explicit search for any HPTEs that need to be flushed.  The patch
to do this is below.  For the pSeries LPAR case (which this is) I also
print a message with the number of HPTEs that were found.  When
running with this patch, I see the message printed out from time to
time, like this:

pSeries_lpar_hugepage_invalidate: no slot array, found 25 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 1 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 26 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 3 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 8 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 9 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 13 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 9 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 2 HPTEs
grep thp /proc/vmstat 
thp_fault_alloc 3253
thp_fault_fallback 0
thp_collapse_alloc 5
thp_collapse_alloc_failed 0
thp_split_page 0
thp_split_page_failed 0
thp_split_pmd 9
thp_zero_page_alloc 1
thp_zero_page_alloc_failed 0
[root@dyn386 ~]# pSeries_lpar_hugepage_invalidate: no slot array, found 8 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 29 HPTEs
pSeries_lpar_hugepage_invalidate: no slot array, found 196 HPTEs
gcc[58246]: unhandled signal 11 at 0000000000000008 nip 00003fff7a7d5a08 lr 00003fff7a7d57f4 code 30001
pSeries_lpar_hugepage_invalidate: no slot array, found 256 HPTEs

So in fact there are HPTEs to be invalidated in the cases where we
don't have the slot array - which could be an explanation for apparent
memory corruption.  However, doing the invalidations doesn't fix the
problems.  (Possibly there is a bug in my patch and we are still not
invalidating the HPTEs correctly.)

Interestingly, whenever the "no slot array" message happens, I
immediately see a burst of the HMI interrupt messages on the host
console.  So whatever we are doing wrong is creating a situation where
the CPU thinks it has encountered an error and needs to recover.

Thoughts? anyone?

Paul.
---
diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index 8eaac81..a433e16 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -339,22 +339,28 @@ static long native_hpte_find(unsigned long vpn, int psize, int ssize)
 	struct hash_pte *hptep;
 	unsigned long hash;
 	unsigned long i;
-	long slot;
+	long slot, tries;
 	unsigned long want_v, hpte_v;
+	unsigned long mask;
 
 	hash = hpt_hash(vpn, mmu_psize_defs[psize].shift, ssize);
-	want_v = hpte_encode_avpn(vpn, psize, ssize);
+	want_v = hpte_encode_avpn(vpn, psize, ssize) | HPTE_V_VALID;
+	mask = SLB_VSID_B | HPTE_V_AVPN | HPTE_V_SECONDARY | HPTE_V_VALID;
 
-	/* Bolted mappings are only ever in the primary group */
+	/* Search the primary group then the secondary */
 	slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-	for (i = 0; i < HPTES_PER_GROUP; i++) {
-		hptep = htab_address + slot;
-		hpte_v = be64_to_cpu(hptep->v);
+	for (tries = 0; tries < 2; ++tries) {
+		for (i = 0; i < HPTES_PER_GROUP; i++) {
+			hptep = htab_address + slot;
+			hpte_v = be64_to_cpu(hptep->v);
 
-		if (HPTE_V_COMPARE(hpte_v, want_v) && (hpte_v & HPTE_V_VALID))
-			/* HPTE matches */
-			return slot;
-		++slot;
+			if ((hpte_v & mask) == want_v)
+				/* HPTE matches */
+				return slot;
+			++slot;
+		}
+		want_v |= HPTE_V_SECONDARY;
+		slot = (~hash & htab_hash_mask) * HPTES_PER_GROUP;
 	}
 
 	return -1;
@@ -448,20 +454,27 @@ static void native_hugepage_invalidate(unsigned long vsid,
 
 	local_irq_save(flags);
 	for (i = 0; i < max_hpte_count; i++) {
-		valid = hpte_valid(hpte_slot_array, i);
-		if (!valid)
-			continue;
-		hidx =  hpte_hash_index(hpte_slot_array, i);
-
 		/* get the vpn */
 		addr = s_addr + (i * (1ul << shift));
 		vpn = hpt_vpn(addr, vsid, ssize);
-		hash = hpt_hash(vpn, shift, ssize);
-		if (hidx & _PTEIDX_SECONDARY)
-			hash = ~hash;
+		if (hpte_slot_array) {
+			valid = hpte_valid(hpte_slot_array, i);
+			if (!valid)
+				continue;
+			hidx =  hpte_hash_index(hpte_slot_array, i);
 
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+			hash = hpt_hash(vpn, shift, ssize);
+			if (hidx & _PTEIDX_SECONDARY)
+				hash = ~hash;
+
+			slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
+			slot += hidx & _PTEIDX_GROUP_IX;
+		} else {
+			/* no slot array, will have to search for the HPTE */
+			slot = native_hpte_find(vpn, psize, ssize);
+			if (slot == (unsigned long)-1)
+				continue;
+		}
 
 		hptep = htab_address + slot;
 		want_v = hpte_encode_avpn(vpn, psize, ssize);
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 47a0bc1..777ab6b 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -1348,6 +1348,13 @@ void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
 
 	s_addr = addr & HPAGE_PMD_MASK;
 	hpte_slot_array = get_hpte_slot_array(pmdp);
+
+	if (ppc_md.hugepage_invalidate) {
+		ppc_md.hugepage_invalidate(vsid, s_addr, hpte_slot_array,
+					   psize, ssize, local);
+		goto tm_abort;
+	}
+
 	/*
 	 * IF we try to do a HUGE PTE update after a withdraw is done.
 	 * we will find the below NULL. This happens when we do
@@ -1356,13 +1363,8 @@ void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
 	if (!hpte_slot_array)
 		return;
 
-	if (ppc_md.hugepage_invalidate) {
-		ppc_md.hugepage_invalidate(vsid, s_addr, hpte_slot_array,
-					   psize, ssize, local);
-		goto tm_abort;
-	}
 	/*
-	 * No bluk hpte removal support, invalidate each entry
+	 * No bulk hpte removal support, invalidate each entry
 	 */
 	shift = mmu_psize_defs[psize].shift;
 	max_hpte_count = HPAGE_PMD_SIZE >> shift;
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 477290a..142e669 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -323,7 +323,10 @@ static long __pSeries_lpar_hpte_find(unsigned long want_v, unsigned long hpte_gr
 		unsigned long pteh;
 		unsigned long ptel;
 	} ptes[4];
+	unsigned long mask;
 
+	mask = SLB_VSID_B | HPTE_V_AVPN | HPTE_V_SECONDARY | HPTE_V_VALID;
+	want_v |= HPTE_V_VALID;
 	for (i = 0; i < HPTES_PER_GROUP; i += 4, hpte_group += 4) {
 
 		lpar_rc = plpar_pte_read_4(0, hpte_group, (void *)ptes);
@@ -331,8 +334,7 @@ static long __pSeries_lpar_hpte_find(unsigned long want_v, unsigned long hpte_gr
 			continue;
 
 		for (j = 0; j < 4; j++) {
-			if (HPTE_V_COMPARE(ptes[j].pteh, want_v) &&
-			    (ptes[j].pteh & HPTE_V_VALID))
+			if ((ptes[j].pteh & mask) == want_v)
 				return i + j;
 		}
 	}
@@ -350,11 +352,17 @@ static long pSeries_lpar_hpte_find(unsigned long vpn, int psize, int ssize)
 	hash = hpt_hash(vpn, mmu_psize_defs[psize].shift, ssize);
 	want_v = hpte_encode_avpn(vpn, psize, ssize);
 
-	/* Bolted entries are always in the primary group */
 	hpte_group = (hash & htab_hash_mask) * HPTES_PER_GROUP;
 	slot = __pSeries_lpar_hpte_find(want_v, hpte_group);
-	if (slot < 0)
-		return -1;
+	if (slot < 0) {
+		/* try the secondary group */
+		hash = ~hash;
+		want_v |= HPTE_V_SECONDARY;
+		hpte_group = (hash & htab_hash_mask) * HPTES_PER_GROUP;
+		slot = __pSeries_lpar_hpte_find(want_v, hpte_group);
+		if (slot < 0)
+			return -1;
+	}
 	return hpte_group + slot;
 }
 
@@ -451,37 +459,46 @@ static void pSeries_lpar_hugepage_invalidate(unsigned long vsid,
 					     unsigned char *hpte_slot_array,
 					     int psize, int ssize, int local)
 {
-	int i, index = 0;
+	long i, index = 0;
 	unsigned long s_addr = addr;
 	unsigned int max_hpte_count, valid;
 	unsigned long vpn_array[PPC64_HUGE_HPTE_BATCH];
 	unsigned long slot_array[PPC64_HUGE_HPTE_BATCH];
 	unsigned long shift, hidx, vpn = 0, hash, slot;
+	unsigned long count = 0;
 
 	shift = mmu_psize_defs[psize].shift;
 	max_hpte_count = 1U << (PMD_SHIFT - shift);
 
 	for (i = 0; i < max_hpte_count; i++) {
-		valid = hpte_valid(hpte_slot_array, i);
-		if (!valid)
-			continue;
-		hidx =  hpte_hash_index(hpte_slot_array, i);
-
 		/* get the vpn */
-		addr = s_addr + (i * (1ul << shift));
+		addr = s_addr + (i << shift);
 		vpn = hpt_vpn(addr, vsid, ssize);
-		hash = hpt_hash(vpn, shift, ssize);
-		if (hidx & _PTEIDX_SECONDARY)
-			hash = ~hash;
+		if (hpte_slot_array) {
+			valid = hpte_valid(hpte_slot_array, i);
+			if (!valid)
+				continue;
+			hidx =  hpte_hash_index(hpte_slot_array, i);
 
-		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
-		slot += hidx & _PTEIDX_GROUP_IX;
+			hash = hpt_hash(vpn, shift, ssize);
+			if (hidx & _PTEIDX_SECONDARY)
+				hash = ~hash;
+
+			slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
+			slot += hidx & _PTEIDX_GROUP_IX;
+
+		} else {
+			slot = pSeries_lpar_hpte_find(vpn, psize, ssize);
+			if (slot == (unsigned long)-1)
+				continue;
+			++count;
+		}
 
 		slot_array[index] = slot;
 		vpn_array[index] = vpn;
 		if (index == PPC64_HUGE_HPTE_BATCH - 1) {
 			/*
-			 * Now do a bluk invalidate
+			 * Now do a bulk invalidate
 			 */
 			__pSeries_lpar_hugepage_invalidate(slot_array,
 							   vpn_array,
@@ -494,6 +511,8 @@ static void pSeries_lpar_hugepage_invalidate(unsigned long vsid,
 	if (index)
 		__pSeries_lpar_hugepage_invalidate(slot_array, vpn_array,
 						   index, psize, ssize);
+	if (!hpte_slot_array)
+		pr_info("pSeries_lpar_hugepage_invalidate: no slot array, found %ld HPTEs\n", count);
 }
 #else
 static void pSeries_lpar_hugepage_invalidate(unsigned long vsid,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
