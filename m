Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 0855A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 04:11:36 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 18:02:47 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D8F0E2CE804D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:11:31 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A7wDOb44433572
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:58:13 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A8BUg2008140
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:11:30 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 08/25] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <20130410071915.GI8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410071915.GI8165@truffula.fritz.box>
Date: Wed, 10 Apr 2013 13:41:16 +0530
Message-ID: <87li8qolej.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Thu, Apr 04, 2013 at 11:27:46AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We look at both the segment base page size and actual page size and store
>> the pte-lp-encodings in an array per base page size.
>> 
>> We also update all relevant functions to take actual page size argument
>> so that we can use the correct PTE LP encoding in HPTE. This should also
>> get the basic Multiple Page Size per Segment (MPSS) support. This is needed
>> to enable THP on ppc64.
>> 

....

>> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
>> +{
>> +	int i, shift;
>> +	unsigned int mask;
>> +	/* Look at the 8 bit LP value */
>> +	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
>> +
>> +	if (!(hptep->v & HPTE_V_VALID))
>> +		return -1;
>
> Folding the validity check into the size check seems confusing to me.

We do end up with invalid hpte with which we call
hpte_actual_psize. So that check is needed. I can either move to caller,
but then i will have to replicate it in all the call sites.


>
>> +	/* First check if it is large page */
>> +	if (!(hptep->v & HPTE_V_LARGE))
>> +		return MMU_PAGE_4K;
>> +
>> +	/* start from 1 ignoring MMU_PAGE_4K */
>> +	for (i = 1; i < MMU_PAGE_COUNT; i++) {
>> +		/* valid entries have a shift value */
>> +		if (!mmu_psize_defs[i].shift)
>> +			continue;
>
> Isn't this check redundant with the one below?

Yes. I guess we can safely assume that if penc is valid then we do
support that specific large page.

I will drop this and keep the penc check. That is more correct check

>
>> +		/* invalid penc */
>> +		if (mmu_psize_defs[psize].penc[i] == -1)
>> +			continue;
>> +		/*
>> +		 * encoding bits per actual page size
>> +		 *        PTE LP     actual page size
>> +		 *    rrrr rrrz		>=8KB
>> +		 *    rrrr rrzz		>=16KB
>> +		 *    rrrr rzzz		>=32KB
>> +		 *    rrrr zzzz		>=64KB
>> +		 * .......
>> +		 */
>> +		shift = mmu_psize_defs[i].shift - LP_SHIFT;
>> +		if (shift > LP_BITS)
>> +			shift = LP_BITS;
>> +		mask = (1 << shift) - 1;
>> +		if ((lp & mask) == mmu_psize_defs[psize].penc[i])
>> +			return i;
>> +	}
>
> Shouldn't we have a BUG() or something here.  If we get here we've
> somehow created a PTE with LP bits we can't interpret, yes?
>

I don't know. Is BUG() the right thing to do ? 


>> +	return -1;
>> +}
>> +
>>  static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
>>  				 unsigned long vpn, int psize, int ssize,
>>  				 int local)
>> @@ -251,6 +294,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
>>  	struct hash_pte *hptep = htab_address + slot;
>>  	unsigned long hpte_v, want_v;
>>  	int ret = 0;
>> +	int actual_psize;
>>  
>>  	want_v = hpte_encode_avpn(vpn, psize, ssize);
>>  
>> @@ -260,9 +304,13 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
>>  	native_lock_hpte(hptep);
>>  
>>  	hpte_v = hptep->v;
>> -
>> +	actual_psize = hpte_actual_psize(hptep, psize);
>> +	if (actual_psize < 0) {
>> +		native_unlock_hpte(hptep);
>> +		return -1;
>> +	}
>
> Wouldn't it make more sense to only do the psize lookup once you've
> found a matching hpte?

But we need to do psize lookup even if V_COMPARE fail, because we want
to do tlbie in both the case.

