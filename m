Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02E266B753A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:54:49 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o18-v6so8759962ioh.23
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:54:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor1571541iof.266.2018.09.05.14.54.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 14:54:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain> <cd1fc4c6-cc86-8bf7-6aa0-b722c56057e3@microsoft.com>
 <CAKgT0UcC2=Nrk+TDkidxjidnJzvhUPyYRD1uZ09BBWLcmcaOug@mail.gmail.com> <985fe87b-b8f4-de58-ea2a-970cbe51b72d@microsoft.com>
In-Reply-To: <985fe87b-b8f4-de58-ea2a-970cbe51b72d@microsoft.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 5 Sep 2018 14:54:35 -0700
Message-ID: <CAKgT0Ud12tMA_LcJ6_yAD4aMObHWCHqKPbwrEdNGcWsiKuVLYg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to CONFIG_DEBUG_VM_PAGE_INIT_POISON
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 5, 2018 at 2:38 PM Pasha Tatashin
<Pavel.Tatashin@microsoft.com> wrote:
>
>
>
> On 9/5/18 5:29 PM, Alexander Duyck wrote:
> > On Wed, Sep 5, 2018 at 2:22 PM Pasha Tatashin
> > <Pavel.Tatashin@microsoft.com> wrote:
> >>
> >>
> >>
> >> On 9/5/18 5:13 PM, Alexander Duyck wrote:
> >>> From: Alexander Duyck <alexander.h.duyck@intel.com>
> >>>
> >>> On systems with a large amount of memory it can take a significant amount
> >>> of time to initialize all of the page structs with the PAGE_POISON_PATTERN
> >>> value. I have seen it take over 2 minutes to initialize a system with
> >>> over 12GB of RAM.
> >>>
> >>> In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
> >>> the boot time returned to something much more reasonable as the
> >>> arch_add_memory call completed in milliseconds versus seconds. However in
> >>> doing that I had to disable all of the other VM debugging on the system.
> >>>
> >>> Instead of keeping the value in CONFIG_DEBUG_VM I am adding a new CONFIG
> >>> value called CONFIG_DEBUG_VM_PAGE_INIT_POISON that will control the page
> >>> poisoning independent of the CONFIG_DEBUG_VM option.
> >>>
> >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >>> ---
> >>>  include/linux/page-flags.h |    8 ++++++++
> >>>  lib/Kconfig.debug          |   14 ++++++++++++++
> >>>  mm/memblock.c              |    5 ++---
> >>>  mm/sparse.c                |    4 +---
> >>>  4 files changed, 25 insertions(+), 6 deletions(-)
> >>>
> >>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >>> index 74bee8cecf4c..0e95ca63375a 100644
> >>> --- a/include/linux/page-flags.h
> >>> +++ b/include/linux/page-flags.h
> >>> @@ -13,6 +13,7 @@
> >>>  #include <linux/mm_types.h>
> >>>  #include <generated/bounds.h>
> >>>  #endif /* !__GENERATING_BOUNDS_H */
> >>> +#include <linux/string.h>
> >>>
> >>>  /*
> >>>   * Various page->flags bits:
> >>> @@ -162,6 +163,13 @@ static inline int PagePoisoned(const struct page *page)
> >>>       return page->flags == PAGE_POISON_PATTERN;
> >>>  }
> >>>
> >>> +static inline void page_init_poison(struct page *page, size_t size)
> >>> +{
> >>> +#ifdef CONFIG_DEBUG_VM_PAGE_INIT_POISON
> >>> +     memset(page, PAGE_POISON_PATTERN, size);
> >>> +#endif
> >>> +}
> >>> +
> >>>  /*
> >>>   * Page flags policies wrt compound pages
> >>>   *
> >>> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> >>> index 613316724c6a..3b1277c52fed 100644
> >>> --- a/lib/Kconfig.debug
> >>> +++ b/lib/Kconfig.debug
> >>> @@ -637,6 +637,20 @@ config DEBUG_VM_PGFLAGS
> >>>
> >>>         If unsure, say N.
> >>>
> >>> +config DEBUG_VM_PAGE_INIT_POISON
> >>> +     bool "Enable early page metadata poisoning"
> >>> +     default y
> >>> +     depends on DEBUG_VM
> >>> +     help
> >>> +       Seed the page metadata with a poison pattern to improve the
> >>> +       likelihood of detecting attempts to access the page prior to
> >>> +       initialization by the memory subsystem.
> >>> +
> >>> +       This initialization can result in a longer boot time for systems
> >>> +       with a large amount of memory.
> >>
> >> What happens when DEBUG_VM_PGFLAGS = y and
> >> DEBUG_VM_PAGE_INIT_POISON = n ?
> >>
> >> We are testing for pattern that was not set?
> >>
> >> I think DEBUG_VM_PAGE_INIT_POISON must depend on DEBUG_VM_PGFLAGS instead.
> >>
> >> Looks good otherwise.
> >>
> >> Thank you,
> >> Pavel
> >
> > The problem is that I then end up in the same situation I had in the
> > last patch where you have to have DEBUG_VM_PGFLAGS on in order to do
> > the seeding with poison.
>
> OK
>
> >
> > I can wrap the bit of code in PagePoisoned to just always return false
> > if we didn't set the pattern. I figure there is value to be had for
> > running DEBUG_VM_PGFLAGS regardless of the poison check, or
> > DEBUG_VM_PAGE_INIT_POISON without the PGFLAGS check. That is why I
> > wanted to leave them independent.
>
> How about:
>
> Remove "depends on DEBUG_VM", but make DEBUG_VM_PGFLAGS to depend on
> both DEBUG_VM and DEBUG_VM_PAGE_INIT_POISON?
>
> DEBUG_VM_PGFLAGS is already extremely slow, so having this extra
> dependency is OK.
>
> Thank you,
> Pavel

Why create the extra dependency though? In the case of DEBUG_VM I am
doing it so that we can retain the original behavior where enabling
DEBUG_VM should enable the poisoning. I want to avoid this just
getting disabled by default and want to try to stick to the original
behavior as closely as possible unless we want to go in and explicitly
turn it off.

>From what I can tell the original code prior to your changes didn't
bother checking for the poison value when testing the page flags. The
poison value only applies prior to the page being initialized, so the
value add for having it is only so much. It makes more sense to me to
have these as two separate config options where enabling both would
give you the maximum benefit, but you could test with either one or
the other if you so desired.

- Alex
