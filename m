Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86AB36B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:32:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i26-v6so2092595edr.4
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:32:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v6-v6si2926512edc.281.2018.07.24.10.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 10:32:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6OHT5Xt113730
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:32:00 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ke7kbu1gb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:31:59 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 18:31:58 +0100
Subject: Re: [RFC v5 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1531956101-8526-1-git-send-email-yang.shi@linux.alibaba.com>
 <1531956101-8526-3-git-send-email-yang.shi@linux.alibaba.com>
 <25fca2a1-0a55-13eb-0c75-6d0238fe780b@linux.vnet.ibm.com>
 <b8c128c4-3a8e-ed17-2d9f-76f71bfdad43@linux.alibaba.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 24 Jul 2018 19:31:53 +0200
MIME-Version: 1.0
In-Reply-To: <b8c128c4-3a8e-ed17-2d9f-76f71bfdad43@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <e9553340-3b8d-bc26-781d-8a6a8716bc8f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 24/07/2018 19:26, Yang Shi wrote:
> 
> 
> On 7/24/18 10:18 AM, Laurent Dufour wrote:
>> On 19/07/2018 01:21, Yang Shi wrote:
>>> When running some mmap/munmap scalability tests with large memory (i.e.
>>>> 300GB), the below hung task issue may happen occasionally.
>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>> A A A A A A A  Tainted: GA A A A A A A A A A A  E 4.9.79-009.ali3000.alios7.x86_64 #1
>>> A  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>> message.
>>> A  psA A A A A A A A A A A A A  DA A A  0 14018A A A A A  1 0x00000004
>>> A A  ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>> A A  ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>> A A  00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>> A  Call Trace:
>>> A A  [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>> A A  [<ffffffff817159e6>] schedule+0x36/0x80
>>> A A  [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>> A A  [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>> A A  [<ffffffff81717db0>] down_read+0x20/0x40
>>> A A  [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>> A A  [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>>> A A  [<ffffffff81241d87>] __vfs_read+0x37/0x150
>>> A A  [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>>> A A  [<ffffffff81242266>] vfs_read+0x96/0x130
>>> A A  [<ffffffff812437b5>] SyS_read+0x55/0xc0
>>> A A  [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
>>>
>>> It is because munmap holds mmap_sem exclusively from very beginning to
>>> all the way down to the end, and doesn't release it in the middle. When
>>> unmapping large mapping, it may take long time (take ~18 seconds to
>>> unmap 320GB mapping with every single page mapped on an idle machine).
>>>
>>> Zapping pages is the most time consuming part, according to the
>>> suggestion from Michal Hocko [1], zapping pages can be done with holding
>>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>>> mmap_sem to cleanup vmas.
>>>
>>> But, some part may need write mmap_sem, for example, vma splitting. So,
>>> the design is as follows:
>>> A A A A A A A A  acquire write mmap_sem
>>> A A A A A A A A  lookup vmas (find and split vmas)
>>> A A A A detach vmas
>>> A A A A A A A A  deal with special mappings
>>> A A A A A A A A  downgrade_write
>>>
>>> A A A A A A A A  zap pages
>>> A A A A free page tables
>>> A A A A A A A A  release mmap_sem
>>>
>>> The vm events with read mmap_sem may come in during page zapping, but
>>> since vmas have been detached before, they, i.e. page fault, gup, etc,
>>> will not be able to find valid vma, then just return SIGSEGV or -EFAULT
>>> as expected.
>>>
>>> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
>>> considered as special mappings. They will be dealt with before zapping
>>> pages with write mmap_sem held. Basically, just update vm_flags.
>>>
>>> And, since they are also manipulated by unmap_single_vma() which is
>>> called by unmap_vma() with read mmap_sem held in this case, to
>>> prevent from updating vm_flags in read critical section, a new
>>> parameter, called "skip_flags" is added to unmap_region(), unmap_vmas()
>>> and unmap_single_vma(). If it is true, then just skip unmap those
>>> special mappings. Currently, the only place which pass true to this
>>> parameter is us.
>>>
>>> With this approach we don't have to re-acquire mmap_sem again to clean
>>> up vmas to avoid race window which might get the address space changed.
>>>
>>> And, since the lock acquire/release cost is managed to the minimum and
>>> almost as same as before, the optimization could be extended to any size
>>> of mapping without incuring significan penalty to small mappings.
>> A A A A A A A A A A A A A A A A A A A A A A A A A  ^A A A A A A  ^
>> A A A A A A A A A A A A A A A A A A A A A  incurring significant
> 
> Thanks for catching the typo.
> 
>>> For the time being, just do this in munmap syscall path. Other
>>> vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
>>> intact for stability reason.
>>>
>>> With the patches, exclusive mmap_sem hold time when munmap a 80GB
>>> address space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to
>>> us level from second.
>>>
>>> munmap_test-15002 [008]A A  594.380138: funcgraph_entry: |A 
>>> vm_munmap_zap_rlock() {
>>> munmap_test-15002 [008]A A  594.380146: funcgraph_entry:A A A A A  !2485684 us |A A A 
>>> unmap_region();
>>> munmap_test-15002 [008]A A  596.865836: funcgraph_exit:A A A A A A  !2485692 us |A  }
>>>
>>> Here the excution time of unmap_region() is used to evaluate the time of
>>> holding read mmap_sem, then the remaining time is used with holding
>>> exclusive lock.
>>>
>>> [1] https://lwn.net/Articles/753269/
>>>
>>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>>> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
>>> Cc: Matthew Wilcox <willy@infradead.org>
>>> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> A  include/linux/mm.h |A  2 +-
>>> A  mm/memory.cA A A A A A A  | 35 +++++++++++++------
>>> A  mm/mmap.cA A A A A A A A A  | 99
>>> +++++++++++++++++++++++++++++++++++++++++++++++++-----
>>> A  3 files changed, 117 insertions(+), 19 deletions(-)
>>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index a0fbb9f..95a4e97 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -1321,7 +1321,7 @@ void zap_vma_ptes(struct vm_area_struct *vma, unsigned
>>> long address,
>>> A  void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>>> A A A A A A A A A A A A A  unsigned long size);
>>> A  void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>> -A A A A A A A  unsigned long start, unsigned long end);
>>> +A A A A A A A  unsigned long start, unsigned long end, bool skip_flags);
>>>
>>> A  /**
>>> A A  * mm_walk - callbacks for walk_page_range
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index 7206a63..00ecdae 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -1514,7 +1514,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>>> A  static void unmap_single_vma(struct mmu_gather *tlb,
>>> A A A A A A A A A  struct vm_area_struct *vma, unsigned long start_addr,
>>> A A A A A A A A A  unsigned long end_addr,
>>> -A A A A A A A  struct zap_details *details)
>>> +A A A A A A A  struct zap_details *details, bool skip_flags)
>>> A  {
>>> A A A A A  unsigned long start = max(vma->vm_start, start_addr);
>>> A A A A A  unsigned long end;
>>> @@ -1525,11 +1525,13 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>> A A A A A  if (end <= vma->vm_start)
>>> A A A A A A A A A  return;
>>>
>>> -A A A  if (vma->vm_file)
>>> -A A A A A A A  uprobe_munmap(vma, start, end);
>>> +A A A  if (!skip_flags) {
>>> +A A A A A A A  if (vma->vm_file)
>>> +A A A A A A A A A A A  uprobe_munmap(vma, start, end);
>>>
>>> -A A A  if (unlikely(vma->vm_flags & VM_PFNMAP))
>>> -A A A A A A A  untrack_pfn(vma, 0, 0);
>>> +A A A A A A A  if (unlikely(vma->vm_flags & VM_PFNMAP))
>>> +A A A A A A A A A A A  untrack_pfn(vma, 0, 0);
>>> +A A A  }
>> I think a comment would be welcomed here to detail why it is safe to not call
>> uprobe_munmap() and untrack_pfn() here i.e this has already been done in
>> do_munmap_zap_rlock().
> 
> OK
> 
>>
>>> A A A A A  if (start != end) {
>>> A A A A A A A A A  if (unlikely(is_vm_hugetlb_page(vma))) {
>>> @@ -1546,7 +1548,19 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>> A A A A A A A A A A A A A A  */
>>> A A A A A A A A A A A A A  if (vma->vm_file) {
>>> A A A A A A A A A A A A A A A A A  i_mmap_lock_write(vma->vm_file->f_mapping);
>>> -A A A A A A A A A A A A A A A  __unmap_hugepage_range_final(tlb, vma, start, end, NULL);
>>> +A A A A A A A A A A A A A A A  if (!skip_flags)
>>> +A A A A A A A A A A A A A A A A A A A  /*
>>> +A A A A A A A A A A A A A A A A A A A A  * The vma is being unmapped with read
>>> +A A A A A A A A A A A A A A A A A A A A  * mmap_sem.
>>> +A A A A A A A A A A A A A A A A A A A A  * Can't update vm_flags, it will be
>>> +A A A A A A A A A A A A A A A A A A A A  * updated later with exclusive lock
>>> +A A A A A A A A A A A A A A A A A A A A  * held
>>> +A A A A A A A A A A A A A A A A A A A A  */
>>> +A A A A A A A A A A A A A A A A A A A  __unmap_hugepage_range(tlb, vma, start,
>>> +A A A A A A A A A A A A A A A A A A A A A A A A A A A  end, NULL);
>>> +A A A A A A A A A A A A A A A  else
>>> +A A A A A A A A A A A A A A A A A A A  __unmap_hugepage_range_final(tlb, vma,
>>> +A A A A A A A A A A A A A A A A A A A A A A A A A A A  start, end, NULL);
>>> A A A A A A A A A A A A A A A A A  i_mmap_unlock_write(vma->vm_file->f_mapping);
>>> A A A A A A A A A A A A A  }
>>> A A A A A A A A A  } else
>>> @@ -1574,13 +1588,14 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>>> A A  */
>>> A  void unmap_vmas(struct mmu_gather *tlb,
>>> A A A A A A A A A  struct vm_area_struct *vma, unsigned long start_addr,
>>> -A A A A A A A  unsigned long end_addr)
>>> +A A A A A A A  unsigned long end_addr, bool skip_flags)
>>> A  {
>>> A A A A A  struct mm_struct *mm = vma->vm_mm;
>>>
>>> A A A A A  mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
>>> A A A A A  for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>>> -A A A A A A A  unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
>>> +A A A A A A A  unmap_single_vma(tlb, vma, start_addr, end_addr, NULL,
>>> +A A A A A A A A A A A A A A A A  skip_flags);
>>> A A A A A  mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
>>> A  }
>>>
>>> @@ -1604,7 +1619,7 @@ void zap_page_range(struct vm_area_struct *vma,
>>> unsigned long start,
>>> A A A A A  update_hiwater_rss(mm);
>>> A A A A A  mmu_notifier_invalidate_range_start(mm, start, end);
>>> A A A A A  for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
>>> -A A A A A A A  unmap_single_vma(&tlb, vma, start, end, NULL);
>>> +A A A A A A A  unmap_single_vma(&tlb, vma, start, end, NULL, false);
>>>
>>> A A A A A A A A A  /*
>>> A A A A A A A A A A  * zap_page_range does not specify whether mmap_sem should be
>>> @@ -1641,7 +1656,7 @@ static void zap_page_range_single(struct
>>> vm_area_struct *vma, unsigned long addr
>>> A A A A A  tlb_gather_mmu(&tlb, mm, address, end);
>>> A A A A A  update_hiwater_rss(mm);
>>> A A A A A  mmu_notifier_invalidate_range_start(mm, address, end);
>>> -A A A  unmap_single_vma(&tlb, vma, address, end, details);
>>> +A A A  unmap_single_vma(&tlb, vma, address, end, details, false);
>>> A A A A A  mmu_notifier_invalidate_range_end(mm, address, end);
>>> A A A A A  tlb_finish_mmu(&tlb, address, end);
>>> A  }
>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>> index 2504094..f5d5312 100644
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -73,7 +73,7 @@
>>>
>>> A  static void unmap_region(struct mm_struct *mm,
>>> A A A A A A A A A  struct vm_area_struct *vma, struct vm_area_struct *prev,
>>> -A A A A A A A  unsigned long start, unsigned long end);
>>> +A A A A A A A  unsigned long start, unsigned long end, bool skip_flags);
>>>
>>> A  /* description of effects of mapping type and prot in current implementation.
>>> A A  * this is due to the limited x86 page protection hardware.A  The expected
>>> @@ -1824,7 +1824,7 @@ unsigned long mmap_region(struct file *file, unsigned
>>> long addr,
>>> A A A A A  fput(file);
>>>
>>> A A A A A  /* Undo any partial mapping done by a device driver. */
>>> -A A A  unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
>>> +A A A  unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end, false);
>>> A A A A A  charged = 0;
>>> A A A A A  if (vm_flags & VM_SHARED)
>>> A A A A A A A A A  mapping_unmap_writable(file->f_mapping);
>>> @@ -2559,7 +2559,7 @@ static void remove_vma_list(struct mm_struct *mm,
>>> struct vm_area_struct *vma)
>>> A A  */
>>> A  static void unmap_region(struct mm_struct *mm,
>>> A A A A A A A A A  struct vm_area_struct *vma, struct vm_area_struct *prev,
>>> -A A A A A A A  unsigned long start, unsigned long end)
>>> +A A A A A A A  unsigned long start, unsigned long end, bool skip_flags)
>>> A  {
>>> A A A A A  struct vm_area_struct *next = prev ? prev->vm_next : mm->mmap;
>>> A A A A A  struct mmu_gather tlb;
>>> @@ -2567,7 +2567,7 @@ static void unmap_region(struct mm_struct *mm,
>>> A A A A A  lru_add_drain();
>>> A A A A A  tlb_gather_mmu(&tlb, mm, start, end);
>>> A A A A A  update_hiwater_rss(mm);
>>> -A A A  unmap_vmas(&tlb, vma, start, end);
>>> +A A A  unmap_vmas(&tlb, vma, start, end, skip_flags);
>>> A A A A A  free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
>>> A A A A A A A A A A A A A A A A A A  next ? next->vm_start : USER_PGTABLES_CEILING);
>>> A A A A A  tlb_finish_mmu(&tlb, start, end);
>>> @@ -2778,6 +2778,79 @@ static inline void munmap_mlock_vma(struct
>>> vm_area_struct *vma,
>>> A A A A A  }
>>> A  }
>>>
>>> +/*
>>> + * Zap pages with read mmap_sem held
>>> + *
>>> + * uf is the list for userfaultfd
>>> + */
>>> +static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>>> +A A A A A A A A A A A A A A A A A A  size_t len, struct list_head *uf)
>>> +{
>>> +A A A  unsigned long end = 0;
>>> +A A A  struct vm_area_struct *start_vma = NULL, *prev, *vma;
>>> +A A A  int ret = 0;
>>> +
>>> +A A A  if (!munmap_addr_sanity(start, len))
>>> +A A A A A A A  return -EINVAL;
>>> +
>>> +A A A  len = PAGE_ALIGN(len);
>>> +
>>> +A A A  end = start + len;
>>> +
>>> +A A A  /*
>>> +A A A A  * need write mmap_sem to split vmas and detach vmas
>>> +A A A A  * splitting vma up-front to save PITA to clean if it is failed
>>> +A A A A  */
>>> +A A A  if (down_write_killable(&mm->mmap_sem))
>>> +A A A A A A A  return -EINTR;
>>> +
>>> +A A A  ret = munmap_lookup_vma(mm, &start_vma, &prev, start, end);
>>> +A A A  if (ret != 1)
>>> +A A A A A A A  goto out;
>>> +
>>> +A A A  if (unlikely(uf)) {
>>> +A A A A A A A  ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
>>> +A A A A A A A  if (ret)
>>> +A A A A A A A A A A A  goto out;
>>> +A A A  }
>>> +
>>> +A A A  /* Handle mlocked vmas */
>>> +A A A  if (mm->locked_vm)
>>> +A A A A A A A  munmap_mlock_vma(start_vma, end);
>>> +
>>> +A A A  /* Detach vmas from rbtree */
>>> +A A A  detach_vmas_to_be_unmapped(mm, start_vma, prev, end);
>>> +
>>> +A A A  /*
>>> +A A A A  * Clear uprobe, VM_PFNMAP and hugetlb mapping in advance since they
>>> +A A A A  * need update vm_flags with write mmap_sem
>>> +A A A A  */
>>> +A A A  vma = start_vma;
>>> +A A A  for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
>>> +A A A A A A A  if (vma->vm_file)
>>> +A A A A A A A A A A A  uprobe_munmap(vma, vma->vm_start, vma->vm_end);
>>> +A A A A A A A  if (unlikely(vma->vm_flags & VM_PFNMAP))
>>> +A A A A A A A A A A A  untrack_pfn(vma, 0, 0);130680130680
>>> +A A A A A A A  if (is_vm_hugetlb_page(vma))
>>> +A A A A A A A A A A A  vma->vm_flags &= ~VM_MAYSHARE;
>>> +A A A  }
>>> +
>>> +A A A  downgrade_write(&mm->mmap_sem);
>>> +
>>> +A A A  /* zap mappings with read mmap_sem */
>>> +A A A  unmap_region(mm, start_vma, prev, start, end, true);
>>> +
>>> +A A A  arch_unmap(mm, start_vma, start, end);
>>> +A A A  remove_vma_list(mm, start_vma);
>>> +A A A  up_read(&mm->mmap_sem);
>>> +
>>> +A A A  return 0;
>>> +
>>> +out:
>>> +A A A  up_write(&mm->mmap_sem);
>>> +A A A  return ret;
>>> +}
>>> +
>>> A  /* Munmap is split into 2 main parts -- this part which finds
>>> A A  * what needs doing, and the areas themselves, which do the
>>> A A  * work.A  This now handles partial unmappings.
>>> @@ -2826,7 +2899,7 @@ int do_munmap(struct mm_struct *mm, unsigned long
>>> start, size_t len,
>>> A A A A A A  * Remove the vma's, and unmap the actual pages
>>> A A A A A A  */
>>> A A A A A  detach_vmas_to_be_unmapped(mm, vma, prev, end);
>>> -A A A  unmap_region(mm, vma, prev, start, end);
>>> +A A A  unmap_region(mm, vma, prev, start, end, false);
>>>
>>> A A A A A  arch_unmap(mm, vma, start, end);
>>>
>>> @@ -2836,6 +2909,17 @@ int do_munmap(struct mm_struct *mm, unsigned long
>>> start, size_t len,
>>> A A A A A  return 0;
>>> A  }
>>>
>>> +static int vm_munmap_zap_rlock(unsigned long start, size_t len)
>>> +{
>>> +A A A  int ret;
>>> +A A A  struct mm_struct *mm = current->mm;
>>> +A A A  LIST_HEAD(uf);
>>> +
>>> +A A A  ret = do_munmap_zap_rlock(mm, start, len, &uf);
>>> +A A A  userfaultfd_unmap_complete(mm, &uf);
>>> +A A A  return ret;
>>> +}
>>> +
>>> A  int vm_munmap(unsigned long start, size_t len)
>>> A  {
>>> A A A A A  int ret;
>> A stupid question, since the overhead of vm_munmap_zap_rlock() compared to
>> vm_munmap() is not significant, why not putting that in vm_munmap() instead of
>> introducing a new vm_munmap_zap_rlock() ?
> 
> Since vm_munmap() is called in other paths too, i.e. drm driver, kvm, etc. I'm
> not quite sure if those paths are safe enough to this optimization. And, it
> looks they are not the main sources of the latency, so here I introduced
> vm_munmap_zap_rlock() for munmap() only.

For my information, what could be unsafe for these paths ?

> 
> If someone reports or we see they are the sources of latency too, and the
> optimization is proved safe to them, we can definitely extend this to all
> vm_munmap() calls
> 
> Thanks,
> Yang
> 
>>
>>> @@ -2855,10 +2939,9 @@ int vm_munmap(unsigned long start, size_t len)
>>> A  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>> A  {
>>> A A A A A  profile_munmap(addr);
>>> -A A A  return vm_munmap(addr, len);
>>> +A A A  return vm_munmap_zap_rlock(addr, len);
>>> A  }
>>>
>>> -
>>> A  /*
>>> A A  * Emulation of deprecated remap_file_pages() syscall.
>>> A A  */
>>> @@ -3146,7 +3229,7 @@ void exit_mmap(struct mm_struct *mm)
>>> A A A A A  tlb_gather_mmu(&tlb, mm, 0, -1);
>>> A A A A A  /* update_hiwater_rss(mm) here? but nobody should be looking */
>>> A A A A A  /* Use -1 here to ensure all VMAs in the mm are unmapped */
>>> -A A A  unmap_vmas(&tlb, vma, 0, -1);
>>> +A A A  unmap_vmas(&tlb, vma, 0, -1, false);
>>> A A A A A  free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>>> A A A A A  tlb_finish_mmu(&tlb, 0, -1);
>>>
> 
