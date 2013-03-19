Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8576A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 05:26:11 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 14:52:55 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 40CA5125805C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 14:57:11 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J9PvXn7471476
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 14:55:58 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J9Q10i002704
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:02 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 2/8] staging: zcache: zero-filled pages awareness
Date: Tue, 19 Mar 2013 17:25:44 +0800
Message-Id: <1363685150-18303-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Compression of zero-filled pages can unneccessarily cause internal
fragmentation, and thus waste memory. This special case can be
optimized.

This patch captures zero-filled pages, and marks their corresponding
zcache backing page entry as zero-filled. Whenever such zero-filled
page is retrieved, we fill the page frame with zero.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   80 ++++++++++++++++++++++++++++-----
 1 files changed, 68 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 86ead8d..050a99f 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -61,6 +61,12 @@ static inline void frontswap_tmem_exclusive_gets(bool b)
 }
 #endif
 
+/*
+ * mark pampd to special value in order that later
+ * retrieve will identify zero-filled pages
+ */
+#define ZERO_FILLED 0x2
+
 /* enable (or fix code) when Seth's patches are accepted upstream */
 #define zcache_writeback_enabled 0
 
@@ -277,17 +283,23 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
 	kmem_cache_free(zcache_obj_cache, obj);
 }
 
-static bool page_is_zero_filled(void *ptr)
+/*
+ * Compressing zero-filled pages will waste memory and introduce
+ * serious fragmentation, skip it to avoid overhead.
+ */
+static bool page_is_zero_filled(struct page *p)
 {
 	unsigned int pos;
-	unsigned long *page;
-
-	page = (unsigned long *)ptr;
+	char *page;
 
+	page = kmap_atomic(p);
 	for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
-		if (page[pos])
+		if (page[pos]) {
+			kunmap_atomic(page);
 			return false;
+		}
 	}
+	kunmap_atomic(page);
 
 	return true;
 }
@@ -355,8 +367,15 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 {
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size;
+	bool zero_filled = false;
 	struct page *page = (struct page *)(data), *newpage;
 
+	if (page_is_zero_filled(page)) {
+		clen = 0;
+		zero_filled = true;
+		goto got_pampd;
+	}
+
 	if (!raw) {
 		zcache_compress(page, &cdata, &clen);
 		if (clen > zbud_max_buddy_size()) {
@@ -396,6 +415,8 @@ got_pampd:
 	inc_zcache_eph_zpages();
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(true, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -405,6 +426,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 {
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size;
+	bool zero_filled = false;
 	struct page *page = (struct page *)(data), *newpage;
 	unsigned long zbud_mean_zsize;
 	unsigned long curr_pers_zpages, total_zsize;
@@ -413,6 +435,13 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		BUG_ON(!ramster_enabled);
 		goto create_pampd;
 	}
+
+	if (page_is_zero_filled(page)) {
+		clen = 0;
+		zero_filled = true;
+		goto got_pampd;
+	}
+
 	curr_pers_zpages = zcache_pers_zpages;
 /* FIXME CONFIG_RAMSTER... subtract atomic remote_pers_pages here? */
 	if (!raw)
@@ -470,6 +499,8 @@ got_pampd:
 	inc_zcache_pers_zbytes(clen);
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(false, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -531,7 +562,8 @@ out:
  */
 void zcache_pampd_create_finish(void *pampd, bool eph)
 {
-	zbud_create_finish((struct zbudref *)pampd, eph);
+	if (pampd != (void *)ZERO_FILLED)
+		zbud_create_finish((struct zbudref *)pampd, eph);
 }
 
 /*
@@ -576,6 +608,14 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
 	BUG_ON(preemptible());
 	BUG_ON(eph);	/* fix later if shared pools get implemented */
 	BUG_ON(pampd_is_remote(pampd));
+
+	if (pampd == (void *)ZERO_FILLED) {
+		handle_zero_filled_page(data);
+		if (!raw)
+			*sizep = PAGE_SIZE;
+		return 0;
+	}
+
 	if (raw)
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
@@ -596,13 +636,22 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 					void *pampd, struct tmem_pool *pool,
 					struct tmem_oid *oid, uint32_t index)
 {
-	int ret;
-	bool eph = !is_persistent(pool);
+	int ret = 0;
+	bool eph = !is_persistent(pool), zero_filled = false;
 	struct page *page = NULL;
 	unsigned int zsize, zpages;
 
 	BUG_ON(preemptible());
 	BUG_ON(pampd_is_remote(pampd));
+
+	if (pampd == (void *)ZERO_FILLED) {
+		handle_zero_filled_page(data);
+		zero_filled = true;
+		if (!raw)
+			*sizep = PAGE_SIZE;
+		goto zero_fill;
+	}
+
 	if (raw)
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
@@ -614,6 +663,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
 					&zsize, &zpages);
+zero_fill:
 	if (eph) {
 		if (page)
 			dec_zcache_eph_pageframes();
@@ -627,7 +677,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	if (!is_local_client(pool->client))
 		ramster_count_foreign_pages(eph, -1);
-	if (page)
+	if (page && !zero_filled)
 		zcache_free_page(page);
 	return ret;
 }
@@ -641,16 +691,22 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 {
 	struct page *page = NULL;
 	unsigned int zsize, zpages;
+	bool zero_filled = false;
 
 	BUG_ON(preemptible());
-	if (pampd_is_remote(pampd)) {
+
+	if (pampd == (void *)ZERO_FILLED)
+		zero_filled = true;
+
+	if (pampd_is_remote(pampd) && !zero_filled) {
 		BUG_ON(!ramster_enabled);
 		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
 		if (pampd == NULL)
 			return;
 	}
 	if (is_ephemeral(pool)) {
-		page = zbud_free_and_delist((struct zbudref *)pampd,
+		if (!zero_filled)
+			page = zbud_free_and_delist((struct zbudref *)pampd,
 						true, &zsize, &zpages);
 		if (page)
 			dec_zcache_eph_pageframes();
@@ -667,7 +723,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 	}
 	if (!is_local_client(pool->client))
 		ramster_count_foreign_pages(is_ephemeral(pool), -1);
-	if (page)
+	if (page && !zero_filled)
 		zcache_free_page(page);
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
