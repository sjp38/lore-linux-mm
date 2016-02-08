Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 77520830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 09:04:54 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id is5so152354268obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 06:04:54 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id t3si16567076obs.47.2016.02.08.06.04.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 06:04:53 -0800 (PST)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 07:04:52 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 850721FF0045
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 06:52:59 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u18E4nk930474488
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 07:04:49 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u18E4mIq003323
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 07:04:49 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] powerpc/mm: Fix Multi hit ERAT cause by recent THP update
In-Reply-To: <20160208075247.GB9075@node.shutemov.name>
References: <1454912062-9681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160208075247.GB9075@node.shutemov.name>
Date: Mon, 08 Feb 2016 19:34:32 +0530
Message-ID: <871t8n1eof.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Mon, Feb 08, 2016 at 11:44:22AM +0530, Aneesh Kumar K.V wrote:
>> With ppc64 we use the deposited pgtable_t to store the hash pte slot
>> information. We should not withdraw the deposited pgtable_t without
>> marking the pmd none. This ensure that low level hash fault handling
>> will skip this huge pte and we will handle them at upper levels.
>>
>> Recent change to pmd splitting changed the above in order to handle the
>> race between pmd split and exit_mmap. The race is explained below.
>>
>> Consider following race:
>>
>> 		CPU0				CPU1
>> shrink_page_list()
>>   add_to_swap()
>>     split_huge_page_to_list()
>>       __split_huge_pmd_locked()
>>         pmdp_huge_clear_flush_notify()
>> 	// pmd_none() == true
>> 					exit_mmap()
>> 					  unmap_vmas()
>> 					    zap_pmd_range()
>> 					      // no action on pmd since pmd_none() == true
>> 	pmd_populate()
>>
>> As result the THP will not be freed. The leak is detected by check_mm():
>>
>> 	BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512
>>
>> The above required us to not mark pmd none during a pmd split.
>>
>> The fix for ppc is to clear the huge pte of _PAGE_USER, so that low
>> level fault handling code skip this pte. At higher level we do take ptl
>> lock. That should serialze us against the pmd split. Once the lock is
>> acquired we do check the pmd again using pmd_same. That should always
>> return false for us and hence we should retry the access.
>
> I guess it worth mention that this serialization against ptl happens in
> huge_pmd_set_accessed(), if I didn't miss anything.

Ok will update the commit message with the below

"We do the pmd_same check in all case after taking plt with
THP (do_huge_pmd_wp_page, do_huge_pmd_numa_page and
huge_pmd_set_accessed)"
>
>>
>> Also make sure we wait for irq disable section in other cpus to finish
>> before flipping a huge pte entry with a regular pmd entry. Code paths
>> like find_linux_pte_or_hugepte depend on irq disable to get
>> a stable pte_t pointer. A parallel thp split need to make sure we
>> don't convert a pmd pte to a regular pmd entry without waiting for the
>> irq disable section to finish.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


.....
...


>>  #ifndef __HAVE_ARCH_PTE_SAME
>>  static inline int pte_same(pte_t pte_a, pte_t pte_b)
>>  {
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 36c070167b71..b52d16a86e91 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2860,6 +2860,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>>  	young = pmd_young(*pmd);
>>  	dirty = pmd_dirty(*pmd);
>>
>> +	pmdp_huge_splitting_flush(vma, haddr, pmd);
>
> Let's call it pmdp_huge_split_prepare().
>
> "_flush" part is ppc-specific implementation detail and generic code
> should not expect tlb to be flushed there.


Ok done

>
> Otherwise,
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
>>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
>>  	pmd_populate(mm, &_pmd, pgtable);
>>
>> --
>> 2.5.0
>>


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
