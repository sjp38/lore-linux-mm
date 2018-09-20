Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB038E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:12:10 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id c46-v6so7918219otd.12
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 04:12:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n186-v6si9953171oib.225.2018.09.20.04.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 04:12:09 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8KB8Eeb033502
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:15:26 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mm9773kp8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:15:26 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 20 Sep 2018 05:12:07 -0600
Subject: Re: [PATCH] mm: Recheck page table entry with page table lock held
References: <20180920092408.9128-1-aneesh.kumar@linux.ibm.com>
 <20180920110538.rlcpw75eabkqudkl@kshutemo-mobl1>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 20 Sep 2018 16:41:59 +0530
MIME-Version: 1.0
In-Reply-To: <20180920110538.rlcpw75eabkqudkl@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <a22a21d6-c872-63e9-77ec-8071bac9bfc9@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/20/18 4:35 PM, Kirill A. Shutemov wrote:
> On Thu, Sep 20, 2018 at 02:54:08PM +0530, Aneesh Kumar K.V wrote:
>> We clear the pte temporarily during read/modify/write update of the pte. If we
>> take a page fault while the pte is cleared, the application can get SIGBUS. One
>> such case is with remap_pfn_range without a backing vm_ops->fault callback.
>> do_fault will return SIGBUS in that case.
> 
> It would be nice to show the path that clears pte temporarily.
> 
>> Fix this by taking page table lock and rechecking for pte_none.


we do that in the ptep_modify_prot_start/ptep_modify_prot_commit. Also 
in hugetlb_change_protection. The hugetlb case many not be relevant 
because that cannot be backed by a vma without vma->vm_ops.

What will hit this will be mprotect of a remap_pfn_range address?

>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   mm/memory.c | 31 +++++++++++++++++++++++++++----
>>   1 file changed, 27 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index c467102a5cbc..c2f933184303 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3745,10 +3745,33 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
>>   	struct vm_area_struct *vma = vmf->vma;
>>   	vm_fault_t ret;
>>   
>> -	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
>> -	if (!vma->vm_ops->fault)
>> -		ret = VM_FAULT_SIGBUS;
>> -	else if (!(vmf->flags & FAULT_FLAG_WRITE))
>> +	/*
>> +	 * The VMA was not fully populated on mmap() or missing VM_DONTEXPAND
>> +	 */
>> +	if (!vma->vm_ops->fault) {
>> +
>> +		/*
>> +		 * pmd entries won't be marked none during a R/M/W cycle.
>> +		 */
>> +		if (unlikely(pmd_none(*vmf->pmd)))
>> +			ret = VM_FAULT_SIGBUS;
>> +		else {
>> +			vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +			/*
>> +			 * Make sure this is not a temporary clearing of pte
>> +			 * by holding ptl and checking again. A R/M/W update
>> +			 * of pte involves: take ptl, clearing the pte so that
>> +			 * we don't have concurrent modification by hardware
>> +			 * followed by an update.
>> +			 */
>> +			spin_lock(vmf->ptl);
>> +			if (unlikely(pte_none(*vmf->pte)))
>> +				ret = VM_FAULT_SIGBUS;
>> +			else
>> +				ret = VM_FAULT_NOPAGE;
> 
> We return 0 if we did nothing in fault path.
> 

I didn't get that. If we find the pte not none, we return so that we 
retry the access. Are you suggesting VM_FAULT_NOPAGE is not the right 
return for that?

-aneesh
