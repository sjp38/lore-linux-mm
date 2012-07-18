Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3AA366B005D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:04:26 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 13:04:25 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AD7D16E854F
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:58:33 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6IGu0iv263800
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:56:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IGu0GO026431
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:56:00 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
Date: Wed, 18 Jul 2012 11:55:54 -0500
Message-Id: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

firstpage already has precedent and meaning the first page
of a zspage.  In the case of the copy mapping functions,
it is the first of a pair of pages needing to be mapped.

This patch just renames the firstpage argument to "page" to
avoid confusion.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 8b0bcb6..3c83c65 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -470,15 +470,15 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
-static void zs_copy_map_object(char *buf, struct page *firstpage,
+static void zs_copy_map_object(char *buf, struct page *page,
 				int off, int size)
 {
 	struct page *pages[2];
 	int sizes[2];
 	void *addr;
 
-	pages[0] = firstpage;
-	pages[1] = get_next_page(firstpage);
+	pages[0] = page;
+	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
 	sizes[0] = PAGE_SIZE - off;
@@ -493,15 +493,15 @@ static void zs_copy_map_object(char *buf, struct page *firstpage,
 	kunmap_atomic(addr);
 }
 
-static void zs_copy_unmap_object(char *buf, struct page *firstpage,
+static void zs_copy_unmap_object(char *buf, struct page *page,
 				int off, int size)
 {
 	struct page *pages[2];
 	int sizes[2];
 	void *addr;
 
-	pages[0] = firstpage;
-	pages[1] = get_next_page(firstpage);
+	pages[0] = page;
+	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
 	sizes[0] = PAGE_SIZE - off;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
