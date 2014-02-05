Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id CEA946B003B
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:13:24 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so9114924pbb.6
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:13:24 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id eb3si26578698pbc.176.2014.02.04.16.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 16:13:23 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so9090899pad.8
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:13:22 -0800 (PST)
Date: Tue, 4 Feb 2014 16:13:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb: mark some bootstrap functions as __init
Message-ID: <alpine.DEB.2.02.1402041612120.14962@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Both prep_compound_huge_page() and prep_compound_gigantic_page() are only
called at bootstrap and can be marked as __init.

The __SetPageTail(page) in prep_compound_gigantic_page() happening before
page->first_page is initialized is not concerning since this is
bootstrap.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -653,7 +653,8 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 	put_page(page); /* free it into the hugepage allocator */
 }
 
-static void prep_compound_gigantic_page(struct page *page, unsigned long order)
+static void __init prep_compound_gigantic_page(struct page *page,
+					       unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
@@ -1294,7 +1295,7 @@ found:
 	return 1;
 }
 
-static void prep_compound_huge_page(struct page *page, int order)
+static void __init prep_compound_huge_page(struct page *page, int order)
 {
 	if (unlikely(order > (MAX_ORDER - 1)))
 		prep_compound_gigantic_page(page, order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
