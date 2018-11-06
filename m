Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F06D76B02EE
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:28:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g24-v6so12018461pfi.23
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:28:59 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id h19si19437141pgb.231.2018.11.06.01.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:28:58 -0800 (PST)
Subject: Re: [PATCH v11 10/26] mm: protect VMA modifications using VMA
 sequence count
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1526555193-7242-11-git-send-email-ldufour@linux.vnet.ibm.com>
 <CAOaiJ-nJ_=+diXz8ji42Rro3Mj16C1=NpenRuY3-mjs_GhR4mA@mail.gmail.com>
 <239bab9c-e38c-951d-9114-34227b1dc94c@liunx.vnet.ibm.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <836276ba-5063-4d65-4649-480c8bd31c45@codeaurora.org>
Date: Tue, 6 Nov 2018 14:58:42 +0530
MIME-Version: 1.0
In-Reply-To: <239bab9c-e38c-951d-9114-34227b1dc94c@liunx.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@liunx.vnet.ibm.com>, vinayak menon <vinayakm.list@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, punitagrawal@gmail.com, yang.shi@linux.alibaba.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, Balbir Singh <bsingharora@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 11/5/2018 11:52 PM, Laurent Dufour wrote:
> Le 05/11/2018 A  08:04, vinayak menon a A(C)critA :
>> Hi Laurent,
>>
>> On Thu, May 17, 2018 at 4:37 PM Laurent Dufour
>> <ldufour@linux.vnet.ibm.com> wrote:
>>>
>>> The VMA sequence count has been introduced to allow fast detection of
>>> VMA modification when running a page fault handler without holding
>>> the mmap_sem.
>>>
>>> This patch provides protection against the VMA modification done in :
>>> A A A A A A A A  - madvise()
>>> A A A A A A A A  - mpol_rebind_policy()
>>> A A A A A A A A  - vma_replace_policy()
>>> A A A A A A A A  - change_prot_numa()
>>> A A A A A A A A  - mlock(), munlock()
>>> A A A A A A A A  - mprotect()
>>> A A A A A A A A  - mmap_region()
>>> A A A A A A A A  - collapse_huge_page()
>>> A A A A A A A A  - userfaultd registering services
>>>
>>> In addition, VMA fields which will be read during the speculative fault
>>> path needs to be written using WRITE_ONCE to prevent write to be split
>>> and intermediate values to be pushed to other CPUs.
>>>
>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>> ---
>>> A  fs/proc/task_mmu.c |A  5 ++++-
>>> A  fs/userfaultfd.cA A  | 17 +++++++++++++----
>>> A  mm/khugepaged.cA A A  |A  3 +++
>>> A  mm/madvise.cA A A A A A  |A  6 +++++-
>>> A  mm/mempolicy.cA A A A  | 51 ++++++++++++++++++++++++++++++++++-----------------
>>> A  mm/mlock.cA A A A A A A A  | 13 ++++++++-----
>>> A  mm/mmap.cA A A A A A A A A  | 22 +++++++++++++---------
>>> A  mm/mprotect.cA A A A A  |A  4 +++-
>>> A  mm/swap_state.cA A A  |A  8 ++++++--
>>> A  9 files changed, 89 insertions(+), 40 deletions(-)
>>>
>>> A  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  struct vm_fault *vmf)
>>> @@ -665,9 +669,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  unsigned long *start,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  unsigned long *end)
>>> A  {
>>> -A A A A A A  *start = max3(lpfn, PFN_DOWN(vma->vm_start),
>>> +A A A A A A  *start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
>>> A A A A A A A A A A A A A A A A A A A A A A  PFN_DOWN(faddr & PMD_MASK));
>>> -A A A A A A  *end = min3(rpfn, PFN_DOWN(vma->vm_end),
>>> +A A A A A A  *end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
>>> A A A A A A A A A A A A A A A A A A A A  PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
>>> A  }
>>>
>>> -- 
>>> 2.7.4
>>>
>>
>> I have got a crash on 4.14 kernel with speculative page faults enabled
>> and here is my analysis of the problem.
>> The issue was reported only once.
>
> Hi Vinayak,
>
> Thanks for reporting this.
>
>>
>> [23409.303395]A  el1_da+0x24/0x84
>> [23409.303400]A  __radix_tree_lookup+0x8/0x90
>> [23409.303407]A  find_get_entry+0x64/0x14c
>> [23409.303410]A  pagecache_get_page+0x5c/0x27c
>> [23409.303416]A  __read_swap_cache_async+0x80/0x260
>> [23409.303420]A  swap_vma_readahead+0x264/0x37c
>> [23409.303423]A  swapin_readahead+0x5c/0x6c
>> [23409.303428]A  do_swap_page+0x128/0x6e4
>> [23409.303431]A  handle_pte_fault+0x230/0xca4
>> [23409.303435]A  __handle_speculative_fault+0x57c/0x7c8
>> [23409.303438]A  do_page_fault+0x228/0x3e8
>> [23409.303442]A  do_translation_fault+0x50/0x6c
>> [23409.303445]A  do_mem_abort+0x5c/0xe0
>> [23409.303447]A  el0_da+0x20/0x24
>>
>> Process A accesses address ADDR (part of VMA A) and that results in a
>> translation fault.
>> Kernel enters __handle_speculative_fault to fix the fault.
>> Process A enters do_swap_page->swapin_readahead->swap_vma_readahead
>> from speculative path.
>> During this time, another process B which shares the same mm, does a
>> mprotect from another CPU which follows
>> mprotect_fixup->__split_vma, and it splits VMA A into VMAs A and B.
>> After the split, ADDR falls into VMA B, but process A is still using
>> VMA A.
>> Now ADDR is greater than VMA_A->vm_start and VMA_A->vm_end.
>> swap_vma_readahead->swap_ra_info uses start and end of vma to
>> calculate ptes and nr_pte, which goes wrong due to this and finally
>> resulting in wrong "entry" passed to
>> swap_vma_readahead->__read_swap_cache_async, and in turn causing
>> invalid swapper_space
>> being passed to __read_swap_cache_async->find_get_page, causing an abort.
>>
>> The fix I have tried is to cache vm_start and vm_end also in vmf and
>> use it in swap_ra_clamp_pfn. Let me know your thoughts on this. I can
>> send
>> the patch I am a using if you feel that is the right thing to do.
>
> I think the best would be to don't do swap readahead during the speculatvive page fault. If the page is found in the swap cache, that's fine, but otherwise, we should fA A A  allback to the regular page fault.
>
> The attached -untested- patch is doing this, if you want to give it a try. I'll review that for the next series.
>

Thanks Laurent. I and going to try this patch.

With this patch, since all non-SWP_SYNCHRONOUS_IO swapins result in non-speculative fault
and a retry, wouldn't this have an impact on some perf numbers ? If so, would caching start
and end be a better option ?

Also, would it make sense to move the FAULT_FLAG_SPECULATIVE check inside swapin_readahead,
in a way thatA  swap_cluster_readahead can take the speculative path ? swap_cluster_readahead
doesn't seem to use vma values.

Thanks,
Vinayak
