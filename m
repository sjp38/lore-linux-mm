Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5A3216B004A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 02:22:43 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/6] zsmalloc: use PageFlag macro instead of [set|test]_bit
Date: Wed, 25 Apr 2012 15:23:09 +0900
Message-Id: <1335334994-22138-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

MM code always uses PageXXX to handle page flags.
Let's keep the consistency.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 917461c..504b6c2 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -45,12 +45,12 @@ static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
 static int is_first_page(struct page *page)
 {
-	return test_bit(PG_private, &page->flags);
+	return PagePrivate(page);
 }
 
 static int is_last_page(struct page *page)
 {
-	return test_bit(PG_private_2, &page->flags);
+	return PagePrivate2(page);
 }
 
 static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
@@ -377,7 +377,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 		INIT_LIST_HEAD(&page->lru);
 		if (i == 0) {	/* first page */
-			set_bit(PG_private, &page->flags);
+			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
 			first_page->inuse = 0;
@@ -389,8 +389,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		if (i >= 2)
 			list_add(&page->lru, &prev_page->lru);
 		if (i == class->zspage_order - 1)	/* last page */
-			set_bit(PG_private_2, &page->flags);
-
+			SetPagePrivate2(page);
 		prev_page = page;
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
