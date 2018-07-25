Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 171ED6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:50:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u21-v6so712663wmc.8
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:50:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j189-v6sor833216wmb.41.2018.07.24.19.50.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 19:50:36 -0700 (PDT)
MIME-Version: 1.0
References: <20180724204639.26934-1-cannonmatthews@google.com> <20180724135350.91a90f4f8742ec59c42721c3@linux-foundation.org>
In-Reply-To: <20180724135350.91a90f4f8742ec59c42721c3@linux-foundation.org>
From: Cannon Matthews <cannonmatthews@google.com>
Date: Tue, 24 Jul 2018 19:50:25 -0700
Message-ID: <CAJfu=UerK+cmgRcVOW_pLw+ADsSSksE1C0dgbGbbgX3DE_KCCg@mail.gmail.com>
Subject: Re: [PATCH] RFC: clear 1G pages with streaming stores on x86
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, sqazi@google.com, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, nullptr@google.com

On Tue, Jul 24, 2018 at 1:53 PM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Tue, 24 Jul 2018 13:46:39 -0700 Cannon Matthews <cannonmatthews@google=
.com> wrote:
>
> > Reimplement clear_gigantic_page() to clear gigabytes pages using the
> > non-temporal streaming store instructions that bypass the cache
> > (movnti), since an entire 1GiB region will not fit in the cache anyway.
> >
> > ...
> >
> > Tested:
> >       Time to `mlock()` a 512GiB region on broadwell CPU
> >                               AVG time (s)    % imp.  ms/page
> >       clear_page_erms         133.584         -       261
> >       clear_page_nt           34.154          74.43%  67
>
> A gigantic improvement!
>
> > --- a/arch/x86/include/asm/page_64.h
> > +++ b/arch/x86/include/asm/page_64.h
> > @@ -56,6 +56,9 @@ static inline void clear_page(void *page)
> >
> >  void copy_page(void *to, void *from);
> >
> > +#define __HAVE_ARCH_CLEAR_GIGANTIC_PAGE
> > +void __clear_page_nt(void *page, u64 page_size);
>
> Nit: the modern way is
>
> #ifndef __clear_page_nt
> void __clear_page_nt(void *page, u64 page_size);
> #define __clear_page_nt __clear_page_nt
> #endif
>
> Not sure why, really.  I guess it avoids adding two symbols and
> having to remember and maintain the relationship between them.
>

That makes sense, changed to this style. Thanks.

> > --- /dev/null
> > +++ b/arch/x86/lib/clear_gigantic_page.c
> > @@ -0,0 +1,30 @@
> > +#include <asm/page.h>
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/mm.h>
> > +#include <linux/sched.h>
> > +
> > +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> > +#define PAGES_BETWEEN_RESCHED 64
> > +void clear_gigantic_page(struct page *page,
> > +                             unsigned long addr,
> > +                             unsigned int pages_per_huge_page)
> > +{
> > +     int i;
> > +     void *dest =3D page_to_virt(page);
> > +     int resched_count =3D 0;
> > +
> > +     BUG_ON(pages_per_huge_page % PAGES_BETWEEN_RESCHED !=3D 0);
> > +     BUG_ON(!dest);
> > +
> > +     might_sleep();
>
> cond_resched() already does might_sleep() - it doesn't seem needed here.

=EF=BF=BCAh gotcha, removed it. The original implementation called both, wh=
ich
does seem redundant.

>
> > +     for (i =3D 0; i < pages_per_huge_page; i +=3D PAGES_BETWEEN_RESCH=
ED) {
> > +             __clear_page_nt(dest + (i * PAGE_SIZE),
> > +                             PAGES_BETWEEN_RESCHED * PAGE_SIZE);
> > +             resched_count +=3D cond_resched();
> > +     }
> > +     /* __clear_page_nt requrires and `sfence` barrier. */
> > +     wmb();
> > +     pr_debug("clear_gigantic_page: rescheduled %d times\n", resched_c=
ount);
> > +}
> > +#endif
>
