Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9496B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:06:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11so2983850pfk.23
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:06:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v68si6923943pfj.359.2017.11.03.08.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 08:06:42 -0700 (PDT)
Subject: Re: Can someone explain what free_pgd_range(), etc actually do?
References: <CALCETrW73eB7GFkO6BEkF25wJODr2KCCv0baUykzfBZnWwOrVQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6afed21b-c017-13f8-40b7-15773fc3ecda@intel.com>
Date: Fri, 3 Nov 2017 08:06:41 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrW73eB7GFkO6BEkF25wJODr2KCCv0baUykzfBZnWwOrVQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: X86 ML <x86@kernel.org>

On 11/03/2017 05:11 AM, Andy Lutomirski wrote:
>  - What is the intended purpose of addr, end, floor, and ceiling?
> What are the pagetable freeing functions actually *supposed* to do?

I've always logically thought of it as: the VMA (and this addr/end) tell
us where we _must_ walk and free.  floor/ceiling tell us about
neighboring areas that are unused.  We do not have to walk the unused
areas, but we must free them if we clear out their last use.

Walking is presumably expensive.  We use the VMA information and plumb
it down through floor/ceiling to make sure that we're not having to look
at a full page of data at each level every time we free a VMA.

I think that might be what's tripping you up: floor/ceiling is just an
optimization.  It's not logically required for freeing page tables, but
it does speed things up.

>  - Are there any invariants that, for example, there is never a
> pagetable that doesn't have any vmas at all under it?  I can
> understand how all the code would be correct if this invariant were to
> exist, but I don't see what would preserve it.  But maybe
> free_pgd_range(), etc really do preserve it.

I think it's implemented more like: the last VMA using a page table will
free the page table when the VMA is torn down.  It does this by looking
at its neighbors (or lack thereof) at unmap_region() time and expanding
the range covered by floor/ceiling.

>  - What keeps mm->mmap pointing to the lowest-addressed vma?  I see
> lots of code that seems to assume that you can start at mm->mmap,
> follow the vm_next links, and find all vmas, but I can't figure out
> why this would work.

__vma_(un)link_list() is where the magic normally happens.  It
effectively uses the rbtree to determine where to put the VMA in the
list to maintain ordering.

>  - What happens if a process exits while mm->mmap is NULL?

You mean how do we free the page tables for it?  We had to do a bunch of
unmap_regions() before that to axe all the VMAs and the page tables
_should_ have zapped then.

Now, if someone goes and just sets mm->mmap, we're obviously screwed,
but we leaked a bunch of VMAs _anyway_, in addition to the page tables.

>  - Is there any piece of code that makes it obvious that all the
> pagetables are gone by the time the exit_mmap() finishes?

mm->nr_ptes and mm->nr_pmds (and soon nr_puds) should tell us if we
forgot to free one.  I think that's our main defense.

I have some vague recollection that we also looked for zero'd page table
pages somewhere at free time, but I'm not finding it.

> Because I'm staring to wonder whether some weird combination of maps
> and unmaps will just leak pagetables, and the code is rather
> complicated, subtle, and completely lacking in documentation, and I've
> learned to be quite suspicious of such things.
There have surely been bugs.  FWIW, there's some code in the MPX
selftests that tries to map and free a bunch of random addresses to trip
up the MPX code.  I ran it a *lot* and this code never got tripped up on
it that I can remember.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
