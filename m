Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC15C6B0008
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:57:12 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so20637116wmf.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:57:12 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id g67si72820985wmc.46.2015.12.29.12.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 12:57:11 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id u188so21834175wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:57:11 -0800 (PST)
Date: Tue, 29 Dec 2015 22:57:09 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] thp: increase split_huge_page() success rate
Message-ID: <20151229205709.GB6260@node.shutemov.name>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151228153026.628d44126a848e14bcbbce68@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151228153026.628d44126a848e14bcbbce68@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Mon, Dec 28, 2015 at 03:30:26PM -0800, Andrew Morton wrote:
> On Thu, 24 Dec 2015 14:51:23 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > During freeze_page(), we remove the page from rmap. It munlocks the page
> > if it was mlocked. clear_page_mlock() uses of lru cache, which temporary
> > pins page.
> > 
> > Let's drain the lru cache before checking page's count vs. mapcount.
> > The change makes mlocked page split on first attempt, if it was not
> > pinned by somebody else.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/huge_memory.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 1a988d9b86ef..4c1c292b7ddd 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3417,6 +3417,9 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
> >  	freeze_page(anon_vma, head);
> >  	VM_BUG_ON_PAGE(compound_mapcount(head), head);
> >  
> > +	/* Make sure the page is not on per-CPU pagevec as it takes pin */
> > +	lru_add_drain();
> > +
> >  	/* Prevent deferred_split_scan() touching ->_count */
> >  	spin_lock(&split_queue_lock);
> >  	count = page_count(head);
> 
> Fair enough.
> 
> mlocked pages are rare and lru_add_drain() isn't free.  We could easily
> and cheaply make page_remove_rmap() return "bool was_mlocked" (or,
> better, "bool might_be_in_lru_cache") to skip this overhead.

Propagating it back is painful. What about this instead:

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ecb4ed1a821a..edfa53eda9ca 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3385,6 +3385,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	struct page *head = compound_head(page);
 	struct anon_vma *anon_vma;
 	int count, mapcount, ret;
+	bool mlocked;
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageAnon(page), page);
@@ -3415,11 +3416,13 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		goto out_unlock;
 	}
 
+	mlocked = PageMlocked(page);
 	freeze_page(anon_vma, head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
 	/* Make sure the page is not on per-CPU pagevec as it takes pin */
-	lru_add_drain();
+	if (mlocked)
+		lru_add_drain();
 
 	/* Prevent deferred_split_scan() touching ->_count */
 	spin_lock(&split_queue_lock);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
