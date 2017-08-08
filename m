Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77C4F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:16:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q189so4326751wmd.6
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:16:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n48si1054479wrn.445.2017.08.08.05.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:16:17 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78CEe9g041266
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 08:16:15 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c79csc9xm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:16:15 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 13:16:13 +0100
Subject: Re: [RFC v5 03/11] mm: Introduce pte_spinlock for
 FAULT_FLAG_SPECULATIVE
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-4-git-send-email-ldufour@linux.vnet.ibm.com>
 <bcad987f-055a-e089-440d-baf4a035aef3@linux.vnet.ibm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 14:16:06 +0200
MIME-Version: 1.0
In-Reply-To: <bcad987f-055a-e089-440d-baf4a035aef3@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <fcb3ccc0-7ea7-4ad5-87b0-fcb261fd4323@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 08/08/2017 12:35, Anshuman Khandual wrote:
> On 06/16/2017 11:22 PM, Laurent Dufour wrote:
>> When handling page fault without holding the mmap_sem the fetch of the
>> pte lock pointer and the locking will have to be done while ensuring
>> that the VMA is not touched in our back.
> 
> It does not change things from whats happening right now, where do we
> check that VMA has not changed by now ?

This patch is preparing the use done later in this series, the goal is to
introduce the service and the check which are relevant.
Later when the VMA check will be added this service is changed.
The goal is to ease the review.

> 
>>
>> So move the fetch and locking operations in a dedicated function.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/memory.c | 15 +++++++++++----
>>  1 file changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 40834444ea0d..f1132f7931ef 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2240,6 +2240,13 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
>>  }
>>  
>> +static bool pte_spinlock(struct vm_fault *vmf)
>> +{
>> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	spin_lock(vmf->ptl);
>> +	return true;
>> +}
>> +
> 
> Moving them together makes sense but again if blocks are redundant when
> it returns true all the time.
> 
>>  static bool pte_map_lock(struct vm_fault *vmf)
>>  {
>>  	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
>> @@ -3552,8 +3559,8 @@ static int do_numa_page(struct vm_fault *vmf)
>>  	 * validation through pte_unmap_same(). It's of NUMA type but
>>  	 * the pfn may be screwed if the read is non atomic.
>>  	 */
>> -	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
>> -	spin_lock(vmf->ptl);
>> +	if (!pte_spinlock(vmf))
>> +		return VM_FAULT_RETRY;
>>  	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
>>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>>  		goto out;
>> @@ -3745,8 +3752,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
>>  	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
>>  		return do_numa_page(vmf);
>>  
>> -	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> -	spin_lock(vmf->ptl);
>> +	if (!pte_spinlock(vmf))
>> +		return VM_FAULT_RETRY;
>>  	entry = vmf->orig_pte;
>>  	if (unlikely(!pte_same(*vmf->pte, entry)))
>>  		goto unlock;
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
