Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 93C296B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 14:49:05 -0400 (EDT)
Date: Tue, 30 Jul 2013 14:48:42 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375210122-kz46l6fv-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87mwp3q4vo.fsf@linux.vnet.ibm.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374728103-17468-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87mwp3q4vo.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] migrate: make core migration code aware of hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 30, 2013 at 11:58:27PM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > Before enabling each user of page migration to support hugepage,
> > this patch enables the list of pages for migration to link not only
> > LRU pages, but also hugepages. As a result, putback_movable_pages()
> > and migrate_pages() can handle both of LRU pages and hugepages.
> >
> > ChangeLog v4:
> >  - make some macros return 'do {} while(0)'
> >  - use more readable variable name
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
> > Acked-by: Andi Kleen <ak@linux.intel.com>
> > Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> > ---
> >  include/linux/hugetlb.h |  6 ++++++
> >  mm/hugetlb.c            | 32 +++++++++++++++++++++++++++++++-
> >  mm/migrate.c            | 10 +++++++++-
> >  3 files changed, 46 insertions(+), 2 deletions(-)
> >
> > diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
> > index c2b1801..c7a14a4 100644
> > --- v3.11-rc1.orig/include/linux/hugetlb.h
> > +++ v3.11-rc1/include/linux/hugetlb.h
> > @@ -66,6 +66,9 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
> >  						vm_flags_t vm_flags);
> >  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
> >  int dequeue_hwpoisoned_huge_page(struct page *page);
> > +bool isolate_huge_page(struct page *page, struct list_head *list);
> > +void putback_active_hugepage(struct page *page);
> > +void putback_active_hugepages(struct list_head *list);
> 
> are we using putback_active_hugepages in the patch series ?

This function has no user, so shouldn't be added.
I forgot to clean it up when changing code.
Thanks for pointing out.

Naoya

> 
> >  void copy_huge_page(struct page *dst, struct page *src);
> >
> >  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> > @@ -134,6 +137,9 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
> >  	return 0;
> >  }
> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
