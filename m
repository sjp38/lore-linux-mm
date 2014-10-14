Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 299796B0072
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:58 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so7336054pdb.39
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:57 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id zz3si3505738pac.49.2014.10.14.04.59.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:55 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF00J42NZTRKA0@mailout1.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:53 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 5/9] mm/zbud: encode zbud handle using struct page
Date: Tue, 14 Oct 2014 20:59:24 +0900
Message-id: <1413287968-13940-6-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

As a preparation for further patches, this patch changes the way of
encoding zbud handle. Currently, zbud handle is actually just a virtual
address that is casted to unsigned long before return back. Exporting
the address to clients would be inappropriate if we use highmem pages
for zbud pages, which will be implemented by following patches.

Change the zbud handle to struct page* with the least significant bit
indicating the first or last. All other information are hidden in the
struct page.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 50 ++++++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 193ea4f..383bab0 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -240,35 +240,32 @@ static void free_zbud_page(struct zbud_header *zhdr)
 	__free_page(virt_to_page(zhdr));
 }
 
+static int is_last_chunk(unsigned long handle)
+{
+	return (handle & LAST) == LAST;
+}
+
 /*
  * Encodes the handle of a particular buddy within a zbud page
  * Pool lock should be held as this function accesses first|last_chunks
  */
-static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
+static unsigned long encode_handle(struct page *page, enum buddy bud)
 {
-	unsigned long handle;
-	struct page *page = virt_to_page(zhdr);
+	return (unsigned long) page | bud;
+}
 
-	/*
-	 * For now, the encoded handle is actually just the pointer to the data
-	 * but this might not always be the case.  A little information hiding.
-	 * Add CHUNK_SIZE to the handle if it is the first allocation to jump
-	 * over the zbud header in the first chunk.
-	 */
-	handle = (unsigned long)zhdr;
-	if (bud == FIRST)
-		/* skip over zbud header */
-		handle += ZHDR_SIZE_ALIGNED;
-	else /* bud == LAST */
-		handle += PAGE_SIZE -
-				(get_num_chunks(page, LAST) << CHUNK_SHIFT);
-	return handle;
+/* Returns struct page of the zbud page where a given handle is stored */
+static struct page *handle_to_zbud_page(unsigned long handle)
+{
+	return (struct page *) (handle & ~LAST);
 }
 
 /* Returns the zbud page where a given handle is stored */
 static struct zbud_header *handle_to_zbud_header(unsigned long handle)
 {
-	return (struct zbud_header *)(handle & PAGE_MASK);
+	struct page *page = handle_to_zbud_page(handle);
+
+	return page_address(page);
 }
 
 /* Returns the number of free chunks in a zbud page */
@@ -395,7 +392,7 @@ found:
 		list_del(&page->lru);
 	list_add(&page->lru, &pool->lru);
 
-	*handle = encode_handle(zhdr, bud);
+	*handle = encode_handle(page, bud);
 	spin_unlock(&pool->lock);
 
 	return 0;
@@ -514,9 +511,9 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		first_handle = 0;
 		last_handle = 0;
 		if (get_num_chunks(page, FIRST))
-			first_handle = encode_handle(zhdr, FIRST);
+			first_handle = encode_handle(page, FIRST);
 		if (get_num_chunks(page, LAST))
-			last_handle = encode_handle(zhdr, LAST);
+			last_handle = encode_handle(page, LAST);
 		spin_unlock(&pool->lock);
 
 		/* Issue the eviction callback(s) */
@@ -570,7 +567,16 @@ next:
  */
 void *zbud_map(struct zbud_pool *pool, unsigned long handle)
 {
-	return (void *)(handle);
+	size_t offset;
+	struct page *page = handle_to_zbud_page(handle);
+
+	if (is_last_chunk(handle))
+		offset = PAGE_SIZE -
+				(get_num_chunks(page, LAST) << CHUNK_SHIFT);
+	else
+		offset = ZHDR_SIZE_ALIGNED;
+
+	return (unsigned char *) page_address(page) + offset;
 }
 
 /**
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
