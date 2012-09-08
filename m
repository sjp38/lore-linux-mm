Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 91A8C6B0087
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 00:45:13 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so271176vbk.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 21:45:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120907232617.GA8439@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
	<1346750457-12385-2-git-send-email-walken@google.com>
	<20120907151341.79cb5638.akpm@linux-foundation.org>
	<CANN689HMxteeUT9q5BgKutEnNQF6sKv2n9ze11Z=wkOoC+XGqw@mail.gmail.com>
	<20120907155514.3fad7887.akpm@linux-foundation.org>
	<20120907232617.GA8439@google.com>
Date: Sat, 8 Sep 2012 12:45:12 +0800
Message-ID: <CAJd=RBC+AhTpLRqRLLHyZ-fhJahKyi5hFHQU5gimcf3NXfzoaw@mail.gmail.com>
Subject: Re: [PATCH 1/7] mm: interval tree updates
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org

Hello Michel

Lets first see snippet in another work.

	https://lkml.org/lkml/2012/9/4/75
	[PATCH 5/7] mm rmap: remove vma_address check for address inside vma

On Tue, Sep 4, 2012 at 5:20 PM, Michel Lespinasse <walken@google.com> wrote:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9c61bf387fd1..28777412de62 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -510,22 +510,26 @@ void page_unlock_anon_vma(struct anon_vma *anon_vma)
>
>  /*
>   * At what user virtual address is page expected in @vma?
> - * Returns virtual address or -EFAULT if page's index/offset is not
> - * within the range mapped the @vma.
>   */
> -inline unsigned long
> -vma_address(struct page *page, struct vm_area_struct *vma)
> +static inline unsigned long
> +__vma_address(struct page *page, struct vm_area_struct *vma)
>  {
>         pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> -       unsigned long address;
>
>         if (unlikely(is_vm_hugetlb_page(vma)))
>                 pgoff = page->index << huge_page_order(page_hstate(page));

The pgoff computation for huge page remains as it was.

> -       address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> -       if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
> -               /* page should be within @vma mapping range */
> -               return -EFAULT;
> -       }
> +
> +       return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> +}
> +
> +inline unsigned long
> +vma_address(struct page *page, struct vm_area_struct *vma)
> +{
> +       unsigned long address = __vma_address(page, vma);
> +
> +       /* page should be within @vma mapping range */
> +       VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +
>         return address;
>  }
>

Then lets see this work.


On Sat, Sep 8, 2012 at 7:26 AM, Michel Lespinasse <walken@google.com> wrote:
> -----------------------------8<-------------------------------------
> From: Michel Lespinasse <walken@google.com>
> Subject: mm: replace vma prio_tree with an interval tree
>
> Implement an interval tree as a replacement for the VMA prio_tree.
> The algorithms are similar to lib/interval_tree.c; however that code
> can't be directly reused as the interval endpoints are not explicitly
> stored in the VMA. So instead, the common algorithm is moved into
> a template and the details (node type, how to get interval endpoints
> from the node, etc) are filled in using the C preprocessor.
>
> Once the interval tree functions are available, using them as a replacement
> to the VMA prio tree is a relatively simple, mechanical job.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hillf Danton <dhillf@gmail.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

[...]

> --- /dev/null
> +++ b/mm/interval_tree.c
> @@ -0,0 +1,59 @@
> +/*
> + * mm/interval_tree.c - interval tree for mapping->i_mmap
> + *
> + * Copyright (C) 2012, Michel Lespinasse <walken@google.com>
> + *
> + * This file is released under the GPL v2.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/fs.h>
> +#include <linux/interval_tree_generic.h>
> +
> +static inline unsigned long vma_start_pgoff(struct vm_area_struct *v)
> +{
> +       return v->vm_pgoff;
> +}
> +
> +static inline unsigned long vma_last_pgoff(struct vm_area_struct *v)
> +{
> +       return v->vm_pgoff + ((v->vm_end - v->vm_start) >> PAGE_SHIFT) - 1;
> +}
> +

The pgoff computations are only for regular page, yes?

> +INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.linear.rb,
> +                    unsigned long, shared.linear.rb_subtree_last,
> +                    vma_start_pgoff, vma_last_pgoff,, vma_interval_tree)
> +

[...]

> @@ -1547,7 +1545,6 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>         struct address_space *mapping = page->mapping;
>         pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

What if page is huge?

>         struct vm_area_struct *vma;
> -       struct prio_tree_iter iter;
>         int ret = SWAP_AGAIN;
>         unsigned long cursor;
>         unsigned long max_nl_cursor = 0;
> @@ -1555,7 +1552,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>         unsigned int mapcount;
>
>         mutex_lock(&mapping->i_mmap_mutex);
> -       vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> +       vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>                 unsigned long address = vma_address(page, vma);
>                 if (address == -EFAULT)
>                         continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
