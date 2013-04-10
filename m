Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9A88B6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:49:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 23:16:02 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 7309BE002D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:21:39 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AHnhXP4456850
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:19:43 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AHnmtJ030130
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 03:49:48 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 08/25] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <87li8qolej.fsf@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410071915.GI8165@truffula.fritz.box> <87li8qolej.fsf@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 23:19:48 +0530
Message-ID: <87bo9mnumb.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

>>>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>>> -			int *psize, int *ssize, unsigned long *vpn)
>>> +			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>>>  {
>>>  	unsigned long avpn, pteg, vpi;
>>>  	unsigned long hpte_r = hpte->r;
>>>  	unsigned long hpte_v = hpte->v;
>>>  	unsigned long vsid, seg_off;
>>> -	int i, size, shift, penc;
>>> +	int i, size, a_size, shift, penc;
>>>  
>>> -	if (!(hpte_v & HPTE_V_LARGE))
>>> -		size = MMU_PAGE_4K;
>>> -	else {
>>> +	if (!(hpte_v & HPTE_V_LARGE)) {
>>> +		size   = MMU_PAGE_4K;
>>> +		a_size = MMU_PAGE_4K;
>>> +	} else {
>>>  		for (i = 0; i < LP_BITS; i++) {
>>>  			if ((hpte_r & LP_MASK(i+1)) == LP_MASK(i+1))
>>>  				break;
>>> @@ -388,19 +444,26 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>>>  		penc = LP_MASK(i+1) >> LP_SHIFT;
>>>  		for (size = 0; size < MMU_PAGE_COUNT; size++) {
>>
>>>  
>>> -			/* 4K pages are not represented by LP */
>>> -			if (size == MMU_PAGE_4K)
>>> -				continue;
>>> -
>>>  			/* valid entries have a shift value */
>>>  			if (!mmu_psize_defs[size].shift)
>>>  				continue;
>>> +			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++) {
>>
>> Can't you resize hpte_actual_psize() here instead of recoding the
>> lookup?
>
> I thought about that, but re-coding avoided some repeated check. But
> then, if I follow your review comments of avoiding hpte valid check etc, may
> be I can reuse the hpte_actual_psize. Will try this. 
>

How about below ?

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index 4427ca8..de235d5 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -271,19 +271,10 @@ static long native_hpte_remove(unsigned long hpte_group)
 	return i;
 }
 
-static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
+static inline int __hpte_actual_psize(unsigned int lp, int psize)
 {
 	int i, shift;
 	unsigned int mask;
-	/* Look at the 8 bit LP value */
-	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
-
-	if (!(hptep->v & HPTE_V_VALID))
-		return -1;
-
-	/* First check if it is large page */
-	if (!(hptep->v & HPTE_V_LARGE))
-		return MMU_PAGE_4K;
 
 	/* start from 1 ignoring MMU_PAGE_4K */
 	for (i = 1; i < MMU_PAGE_COUNT; i++) {
@@ -310,6 +301,21 @@ static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
 	return -1;
 }
 
+static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
+{
+	/* Look at the 8 bit LP value */
+	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
+
+	if (!(hptep->v & HPTE_V_VALID))
+		return -1;
+
+	/* First check if it is large page */
+	if (!(hptep->v & HPTE_V_LARGE))
+		return MMU_PAGE_4K;
+
+	return __hpte_actual_psize(lp, psize);
+}
+
 static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
 				 unsigned long vpn, int psize, int ssize,
 				 int local)
@@ -530,7 +536,7 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 	unsigned long avpn, pteg, vpi;
 	unsigned long hpte_v = hpte->v;
 	unsigned long vsid, seg_off;
-	int size, a_size, shift, mask;
+	int size, a_size, shift;
 	/* Look at the 8 bit LP value */
 	unsigned int lp = (hpte->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
 
@@ -544,33 +550,11 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
 			if (!mmu_psize_defs[size].shift)
 				continue;
 
-			/* start from 1 ignoring MMU_PAGE_4K */
-			for (a_size = 1; a_size < MMU_PAGE_COUNT; a_size++) {
-
-				/* invalid penc */
-				if (mmu_psize_defs[size].penc[a_size] == -1)
-					continue;
-				/*
-				 * encoding bits per actual page size
-				 *        PTE LP     actual page size
-				 *    rrrr rrrz		>=8KB
-				 *    rrrr rrzz		>=16KB
-				 *    rrrr rzzz		>=32KB
-				 *    rrrr zzzz		>=64KB
-				 * .......
-				 */
-				shift = mmu_psize_defs[a_size].shift - LP_SHIFT;
-				if (shift > LP_BITS)
-					shift = LP_BITS;
-				mask = (1 << shift) - 1;
-				if ((lp & mask) ==
-				    mmu_psize_defs[size].penc[a_size]) {
-					goto out;
-				}
-			}
+			a_size = __hpte_actual_psize(lp, size);
+			if (a_size != -1)
+				break;
 		}
 	}
-out:
 	/* This works for all page sizes, and for 256M and 1T segments */
 	*ssize = hpte_v >> HPTE_V_SSIZE_SHIFT;
 	shift = mmu_psize_defs[size].shift;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
