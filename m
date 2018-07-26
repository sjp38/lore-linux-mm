Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1D56B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:04:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w1-v6so1816660ply.12
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:04:22 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id ay1-v6si1727175plb.266.2018.07.26.12.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:04:21 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
 <f89abbc5-c907-1f72-495c-318011415697@nextfour.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <61be766f-d465-fd24-309c-084a1f88f37d@linux.alibaba.com>
Date: Thu, 26 Jul 2018 12:03:59 -0700
MIME-Version: 1.0
In-Reply-To: <f89abbc5-c907-1f72-495c-318011415697@nextfour.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/26/18 11:34 AM, Mika PenttilA? wrote:
>
> On 26.07.2018 21:10, Yang Shi wrote:
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
> Should that be :
> 	if (skip_vm_flags) {
> instead?

Oh, yes. Thanks for catching this.

Yang

>   
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
>>
> --Mika
