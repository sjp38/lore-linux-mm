Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id DD2F86B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:02:36 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kq13so1177953pab.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 18:02:35 -0700 (PDT)
Date: Fri, 12 Apr 2013 09:02:29 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
Message-ID: <20130412010229.GA31445@kernel.org>
References: <20130401132605.GA2996@kernel.org>
 <20130411164421.697ee91f85002f74aea8c4ad@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411164421.697ee91f85002f74aea8c4ad@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hughd@google.com, aarcange@redhat.com, minchan@kernel.org

On Thu, Apr 11, 2013 at 04:44:21PM -0700, Andrew Morton wrote:
> On Mon, 1 Apr 2013 21:26:05 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> > In page reclaim, huge page is split. split_huge_page() adds tail pages to LRU
> > list. Since we are reclaiming a huge page, it's better we reclaim all subpages
> > of the huge page instead of just the head page. This patch adds split tail
> > pages to shrink page list so the tail pages can be reclaimed soon.
> > 
> > Before this patch, run a swap workload:
> > thp_fault_alloc 3492
> > thp_fault_fallback 608
> > thp_collapse_alloc 6
> > thp_collapse_alloc_failed 0
> > thp_split 916
> > 
> > With this patch:
> > thp_fault_alloc 4085
> > thp_fault_fallback 16
> > thp_collapse_alloc 90
> > thp_collapse_alloc_failed 0
> > thp_split 1272
> > 
> > fallback allocation is reduced a lot.
> > 
> > ...
> >
> > -int split_huge_page(struct page *page)
> > +int split_huge_page_to_list(struct page *page, struct list_head *list)
> 
> While it's fresh, could you please prepare a covering comment describing
> this function?  The meaning of the return value is particularly
> cryptic.

Is this ok to you?

---
 mm/huge_memory.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2013-04-12 08:07:59.075329318 +0800
+++ linux/mm/huge_memory.c	2013-04-12 08:53:53.076706235 +0800
@@ -1801,6 +1801,13 @@ static void __split_huge_page(struct pag
 	BUG_ON(mapcount != mapcount2);
 }
 
+/*
+ * Split a hugepage into normal pages. This doesn't change the position of head
+ * page. If @list is null, tail pages will be added to LRU list, otherwise, to
+ * @list. Both head page and tail pages will inherit mapping, flags, and so on
+ * from the hugepage.
+ * Return 0 if the hugepage is split successfully otherwise return 1.
+ */
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct anon_vma *anon_vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
