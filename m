Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id C8F876B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 21:39:32 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id y89so4901972qge.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 18:39:32 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id g6si1340582qhd.43.2016.02.09.18.39.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 18:39:32 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 9 Feb 2016 19:39:31 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id CB5B319D8042
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 19:27:27 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1A2dTk031260722
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 19:39:29 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1A2dSnH023051
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 19:39:28 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm: Some arch may want to use HPAGE_PMD related values as variables
In-Reply-To: <20160209132608.814f08a0c3670b4f9d807441@linux-foundation.org>
References: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160209132608.814f08a0c3670b4f9d807441@linux-foundation.org>
Date: Wed, 10 Feb 2016 08:09:24 +0530
Message-ID: <87io1xxp9f.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue,  9 Feb 2016 21:41:44 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> With next generation power processor, we are having a new mmu model
>> [1] that require us to maintain a different linux page table format.
>> 
>> Inorder to support both current and future ppc64 systems with a single
>> kernel we need to make sure kernel can select between different page
>> table format at runtime. With the new MMU (radix MMU) added, we will
>> have two different pmd hugepage size 16MB for hash model and 2MB for
>> Radix model. Hence make HPAGE_PMD related values as a variable.
>> 
>> [1] http://ibm.biz/power-isa3 (Needs registration).
>> 
>> ...
>>
>> --- a/include/linux/bug.h
>> +++ b/include/linux/bug.h
>> @@ -20,6 +20,7 @@ struct pt_regs;
>>  #define BUILD_BUG_ON_MSG(cond, msg) (0)
>>  #define BUILD_BUG_ON(condition) (0)
>>  #define BUILD_BUG() (0)
>> +#define MAYBE_BUILD_BUG_ON(cond) (0)
>>  #else /* __CHECKER__ */
>>  
>>  /* Force a compilation error if a constant expression is not a power of 2 */
>> @@ -83,6 +84,14 @@ struct pt_regs;
>>   */
>>  #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>>  
>> +#define MAYBE_BUILD_BUG_ON(cond)			\
>> +	do {						\
>> +		if (__builtin_constant_p((cond)))       \
>> +			BUILD_BUG_ON(cond);             \
>> +		else                                    \
>> +			BUG_ON(cond);                   \
>> +	} while (0)
>> +
>
> hm.  I suppose so.
>
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -111,9 +111,6 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>>  			__split_huge_pmd(__vma, __pmd, __address);	\
>>  	}  while (0)
>>  
>> -#if HPAGE_PMD_ORDER >= MAX_ORDER
>> -#error "hugepages can't be allocated by the buddy allocator"
>> -#endif
>>  extern int hugepage_madvise(struct vm_area_struct *vma,
>>  			    unsigned long *vm_flags, int advice);
>>  extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index cd26f3f14cab..350410e9019e 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -83,7 +83,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
>>  	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>>  
>>  /* default scan 8*512 pte (or vmas) every 30 second */
>> -static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
>> +static unsigned int khugepaged_pages_to_scan __read_mostly;
>>  static unsigned int khugepaged_pages_collapsed;
>>  static unsigned int khugepaged_full_scans;
>>  static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
>> @@ -98,7 +98,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>>   * it would have happened if the vma was large enough during page
>>   * fault.
>>   */
>> -static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
>> +static unsigned int khugepaged_max_ptes_none __read_mostly;
>>  
>>  static int khugepaged(void *none);
>>  static int khugepaged_slab_init(void);
>> @@ -660,6 +660,18 @@ static int __init hugepage_init(void)
>>  		return -EINVAL;
>>  	}
>>  
>> +	khugepaged_pages_to_scan = HPAGE_PMD_NR * 8;
>> +	khugepaged_max_ptes_none = HPAGE_PMD_NR - 1;
>
> I don't understand this change.  We change the initialization from
> at-compile-time to at-run-time, but nothing useful appears to have been
> done.
>

The related changes are in another series, 
https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-February/thread.html#138948

I would also like to keep the two core mm patches[1] in that series so that
it can go with the other related changes via powerpc tree. The reason to
send out them as separate patches is to get the correct feedback so that
it won't get lost in the large series.

Let me know if that is ok with you.

[1] https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-February/138955.html
    https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-February/138964.html

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
