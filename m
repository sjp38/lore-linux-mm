Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF276B0286
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 17:54:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d1-v6so14466600qkb.11
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 14:54:57 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t60-v6si2171349qtd.29.2018.10.30.14.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 14:54:55 -0700 (PDT)
Subject: Re: [PATCH RFC v2 1/1] hugetlbfs: use i_mmap_rwsem for pmd sharing
 and truncate/fault sync
References: <20181024045053.1467-1-mike.kravetz@oracle.com>
 <20181024045053.1467-2-mike.kravetz@oracle.com>
 <20181026004220.GA8637@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <619e9f24-4af1-2083-6219-34a3601b002e@oracle.com>
Date: Tue, 30 Oct 2018 14:54:41 -0700
MIME-Version: 1.0
In-Reply-To: <20181026004220.GA8637@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>

On 10/25/18 5:42 PM, Naoya Horiguchi wrote:
> Hi Mike,
> 
> On Tue, Oct 23, 2018 at 09:50:53PM -0700, Mike Kravetz wrote:
>>   Now, anopther task truncates the hugetlbfs file.  As part of truncation,
>>   it unmaps everyone who has the file mapped.  If a task has a shared pmd
>>   in this range, huge_pmd_unshhare will be called.  If this is not the last
> 
> (sorry, nitpicking ..) a few typos ("anophter" and "unshhare").

Hi Naoya,

Thanks for looking at the patch.  I put this together somewhat quickly before
traveling and unfortunately made several typos.  Wanted to provide adequate
documentation to help understand the changes.

>>   user sharing the pmd, huge_pmd_unshare will clear pud pointing to the
>>   pmd.  For the task in the middle of the page fault, the ptep returned by
>>   huge_pte_alloc points to another task's page table or worse.  This leads
>>   to bad things such as incorrect page map/reference counts or invalid
>>   memory references.
>>
>> i_mmap_rwsem is currently used for pmd sharing synchronization.  It is also
>> held during unmap and whenever a call to huge_pmd_unshare is possible.  It
>> is only acquired in write mode.  Expand and modify the use of i_mmap_rwsem
>> as follows:
>> - i_mmap_rwsem is held in write mode for the duration of truncate
>>   processing.
>> - i_mmap_rwsem is held in write mode whenever huge_pmd_share is called.
> 
> I guess you mean huge_pmd_unshare here, right?
> 

Correct, i_mmap_rwsem is held in write mode whenever huge_pmd_unshare
is called.

>> - i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
>>   Today that is only via huge_pte_alloc.
>> - i_mmap_rwsem is held in read mode after huge_pte_alloc, until the caller
>>   is finished with the returned ptep.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
[...]
>> @@ -505,8 +512,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
>>  	i_mmap_lock_write(mapping);
>>  	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
>>  		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
>> -	i_mmap_unlock_write(mapping);
>>  	remove_inode_hugepages(inode, offset, LLONG_MAX);
>> +	i_mmap_unlock_write(mapping);
> 
> I just have an impression that hugetlbfs_punch_hole() could have the
> similar race and extending lock range there could be an improvement,
> although I might miss something as always.
> 

You are correct.  The hole punch routine (hugetlbfs_punch_hole) should
continue to hold i_mmap_rwsem in write mode until after calling
remove_inode_hugepages.

>>  	return 0;
>>  }
>>  
>> @@ -624,7 +631,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>>  		/* addr is the offset within the file (zero based) */
>>  		addr = index * hpage_size;
>>  
>> -		/* mutex taken here, fault path and hole punch */
>> +		/*
>> +		 * fault mutex taken here, protects against fault path
>> +		 * and hole punch.  inode_lock previously taken protects
>> +		 * against truncation.
>> +		 */
>>  		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
>>  						index, addr);
>>  		mutex_lock(&hugetlb_fault_mutex_table[hash]);
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 7b5c0ad9a6bd..e9da3eee262f 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3252,18 +3252,33 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>>  
>>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>>  		spinlock_t *src_ptl, *dst_ptl;
>> +		struct vm_area_struct *dst_vma;
>> +		struct address_space *mapping;
>> +
>>  		src_pte = huge_pte_offset(src, addr, sz);
>>  		if (!src_pte)
>>  			continue;
>> +
>> +		/*
>> +		 * i_mmap_rwsem must be held to call huge_pte_alloc.
>> +		 * Continue to hold until finished with dst_pte, otherwise
>> +		 * it could go away if part of a shared pmd.
>> +		 */
>> +		dst_vma = find_vma(dst, addr);
>> +		mapping = dst_vma->vm_file->f_mapping;
> 
> If vma->vm_file->f_mapping gives the same mapping, you may omit the find_vma()?
> 

Thanks.  You are correct.  'dst_vma' should be the same as vma as it is
a copy.  This find is unnecessary.

>> +		i_mmap_lock_read(mapping);
>>  		dst_pte = huge_pte_alloc(dst, addr, sz);
>>  		if (!dst_pte) {
>> +			i_mmap_unlock_read(mapping);
>>  			ret = -ENOMEM;
>>  			break;
>>  		}
>>  
>>  		/* If the pagetables are shared don't copy or take references */
>> -		if (dst_pte == src_pte)
>> +		if (dst_pte == src_pte) {
>> +			i_mmap_unlock_read(mapping);
>>  			continue;
>> +		}
>>  
>>  		dst_ptl = huge_pte_lock(h, dst, dst_pte);
>>  		src_ptl = huge_pte_lockptr(h, src, src_pte);
> 
> [...]
> 
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 1e79fac3186b..db49e734dda8 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1347,6 +1347,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  	bool ret = true;
>>  	unsigned long start = address, end;
>>  	enum ttu_flags flags = (enum ttu_flags)arg;
>> +	bool pmd_sharing_possible = false;
>>  
>>  	/* munlock has nothing to gain from examining un-locked vmas */
>>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>> @@ -1376,8 +1377,15 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  		 * accordingly.
>>  		 */
>>  		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
>> +		if ((end - start) > (PAGE_SIZE << compound_order(page)))
>> +			pmd_sharing_possible = true;
> 
> Maybe the similar check is done in adjust_range_if_pmd_sharing_possible()
> as the function name claims, so does it make more sense to get this bool
> value via the return value?

Yes, that makes sense.  This use of adjust_range_if_pmd_sharing_possible
would be the only place a return value is used.

Thanks for your comments!

I am concerned about the use of any huge pte pointers when the page table
lock or i_mmap_rwsem is not held.  There may be more instances of this we
need to protect.  For example, huge_pte_offset at the beginning of
hugetlb_fault() is still called without any synchronization.  I think we
may need to acquire i_mmap_rwsem before this call.  I'm trying to think of
other areas that may be of concern.
-- 
Mike Kravetz
