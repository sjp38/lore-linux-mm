Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 95B576B02F5
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:05:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 May 2013 00:30:31 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 50D753940053
	for <linux-mm@kvack.org>; Sat,  4 May 2013 00:35:09 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43J531961407314
	for <linux-mm@kvack.org>; Sat, 4 May 2013 00:35:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43J57ph026915
	for <linux-mm@kvack.org>; Sat, 4 May 2013 05:05:08 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 09/10] powerpc: Optimize hugepage invalidate
In-Reply-To: <20130503052846.GU13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367178711-8232-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130503052846.GU13041@truffula.fritz.box>
Date: Sat, 04 May 2013 00:35:07 +0530
Message-ID: <87fvy351gc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Mon, Apr 29, 2013 at 01:21:50AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Hugepage invalidate involves invalidating multiple hpte entries.
>> Optimize the operation using H_BULK_REMOVE on lpar platforms.
>> On native, reduce the number of tlb flush.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Since this is purely an optimization, have you tried reproducing the
> bugs you're chasing with this patch not included?

That was due to not handling thp split while walking page table. I have
that fixed. Will post the next version soon.

>
>> ---
>>  arch/powerpc/include/asm/machdep.h    |   3 +
>>  arch/powerpc/mm/hash_native_64.c      |  78 +++++++++++++++++++++
>>  arch/powerpc/mm/pgtable_64.c          |  13 +++-
>>  arch/powerpc/platforms/pseries/lpar.c | 126 ++++++++++++++++++++++++++++++++--
>>  4 files changed, 210 insertions(+), 10 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
>> index 3f3f691..5d1e7d2 100644
>> --- a/arch/powerpc/include/asm/machdep.h
>> +++ b/arch/powerpc/include/asm/machdep.h
>> @@ -56,6 +56,9 @@ struct machdep_calls {

.....

>>  
>> +/*
>> + * Limit iterations holding pSeries_lpar_tlbie_lock to 3. We also need
>> + * to make sure that we avoid bouncing the hypervisor tlbie lock.
>> + */
>> +#define PPC64_HUGE_HPTE_BATCH 12
>> +
>> +static void __pSeries_lpar_hugepage_invalidate(unsigned long *slot,
>> +					     unsigned long *vpn, int count,
>> +					     int psize, int ssize)
>> +{
>> +	unsigned long param[9];
>
> [9]?  I only see 8 elements being used.

cut paste error from pSeries_lpar_flush_hash_range

>
>> +	int i = 0, pix = 0, rc;
>> +	unsigned long flags = 0;
>> +	int lock_tlbie = !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
>> +
>> +	if (lock_tlbie)
>> +		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);
>
> Why are these hash operations being called with the tlbie lock held?

if the firmware doesn't support lockless TLBIE, we need to do locking
at the guest side. pSeries_lpar_flush_hash_range does that.

>
>> +
>> +	for (i = 0; i < count; i++) {
>> +
>> +		if (!firmware_has_feature(FW_FEATURE_BULK_REMOVE)) {
>> +			pSeries_lpar_hpte_invalidate(slot[i], vpn[i], psize,
>> +						     ssize, 0);
>
> Couldn't you set the ppc_md hook based on the firmware request to
> avoid this test in the inner loop?  I don't see any tlbie operations
> at all.

didn't get that.

>
>> +		} else {
>> +			param[pix] = HBR_REQUEST | HBR_AVPN | slot[i];
>> +			param[pix+1] = hpte_encode_avpn(vpn[i], psize, ssize);
>> +			pix += 2;
>> +			if (pix == 8) {
>> +				rc = plpar_hcall9(H_BULK_REMOVE, param,
>> +						  param[0], param[1], param[2],
>> +						  param[3], param[4], param[5],
>> +						  param[6], param[7]);
>> +				BUG_ON(rc != H_SUCCESS);
>> +				pix = 0;
>> +			}
>> +		}
>> +	}
>> +	if (pix) {
>> +		param[pix] = HBR_END;
>> +		rc = plpar_hcall9(H_BULK_REMOVE, param, param[0], param[1],
>> +				  param[2], param[3], param[4], param[5],
>> +				  param[6], param[7]);
>> +		BUG_ON(rc != H_SUCCESS);
>> +	}
>> +
>> +	if (lock_tlbie)
>> +		spin_unlock_irqrestore(&pSeries_lpar_tlbie_lock, flags);
>> +}
>> +
>> +static void pSeries_lpar_hugepage_invalidate(struct mm_struct *mm,
>> +				       unsigned char *hpte_slot_array,
>> +				       unsigned long addr, int psize)
>> +{
>> +	int ssize = 0, i, index = 0;
>> +	unsigned long s_addr = addr;
>> +	unsigned int max_hpte_count, valid;
>> +	unsigned long vpn_array[PPC64_HUGE_HPTE_BATCH];
>> +	unsigned long slot_array[PPC64_HUGE_HPTE_BATCH];
>> +	unsigned long shift, hidx, vpn = 0, vsid, hash, slot;
>> +
>> +	shift = mmu_psize_defs[psize].shift;
>> +	max_hpte_count = HUGE_PAGE_SIZE >> shift;
>> +
>> +	for (i = 0; i < max_hpte_count; i++) {
>> +		/*
>> +		 * 8 bits per each hpte entries
>> +		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
>> +		 */
>> +		valid = hpte_slot_array[i] & 0x1;
>> +		if (!valid)
>> +			continue;
>> +		hidx =  hpte_slot_array[i]  >> 1;
>> +
>> +		/* get the vpn */
>> +		addr = s_addr + (i * (1ul << shift));
>> +		if (!is_kernel_addr(addr)) {
>> +			ssize = user_segment_size(addr);
>> +			vsid = get_vsid(mm->context.id, addr, ssize);
>> +			WARN_ON(vsid == 0);
>> +		} else {
>> +			vsid = get_kernel_vsid(addr, mmu_kernel_ssize);
>> +			ssize = mmu_kernel_ssize;
>> +		}
>> +
>> +		vpn = hpt_vpn(addr, vsid, ssize);
>> +		hash = hpt_hash(vpn, shift, ssize);
>> +		if (hidx & _PTEIDX_SECONDARY)
>> +			hash = ~hash;
>> +
>> +		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
>> +		slot += hidx & _PTEIDX_GROUP_IX;
>> +
>> +		slot_array[index] = slot;
>> +		vpn_array[index] = vpn;
>> +		if (index == PPC64_HUGE_HPTE_BATCH - 1) {
>> +			/*
>> +			 * Now do a bluk invalidate
>> +			 */
>> +			__pSeries_lpar_hugepage_invalidate(slot_array,
>> +							   vpn_array,
>> +							   PPC64_HUGE_HPTE_BATCH,
>> +							   psize, ssize);
>
> I don't really understand why you have one loop in this function, then
> another in the __ function.

?? if we didn't accumulate batch size number of entries, we won't call
the above. Hence we will have to do the bulk remove outside the if
loop. 


>
>> +			index = 0;
>> +		} else
>> +			index++;
>> +	}
>> +	if (index)
>> +		__pSeries_lpar_hugepage_invalidate(slot_array, vpn_array,
>> +						   index, psize, ssize);
>> +}
>> +
>>  static void pSeries_lpar_hpte_removebolted(unsigned long ea,
>>  					   int psize, int ssize)
>>  {
>> @@ -360,13 +478,6 @@ static void pSeries_lpar_hpte_removebolted(unsigned long ea,
>>  	pSeries_lpar_hpte_invalidate(slot, vpn, psize, ssize, 0);
>>  }
>>  
>> -/* Flag bits for H_BULK_REMOVE */
>> -#define HBR_REQUEST	0x4000000000000000UL
>> -#define HBR_RESPONSE	0x8000000000000000UL
>> -#define HBR_END		0xc000000000000000UL
>> -#define HBR_AVPN	0x0200000000000000UL
>> -#define HBR_ANDCOND	0x0100000000000000UL
>> -
>>  /*
>>   * Take a spinlock around flushes to avoid bouncing the hypervisor tlbie
>>   * lock.
>> @@ -452,6 +563,7 @@ void __init hpte_init_lpar(void)
>>  	ppc_md.hpte_removebolted = pSeries_lpar_hpte_removebolted;
>>  	ppc_md.flush_hash_range	= pSeries_lpar_flush_hash_range;
>>  	ppc_md.hpte_clear_all   = pSeries_lpar_hptab_clear;
>> +	ppc_md.hugepage_invalidate = pSeries_lpar_hugepage_invalidate;
>>  }
>>  
>>  #ifdef CONFIG_PPC_SMLPAR
>
> -- 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
