Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9103A6B003C
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 03:05:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 12:32:24 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3B9B33940055
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:35:41 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D75chx22347874
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:35:38 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D75d6t011563
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:05:39 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/4] zcache: zero-filled pages awareness
Date: Wed, 13 Mar 2013 15:05:19 +0800
Message-Id: <1363158321-20790-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Compression of zero-filled pages can unneccessarily cause internal
fragmentation, and thus waste memory. This special case can be
optimized.

This patch captures zero-filled pages, and marks their corresponding
zcache backing page entry as zero-filled. Whenever such zero-filled
page is retrieved, we fill the page frame with zero.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/tmem.c        |    4 +-
 drivers/staging/zcache/tmem.h        |    5 ++
 drivers/staging/zcache/zcache-main.c |   87 ++++++++++++++++++++++++++++++----
 3 files changed, 85 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
index a2b7e03..62468ea 100644
--- a/drivers/staging/zcache/tmem.c
+++ b/drivers/staging/zcache/tmem.c
@@ -597,7 +597,9 @@ int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
 	if (unlikely(ret == -ENOMEM))
 		/* may have partially built objnode tree ("stump") */
 		goto delete_and_free;
-	(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
+	if (pampd != (void *)ZERO_FILLED)
+		(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
+
 	goto out;
 
 delete_and_free:
diff --git a/drivers/staging/zcache/tmem.h b/drivers/staging/zcache/tmem.h
index adbe5a8..6719dbd 100644
--- a/drivers/staging/zcache/tmem.h
+++ b/drivers/staging/zcache/tmem.h
@@ -204,6 +204,11 @@ struct tmem_handle {
 	uint16_t client_id;
 };
 
+/*
+ * mark pampd to special vaule in order that later
+ * retrieve will identify zero-filled pages
+ */
+#define ZERO_FILLED 0x2
 
 /* pampd abstract datatype methods provided by the PAM implementation */
 struct tmem_pamops {
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index b71e033..ed5ef26 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -543,7 +543,23 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 {
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size;
+	bool zero_filled = false;
 	struct page *page = (struct page *)(data), *newpage;
+	char *user_mem;
+
+	user_mem = kmap_atomic(page);
+
+	/*
+	 * Compressing zero-filled pages will waste memory and introduce
+	 * serious fragmentation, skip it to avoid overhead
+	 */
+	if (page_zero_filled(user_mem)) {
+		kunmap_atomic(user_mem);
+		clen = 0;
+		zero_filled = true;
+		goto got_pampd;
+	}
+	kunmap_atomic(user_mem);
 
 	if (!raw) {
 		zcache_compress(page, &cdata, &clen);
@@ -592,6 +608,8 @@ got_pampd:
 		zcache_eph_zpages_max = zcache_eph_zpages;
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(true, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -600,15 +618,31 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 					struct tmem_handle *th)
 {
 	void *pampd = NULL, *cdata = data;
-	unsigned clen = size;
+	unsigned clen = size, zero_filled = 0;
 	struct page *page = (struct page *)(data), *newpage;
 	unsigned long zbud_mean_zsize;
 	unsigned long curr_pers_zpages, total_zsize;
+	char *user_mem;
 
 	if (data == NULL) {
 		BUG_ON(!ramster_enabled);
 		goto create_pampd;
 	}
+
+	user_mem = kmap_atomic(page);
+
+	/*
+	 * Compressing zero-filled pages will waste memory and introduce
+	 * serious fragmentation, skip it to avoid overhead
+	 */
+	if (page_zero_filled(page)) {
+		kunmap_atomic(user_mem);
+		clen = 0;
+		zero_filled = 1;
+		goto got_pampd;
+	}
+	kunmap_atomic(user_mem);
+
 	curr_pers_zpages = zcache_pers_zpages;
 /* FIXME CONFIG_RAMSTER... subtract atomic remote_pers_pages here? */
 	if (!raw)
@@ -674,6 +708,8 @@ got_pampd:
 		zcache_pers_zbytes_max = zcache_pers_zbytes;
 	if (ramster_enabled && raw)
 		ramster_count_foreign_pages(false, 1);
+	if (zero_filled)
+		pampd = (void *)ZERO_FILLED;
 out:
 	return pampd;
 }
@@ -780,6 +816,14 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
 	BUG_ON(preemptible());
 	BUG_ON(eph);	/* fix later if shared pools get implemented */
 	BUG_ON(pampd_is_remote(pampd));
+
+	if (pampd == (void *)ZERO_FILLED) {
+		handle_zero_page(data);
+		if (!raw)
+			*sizep = PAGE_SIZE;
+		return 0;
+	}
+
 	if (raw)
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
@@ -800,13 +844,24 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
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
+		handle_zero_page(data);
+		zero_filled = true;
+		zsize = 0;
+		zpages = 1;
+		if (!raw)
+			*sizep = PAGE_SIZE;
+		goto zero_fill;
+	}
+
 	if (raw)
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
@@ -818,8 +873,9 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
 					&zsize, &zpages);
+zero_fill:
 	if (eph) {
-		if (page)
+		if (page || zero_filled)
 			zcache_eph_pageframes =
 			    atomic_dec_return(&zcache_eph_pageframes_atomic);
 		zcache_eph_zpages =
@@ -827,7 +883,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		zcache_eph_zbytes =
 		    atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
 	} else {
-		if (page)
+		if (page || zero_filled)
 			zcache_pers_pageframes =
 			    atomic_dec_return(&zcache_pers_pageframes_atomic);
 		zcache_pers_zpages =
@@ -837,7 +893,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	}
 	if (!is_local_client(pool->client))
 		ramster_count_foreign_pages(eph, -1);
-	if (page)
+	if (page && !zero_filled)
 		zcache_free_page(page);
 	return ret;
 }
@@ -851,18 +907,29 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 {
 	struct page *page = NULL;
 	unsigned int zsize, zpages;
+	bool zero_filled = false;
 
 	BUG_ON(preemptible());
-	if (pampd_is_remote(pampd)) {
+
+	if (pampd == (void *)ZERO_FILLED) {
+		zero_filled = true;
+		zsize = 0;
+		zpages = 1;
+	}
+
+	if (pampd_is_remote(pampd) && !zero_filled) {
+
 		BUG_ON(!ramster_enabled);
 		pampd = ramster_pampd_free(pampd, pool, oid, index, acct);
 		if (pampd == NULL)
 			return;
 	}
 	if (is_ephemeral(pool)) {
-		page = zbud_free_and_delist((struct zbudref *)pampd,
+		if (!zero_filled)
+			page = zbud_free_and_delist((struct zbudref *)pampd,
+
 						true, &zsize, &zpages);
-		if (page)
+		if (page || zero_filled)
 			zcache_eph_pageframes =
 			    atomic_dec_return(&zcache_eph_pageframes_atomic);
 		zcache_eph_zpages =
@@ -883,7 +950,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
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
