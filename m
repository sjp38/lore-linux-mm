Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 813E96B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:19:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id s1-v6so1298625pfm.22
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:19:02 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id c18-v6si4065349pgd.448.2018.07.27.09.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 09:19:00 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
 <4d45b22e-1afc-8763-eed7-bef57a44303c@linux.vnet.ibm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9252527f-152a-4191-8b5a-b9ca437f1e22@linux.alibaba.com>
Date: Fri, 27 Jul 2018 09:18:51 -0700
MIME-Version: 1.0
In-Reply-To: <4d45b22e-1afc-8763-eed7-bef57a44303c@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, mhocko@kernel.org, willy@infradead.org, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/27/18 1:15 AM, Laurent Dufour wrote:
> On 26/07/2018 20:10, Yang Shi wrote:
>> When running some mmap/munmap scalability tests with large memory (i.e.
>>> 300GB), the below hung task issue may happen occasionally.
>> INFO: task ps:14018 blocked for more than 120 seconds.
>>         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>>   ps              D    0 14018      1 0x00000004
>>    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>   Call Trace:
>>    [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>    [<ffffffff817159e6>] schedule+0x36/0x80
>>    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>    [<ffffffff81717db0>] down_read+0x20/0x40
>>    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>    [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>>    [<ffffffff81241d87>] __vfs_read+0x37/0x150
>>    [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>>    [<ffffffff81242266>] vfs_read+0x96/0x130
>>    [<ffffffff812437b5>] SyS_read+0x55/0xc0
>>    [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
>>
>> It is because munmap holds mmap_sem exclusively from very beginning to
>> all the way down to the end, and doesn't release it in the middle. When
>> unmapping large mapping, it may take long time (take ~18 seconds to
>> unmap 320GB mapping with every single page mapped on an idle machine).
>>
>> Zapping pages is the most time consuming part, according to the
>> suggestion from Michal Hocko [1], zapping pages can be done with holding
>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>> mmap_sem to cleanup vmas.
>>
>> But, some part may need write mmap_sem, for example, vma splitting. So,
>> the design is as follows:
>>          acquire write mmap_sem
>>          lookup vmas (find and split vmas)
>> 	detach vmas
>>          deal with special mappings
>>          downgrade_write
>>
>>          zap pages
>> 	free page tables
>>          release mmap_sem
>>
>> The vm events with read mmap_sem may come in during page zapping, but
>> since vmas have been detached before, they, i.e. page fault, gup, etc,
>> will not be able to find valid vma, then just return SIGSEGV or -EFAULT
>> as expected.
>>
>> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
>> considered as special mappings. They will be dealt with before zapping
>> pages with write mmap_sem held. Basically, just update vm_flags.
>>
>> And, since they are also manipulated by unmap_single_vma() which is
>> called by unmap_vma() with read mmap_sem held in this case, to
>> prevent from updating vm_flags in read critical section, a new
>> parameter, called "skip_flags" is added to unmap_region(), unmap_vmas()
>> and unmap_single_vma(). If it is true, then just skip unmap those
>> special mappings. Currently, the only place which pass true to this
>> parameter is us.
>>
>> With this approach we don't have to re-acquire mmap_sem again to clean
>> up vmas to avoid race window which might get the address space changed.
>>
>> And, since the lock acquire/release cost is managed to the minimum and
>> almost as same as before, the optimization could be extended to any size
>> of mapping without incurring significant penalty to small mappings.
>>
>> For the time being, just do this in munmap syscall path. Other
>> vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
>> intact for stability reason.
>>
>> With the patches, exclusive mmap_sem hold time when munmap a 80GB
>> address space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to
>> us level from second.
>>
>> munmap_test-15002 [008]   594.380138: funcgraph_entry: |  vm_munmap_zap_rlock() {
>> munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
>> munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }
>>
>> Here the excution time of unmap_region() is used to evaluate the time of
>> holding read mmap_sem, then the remaining time is used with holding
>> exclusive lock.
>>
>> [1] https://lwn.net/Articles/753269/
>>
>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   include/linux/mm.h |  2 +-
>>   mm/memory.c        | 41 ++++++++++++++++------
>>   mm/mmap.c          | 99 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>>   3 files changed, 123 insertions(+), 19 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index a0fbb9f..e4480d8 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1321,7 +1321,7 @@ void zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>>   void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>>   		    unsigned long size);
>>   void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>> -		unsigned long start, unsigned long end);
>> +		unsigned long start, unsigned long end, bool skip_vm_flags);
>>
>>   /**
>>    * mm_walk - callbacks for walk_page_range
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 7206a63..6a772bd 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1514,7 +1514,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>>   static void unmap_single_vma(struct mmu_gather *tlb,
>>   		struct vm_area_struct *vma, unsigned long start_addr,
>>   		unsigned long end_addr,
>> -		struct zap_details *details)
>> +		struct zap_details *details, bool skip_vm_flags)
>>   {
>>   	unsigned long start = max(vma->vm_start, start_addr);
>>   	unsigned long end;
>> @@ -1525,11 +1525,19 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>   	if (end <= vma->vm_start)
>>   		return;
>>
>> -	if (vma->vm_file)
>> -		uprobe_munmap(vma, start, end);
>> +	/*
>> +	 * Since unmap_single_vma might be called with read mmap_sem held
>> +	 * in munmap optimization, so vm_flags can't be updated in this case.
>> +	 * They have been updated before this call with write mmap_sem held.
>> +	 * Here if skip_vm_flags is true, just skip the update.
>> +	 */
>> +	if (!skip_vm_flags) {
>> +		if (vma->vm_file)
>> +			uprobe_munmap(vma, start, end);
>>
>> -	if (unlikely(vma->vm_flags & VM_PFNMAP))
>> -		untrack_pfn(vma, 0, 0);
>> +		if (unlikely(vma->vm_flags & VM_PFNMAP))
>> +			untrack_pfn(vma, 0, 0);
>> +	}
>>
>>   	if (start != end) {
>>   		if (unlikely(is_vm_hugetlb_page(vma))) {
>> @@ -1546,7 +1554,19 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>   			 */
>>   			if (vma->vm_file) {
>>   				i_mmap_lock_write(vma->vm_file->f_mapping);
>> -				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
>> +				if (!skip_vm_flags) {
> As already reported by Mika : if (skip_vm_flags).
>
>> +					/*
>> +					 * The vma is being unmapped with read
>> +					 * mmap_sem.
>> +					 * Can't update vm_flags here, it has
>> +					 * been updated before this call with
>> +					 * write mmap_sem held.
>> +					 */
>> +					__unmap_hugepage_range(tlb, vma, start,
>> +							end, NULL);
>> +				} else
>> +					__unmap_hugepage_range_final(tlb, vma,
>> +							start, end, NULL);
>>   				i_mmap_unlock_write(vma->vm_file->f_mapping);
>>   			}
>>   		} else
>> @@ -1574,13 +1594,14 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>    */
>>   void unmap_vmas(struct mmu_gather *tlb,
>>   		struct vm_area_struct *vma, unsigned long start_addr,
>> -		unsigned long end_addr)
>> +		unsigned long end_addr, bool skip_vm_flags)
>>   {
>>   	struct mm_struct *mm = vma->vm_mm;
>>
>>   	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
>>   	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>> -		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
>> +		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL,
>> +				 skip_vm_flags);
>>   	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
>>   }
>>
>> @@ -1604,7 +1625,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>>   	update_hiwater_rss(mm);
>>   	mmu_notifier_invalidate_range_start(mm, start, end);
>>   	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
>> -		unmap_single_vma(&tlb, vma, start, end, NULL);
>> +		unmap_single_vma(&tlb, vma, start, end, NULL, false);
>>
>>   		/*
>>   		 * zap_page_range does not specify whether mmap_sem should be
>> @@ -1641,7 +1662,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
>>   	tlb_gather_mmu(&tlb, mm, address, end);
>>   	update_hiwater_rss(mm);
>>   	mmu_notifier_invalidate_range_start(mm, address, end);
>> -	unmap_single_vma(&tlb, vma, address, end, details);
>> +	unmap_single_vma(&tlb, vma, address, end, details, false);
>>   	mmu_notifier_invalidate_range_end(mm, address, end);
>>   	tlb_finish_mmu(&tlb, address, end);
>>   }
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 2504094..663a0c5 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -73,7 +73,7 @@
>>
>>   static void unmap_region(struct mm_struct *mm,
>>   		struct vm_area_struct *vma, struct vm_area_struct *prev,
>> -		unsigned long start, unsigned long end);
>> +		unsigned long start, unsigned long end, bool skip_flags);
> Earlier, you used the name 'skip_vm_flags'. It would be nice to keep the same
> parameter name everywhere, isn't it ?

Yes, sure.

>
>>   /* description of effects of mapping type and prot in current implementation.
>>    * this is due to the limited x86 page protection hardware.  The expected
>> @@ -1824,7 +1824,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>>   	fput(file);
>>
>>   	/* Undo any partial mapping done by a device driver. */
>> -	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
>> +	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end, false);
>>   	charged = 0;
>>   	if (vm_flags & VM_SHARED)
>>   		mapping_unmap_writable(file->f_mapping);
>> @@ -2559,7 +2559,7 @@ static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
>>    */
>>   static void unmap_region(struct mm_struct *mm,
>>   		struct vm_area_struct *vma, struct vm_area_struct *prev,
>> -		unsigned long start, unsigned long end)
>> +		unsigned long start, unsigned long end, bool skip_flags)
> Here too.
>
>>   {
>>   	struct vm_area_struct *next = prev ? prev->vm_next : mm->mmap;
>>   	struct mmu_gather tlb;
>> @@ -2567,7 +2567,7 @@ static void unmap_region(struct mm_struct *mm,
>>   	lru_add_drain();
>>   	tlb_gather_mmu(&tlb, mm, start, end);
>>   	update_hiwater_rss(mm);
>> -	unmap_vmas(&tlb, vma, start, end);
>> +	unmap_vmas(&tlb, vma, start, end, skip_flags);
>>   	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
>>   				 next ? next->vm_start : USER_PGTABLES_CEILING);
>>   	tlb_finish_mmu(&tlb, start, end);
>> @@ -2778,6 +2778,79 @@ static inline void munmap_mlock_vma(struct vm_area_struct *vma,
>>   	}
>>   }
>>
>> +/*
>> + * Zap pages with read mmap_sem held
>> + *
>> + * uf is the list for userfaultfd
>> + */
>> +static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>> +			       size_t len, struct list_head *uf)
>> +{
>> +	unsigned long end = 0;
>> +	struct vm_area_struct *start_vma = NULL, *prev, *vma;
>> +	int ret = 0;
> No need to initialize end, start_vma and ret here, they will be assigned before
> used.

OK

>
>> +
>> +	if (!munmap_addr_sanity(start, len))
>> +		return -EINVAL;
>> +
>> +	len = PAGE_ALIGN(len);
>> +
>> +	end = start + len;
>> +
>> +	/*
>> +	 * Need write mmap_sem to split vmas and detach vmas
>> +	 * splitting vma up-front to save PITA to clean if it is failed
>> +	 */
>> +	if (down_write_killable(&mm->mmap_sem))
>> +		return -EINTR;
>> +
>> +	ret = munmap_lookup_vma(mm, &start_vma, &prev, start, end);
>> +	if (ret != 1)
>> +		goto out;
>> +
>> +	if (unlikely(uf)) {
>> +		ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
>> +		if (ret)
>> +			goto out;
>> +	}
>> +
>> +	/* Handle mlocked vmas */
>> +	if (mm->locked_vm)
>> +		munmap_mlock_vma(start_vma, end);
>> +
>> +	/* Detach vmas from rbtree */
>> +	detach_vmas_to_be_unmapped(mm, start_vma, prev, end);
>> +
>> +	/*
>> +	 * Clear uprobe, VM_PFNMAP and hugetlb mapping in advance since they
>> +	 * need update vm_flags with write mmap_sem
>> +	 */
>> +	vma = start_vma;
>> +	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
> Not critical, but 'vma = start_vma' should be part of the init stuff in for(),
> like this:
> 	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {

OK

Thanks for reviewing these patches. Will fix these comments in next 
version. Before I prepare the next version, I would like to wait for one 
or two days to see if anyone else has more comments.

Andrew & Michal,

Do you have any comment on this version?

Thanks,
Yang

>
>> +		if (vma->vm_file)
>> +			uprobe_munmap(vma, vma->vm_start, vma->vm_end);
>> +		if (unlikely(vma->vm_flags & VM_PFNMAP))
>> +			untrack_pfn(vma, 0, 0);
>> +		if (is_vm_hugetlb_page(vma))
>> +			vma->vm_flags &= ~VM_MAYSHARE;
>> +	}
>> +
>> +	downgrade_write(&mm->mmap_sem);
>> +
>> +	/* Zap mappings with read mmap_sem */
>> +	unmap_region(mm, start_vma, prev, start, end, true);
>> +
>> +	arch_unmap(mm, start_vma, start, end);
>> +	remove_vma_list(mm, start_vma);
>> +	up_read(&mm->mmap_sem);
>> +
>> +	return 0;
>> +
>> +out:
>> +	up_write(&mm->mmap_sem);
>> +	return ret;
>> +}
>> +
>>   /* Munmap is split into 2 main parts -- this part which finds
>>    * what needs doing, and the areas themselves, which do the
>>    * work.  This now handles partial unmappings.
>> @@ -2826,7 +2899,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>>   	 * Remove the vma's, and unmap the actual pages
>>   	 */
>>   	detach_vmas_to_be_unmapped(mm, vma, prev, end);
>> -	unmap_region(mm, vma, prev, start, end);
>> +	unmap_region(mm, vma, prev, start, end, false);
>>
>>   	arch_unmap(mm, vma, start, end);
>>
>> @@ -2836,6 +2909,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>>   	return 0;
>>   }
>>
>> +static int vm_munmap_zap_rlock(unsigned long start, size_t len)
>> +{
>> +	int ret;
>> +	struct mm_struct *mm = current->mm;
>> +	LIST_HEAD(uf);
>> +
>> +	ret = do_munmap_zap_rlock(mm, start, len, &uf);
>> +	userfaultfd_unmap_complete(mm, &uf);
>> +	return ret;
>> +}
>> +
>>   int vm_munmap(unsigned long start, size_t len)
>>   {
>>   	int ret;
>> @@ -2855,10 +2939,9 @@ int vm_munmap(unsigned long start, size_t len)
>>   SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>   {
>>   	profile_munmap(addr);
>> -	return vm_munmap(addr, len);
>> +	return vm_munmap_zap_rlock(addr, len);
>>   }
>>
>> -
>>   /*
>>    * Emulation of deprecated remap_file_pages() syscall.
>>    */
>> @@ -3146,7 +3229,7 @@ void exit_mmap(struct mm_struct *mm)
>>   	tlb_gather_mmu(&tlb, mm, 0, -1);
>>   	/* update_hiwater_rss(mm) here? but nobody should be looking */
>>   	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>> -	unmap_vmas(&tlb, vma, 0, -1);
>> +	unmap_vmas(&tlb, vma, 0, -1, false);
>>   	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>>   	tlb_finish_mmu(&tlb, 0, -1);
>>
