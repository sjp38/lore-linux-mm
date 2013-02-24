Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5D9916B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 11:51:51 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 02:42:24 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 390C62BB004F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 03:51:43 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1OGdH3158589402
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 03:39:18 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1OGpfj9024551
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 03:51:42 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH -V2 08/21] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <20130222053735.GH6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361465248-10867-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130222053735.GH6139@drongo>
Date: Sun, 24 Feb 2013 22:21:37 +0530
Message-ID: <87sj4lbqp2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Thu, Feb 21, 2013 at 10:17:15PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We look at both the segment base page size and actual page size and store
>> the pte-lp-encodings in an array per base page size.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> This needs more than 2 lines of patch description.  In fact what
> you're doing is adding general mixed page-size segment (MPSS)
> support.  Doing this should mean that you can also get rid of the
> MMU_PAGE_64K_AP value from the list in asm/mmu.h.
>

Can you elaborate on Admixed pages ? I was not able to find more info on
that. 


>>  struct mmu_psize_def
>>  {
>>  	unsigned int	shift;	/* number of bits */
>> -	unsigned int	penc;	/* HPTE encoding */
>> +	unsigned int	penc[MMU_PAGE_COUNT];	/* HPTE encoding */
>
> I guess this is reasonable, though adding space for 14 page size
> encodings seems a little bit over the top.  Also, you don't seem to
> have any way to indicate which encodings are valid, since 0 is a valid
> encoding.  Maybe you need to add a valid bit higher up to indicate
> which page sizes are valid.
>

how about penc = { [0 ... MMU_PAGE_COUNT] = -1 } ?, that would make sure
we set all the bits for invalid entries. 


>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>> index 71d0c90..d2c9932 100644
>> --- a/arch/powerpc/kvm/book3s_hv.c
>> +++ b/arch/powerpc/kvm/book3s_hv.c
>> @@ -1515,7 +1515,12 @@ static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
>>  	(*sps)->page_shift = def->shift;
>>  	(*sps)->slb_enc = def->sllp;
>>  	(*sps)->enc[0].page_shift = def->shift;
>> -	(*sps)->enc[0].pte_enc = def->penc;
>> +	/*
>> +	 * FIXME!!
>> +	 * This is returned to user space. Do we need to
>> +	 * return details of MPSS here ?
>
> Yes, we do, probably a separate entry for each valid base/actual page
> size pair.
>

Ok will do new entries to enc for valid actual page size supported.

for 16MB actual page size 

enc[1].page_shift = 24
enc[1].page_shift = x

should this be a seperate patch ?

>> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
>> +{
>> +	unsigned int mask;
>> +	int i, penc, shift;
>> +	/* Look at the 8 bit LP value */
>> +	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << (LP_BITS + 1)) - 1);
>
> Why LP_BITS + 1 here?  You seem to be extracting and comparing 9 bits
> rather than 8.  Why is that?
>

My mistake.  Will fix

>> @@ -395,12 +422,13 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>>  			/* valid entries have a shift value */
>>  			if (!mmu_psize_defs[size].shift)
>>  				continue;
>> -
>> -			if (penc == mmu_psize_defs[size].penc)
>> -				break;
>> +			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++)
>> +				if (penc == mmu_psize_defs[size].penc[a_size])
>> +					goto out;
>
> I think this will get false matches due to unused/invalid entries
> in mmu_psize_defs[size].penc[] containing 0.

Will set the invalid value to 0xff. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
