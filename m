Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8D6376B003D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:47:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 12:40:23 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 81CC43578052
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 13:47:02 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r322XNwM50594030
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:33:24 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r322kTob026825
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:30 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 2/8] staging: zcache: zero-filled pages awareness
Date: Tue,  2 Apr 2013 10:46:14 +0800
Message-Id: <1364870780-16296-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
 drivers/staging/zcache/zcache-main.c |   83 ++++++++++++++++++++++++++++-----
 1 files changed, 70 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index a0578d1..961fbf1 100644
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
@@ -356,8 +368,15 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
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
@@ -397,6 +416,8 @@ got_pampd:
 	inc_zcache_eph_zpages();
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(true, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -406,6 +427,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 {
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size;
+	bool zero_filled = false;
 	struct page *page = (struct page *)(data), *newpage;
 	unsigned long zbud_mean_zsize;
 	unsigned long curr_pers_zpages, total_zsize;
@@ -414,6 +436,13 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
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
@@ -471,6 +500,8 @@ got_pampd:
 	inc_zcache_pers_zbytes(clen);
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(false, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -532,7 +563,8 @@ out:
  */
 void zcache_pampd_create_finish(void *pampd, bool eph)
 {
-	zbud_create_finish((struct zbudref *)pampd, eph);
+	if (pampd != (void *)ZERO_FILLED)
+		zbud_create_finish((struct zbudref *)pampd, eph);
 }
 
 /*
@@ -577,6 +609,14 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
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
@@ -597,13 +637,22 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
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
@@ -615,6 +664,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
 					&zsize, &zpages);
+zero_fill:
 	if (eph) {
 		if (page)
 			dec_zcache_eph_pageframes();
@@ -628,7 +678,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	if (!is_local_client(pool->client))
 		ramster_count_foreign_pages(eph, -1);
-	if (page)
+	if (page && !zero_filled)
 		zcache_free_page(page);
 	return ret;
 }
@@ -642,16 +692,22 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
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
@@ -659,7 +715,8 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		dec_zcache_eph_zbytes(zsize);
 		/* FIXME CONFIG_RAMSTER... check acct parameter? */
 	} else {
-		page = zbud_free_and_delist((struct zbudref *)pampd,
+		if (!zero_filled)
+			page = zbud_free_and_delist((struct zbudref *)pampd,
 						false, &zsize, &zpages);
 		if (page)
 			dec_zcache_pers_pageframes();
@@ -668,7 +725,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
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
