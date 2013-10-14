Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B1C876B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 08:40:22 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so7248289pbc.17
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 05:40:22 -0700 (PDT)
Date: Mon, 14 Oct 2013 14:43:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: CONFIG_SLUB/USE_SPLIT_PTLOCKS compatibility
Message-ID: <20131014114341.GA24483@shutemov.name>
References: <CAMo8BfKqWPbDCMwCoH6BO6uXyYwr0Z1=AaMJDRLQt66FLb7LAg@mail.gmail.com>
 <20131014071205.GA23735@shutemov.name>
 <CAMo8Bf+9+_S0HeOUWjd3AXgsuM-XWYZx8b6aL=2+AFt0EK9DKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMo8Bf+9+_S0HeOUWjd3AXgsuM-XWYZx8b6aL=2+AFt0EK9DKg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "David S. Miller" <davem@davemloft.net>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Chris Zankel <chris@zankel.net>

On Mon, Oct 14, 2013 at 03:49:00PM +0400, Max Filippov wrote:
> On Mon, Oct 14, 2013 at 11:12 AM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> > On Mon, Oct 14, 2013 at 01:12:47AM +0400, Max Filippov wrote:
> >> Hello,
> >>
> >> I'm reliably getting kernel crash on xtensa when CONFIG_SLUB
> >> is selected and USE_SPLIT_PTLOCKS appears to be true (SMP=y,
> >> NR_CPUS=4, DEBUG_SPINLOCK=n, DEBUG_LOCK_ALLOC=n).
> >> This happens because spinlock_t ptl and struct page *first_page overlap
> >> in the struct page. The following call chain makes allocation of order
> >> 3 and initializes first_page pointer in its 7 tail pages:
> >>
> >>  do_page_fault
> >>   handle_mm_fault
> >>    __pte_alloc
> >>     kmem_cache_alloc
> >>      __slab_alloc
> >>       new_slab
> >>        __alloc_pages_nodemask
> >>         get_page_from_freelist
> >>          prep_compound_page
> >>
> >> Later pte_offset_map_lock is called with one of these tail pages
> >> overwriting its first_page pointer:
> >>
> >>  do_fork
> >>   copy_process
> >>    dup_mm
> >>     copy_page_range
> >>      copy_pte_range
> >>       pte_alloc_map_lock
> >>        pte_offset_map_lock
> >>
> >> Finally kmem_cache_free is called for that tail page, which calls
> >> slab_free(s, virt_to_head_page(x),... but virt_to_head_page here
> >> returns NULL, because the page's first_page pointer was overwritten
> >> earlier:
> >>
> >> exit_mmap
> >>  free_pgtables
> >>   free_pgd_range
> >>    free_pud_range
> >>     free_pmd_range
> >>      free_pte_range
> >>       pte_free
> >>        kmem_cache_free
> >>         slab_free
> >>          __slab_free
> >>
> >> __slab_free touches NULL struct page, that's it.
> >>
> >> Changing allocator to SLAB or enabling DEBUG_SPINLOCK
> >> fixes that crash.
> >>
> >> My question is, is CONFIG_SLUB supposed to work with
> >> USE_SPLIT_PTLOCKS (and if yes what's wrong in my case)?
> >
> > Sure, CONFIG_SLUB && USE_SPLIT_PTLOCKS works fine. Unless you try use slab
> > to allocate pagetable.
> >
> > Note: no other arch allocates PTE page tables from slab.
> > Some archs (sparc, power) uses slabs to allocate hihger page tables, but
> > not PTE. [ And these archs will have to avoid slab, if they wants to
> > support split ptl for PMD tables. ]
> >
> > I don't see much sense in having separate slab for allocting PAGE_SIZE
> > objects aligned to PAGE_SIZE. What's wrong with plain buddy allocator?
> 
> Buddy allocator was used here prior to commit
> 
> 6656920 [XTENSA] Add support for cache-aliasing
> 
> I can only guess that the change was made to make allocated page
> tables have the same colour, but am not sure why this is needed.
> Chris?

Other way around: different colours. In hope to increase cache usage.

> > Completely untested patch to use buddy allocator instead of slub for page
> > table allocation on xtensa is below. Please, try.
> 
> I've tried it (with minor modifications to make it build) and it fixes
> my original
> issue. Not sure about possible issues with cache aliasing though.

Okay. Broken colouring is a [potential] perfomance issue. Fixing crash is
more important. Performance can be fixed later.

I'll send the patchset with bugfix.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
