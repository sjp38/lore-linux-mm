Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 135AE6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 21:40:53 -0400 (EDT)
Date: Thu, 3 Jun 2010 10:38:02 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] replace ifdef CONFIG_HUGETLBFS into ifdef
 CONFIG_HUGETLB_PAGE (Re: [PATCH 2/8] hugetlb, rmap: add reverse mapping for
 hugepage)
Message-ID: <20100603013802.GD2833@spritzera.linux.bs1.fc.nec.co.jp>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1275006562-18946-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100602111617.0c292178.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100602111617.0c292178.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 02, 2010 at 11:16:17AM -0700, Andrew Morton wrote:
> On Fri, 28 May 2010 09:29:16 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > +#ifdef CONFIG_HUGETLBFS
> > +/*
> > + * The following three functions are for anonymous (private mapped) hugepages.
> > + * Unlike common anonymous pages, anonymous hugepages have no accounting code
> > + * and no lru code, because we handle hugepages differently from common pages.
> > + */
> > +static void __hugepage_set_anon_rmap(struct page *page,
> > +   struct vm_area_struct *vma, unsigned long address, int exclusive)
> > +{
> > +   struct anon_vma *anon_vma = vma->anon_vma;
> > +   BUG_ON(!anon_vma);
> > +   if (!exclusive) {
> > +           struct anon_vma_chain *avc;
> > +           avc = list_entry(vma->anon_vma_chain.prev,
> > +                            struct anon_vma_chain, same_vma);
> > +           anon_vma = avc->anon_vma;
> > +   }
> > +   anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > +   page->mapping = (struct address_space *) anon_vma;
> > +   page->index = linear_page_index(vma, address);
> > +}
> > +
> > +void hugepage_add_anon_rmap(struct page *page,
> > +                       struct vm_area_struct *vma, unsigned long address)
> > +{
> > +   struct anon_vma *anon_vma = vma->anon_vma;
> > +   int first;
> > +   BUG_ON(!anon_vma);
> > +   BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +   first = atomic_inc_and_test(&page->_mapcount);
> > +   if (first)
> > +           __hugepage_set_anon_rmap(page, vma, address, 0);
> > +}
> > +
> > +void hugepage_add_new_anon_rmap(struct page *page,
> > +                   struct vm_area_struct *vma, unsigned long address)
> > +{
> > +   BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +   atomic_set(&page->_mapcount, 0);
> > +   __hugepage_set_anon_rmap(page, vma, address, 1);
> > +}
> > +#endif /* CONFIG_HUGETLBFS */
> 
> This code still make sense if CONFIG_HUGETLBFS=n, I think?  Should it
> instead depend on CONFIG_HUGETLB_PAGE?

Yes.
CONFIG_HUGETLBFS controls hugetlbfs interface code.
OTOH, CONFIG_HUGETLB_PAGE controls hugepage management code.
So we should use CONFIG_HUGETLB_PAGE here.

I attached a fix patch below. This includes another fix in
include/linux/hugetlb_inline.h (commented by Mel Gorman.)

Andi-san, could you add this patch on top of your tree?

> I have a feeling that we make that confusion relatively often.  Perhaps
> CONFIG_HUGETLB_PAGE=y && CONFIG_HUGETLBFS=n makes no sense and we
> should unify them...  

Agreed.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 3 Jun 2010 10:32:08 +0900
Subject: [PATCH] replace ifdef CONFIG_HUGETLBFS into ifdef CONFIG_HUGETLB_PAGE

CONFIG_HUGETLBFS controls hugetlbfs interface code.
OTOH, CONFIG_HUGETLB_PAGE controls hugepage management code.
So we should use CONFIG_HUGETLB_PAGE here.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb_inline.h |    4 ++--
 mm/rmap.c                      |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index cf00b6d..6931489 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -1,7 +1,7 @@
 #ifndef _LINUX_HUGETLB_INLINE_H
-#define _LINUX_HUGETLB_INLINE_H 1
+#define _LINUX_HUGETLB_INLINE_H
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mm.h>
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 5278371..f7114c6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1436,7 +1436,7 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 }
 #endif /* CONFIG_MIGRATION */
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB_PAGE
 /*
  * The following three functions are for anonymous (private mapped) hugepages.
  * Unlike common anonymous pages, anonymous hugepages have no accounting code
@@ -1477,4 +1477,4 @@ void hugepage_add_new_anon_rmap(struct page *page,
 	atomic_set(&page->_mapcount, 0);
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
-#endif /* CONFIG_HUGETLBFS */
+#endif /* CONFIG_HUGETLB_PAGE */
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
