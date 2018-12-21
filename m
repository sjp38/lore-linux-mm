Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 316C88E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:20:32 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id f2so1663063ioq.22
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:20:32 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j185si221180ite.5.2018.12.21.10.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 10:20:31 -0800 (PST)
Subject: Re: [PATCH v2 1/2] hugetlbfs: use i_mmap_rwsem for more pmd sharing
 synchronization
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-2-mike.kravetz@oracle.com>
 <20181221100528.bkvddcqom7qaxwbe@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6b91dd42-b903-1f6c-729a-bd9f51273986@oracle.com>
Date: Fri, 21 Dec 2018 10:20:18 -0800
MIME-Version: 1.0
In-Reply-To: <20181221100528.bkvddcqom7qaxwbe@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/21/18 2:05 AM, Kirill A. Shutemov wrote:
> On Tue, Dec 18, 2018 at 02:35:56PM -0800, Mike Kravetz wrote:
>> While looking at BUGs associated with invalid huge page map counts,
>> it was discovered and observed that a huge pte pointer could become
>> 'invalid' and point to another task's page table.  Consider the
>> following:
>>
>> A task takes a page fault on a shared hugetlbfs file and calls
>> huge_pte_alloc to get a ptep.  Suppose the returned ptep points to a
>> shared pmd.
>>
>> Now, another task truncates the hugetlbfs file.  As part of truncation,
>> it unmaps everyone who has the file mapped.  If the range being
>> truncated is covered by a shared pmd, huge_pmd_unshare will be called.
>> For all but the last user of the shared pmd, huge_pmd_unshare will
>> clear the pud pointing to the pmd.  If the task in the middle of the
>> page fault is not the last user, the ptep returned by huge_pte_alloc
>> now points to another task's page table or worse.  This leads to bad
>> things such as incorrect page map/reference counts or invalid memory
>> references.
>>
>> To fix, expand the use of i_mmap_rwsem as follows:
>> - i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
>>   huge_pmd_share is only called via huge_pte_alloc, so callers of
>>   huge_pte_alloc take i_mmap_rwsem before calling.  In addition, callers
>>   of huge_pte_alloc continue to hold the semaphore until finished with
>>   the ptep.
>> - i_mmap_rwsem is held in write mode whenever huge_pmd_unshare is called.
>>
>> Cc: <stable@vger.kernel.org>
>> Fixes: 39dde65c9940 ("shared page table for hugetlb page")
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Other the few questions below. The patch looks reasonable to me.

Thanks for taking a look.

> 
>> @@ -3252,11 +3253,23 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>>  
>>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>>  		spinlock_t *src_ptl, *dst_ptl;
>> +
>>  		src_pte = huge_pte_offset(src, addr, sz);
>>  		if (!src_pte)
>>  			continue;
>> +
>> +		/*
>> +		 * i_mmap_rwsem must be held to call huge_pte_alloc.
>> +		 * Continue to hold until finished  with dst_pte, otherwise
>> +		 * it could go away if part of a shared pmd.
>> +		 *
>> +		 * Technically, i_mmap_rwsem is only needed in the non-cow
>> +		 * case as cow mappings are not shared.
>> +		 */
>> +		i_mmap_lock_read(mapping);
> 
> Any reason you do lock/unlock on each iteration rather than around whole
> loop?

I am simply mirroring the page table locking.  This is not necessary.
The page table lock can change while processing the range, but the
i_mmap_rwsem can not.  Therefore, we can hold around the whole loop.

I will modify, test and put out an updated patch later today.

>>  		dst_pte = huge_pte_alloc(dst, addr, sz);
>>  		if (!dst_pte) {
>> +			i_mmap_unlock_read(mapping);
>>  			ret = -ENOMEM;
>>  			break;
>>  		}
> 
> ...
> 
>> @@ -3772,14 +3789,18 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>  			};
>>  
>>  			/*
>> -			 * hugetlb_fault_mutex must be dropped before
>> -			 * handling userfault.  Reacquire after handling
>> -			 * fault to make calling code simpler.
>> +			 * hugetlb_fault_mutex and i_mmap_rwsem must be
>> +			 * dropped before handling userfault.  Reacquire
>> +			 * after handling fault to make calling code simpler.
>>  			 */
>>  			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
>>  							idx, haddr);
>>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>> +			i_mmap_unlock_read(mapping);
>> +
> 
> Do we have order of hugetlb_fault_mutex vs. i_mmap_lock documented?
> I *looks* correct to me, but it's better to write it down somewhere.
> Mayby add to the header of mm/rmap.c?

No it is not documented.  I don't think there is much/any documentation
for hugetlb_fault_mutex at all.  I will add it to the lock documentation
in mm/rmap.c as you suggest.

-- 
Mike Kravetz
