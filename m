Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4146B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 08:32:12 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so8707884qge.32
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 05:32:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l34si30993069qgd.77.2014.08.21.05.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Aug 2014 05:32:11 -0700 (PDT)
Date: Thu, 21 Aug 2014 09:31:58 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup
Message-ID: <20140821123157.GA19986@optiplex.redhat.com>
References: <5ad4664811559496e563ead974f10e8ee6b4ed47.1408576903.git.aquini@redhat.com>
 <20140820150509.4194.24336.stgit@buzz>
 <60e809f1c932fbbb175d59a750a329f04730717e.1408576903.git.aquini@redhat.com>
 <CALYGNiN+MZO42FLhpeyGXhs6a8MRPDDgKfngusWdfNV3r_C0dw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiN+MZO42FLhpeyGXhs6a8MRPDDgKfngusWdfNV3r_C0dw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On Thu, Aug 21, 2014 at 11:30:59AM +0400, Konstantin Khlebnikov wrote:
> On Thu, Aug 21, 2014 at 3:58 AM, Rafael Aquini <aquini@redhat.com> wrote:
> > On Wed, Aug 20, 2014 at 07:05:09PM +0400, Konstantin Khlebnikov wrote:
> >> * move special branch for balloon migraion into migrate_pages
> >> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> >> * embed struct balloon_dev_info into struct virtio_balloon
> >> * cleanup balloon_page_dequeue, kill balloon_page_free
> >>
> >> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> >> ---
> >>  drivers/virtio/virtio_balloon.c    |   77 ++++---------
> >>  include/linux/balloon_compaction.h |  107 ++++++------------
> >>  include/linux/migrate.h            |   11 --
> >>  include/linux/pagemap.h            |   18 ---
> >>  mm/balloon_compaction.c            |  214 ++++++++++++------------------------
> >>  mm/migrate.c                       |   27 +----
> >>  6 files changed, 130 insertions(+), 324 deletions(-)
> >>
> > Very nice clean-up, just as all other patches in this set.
> > Please, just consider amending the following changes to this patch of yours
> 
> Well. Probably it's better to hide __Set/Clear inside mm/balloon_compaction.c
> it very unlikely that they might  be used by somebody else.
> mm.h contains too many obscure static inlines and other barely used stuff.
>
Although I agree that very few codesites will actually resort to them,
I believe there's no argument to hide __Set/Clear if PageBalloon() itself is there.
Take a look into how many codesites __{Set,Clear}PageBuddy are being
called -- (as in their Balloon counterpart, just 1 codesite each).

For the sake of consistency and ease of maintainability, either leave all
BalloonPage() and friends at mm.h or move them all out, 
hiding them in balloon_compaction.h.

> And it's worth to rename balloon_compaction.c/h into just balloon.c or
> memory_balloon because
> it provides generic balloon wtihout compaction too. Any objections?
>
No objections here, I was actually thinking about renaming them too.

--
Rafael
 
