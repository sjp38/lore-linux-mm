Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 628876B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:54:26 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l6so142397860wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:54:26 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id c126si18014400wme.33.2016.04.11.04.54.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:54:24 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id n3so101044355wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:54:24 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:54:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 09/31] huge tmpfs: avoid premature exposure of new
 pagetable
Message-ID: <20160411115422.GF22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051423160.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051423160.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 02:24:23PM -0700, Hugh Dickins wrote:
> In early development, a huge tmpfs fault simply replaced the pmd which
> pointed to the empty pagetable just allocated in __handle_mm_fault():
> but that is unsafe.
> 
> Andrea wrote a very interesting comment on THP in mm/memory.c,
> just before the end of __handle_mm_fault():
> 
>  * A regular pmd is established and it can't morph into a huge pmd
>  * from under us anymore at this point because we hold the mmap_sem
>  * read mode and khugepaged takes it in write mode. So now it's
>  * safe to run pte_offset_map().
> 
> This comment hints at several difficulties, which anon THP solved
> for itself with mmap_sem and anon_vma lock, but which huge tmpfs
> may need to solve differently.
> 
> The reference to pte_offset_map() above: I believe that's a hint
> that on a 32-bit machine, the pagetables might need to come from
> kernel-mapped memory, but a huge pmd pointing to user memory beyond
> that limit could be racily substituted, causing undefined behavior
> in the architecture-dependent pte_offset_map().
> 
> That itself is not a problem on x86_64, but there's plenty more:
> how about those places which use pte_offset_map_lock() - if that
> spinlock is in the struct page of a pagetable, which has been
> deposited and might be withdrawn and freed at any moment (being
> on a list unattached to the allocating pmd in the case of x86),
> taking the spinlock might corrupt someone else's struct page.
> 
> Because THP has departed from the earlier rules (when pagetable
> was only freed under exclusive mmap_sem, or at exit_mmap, after
> removing all affected vmas from the rmap list): zap_huge_pmd()
> does pte_free() even when serving MADV_DONTNEED under down_read
> of mmap_sem.

Emm.. The pte table freed from zap_huge_pmd() is from deposit. It wasn't
linked into process' page table tree. So I don't see how THP has departed
from the rules.

I don't think it changes anything to implementation, but this part of
commit message, I believe, is inaccurate.

> And what of the "entry = *pte" at the start of handle_pte_fault(),
> getting the entry used in pte_same(,orig_pte) tests to validate all
> fault handling?  If that entry can itself be junk picked out of some
> freed and reused pagetable, it's hard to estimate the consequences.
> 
> We need to consider the safety of concurrent faults, and the
> safety of rmap lookups, and the safety of miscellaneous operations
> such as smaps_pte_range() for reading /proc/<pid>/smaps.
> 
> I set out to make safe the places which descend pgd,pud,pmd,pte,
> using more careful access techniques like mm_find_pmd(); but with
> pte_offset_map() being architecture-defined, found it too big a job
> to tighten up all over.
> 
> Instead, approach from the opposite direction: just do not expose
> a pagetable in an empty *pmd, until vm_ops->fault has had a chance
> to ask for a huge pmd there.  This is a much easier change to make,
> and we are lucky that all the driver faults appear to be using
> interfaces (like vm_insert_page() and remap_pfn_range()) which
> automatically do the pte_alloc() if it was not already done.
> 
> But we must not get stuck refaulting: need FAULT_FLAG_MAY_HUGE for
> __do_fault() to tell shmem_fault() to try for huge only when *pmd is
> empty (could instead add pmd to vmf and let shmem work that out for
> itself, but probably better to hide pmd from vm_ops->faults).
> 
> Without a pagetable to hold the pte_none() entry found in a newly
> allocated pagetable, handle_pte_fault() would like to provide a static
> none entry for later orig_pte checks.  But architectures have never had
> to provide that definition before; and although almost all use zeroes
> for an empty pagetable, a few do not - nios2, s390, um, xtensa.
> 
> Never mind, forget about pte_same(,orig_pte), the three __do_fault()
> callers can follow do_anonymous_page(), and just use a pte_none() check.
> 
> do_fault_around() presents one last problem: it wants pagetable to
> have been allocated, but was being called by do_read_fault() before
> __do_fault().  I see no disadvantage to moving it after, allowing huge
> pmd to be chosen first; but Kirill reports additional radix-tree lookup
> in hot pagecache case when he implemented faultaround: needs further
> investigation.

In my implementation faultaround can establish PMD mappings. So there's no
disadvantage to call faultaround first.

And if faultaround happened to solve the page fault we don't need to do
usual ->fault lookup.

> Note: after months of use, we recently hit an OOM deadlock: this patch
> moves the new pagetable allocation inside where page lock is held on a
> pagecache page, and exit's munlock_vma_pages_all() takes page lock on
> all mlocked pages.  Both parties are behaving badly: we hope to change
> munlock to use trylock_page() instead, but should certainly switch here
> to preallocating the pagetable outside the page lock.  But I've not yet
> written and tested that change.

Hm. Okay, I need to fix this in my implementation too. It shouldn't be too
hard as I have fe->pte_prealloc around already.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
