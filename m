Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1901A6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 12:19:30 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so220661844wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 09:19:29 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id n4si4982676wia.64.2015.10.07.09.19.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 09:19:29 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so220661224wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 09:19:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1444170529-12814-2-git-send-email-ross.zwisler@linux.intel.com>
References: <1444170529-12814-1-git-send-email-ross.zwisler@linux.intel.com>
	<1444170529-12814-2-git-send-email-ross.zwisler@linux.intel.com>
Date: Wed, 7 Oct 2015 09:19:28 -0700
Message-ID: <CAPcyv4ikrVqYc4QxAaZiPMc4awh6h6WG0kP5nH=ZnuNTJVDwiQ@mail.gmail.com>
Subject: Re: [PATCH v4 1/2] Revert "mm: take i_mmap_lock in
 unmap_mapping_range() for DAX"
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Tue, Oct 6, 2015 at 3:28 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> This reverts commits 46c043ede4711e8d598b9d63c5616c1fedb0605e
> and 8346c416d17bf5b4ea1508662959bb62e73fd6a5.
>
> The following two locking commits in the DAX code:
>
> commit 843172978bb9 ("dax: fix race between simultaneous faults")
> commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")
>
> introduced a number of deadlocks and other issues, and need to be
> reverted for the v4.3 kernel. The list of issues in DAX after these
> commits (some newly introduced by the commits, some preexisting) can be
> found here:
>
> https://lkml.org/lkml/2015/9/25/602
>
> This revert keeps the PMEM API changes to the zeroing code in
> __dax_pmd_fault(), which were added by this commit:
>
> commit d77e92e270ed ("dax: update PMD fault handler with PMEM API")
>
> It also keeps the code dropping mapping->i_mmap_rwsem before calling
> unmap_mapping_range(), but converts it to a read lock since that's what is
> now used by the rest of __dax_pmd_fault().  This is needed to avoid
> recursively acquiring mapping->i_mmap_rwsem, once with a read lock in
> __dax_pmd_fault() and once with a write lock in unmap_mapping_range().

I think it is safe to say that this has now morphed into a full blown
fix and the "revert" label no longer applies.  But, I'll let Andrew
weigh in if he wants that fixed up or will replace these patches in
-mm:

revert-mm-take-i_mmap_lock-in-unmap_mapping_range-for-dax.patch
revert-dax-fix-race-between-simultaneous-faults.patch
dax-temporarily-disable-dax-pmd-fault-path.patch

...with this new series.

However, a question below:

> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c    | 37 +++++++++++++------------------------
>  mm/memory.c | 11 +++++++++--
>  2 files changed, 22 insertions(+), 26 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index bcfb14b..f665bc9 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -569,36 +569,14 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
>                 goto fallback;
>
> -       sector = bh.b_blocknr << (blkbits - 9);
> -
> -       if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> -               int i;
> -
> -               length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
> -                                               bh.b_size);
> -               if (length < 0) {
> -                       result = VM_FAULT_SIGBUS;
> -                       goto out;
> -               }
> -               if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
> -                       goto fallback;
> -
> -               for (i = 0; i < PTRS_PER_PMD; i++)
> -                       clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
> -               wmb_pmem();
> -               count_vm_event(PGMAJFAULT);
> -               mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> -               result |= VM_FAULT_MAJOR;
> -       }
> -
>         /*
>          * If we allocated new storage, make sure no process has any
>          * zero pages covering this hole
>          */
>         if (buffer_new(&bh)) {
> -               i_mmap_unlock_write(mapping);
> +               i_mmap_unlock_read(mapping);
>                 unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
> -               i_mmap_lock_write(mapping);
> +               i_mmap_lock_read(mapping);
>         }
>
>         /*
> @@ -635,6 +613,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>                 result = VM_FAULT_NOPAGE;
>                 spin_unlock(ptl);
>         } else {
> +               sector = bh.b_blocknr << (blkbits - 9);
>                 length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
>                                                 bh.b_size);
>                 if (length < 0) {
> @@ -644,6 +623,16 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>                 if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
>                         goto fallback;
>
> +               if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> +                       int i;
> +                       for (i = 0; i < PTRS_PER_PMD; i++)
> +                               clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
> +                       wmb_pmem();
> +                       count_vm_event(PGMAJFAULT);
> +                       mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +                       result |= VM_FAULT_MAJOR;
> +               }
> +
>                 result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
>         }
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 9cb2747..5ec066f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2426,10 +2426,17 @@ void unmap_mapping_range(struct address_space *mapping,
>         if (details.last_index < details.first_index)
>                 details.last_index = ULONG_MAX;
>
> -       i_mmap_lock_write(mapping);
> +
> +       /*
> +        * DAX already holds i_mmap_lock to serialise file truncate vs
> +        * page fault and page fault vs page fault.
> +        */
> +       if (!IS_DAX(mapping->host))
> +               i_mmap_lock_write(mapping);
>         if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>                 unmap_mapping_range_tree(&mapping->i_mmap, &details);
> -       i_mmap_unlock_write(mapping);
> +       if (!IS_DAX(mapping->host))
> +               i_mmap_unlock_write(mapping);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);

What about cases where unmap_mapping_range() is called without an fs
lock?  For the get_user_pages() and ZONE_DEVICE implementation I'm
looking to call truncate_pagecache() from the driver shutdown path to
revoke usage of the struct page's that were allocated by
devm_memremap_pages().

Likely I'm introducing a path through unmap_mapping_range() that does
not exist today, but I don't like that unmap_mapping_range() with this
change is presuming a given locking context.  It's not clear to me how
this routine is safe when it optionally takes i_mmap_lock_write(), at
a minimum this needs documenting, and possibly assertions if the
locking assumptions are violated.

invalidate_inode_pages2_range() seems to call unmap_mapping_range()
without the the correct locking, but this was just a quick scan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
