Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDC16B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 02:04:47 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id d8-v6so5976180wmb.5
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 23:04:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor16295421wrx.38.2018.11.04.23.04.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Nov 2018 23:04:45 -0800 (PST)
MIME-Version: 1.0
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com> <1526555193-7242-11-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1526555193-7242-11-git-send-email-ldufour@linux.vnet.ibm.com>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Mon, 5 Nov 2018 12:34:33 +0530
Message-ID: <CAOaiJ-nJ_=+diXz8ji42Rro3Mj16C1=NpenRuY3-mjs_GhR4mA@mail.gmail.com>
Subject: Re: [PATCH v11 10/26] mm: protect VMA modifications using VMA
 sequence count
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, punitagrawal@gmail.com, yang.shi@linux.alibaba.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, Balbir Singh <bsingharora@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

Hi Laurent,

On Thu, May 17, 2018 at 4:37 PM Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
>
> The VMA sequence count has been introduced to allow fast detection of
> VMA modification when running a page fault handler without holding
> the mmap_sem.
>
> This patch provides protection against the VMA modification done in :
>         - madvise()
>         - mpol_rebind_policy()
>         - vma_replace_policy()
>         - change_prot_numa()
>         - mlock(), munlock()
>         - mprotect()
>         - mmap_region()
>         - collapse_huge_page()
>         - userfaultd registering services
>
> In addition, VMA fields which will be read during the speculative fault
> path needs to be written using WRITE_ONCE to prevent write to be split
> and intermediate values to be pushed to other CPUs.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  fs/proc/task_mmu.c |  5 ++++-
>  fs/userfaultfd.c   | 17 +++++++++++++----
>  mm/khugepaged.c    |  3 +++
>  mm/madvise.c       |  6 +++++-
>  mm/mempolicy.c     | 51 ++++++++++++++++++++++++++++++++++-----------------
>  mm/mlock.c         | 13 ++++++++-----
>  mm/mmap.c          | 22 +++++++++++++---------
>  mm/mprotect.c      |  4 +++-
>  mm/swap_state.c    |  8 ++++++--
>  9 files changed, 89 insertions(+), 40 deletions(-)
>
>  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>                                 struct vm_fault *vmf)
> @@ -665,9 +669,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
>                                      unsigned long *start,
>                                      unsigned long *end)
>  {
> -       *start = max3(lpfn, PFN_DOWN(vma->vm_start),
> +       *start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
>                       PFN_DOWN(faddr & PMD_MASK));
> -       *end = min3(rpfn, PFN_DOWN(vma->vm_end),
> +       *end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
>                     PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
>  }
>
> --
> 2.7.4
>

I have got a crash on 4.14 kernel with speculative page faults enabled
and here is my analysis of the problem.
The issue was reported only once.

[23409.303395]  el1_da+0x24/0x84
[23409.303400]  __radix_tree_lookup+0x8/0x90
[23409.303407]  find_get_entry+0x64/0x14c
[23409.303410]  pagecache_get_page+0x5c/0x27c
[23409.303416]  __read_swap_cache_async+0x80/0x260
[23409.303420]  swap_vma_readahead+0x264/0x37c
[23409.303423]  swapin_readahead+0x5c/0x6c
[23409.303428]  do_swap_page+0x128/0x6e4
[23409.303431]  handle_pte_fault+0x230/0xca4
[23409.303435]  __handle_speculative_fault+0x57c/0x7c8
[23409.303438]  do_page_fault+0x228/0x3e8
[23409.303442]  do_translation_fault+0x50/0x6c
[23409.303445]  do_mem_abort+0x5c/0xe0
[23409.303447]  el0_da+0x20/0x24

Process A accesses address ADDR (part of VMA A) and that results in a
translation fault.
Kernel enters __handle_speculative_fault to fix the fault.
Process A enters do_swap_page->swapin_readahead->swap_vma_readahead
from speculative path.
During this time, another process B which shares the same mm, does a
mprotect from another CPU which follows
mprotect_fixup->__split_vma, and it splits VMA A into VMAs A and B.
After the split, ADDR falls into VMA B, but process A is still using
VMA A.
Now ADDR is greater than VMA_A->vm_start and VMA_A->vm_end.
swap_vma_readahead->swap_ra_info uses start and end of vma to
calculate ptes and nr_pte, which goes wrong due to this and finally
resulting in wrong "entry" passed to
swap_vma_readahead->__read_swap_cache_async, and in turn causing
invalid swapper_space
being passed to __read_swap_cache_async->find_get_page, causing an abort.

The fix I have tried is to cache vm_start and vm_end also in vmf and
use it in swap_ra_clamp_pfn. Let me know your thoughts on this. I can
send
the patch I am a using if you feel that is the right thing to do.

Thanks,
Vinayak
