Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7B406B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 09:33:26 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id n10-v6so6581684oib.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 06:33:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p189-v6sor15109032oia.114.2018.11.05.06.33.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 06:33:25 -0800 (PST)
MIME-Version: 1.0
References: <20181105111348.182492-1-vovoy@chromium.org> <20181105130209.GI4361@dhcp22.suse.cz>
In-Reply-To: <20181105130209.GI4361@dhcp22.suse.cz>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Mon, 5 Nov 2018 22:33:13 +0800
Message-ID: <CAEHM+4r4gRiBdRHaziiAFzwB5VD785zpUEr31zFLbx4sNUW6TQ@mail.gmail.com>
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, Nov 5, 2018 at 9:02 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 05-11-18 19:13:48, Kuo-Hsin Yang wrote:
> > The i915 driver uses shmemfs to allocate backing storage for gem
> > objects. These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. In some extreme case,
> > all pages in the inactive anon lru are pinned, and only the inactive
> > anon lru is scanned due to inactive_ratio, the system cannot swap and
> > invokes the oom-killer. Mark these pinned pages as unevictable to speed
> > up vmscan.
> >
> > Export pagevec API check_move_unevictable_pages().
>
> Thanks for reworking the patch. This looks much more to my taste. At
> least the mm part. I haven't really looked at the the drm part.
>
> Just a nit below
>
> > This patch was inspired by Chris Wilson's change [1].
> >
> > [1]: https://patchwork.kernel.org/patch/9768741/
>
> I would recommend using msg-id based url.

I didn't find a msg-id based url for the [1] patch. This patch is sent
to intel-gfx@lists.freedesktop.org and linux-mm@kvack.org, but not to
linux-kernel@vger.kernel.org .

>
> > Cc: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
>
> other than that
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> [...]
>
> > @@ -4184,15 +4185,13 @@ int page_evictable(struct page *page)
> >
> >  #ifdef CONFIG_SHMEM
> >  /**
> > - * check_move_unevictable_pages - check pages for evictability and move to appropriate zone lru list
> > - * @pages:   array of pages to check
> > - * @nr_pages:        number of pages to check
> > + * check_move_unevictable_pages - move evictable pages to appropriate evictable
> > + * lru lists
>
> I am not sure this is an improvement. I would just keep the original
> wording. It is not great either but the explicit note about check for
> evictability sounds like a better fit to me.

OK, will keep the original wording.

>
> > + * @pvec: pagevec with pages to check
> >   *
> > - * Checks pages for evictability and moves them to the appropriate lru list.
> > - *
> > - * This function is only used for SysV IPC SHM_UNLOCK.
> > + * This function is only used to move shmem pages.
>
> I do not really see anything that would be shmem specific here. We can
> use this function for any LRU pages unless I am missing something
> obscure. I would just drop the last sentence.

OK, this function should not be specific to shmem pages.

Is it OK to remove the #ifdef SHMEM surrounding check_move_unevictable_pages?

>
> A note that this function should be only used for LRU pages would be
> nice.
>
> >   */
> > -void check_move_unevictable_pages(struct page **pages, int nr_pages)
> > +void check_move_unevictable_pages(struct pagevec *pvec)
> >  {
> >       struct lruvec *lruvec;
> >       struct pglist_data *pgdat = NULL;
> > @@ -4200,8 +4199,8 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
> >       int pgrescued = 0;
> >       int i;
> >
> > -     for (i = 0; i < nr_pages; i++) {
> > -             struct page *page = pages[i];
> > +     for (i = 0; i < pvec->nr; i++) {
> > +             struct page *page = pvec->pages[i];
> >               struct pglist_data *pagepgdat = page_pgdat(page);
> >
> >               pgscanned++;
> > @@ -4233,4 +4232,5 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
> >               spin_unlock_irq(&pgdat->lru_lock);
> >       }
> >  }
> > +EXPORT_SYMBOL(check_move_unevictable_pages);
> >  #endif /* CONFIG_SHMEM */
> > --
> > 2.19.1.930.g4563a0d9d0-goog
> >
>
> --
> Michal Hocko
> SUSE Labs
