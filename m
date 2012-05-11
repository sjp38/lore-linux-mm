Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B80DA8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:16:19 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 11 May 2012 03:16:18 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4FA12C90057
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:16:12 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4B9GE1I120144
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:16:14 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4B9GDhf017492
	for <linux-mm@kvack.org>; Fri, 11 May 2012 03:16:13 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/slab: remove duplicate check
Date: Fri, 11 May 2012 17:16:09 +0800
Message-Id: <1336727769-19555-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

While allocateing pages using buddy allocator, the compound page
is probably split up to free pages. Under the circumstance, the
compound page should be destroied by function destroy_compound_page().
However, there has duplicate check to judge if the page is compound
one.

The patch removes the duplicate check since the function compound_order()
will returns 0 while the page hasn't PG_head set in function destroy_compound_page().
That's to say, the function destroy_compound_page() needn't check
PG_head any more through function PageHead().

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a712fb9..1277632 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -363,8 +363,7 @@ static int destroy_compound_page(struct page *page, unsigned long order)
 	int nr_pages = 1 << order;
 	int bad = 0;
 
-	if (unlikely(compound_order(page) != order) ||
-	    unlikely(!PageHead(page))) {
+	if (unlikely(compound_order(page) != order)) {
 		bad_page(page);
 		bad++;
 	}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