>
>>  	/* Even if we miss, we need to invalidate the TLB */
>> -	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID)) {
>> +	if (!HPTE_V_COMPARE(hpte_v, want_v)) {
>>  		DBG_LOW(" -> miss\n");
>>  		ret = -1;
>>  	} else {
>> @@ -274,7 +322,7 @@ static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
>>  	native_unlock_hpte(hptep);
>>  
>>  	/* Ensure it is out of the tlb too. */
>> -	tlbie(vpn, psize, ssize, local);
>> +	tlbie(vpn, psize, actual_psize, ssize, local);
>>  
>>  	return ret;
>>  }
>> @@ -315,6 +363,7 @@ static long native_hpte_find(unsigned long vpn, int psize, int ssize)
>>  static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
>>  				       int psize, int ssize)
>>  {
>> +	int actual_psize;
>>  	unsigned long vpn;
>>  	unsigned long vsid;
>>  	long slot;
>> @@ -327,13 +376,16 @@ static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
>>  	if (slot == -1)
>>  		panic("could not find page to bolt\n");
>>  	hptep = htab_address + slot;
>> +	actual_psize = hpte_actual_psize(hptep, psize);
>> +	if (actual_psize < 0)
>> +		return;
>>  
>>  	/* Update the HPTE */
>>  	hptep->r = (hptep->r & ~(HPTE_R_PP | HPTE_R_N)) |
>>  		(newpp & (HPTE_R_PP | HPTE_R_N));
>>  
>>  	/* Ensure it is out of the tlb too. */
>> -	tlbie(vpn, psize, ssize, 0);
>> +	tlbie(vpn, psize, actual_psize, ssize, 0);
>>  }
>>  
>>  static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
>> @@ -343,6 +395,7 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
>>  	unsigned long hpte_v;
>>  	unsigned long want_v;
>>  	unsigned long flags;
>> +	int actual_psize;
>>  
>>  	local_irq_save(flags);
>>  
>> @@ -352,35 +405,38 @@ static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
>>  	native_lock_hpte(hptep);
>>  	hpte_v = hptep->v;
>>  
>> +	actual_psize = hpte_actual_psize(hptep, psize);
>> +	if (actual_psize < 0) {
>> +		native_unlock_hpte(hptep);
>> +		local_irq_restore(flags);
>> +		return;
>> +	}
>>  	/* Even if we miss, we need to invalidate the TLB */
>> -	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID))
>> +	if (!HPTE_V_COMPARE(hpte_v, want_v))
>>  		native_unlock_hpte(hptep);
>>  	else
>>  		/* Invalidate the hpte. NOTE: this also unlocks it */
>>  		hptep->v = 0;
>>  
>>  	/* Invalidate the TLB */
>> -	tlbie(vpn, psize, ssize, local);
>> +	tlbie(vpn, psize, actual_psize, ssize, local);
>>  
>>  	local_irq_restore(flags);
>>  }
>>  
>> -#define LP_SHIFT	12
>> -#define LP_BITS		8
>> -#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
>> -
>>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>> -			int *psize, int *ssize, unsigned long *vpn)
>> +			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>>  {
>>  	unsigned long avpn, pteg, vpi;
>>  	unsigned long hpte_r = hpte->r;
>>  	unsigned long hpte_v = hpte->v;
>>  	unsigned long vsid, seg_off;
>> -	int i, size, shift, penc;
>> +	int i, size, a_size, shift, penc;
>>  
>> -	if (!(hpte_v & HPTE_V_LARGE))
>> -		size = MMU_PAGE_4K;
>> -	else {
>> +	if (!(hpte_v & HPTE_V_LARGE)) {
>> +		size   = MMU_PAGE_4K;
>> +		a_size = MMU_PAGE_4K;
>> +	} else {
>>  		for (i = 0; i < LP_BITS; i++) {
>>  			if ((hpte_r & LP_MASK(i+1)) == LP_MASK(i+1))
>>  				break;
>> @@ -388,19 +444,26 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>>  		penc = LP_MASK(i+1) >> LP_SHIFT;
>>  		for (size = 0; size < MMU_PAGE_COUNT; size++) {
>
>>  
>> -			/* 4K pages are not represented by LP */
>> -			if (size == MMU_PAGE_4K)
>> -				continue;
>> -
>>  			/* valid entries have a shift value */
>>  			if (!mmu_psize_defs[size].shift)
>>  				continue;
>> +			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++) {
>
> Can't you resize hpte_actual_psize() here instead of recoding the
> lookup?

I thought about that, but re-coding avoided some repeated check. But
then, if I follow your review comments of avoiding hpte valid check etc, may
be I can reuse the hpte_actual_psize. Will try this. 


>
>> -			if (penc == mmu_psize_defs[size].penc)
>> -				break;
>> +				/* 4K pages are not represented by LP */
>> +				if (a_size == MMU_PAGE_4K)
>> +					continue;
>> +
>> +				/* valid entries have a shift value */
>> +				if (!mmu_psize_defs[a_size].shift)
>> +					continue;
>> +
>> +				if (penc == mmu_psize_defs[size].penc[a_size])
>> +					goto out;
>> +			}
>>  		}
>>  	}
>>  
>> +out:

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
