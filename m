Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id C5E376B0127
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:21:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Apr 2013 22:47:38 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AE9AB394002D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 22:51:02 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3UHKvmq15532322
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 22:50:57 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3UHL1CB032139
	for <linux-mm@kvack.org>; Wed, 1 May 2013 03:21:01 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 18/18] powerpc: Update tlbie/tlbiel as per ISA doc
In-Reply-To: <20130430061522.GC20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367177859-7893-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130430061522.GC20202@truffula.fritz.box>
Date: Tue, 30 Apr 2013 22:51:00 +0530
Message-ID: <87ppxc9bpf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Mon, Apr 29, 2013 at 01:07:39AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Encode the actual page correctly in tlbie/tlbiel. This make sure we handle
>> multiple page size segment correctly.
>
> As mentioned in previous comments, this commit message needs to give
> much more detail about what precisely the existing implementation is
> doing wrong.
>
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/mm/hash_native_64.c | 32 ++++++++++++++++++++++++++++++--
>>  1 file changed, 30 insertions(+), 2 deletions(-)
>> 
>> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
>> index bb920ee..6a2aead 100644
>> --- a/arch/powerpc/mm/hash_native_64.c
>> +++ b/arch/powerpc/mm/hash_native_64.c
>> @@ -61,7 +61,10 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
>>  
>>  	switch (psize) {
>>  	case MMU_PAGE_4K:
>> +		/* clear out bits after (52) [0....52.....63] */
>> +		va &= ~((1ul << (64 - 52)) - 1);
>>  		va |= ssize << 8;
>> +		va |= mmu_psize_defs[apsize].sllp << 6;
>>  		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
>>  			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
>>  			     : "memory");
>> @@ -69,9 +72,20 @@ static inline void __tlbie(unsigned long vpn, int psize, int apsize, int ssize)
>>  	default:
>>  		/* We need 14 to 14 + i bits of va */
>>  		penc = mmu_psize_defs[psize].penc[apsize];
>> -		va &= ~((1ul << mmu_psize_defs[psize].shift) - 1);
>> +		va &= ~((1ul << mmu_psize_defs[apsize].shift) - 1);
>>  		va |= penc << 12;
>>  		va |= ssize << 8;
>> +		/* Add AVAL part */
>> +		if (psize != apsize) {
>> +			/*
>> +			 * MPSS, 64K base page size and 16MB parge page size
>> +			 * We don't need all the bits, but rest of the bits
>> +			 * must be ignored by the processor.
>> +			 * vpn cover upto 65 bits of va. (0...65) and we need
>> +			 * 58..64 bits of va.
>
> I can't understand what this comment is saying.  Why do we need to do
> something different in the psize != apsize case?
>
>> +			 */
>> +			va |= (vpn & 0xfe);
>> +		}

That is as per ISA doc. It says if base page size == actual page size,
(RB)56:62 must be zeros, which must be ignored by the processor.
Otherwise it should be filled with the selected bits of VA as explained above.

We only support MPSS with base page size = 64K and actual page size = 16MB.

-aneesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
