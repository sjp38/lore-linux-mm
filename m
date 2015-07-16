Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 145432802DE
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 05:54:21 -0400 (EDT)
Received: by padck2 with SMTP id ck2so40146354pad.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 02:54:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h4si12152736pdi.136.2015.07.16.02.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 02:54:20 -0700 (PDT)
Date: Thu, 16 Jul 2015 12:53:56 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v8 6/7] proc: add kpageidle file
Message-ID: <20150716095356.GB2001@esperanza>
References: <cover.1436967694.git.vdavydov@parallels.com>
 <a414d0458156434ca428c0c810db2e86878e1897.1436967694.git.vdavydov@parallels.com>
 <CAJu=L59He_qOEM3fEADLaKcV0YGY+QKQ_kPN=rSF8=U_UzAt2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L59He_qOEM3fEADLaKcV0YGY+QKQ_kPN=rSF8=U_UzAt2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 12:42:28PM -0700, Andres Lagar-Cavilla wrote:
> On Wed, Jul 15, 2015 at 6:54 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
[...]
> > +static void kpageidle_clear_pte_refs(struct page *page)
> > +{
> > +       struct rmap_walk_control rwc = {
> > +               .rmap_one = kpageidle_clear_pte_refs_one,
> > +               .anon_lock = page_lock_anon_vma_read,
> > +       };
> > +       bool need_lock;
> > +
> > +       if (!page_mapped(page) ||
> 
> Question: what about mlocked pages? Is there any point in calculating
> their idleness?

Those can be filtered out with the aid of /proc/kpageflags (this is what
the script attached to patch #0 of the series actually does). We have to
read the latter anyway in order to get information about THP. That said,
I prefer not to introduce any artificial checks for locked memory. Who
knows, may be one day somebody will use this API to track access pattern
to an mlocked area.

> 
> > +           !page_rmapping(page))
> 
> Not sure, does this skip SwapCache pages? Is there any point in
> calculating their idleness?

A SwapCache page may be mapped, and if it is we should not skip it. If
it is unmapped, we have nothing to do.

Regarding idleness of SwapCache pages, I think we shouldn't
differentiate them from other user pages here, because a shmem/anon page
can migrate to-and-fro the swap cache occasionally during a
memory-active workload, and we don't want to lose its idle status then.

> 
> > +               return;
> > +
> > +       need_lock = !PageAnon(page) || PageKsm(page);
> > +       if (need_lock && !trylock_page(page))
> > +               return;
> > +
> > +       rmap_walk(page, &rwc);
> > +
> > +       if (need_lock)
> > +               unlock_page(page);
> > +}
[...]
> > @@ -1754,6 +1754,11 @@ static void __split_huge_page_refcount(struct page *page,
> >                 /* clear PageTail before overwriting first_page */
> >                 smp_wmb();
> >
> > +               if (page_is_young(page))
> > +                       set_page_young(page_tail);
> > +               if (page_is_idle(page))
> > +                       set_page_idle(page_tail);
> > +
> 
> Why not in the block above?
> 
> page_tail->flags |= (page->flags &
> ...
> #ifdef CONFIG_WHATEVER_IT_WAS
> 1 << PG_idle
> 1 << PG_young
> #endif

Too many ifdef's :-/ Note, the flags can be in page_ext, which mean we
would have to add something like this

#if defined(CONFIG_WHATEVER_IT_WAS) && defined(CONFIG_64BIT)
1 << PG_idle
1 << PG_young
#endif
<...>
#ifndef CONFIG_64BIT
if (page_is_young(page))
	set_page_young(page_tail);
if (page_is_idle(page))
	set_page_idle(page_tail);
#endif

which IMO looks less readable than what we have now.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