> >
> > Rafael
> > ---
> >
> > diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> > index dc7073b..569cf96 100644
> > --- a/include/linux/balloon_compaction.h
> > +++ b/include/linux/balloon_compaction.h
> > @@ -75,41 +75,6 @@ extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> >  #ifdef CONFIG_BALLOON_COMPACTION
> >  extern bool balloon_page_isolate(struct page *page);
> >  extern void balloon_page_putback(struct page *page);
> > -
> > -/*
> > - * balloon_page_insert - insert a page into the balloon's page list and make
> > - *                      the page->mapping assignment accordingly.
> > - * @page    : page to be assigned as a 'balloon page'
> > - * @mapping : allocated special 'balloon_mapping'
> > - * @head    : balloon's device page list head
> > - *
> > - * Caller must ensure the page is locked and the spin_lock protecting balloon
> > - * pages list is held before inserting a page into the balloon device.
> > - */
> > -static inline void
> > -balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
> > -{
> > -       __SetPageBalloon(page);
> > -       set_page_private(page, (unsigned long)balloon);
> > -       list_add(&page->lru, &balloon->pages);
> > -}
> > -
> > -/*
> > - * balloon_page_delete - delete a page from balloon's page list and clear
> > - *                      the page->mapping assignement accordingly.
> > - * @page    : page to be released from balloon's page list
> > - *
> > - * Caller must ensure the page is locked and the spin_lock protecting balloon
> > - * pages list is held before deleting a page from the balloon device.
> > - */
> > -static inline void balloon_page_delete(struct page *page, bool isolated)
> > -{
> > -       __ClearPageBalloon(page);
> > -       set_page_private(page, 0);
> > -       if (!isolated)
> > -               list_del(&page->lru);
> > -}
> > -
> >  int balloon_page_migrate(new_page_t get_new_page, free_page_t put_new_page,
> >                 unsigned long private, struct page *page,
> >                 int force, enum migrate_mode mode);
> > @@ -130,31 +95,6 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
> >
> >  #else /* !CONFIG_BALLOON_COMPACTION */
> >
> > -static inline void *balloon_mapping_alloc(void *balloon_device,
> > -                               const struct address_space_operations *a_ops)
> > -{
> > -       return ERR_PTR(-EOPNOTSUPP);
> > -}
> > -
> > -static inline void balloon_mapping_free(struct address_space *balloon_mapping)
> > -{
> > -       return;
> > -}
> > -
> > -static inline void
> > -balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
> > -{
> > -       __SetPageBalloon(page);
> > -       list_add(&page->lru, head);
> > -}
> > -
> > -static inline void balloon_page_delete(struct page *page, bool isolated)
> > -{
> > -       __ClearPageBalloon(page);
> > -       if (!isolated)
> > -               list_del(&page->lru);
> > -}
> > -
> >  static inline int balloon_page_migrate(new_page_t get_new_page,
> >                 free_page_t put_new_page, unsigned long private,
> >                 struct page *page, int force, enum migrate_mode mode)
> > @@ -176,6 +116,46 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
> >  {
> >         return GFP_HIGHUSER;
> >  }
> > -
> >  #endif /* CONFIG_BALLOON_COMPACTION */
> > +
> > +/*
> > + * balloon_page_insert - insert a page into the balloon's page list and make
> > + *                      the page->mapping assignment accordingly.
> > + * @page    : page to be assigned as a 'balloon page'
> > + * @mapping : allocated special 'balloon_mapping'
> > + * @head    : balloon's device page list head
> > + *
> > + * Caller must ensure the page is locked and the spin_lock protecting balloon
> > + * pages list is held before inserting a page into the balloon device.
> > + */
> > +static inline void
> > +balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
> > +{
> > +#ifdef CONFIG_MEMORY_BALLOON
> > +       __SetPageBalloon(page);
> > +       set_page_private(page, (unsigned long)balloon);
> > +       list_add(&page->lru, &balloon->pages);
> > +       inc_zone_page_state(page, NR_BALLOON_PAGES);
> > +#endif
> > +}
> > +
> > +/*
> > + * balloon_page_delete - delete a page from balloon's page list and clear
> > + *                      the page->mapping assignement accordingly.
> > + * @page    : page to be released from balloon's page list
> > + *
> > + * Caller must ensure the page is locked and the spin_lock protecting balloon
> > + * pages list is held before deleting a page from the balloon device.
> > + */
> > +static inline void balloon_page_delete(struct page *page, bool isolated)
> > +{
> > +#ifdef CONFIG_MEMORY_BALLOON
> > +       __ClearPageBalloon(page);
> > +       set_page_private(page, 0);
> > +       if (!isolated)
> > +               list_del(&page->lru);
> > +       dec_zone_page_state(page, NR_BALLOON_PAGES);
> > +#endif
> > +}
> > +
> >  #endif /* _LINUX_BALLOON_COMPACTION_H */
> > --
> > 1.9.3
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
