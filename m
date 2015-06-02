Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EC2806B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 05:25:38 -0400 (EDT)
Received: by wgme6 with SMTP id e6so134722094wgm.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 02:25:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1si23779175wjw.91.2015.06.02.02.25.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 02:25:36 -0700 (PDT)
Date: Tue, 2 Jun 2015 11:25:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150602092535.GB4440@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
 <20150522142143.GF5109@dhcp22.suse.cz>
 <20150522143558.GA2462@suse.de>
 <55633EAC.8060702@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55633EAC.8060702@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 25-05-15 17:24:28, Vlastimil Babka wrote:
> On 05/22/2015 04:35 PM, Mel Gorman wrote:
> >> 
> >> Thanks!
> >> 
> >> > This makes a lot of sense to me.  The only thing I worry about is the
> >> > proliferation of PageHuge(), a function call, in relatively hot paths.
> >> 
> >> I've tried that (see the patch below) but it enlarged the code by almost
> >> 1k
> >>    text    data     bss     dec     hex filename
> >>  510323   74273   44440  629036   9992c mm/built-in.o.before
> >>  511248   74273   44440  629961   99cc9 mm/built-in.o.after
> >> 
> >> I am not sure the code size increase is worth it. Maybe we can reduce
> >> the check to only PageCompound(page) as huge pages are no in the page
> >> cache (yet).
> >> 
> > 
> > That would be a more sensible route because it also avoids exposing the
> > hugetlbfs destructor unnecessarily.
> 
> You could maybe do test such as (PageCompound(page) && PageHuge(page)) to
> short-circuit the call while remaining future-proof.

How about this?
---
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 91b7f9b2b774..bb8a70e8fc77 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -547,7 +547,13 @@ static inline void ClearPageCompound(struct page *page)
 #endif /* !PAGEFLAGS_EXTENDED */
 
 #ifdef CONFIG_HUGETLB_PAGE
-int PageHuge(struct page *page);
+int __PageHuge(struct page *page);
+static inline int PageHuge(struct page *page)
+{
+	if (!PageCompound(page))
+		return 0;
+	return __PageHuge(page);
+}
 int PageHeadHuge(struct page *page);
 bool page_huge_active(struct page *page);
 #else
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 33defbe1897f..648c0c32857c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1107,19 +1107,17 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 }
 
 /*
- * PageHuge() only returns true for hugetlbfs pages, but not for normal or
+ * __PageHuge() only returns true for hugetlbfs pages, but not for normal or
  * transparent huge pages.  See the PageTransHuge() documentation for more
  * details.
  */
-int PageHuge(struct page *page)
+int __PageHuge(struct page *page)
 {
-	if (!PageCompound(page))
-		return 0;
-
+	VM_BUG_ON(!PageCompound(page));
 	page = compound_head(page);
 	return get_compound_page_dtor(page) == free_huge_page;
 }
-EXPORT_SYMBOL_GPL(PageHuge);
+EXPORT_SYMBOL_GPL(__PageHuge);
 
 /*
  * PageHeadHuge() only returns true for hugetlbfs head page, but not for

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
