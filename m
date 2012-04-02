Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id CFC726B004D
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 10:15:21 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 2 Apr 2012 08:15:14 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9C85519D8048
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 08:14:11 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q32EE0bs091810
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 08:14:04 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q32EDxuY026236
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 08:13:59 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zsmalloc: fix memory leak
Date: Mon,  2 Apr 2012 09:13:56 -0500
Message-Id: <1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Nitin Gupta <ngupta@vflare.org>

This patch fixes a memory leak in zsmalloc where the first
subpage of each zspage is leaked when the zspage is freed.

Based on 3.4-rc1.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 09caa4f..917461c 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -267,33 +267,39 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	return off + obj_idx * class_size;
 }
 
+static void reset_page(struct page *page)
+{
+	clear_bit(PG_private, &page->flags);
+	clear_bit(PG_private_2, &page->flags);
+	set_page_private(page, 0);
+	page->mapping = NULL;
+	page->freelist = NULL;
+	reset_page_mapcount(page);
+}
+
 static void free_zspage(struct page *first_page)
 {
-	struct page *nextp, *tmp;
+	struct page *nextp, *tmp, *head_extra;
 
 	BUG_ON(!is_first_page(first_page));
 	BUG_ON(first_page->inuse);
 
-	nextp = (struct page *)page_private(first_page);
+	head_extra = (struct page *)page_private(first_page);
 
-	clear_bit(PG_private, &first_page->flags);
-	clear_bit(PG_private_2, &first_page->flags);
-	set_page_private(first_page, 0);
-	first_page->mapping = NULL;
-	first_page->freelist = NULL;
-	reset_page_mapcount(first_page);
+	reset_page(first_page);
 	__free_page(first_page);
 
 	/* zspage with only 1 system page */
-	if (!nextp)
+	if (!head_extra)
 		return;
 
-	list_for_each_entry_safe(nextp, tmp, &nextp->lru, lru) {
+	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
 		list_del(&nextp->lru);
-		clear_bit(PG_private_2, &nextp->flags);
-		nextp->index = 0;
+		reset_page(nextp);
 		__free_page(nextp);
 	}
+	reset_page(head_extra);
+	__free_page(head_extra);
 }
 
 /* Initialize a newly allocated zspage */
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
