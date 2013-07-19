Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3EA3B6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 23:18:39 -0400 (EDT)
Date: Thu, 18 Jul 2013 23:18:19 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374203899-w7jwqowi-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBD-uCuqyD0OTJ119woikBSyd8=A7uhHp5kUJeweS+2okQ@mail.gmail.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAJd=RBD-uCuqyD0OTJ119woikBSyd8=A7uhHp5kUJeweS+2okQ@mail.gmail.com>
Subject: Re: [PATCH 1/8] migrate: make core migration code aware of hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hello Hillf,

Thanks for your reviewing.

On Fri, Jul 19, 2013 at 10:38:35AM +0800, Hillf Danton wrote:
> Hey Naoya,
> 
> On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Before enabling each user of page migration to support hugepage,
> > this patch enables the list of pages for migration to link not only
> > LRU pages, but also hugepages. As a result, putback_movable_pages()
> > and migrate_pages() can handle both of LRU pages and hugepages.
> >
> > ChangeLog v3:
> >  - revert introducing migrate_movable_pages
> >  - add isolate_huge_page
> >
> > ChangeLog v2:
> >  - move code removing VM_HUGETLB from vma_migratable check into a
> >    separate patch
> >  - hold hugetlb_lock in putback_active_hugepage
> >  - update comment near the definition of hugetlb_lock
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  include/linux/hugetlb.h |  6 ++++++
> >  mm/hugetlb.c            | 32 +++++++++++++++++++++++++++++++-
> >  mm/migrate.c            | 10 +++++++++-
> >  3 files changed, 46 insertions(+), 2 deletions(-)
> >
> > diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
> > index c2b1801..0b7a9e7 100644
> > --- v3.11-rc1.orig/include/linux/hugetlb.h
> > +++ v3.11-rc1/include/linux/hugetlb.h
> > @@ -66,6 +66,9 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
> >                                                 vm_flags_t vm_flags);
> >  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
> >  int dequeue_hwpoisoned_huge_page(struct page *page);
> > +bool isolate_huge_page(struct page *page, struct list_head *l);
> > +void putback_active_hugepage(struct page *page);
> > +void putback_active_hugepages(struct list_head *l);
> >  void copy_huge_page(struct page *dst, struct page *src);
> >
> >  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> > @@ -134,6 +137,9 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
> >         return 0;
> >  }
> >
> > +#define isolate_huge_page(p, l) false
> > +#define putback_active_hugepage(p)
> 
> Add do{}while(o), ok?

OK. And I will get the same comment for patch 7/8.

> > +#define putback_active_hugepages(l)
> >  static inline void copy_huge_page(struct page *dst, struct page *src)
> >  {
> >  }
> > diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
> > index 83aff0a..4c48a70 100644
> > --- v3.11-rc1.orig/mm/hugetlb.c
> > +++ v3.11-rc1/mm/hugetlb.c
> > @@ -48,7 +48,8 @@ static unsigned long __initdata default_hstate_max_huge_pages;
> >  static unsigned long __initdata default_hstate_size;
> >
> >  /*
> > - * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> > + * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
> > + * free_huge_pages, and surplus_huge_pages.
> >   */
> >  DEFINE_SPINLOCK(hugetlb_lock);
> >
> > @@ -3431,3 +3432,32 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
> >         return ret;
> >  }
> >  #endif
> > +
> > +bool isolate_huge_page(struct page *page, struct list_head *l)
> 
> Can we replace the page parameter with p?

Yes. Maybe it's strange to use the full name "page" for one parameter
and an extremely shortened one "l" for another one.

> > +{
> > +       VM_BUG_ON(!PageHead(page));
> > +       if (!get_page_unless_zero(page))
> > +               return false;
> > +       spin_lock(&hugetlb_lock);
> > +       list_move_tail(&page->lru, l);
> > +       spin_unlock(&hugetlb_lock);
> > +       return true;
> > +}
> > +
> > +void putback_active_hugepage(struct page *page)
> > +{
> > +       VM_BUG_ON(!PageHead(page));
> > +       spin_lock(&hugetlb_lock);
> > +       list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
> > +       spin_unlock(&hugetlb_lock);
> > +       put_page(page);
> > +}
> > +
> > +void putback_active_hugepages(struct list_head *l)
> > +{
> > +       struct page *page;
> > +       struct page *page2;
> > +
> > +       list_for_each_entry_safe(page, page2, l, lru)
> > +               putback_active_hugepage(page);
> 
> Can we acquire hugetlb_lock only once?

I'm not sure which is the best. In general, fine-grained locking is
preferred because other lock contenders wait less.
Could you tell some specific reason to hold lock outside the loop?

> > +}
> > diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
> > index 6f0c244..b44a067 100644
> > --- v3.11-rc1.orig/mm/migrate.c
> > +++ v3.11-rc1/mm/migrate.c
> > @@ -100,6 +100,10 @@ void putback_movable_pages(struct list_head *l)
> >         struct page *page2;
> >
> >         list_for_each_entry_safe(page, page2, l, lru) {
> > +               if (unlikely(PageHuge(page))) {
> > +                       putback_active_hugepage(page);
> > +                       continue;
> > +               }
> >                 list_del(&page->lru);
> >                 dec_zone_page_state(page, NR_ISOLATED_ANON +
> >                                 page_is_file_cache(page));
> > @@ -1025,7 +1029,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >                 list_for_each_entry_safe(page, page2, from, lru) {
> >                         cond_resched();
> >
> > -                       rc = unmap_and_move(get_new_page, private,
> > +                       if (PageHuge(page))
> > +                               rc = unmap_and_move_huge_page(get_new_page,
> > +                                               private, page, pass > 2, mode);
> > +                       else
> > +                               rc = unmap_and_move(get_new_page, private,
> >                                                 page, pass > 2, mode);
> >
> Is this hunk unclean merge?

Sorry, I don't catch the point. This patch is based on v3.11-rc1 and
the present HEAD has no changes from that release.
Or do you mean that other trees have some conflicts? (my brief checking
on -mm/-next didn't find that...)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
