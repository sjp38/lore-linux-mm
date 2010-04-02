Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 40B076B01FB
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 04:51:29 -0400 (EDT)
Date: Fri, 2 Apr 2010 09:51:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100402085106.GC621@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie> <1269940489-5776-15-git-send-email-mel@csn.ul.ie> <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com> <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com> <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com> <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com> <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com> <w2i28c262361004010351r605c897dzd2bdccac149dcc6b@mail.gmail.com> <20100401173640.GB621@csn.ul.ie> <l2s28c262361004011720pd7abc6d6id54d85c756997b95@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <l2s28c262361004011720pd7abc6d6id54d85c756997b95@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 09:20:27AM +0900, Minchan Kim wrote:
> On Fri, Apr 2, 2010 at 2:36 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Thu, Apr 01, 2010 at 07:51:31PM +0900, Minchan Kim wrote:
> >> On Thu, Apr 1, 2010 at 2:42 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Thu, 1 Apr 2010 13:44:29 +0900
> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >
> >> >> On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
> >> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >> > On Thu, 1 Apr 2010 11:43:18 +0900
> >> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >> >
> >> >> >> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki       /*
> >> >> >> >> diff --git a/mm/rmap.c b/mm/rmap.c
> >> >> >> >> index af35b75..d5ea1f2 100644
> >> >> >> >> --- a/mm/rmap.c
> >> >> >> >> +++ b/mm/rmap.c
> >> >> >> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
> >> >> >> >>
> >> >> >> >>       if (unlikely(PageKsm(page)))
> >> >> >> >>               return rmap_walk_ksm(page, rmap_one, arg);
> >> >> >> >> -     else if (PageAnon(page))
> >> >> >> >> +     else if (PageAnon(page)) {
> >> >> >> >> +             if (PageSwapCache(page))
> >> >> >> >> +                     return SWAP_AGAIN;
> >> >> >> >>               return rmap_walk_anon(page, rmap_one, arg);
> >> >> >> >
> >> >> >> > SwapCache has a condition as (PageSwapCache(page) && page_mapped(page) == true.
> >> >> >> >
> >> >> >>
> >> >> >> In case of tmpfs, page has swapcache but not mapped.
> >> >> >>
> >> >> >> > Please see do_swap_page(), PageSwapCache bit is cleared only when
> >> >> >> >
> >> >> >> > do_swap_page()...
> >> >> >> >       swap_free(entry);
> >> >> >> >        if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> >> >> >> >                try_to_free_swap(page);
> >> >> >> >
> >> >> >> > Then, PageSwapCache is cleared only when swap is freeable even if mapped.
> >> >> >> >
> >> >> >> > rmap_walk_anon() should be called and the check is not necessary.
> >> >> >>
> >> >> >> Frankly speaking, I don't understand what is Mel's problem, why he added
> >> >> >> Swapcache check in rmap_walk, and why do you said we don't need it.
> >> >> >>
> >> >> >> Could you explain more detail if you don't mind?
> >> >> >>
> >> >> > I may miss something.
> >> >> >
> >> >> > unmap_and_move()
> >> >> >  1. try_to_unmap(TTU_MIGRATION)
> >> >> >  2. move_to_newpage
> >> >> >  3. remove_migration_ptes
> >> >> >        -> rmap_walk()
> >> >> >
> >> >> > Then, to map a page back we unmapped we call rmap_walk().
> >> >> >
> >> >> > Assume a SwapCache which is mapped, then, PageAnon(page) == true.
> >> >> >
> >> >> >  At 1. try_to_unmap() will rewrite pte with swp_entry of SwapCache.
> >> >> >       mapcount goes to 0.
> >> >> >  At 2. SwapCache is copied to a new page.
> >> >> >  At 3. The new page is mapped back to the place. Now, newpage's mapcount is 0.
> >> >> >       Before patch, the new page is mapped back to all ptes.
> >> >> >       After patch, the new page is not mapped back because its mapcount is 0.
> >> >> >
> >> >> > I don't think shared SwapCache of anon is not an usual behavior, so, the logic
> >> >> > before patch is more attractive.
> >> >> >
> >> >> > If SwapCache is not mapped before "1", we skip "1" and rmap_walk will do nothing
> >> >> > because page->mapping is NULL.
> >> >> >
> >> >>
> >> >> Thanks. I agree. We don't need the check.
> >> >> Then, my question is why Mel added the check in rmap_walk.
> >> >> He mentioned some BUG trigger and fixed things after this patch.
> >> >> What's it?
> >> >> Is it really related to this logic?
> >> >> I don't think so or we are missing something.
> >> >>
> >> > Hmm. Consiering again.
> >> >
> >> > Now.
> >> >        if (PageAnon(page)) {
> >> >                rcu_locked = 1;
> >> >                rcu_read_lock();
> >> >                if (!page_mapped(page)) {
> >> >                        if (!PageSwapCache(page))
> >> >                                goto rcu_unlock;
> >> >                } else {
> >> >                        anon_vma = page_anon_vma(page);
> >> >                        atomic_inc(&anon_vma->external_refcount);
> >> >                }
> >> >
> >> >
> >> > Maybe this is a fix.
> >> >
> >> > ==
> >> >        skip_remap = 0;
> >> >        if (PageAnon(page)) {
> >> >                rcu_read_lock();
> >> >                if (!page_mapped(page)) {
> >> >                        if (!PageSwapCache(page))
> >> >                                goto rcu_unlock;
> >> >                        /*
> >> >                         * We can't convice this anon_vma is valid or not because
> >> >                         * !page_mapped(page). Then, we do migration(radix-tree replacement)
> >> >                         * but don't remap it which touches anon_vma in page->mapping.
> >> >                         */
> >> >                        skip_remap = 1;
> >> >                        goto skip_unmap;
> >> >                } else {
> >> >                        anon_vma = page_anon_vma(page);
> >> >                        atomic_inc(&anon_vma->external_refcount);
> >> >                }
> >> >        }
> >> >        .....copy page, radix-tree replacement,....
> >> >
> >>
> >> It's not enough.
> >> we uses remove_migration_ptes in  move_to_new_page, too.
> >> We have to prevent it.
> >> We can check PageSwapCache(page) in move_to_new_page and then
> >> skip remove_migration_ptes.
> >>
> >> ex)
> >> static int move_to_new_page(....)
> >> {
> >>      int swapcache = PageSwapCache(page);
> >>      ...
> >>      if (!swapcache)
> >>          if(!rc)
> >>              remove_migration_ptes
> >>          else
> >>              newpage->mapping = NULL;
> >> }
> >>
> >
> > This I agree with.
> >
> >> And we have to close race between PageAnon(page) and rcu_read_lock.
> >
> > Not so sure on this. The page is locked at this point and that should
> > prevent it from becoming !PageAnon
> 
> page lock can't prevent anon_vma free.

