Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 678766B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:19:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18so5972733pgv.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 00:19:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z68sor2720957pgb.11.2018.04.23.00.19.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 00:19:52 -0700 (PDT)
Date: Mon, 23 Apr 2018 16:19:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 09/25] mm: protect VMA modifications using VMA
 sequence count
Message-ID: <20180423071941.GD114098@rodete-desktop-imager.corp.google.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-10-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523975611-15978-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Apr 17, 2018 at 04:33:15PM +0200, Laurent Dufour wrote:
> The VMA sequence count has been introduced to allow fast detection of
> VMA modification when running a page fault handler without holding
> the mmap_sem.
> 
> This patch provides protection against the VMA modification done in :
> 	- madvise()
> 	- mpol_rebind_policy()
> 	- vma_replace_policy()
> 	- change_prot_numa()
> 	- mlock(), munlock()
> 	- mprotect()
> 	- mmap_region()
> 	- collapse_huge_page()
> 	- userfaultd registering services
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
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index c486ad4b43f0..aeb417f28839 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1136,8 +1136,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  					goto out_mm;
>  				}
>  				for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -					vma->vm_flags &= ~VM_SOFTDIRTY;
> +					vm_write_begin(vma);
> +					WRITE_ONCE(vma->vm_flags,
> +						   vma->vm_flags & ~VM_SOFTDIRTY);
>  					vma_set_page_prot(vma);
> +					vm_write_end(vma);

trivial:

I think It's tricky to maintain that VMA fields to be read during SPF should be
(READ|WRITE_ONCE). I think we need some accessor to read/write them rather than
raw accessing like like vma_set_page_prot. Maybe spf prefix would be helpful. 

	vma_spf_set_value(vma, vm_flags, val);

We also add some markers in vm_area_struct's fileds to indicate that
people shouldn't access those fields directly.

Just a thought.


>  				}
>  				downgrade_write(&mm->mmap_sem);


> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index fe079756bb18..8a8a402ed59f 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -575,6 +575,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
>   * the readahead.
>   *
>   * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
> + * This is needed to ensure the VMA will not be freed in our back. In the case
> + * of the speculative page fault handler, this cannot happen, even if we don't
> + * hold the mmap_sem. Callees are assumed to take care of reading VMA's fields

I guess reader would be curious on *why* is safe with SPF.
Comment about the why could be helpful for reviewer.

> + * using READ_ONCE() to read consistent values.
>   */
>  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  				struct vm_fault *vmf)
> @@ -668,9 +672,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
>  				     unsigned long *start,
>  				     unsigned long *end)
>  {
> -	*start = max3(lpfn, PFN_DOWN(vma->vm_start),
> +	*start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
>  		      PFN_DOWN(faddr & PMD_MASK));
> -	*end = min3(rpfn, PFN_DOWN(vma->vm_end),
> +	*end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
>  		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
>  }
>  
> -- 
> 2.7.4
> 
