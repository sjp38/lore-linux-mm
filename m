Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5AFED6B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 07:21:24 -0400 (EDT)
Date: Thu, 23 Apr 2009 19:21:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
	(take 3)
Message-ID: <20090423112124.GA20425@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com> <20090423022625.GA8822@localhost> <20090423074848.GJ13896@one.firstfloor.org> <20090423081047.GA18898@localhost> <20090423085405.GL13896@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090423085405.GL13896@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 04:54:06PM +0800, Andi Kleen wrote:
> > Good idea.
> > 
> > Would you recommend a good way to identify huge pages?
> > Test by page order, or by (dtor == free_huge_page)?      
> 
> That doesn't work for GB pages. The best way would be to make
> slub stop using it and then check for compound, but I don't know what 
> this implies. Otherwise would need some other way, perhaps a new
> flag?

Or play the following trick? :-)

This helps hide the internal compound page consumers(SLAB/SLUB/... and
loads of device drivers) to user space. However there are still huge
pages of different orders(IA64?). Does this make a good reason for
exporting both HEAD/TAIL flags, instead of a combined COMPOUND flag?

Thanks,
Fengguang
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c722aa6..7d0bd0d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -298,6 +298,14 @@ void prep_compound_page(struct page *page, unsigned long order)
 	}
 }
 
+/*
+ * This function helps distinguish gigantic pages from normal compound pages.
+ */
+static void free_gigantic_page(struct page *page)
+{
+	__free_pages_ok(page, compound_order(page));
+}
+
 #ifdef CONFIG_HUGETLBFS
 void prep_compound_gigantic_page(struct page *page, unsigned long order)
 {
@@ -305,7 +313,7 @@ void prep_compound_gigantic_page(struct page *page, unsigned long order)
 	int nr_pages = 1 << order;
 	struct page *p = page + 1;
 
-	set_compound_page_dtor(page, free_compound_page);
+	set_compound_page_dtor(page, free_gigantic_page);
 	set_compound_order(page, order);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
