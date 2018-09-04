Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10D656B6F3E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:55:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i188-v6so5053031itf.6
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:55:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n81-v6sor38283itb.99.2018.09.04.12.55.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 12:55:03 -0700 (PDT)
MIME-Version: 1.0
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain> <fe84cdb4-7be7-8ad8-58ca-681f46e2e55c@intel.com>
In-Reply-To: <fe84cdb4-7be7-8ad8-58ca-681f46e2e55c@intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Sep 2018 12:54:50 -0700
Message-ID: <CAKgT0Uc+UuXfK+KcN=9L2M7i+h7oUX9W912z82q-Vs0TFDJEpg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 4, 2018 at 12:25 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 09/04/2018 11:33 AM, Alexander Duyck wrote:
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -1444,7 +1444,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
> >
> >       ptr = memblock_virt_alloc_internal(size, align,
> >                                          min_addr, max_addr, nid);
> > -#ifdef CONFIG_DEBUG_VM
> > +#ifdef CONFIG_DEBUG_VM_PGFLAGS
> >       if (ptr && size > 0)
> >               memset(ptr, PAGE_POISON_PATTERN, size);
> >  #endif
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 10b07eea9a6e..0fd9ad5021b0 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -696,7 +696,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
> >               goto out;
> >       }
> >
> > -#ifdef CONFIG_DEBUG_VM
> > +#ifdef CONFIG_DEBUG_VM_PGFLAGS
> >       /*
> >        * Poison uninitialized struct pages in order to catch invalid flags
> >        * combinations.
>
> I think this is the wrong way to do this.  It keeps the setting and
> checking still rather tenuously connected.  If you were to leave it this
> way, it needs commenting.  It's also rather odd that we're memsetting
> the entire 'struct page' for a config option that's supposedly dealing
> with page->flags.  That deserves _some_ addressing in a comment or
> changelog.
>
> How about:
>
> #ifdef CONFIG_DEBUG_VM_PGFLAGS
> #define VM_BUG_ON_PGFLAGS(cond, page) VM_BUG_ON_PAGE(cond, page)
> +static inline void poison_struct_pages(struct page *pages, int nr)
> +{
> +       memset(pages, PAGE_POISON_PATTERN, size * sizeof(...));
> +}
> #else
> #define VM_BUG_ON_PGFLAGS(cond, page) BUILD_BUG_ON_INVALID(cond)
> static inline void poison_struct_pages(struct page *pages, int nr) {}
> #endif
>
> That puts the setting and checking in one spot, and also removes a
> couple of #ifdefs from .c files.

So the only issue with this is the fact that the code here is wrapped
in a check for CONFIG_DEBUG_VM, so if that isn't defined we end up
with build errors.

If the goal is to consolidate things I could probably look at adding a
function in include/linux/page-flags.h, probably next to PagePoisoned.
I could then probably just look at wrapping the memset call itself
with the CONFIG_DEBUG_VM_PGFLAGS instead of the entire function. I
could then place some code documentation in there explaining why it is
wrapped.

- Alex