True, it can't in itself but it is a bug to free a locked page. As PageAnon
is cleared by the page allocator (see comments in page_remove_rmap) and we
have taken a reference to this page when isolating for migration, I still
don't see how it is possible for PageAnon to get cleared from underneath us.

> It's valid just only file-backed page, I think.
> 
> >> If we don't do it, anon_vma could be free in the middle of operation.
> >> I means
> >>
> >>          * of migration. File cache pages are no problem because of page_lock()
> >>          * File Caches may use write_page() or lock_page() in migration, then,
> >>          * just care Anon page here.
> >>          */
> >>         if (PageAnon(page)) {
> >>                 !!! RACE !!!!
> >>                 rcu_read_lock();
> >>                 rcu_locked = 1;
> >>
> >> +
> >> +               /*
> >> +                * If the page has no mappings any more, just bail. An
> >> +                * unmapped anon page is likely to be freed soon but worse,
> >>
> >
> > I am not sure this race exists because the page is locked but a key
> > observation has been made - A page that is unmapped can be migrated if
> > it's PageSwapCache but it may not have a valid anon_vma. Hence, in the
> > !page_mapped case, the key is to not use anon_vma. How about the
> > following patch?
> 
> I like this. Kame. How about your opinion?
> please, look at a comment.
> 
> >
> > ==== CUT HERE ====
> >
> > mm,migration: Allow the migration of PageSwapCache pages
> >
> > PageAnon pages that are unmapped may or may not have an anon_vma so are
> > not currently migrated. However, a swap cache page can be migrated and
> > fits this description. This patch identifies page swap caches and allows
> > them to be migrated but ensures that no attempt to made to remap the pages
> > would would potentially try to access an already freed anon_vma.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 35aad2a..5d0218b 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -484,7 +484,8 @@ static int fallback_migrate_page(struct address_space *mapping,
> >  *   < 0 - error code
> >  *  == 0 - success
> >  */
> > -static int move_to_new_page(struct page *newpage, struct page *page)
> > +static int move_to_new_page(struct page *newpage, struct page *page,
> > +                                               int safe_to_remap)
> >  {
> >        struct address_space *mapping;
> >        int rc;
> > @@ -519,10 +520,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
> >        else
> >                rc = fallback_migrate_page(mapping, newpage, page);
> >
> > -       if (!rc)
> > -               remove_migration_ptes(page, newpage);
> > -       else
> > -               newpage->mapping = NULL;
> > +       if (safe_to_remap) {
> > +               if (!rc)
> > +                       remove_migration_ptes(page, newpage);
> > +               else
> > +                       newpage->mapping = NULL;
> > +       }
> >
> >        unlock_page(newpage);
> >
> > @@ -539,6 +542,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >        int rc = 0;
> >        int *result = NULL;
> >        struct page *newpage = get_new_page(page, private, &result);
> > +       int safe_to_remap = 1;
> >        int rcu_locked = 0;
> >        int charge = 0;
> >        struct mem_cgroup *mem = NULL;
> > @@ -600,18 +604,26 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >                rcu_read_lock();
> >                rcu_locked = 1;
> >
> > -               /*
> > -                * If the page has no mappings any more, just bail. An
> > -                * unmapped anon page is likely to be freed soon but worse,
> > -                * it's possible its anon_vma disappeared between when
> > -                * the page was isolated and when we reached here while
> > -                * the RCU lock was not held
> > -                */
> > -               if (!page_mapped(page))
> > -                       goto rcu_unlock;
> > +               /* Determine how to safely use anon_vma */
> > +               if (!page_mapped(page)) {
> > +                       if (!PageSwapCache(page))
> > +                               goto rcu_unlock;
> >
> > -               anon_vma = page_anon_vma(page);
> > -               atomic_inc(&anon_vma->external_refcount);
> > +                       /*
> > +                        * We cannot be sure that the anon_vma of an unmapped
> > +                        * page is safe to use. In this case, the page still
> 
> How about changing comment?
> "In this case, swapcache page still "
> Also, I want to change "safe_to_remap" to "remap_swapcache".

Done.

> I think it's just problem related to swapcache page.
> So I want to represent it explicitly although we can know it's swapcache
> by code.
> 

Sure. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
