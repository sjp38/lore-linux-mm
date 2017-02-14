Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 757836B03A5
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:40:59 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x84so195509591oix.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:40:59 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id f125si430119oia.267.2017.02.14.07.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 07:40:58 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id j15so1166676oih.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:40:58 -0800 (PST)
From: Mahipal Challa <mahipalreddy2006@gmail.com>
Subject: [RFC PATCH v1 1/1] mm: zswap - Add crypto acomp/scomp framework support
Date: Tue, 14 Feb 2017 21:10:21 +0530
Message-Id: <1487086821-5880-2-git-send-email-Mahipal.Challa@cavium.com>
In-Reply-To: <1487086821-5880-1-git-send-email-Mahipal.Challa@cavium.com>
References: <1487086821-5880-1-git-send-email-Mahipal.Challa@cavium.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: herbert@gondor.apana.org.au, sjenning@redhat.com, davem@davemloft.net
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pathreya@cavium.com, vnair@cavium.com, Mahipal Challa <Mahipal.Challa@cavium.com>, Vishnu Nair <Vishnu.Nair@cavium.com>

This adds the support for kernel's crypto new acomp/scomp framework
to zswap.

Signed-off-by: Mahipal Challa <Mahipal.Challa@cavium.com>
Signed-off-by: Vishnu Nair <Vishnu.Nair@cavium.com> 
---
 mm/zswap.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 99 insertions(+), 30 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 067a0d6..d08631b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -33,6 +33,8 @@
 #include <linux/rbtree.h>
 #include <linux/swap.h>
 #include <linux/crypto.h>
+#include <crypto/acompress.h>
+#include <linux/scatterlist.h>
 #include <linux/mempool.h>
 #include <linux/zpool.h>
 
@@ -114,7 +116,8 @@ static int zswap_compressor_param_set(const char *,
 
 struct zswap_pool {
 	struct zpool *zpool;
-	struct crypto_comp * __percpu *tfm;
+	struct crypto_acomp * __percpu *acomp;
+	struct acomp_req * __percpu *acomp_req;
 	struct kref kref;
 	struct list_head list;
 	struct work_struct work;
@@ -379,30 +382,49 @@ static int zswap_dstmem_dead(unsigned int cpu)
 static int zswap_cpu_comp_prepare(unsigned int cpu, struct hlist_node *node)
 {
 	struct zswap_pool *pool = hlist_entry(node, struct zswap_pool, node);
-	struct crypto_comp *tfm;
+	struct crypto_acomp *acomp;
+	struct acomp_req *acomp_req;
 
-	if (WARN_ON(*per_cpu_ptr(pool->tfm, cpu)))
+	if (WARN_ON(*per_cpu_ptr(pool->acomp, cpu)))
 		return 0;
+	if (WARN_ON(*per_cpu_ptr(pool->acomp_req, cpu)))
+		return 0;
+
+	acomp = crypto_alloc_acomp(pool->tfm_name, 0, 0);
+	if (IS_ERR_OR_NULL(acomp)) {
+		pr_err("could not alloc crypto acomp %s : %ld\n",
+		       pool->tfm_name, PTR_ERR(acomp));
+		return -ENOMEM;
+	}
+	*per_cpu_ptr(pool->acomp, cpu) = acomp;
 
-	tfm = crypto_alloc_comp(pool->tfm_name, 0, 0);
-	if (IS_ERR_OR_NULL(tfm)) {
-		pr_err("could not alloc crypto comp %s : %ld\n",
-		       pool->tfm_name, PTR_ERR(tfm));
+	acomp_req = acomp_request_alloc(acomp);
+	if (IS_ERR_OR_NULL(acomp_req)) {
+		pr_err("could not alloc crypto acomp %s : %ld\n",
+		       pool->tfm_name, PTR_ERR(acomp));
 		return -ENOMEM;
 	}
-	*per_cpu_ptr(pool->tfm, cpu) = tfm;
+	*per_cpu_ptr(pool->acomp_req, cpu) = acomp_req;
+
 	return 0;
 }
 
 static int zswap_cpu_comp_dead(unsigned int cpu, struct hlist_node *node)
 {
 	struct zswap_pool *pool = hlist_entry(node, struct zswap_pool, node);
-	struct crypto_comp *tfm;
+	struct crypto_acomp *acomp;
+	struct acomp_req *acomp_req;
+
+	acomp_req = *per_cpu_ptr(pool->acomp_req, cpu);
+	if (!IS_ERR_OR_NULL(acomp_req))
+		acomp_request_free(acomp_req);
+	*per_cpu_ptr(pool->acomp_req, cpu) = NULL;
+
+	acomp = *per_cpu_ptr(pool->acomp, cpu);
+	if (!IS_ERR_OR_NULL(acomp))
+		crypto_free_acomp(acomp);
+	*per_cpu_ptr(pool->acomp, cpu) = NULL;
 
-	tfm = *per_cpu_ptr(pool->tfm, cpu);
-	if (!IS_ERR_OR_NULL(tfm))
-		crypto_free_comp(tfm);
-	*per_cpu_ptr(pool->tfm, cpu) = NULL;
 	return 0;
 }
 
@@ -503,8 +525,14 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 	pr_debug("using %s zpool\n", zpool_get_type(pool->zpool));
 
 	strlcpy(pool->tfm_name, compressor, sizeof(pool->tfm_name));
-	pool->tfm = alloc_percpu(struct crypto_comp *);
-	if (!pool->tfm) {
+	pool->acomp = alloc_percpu(struct crypto_acomp *);
+	if (!pool->acomp) {
+		pr_err("percpu alloc failed\n");
+		goto error;
+	}
+
+	pool->acomp_req = alloc_percpu(struct acomp_req *);
+	if (!pool->acomp_req) {
 		pr_err("percpu alloc failed\n");
 		goto error;
 	}
@@ -526,7 +554,8 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 	return pool;
 
 error:
-	free_percpu(pool->tfm);
+	free_percpu(pool->acomp_req);
+	free_percpu(pool->acomp);
 	if (pool->zpool)
 		zpool_destroy_pool(pool->zpool);
 	kfree(pool);
@@ -566,7 +595,8 @@ static void zswap_pool_destroy(struct zswap_pool *pool)
 	zswap_pool_debug("destroying", pool);
 
 	cpuhp_state_remove_instance(CPUHP_MM_ZSWP_POOL_PREPARE, &pool->node);
-	free_percpu(pool->tfm);
+	free_percpu(pool->acomp_req);
+	free_percpu(pool->acomp);
 	zpool_destroy_pool(pool->zpool);
 	kfree(pool);
 }
@@ -763,7 +793,8 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 	pgoff_t offset;
 	struct zswap_entry *entry;
 	struct page *page;
-	struct crypto_comp *tfm;
+	struct scatterlist input, output;
+	struct acomp_req *req;
 	u8 *src, *dst;
 	unsigned int dlen;
 	int ret;
@@ -803,14 +834,23 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 
 	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
 		/* decompress */
+		req = *get_cpu_ptr(entry->pool->acomp_req);
 		dlen = PAGE_SIZE;
 		src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
 				ZPOOL_MM_RO) + sizeof(struct zswap_header);
 		dst = kmap_atomic(page);
-		tfm = *get_cpu_ptr(entry->pool->tfm);
-		ret = crypto_comp_decompress(tfm, src, entry->length,
-					     dst, &dlen);
-		put_cpu_ptr(entry->pool->tfm);
+
+		sg_init_one(&input, src, entry->length);
+		sg_init_one(&output, dst, dlen);
+		acomp_request_set_params(req, &input, &output, entry->length,
+					 dlen);
+		acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+					   NULL, NULL);
+
+		ret = crypto_acomp_decompress(req);
+
+		dlen = req->dlen;
+		put_cpu_ptr(entry->pool->acomp_req);
 		kunmap_atomic(dst);
 		zpool_unmap_handle(entry->pool->zpool, entry->handle);
 		BUG_ON(ret);
@@ -886,7 +926,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 {
 	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry, *dupentry;
-	struct crypto_comp *tfm;
+	struct scatterlist input, output;
+	struct acomp_req *req;
 	int ret;
 	unsigned int dlen = PAGE_SIZE, len;
 	unsigned long handle;
@@ -925,12 +966,27 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* compress */
+	req = *get_cpu_ptr(entry->pool->acomp_req);
+	if (!req) {
+		put_cpu_ptr(entry->pool->acomp_req);
+		ret = -EINVAL;
+		goto freepage;
+	}
+
 	dst = get_cpu_var(zswap_dstmem);
-	tfm = *get_cpu_ptr(entry->pool->tfm);
 	src = kmap_atomic(page);
-	ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
+
+	sg_init_one(&input, src, PAGE_SIZE);
+	/* zswap_dstmem is of size (PAGE_SIZE * 2). Reflect same in sg_list */
+	sg_init_one(&output, dst, PAGE_SIZE * 2);
+	acomp_request_set_params(req, &input, &output, PAGE_SIZE, dlen);
+	acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG, NULL,
+				   NULL);
+
+	ret = crypto_acomp_compress(req);
 	kunmap_atomic(src);
-	put_cpu_ptr(entry->pool->tfm);
+	put_cpu_ptr(entry->pool->acomp_req);
+	dlen = req->dlen;
 	if (ret) {
 		ret = -EINVAL;
 		goto put_dstmem;
@@ -998,7 +1054,8 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 {
 	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry;
-	struct crypto_comp *tfm;
+	struct scatterlist input, output;
+	struct acomp_req *req;
 	u8 *src, *dst;
 	unsigned int dlen;
 	int ret;
@@ -1014,13 +1071,25 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	spin_unlock(&tree->lock);
 
 	/* decompress */
+	req = *get_cpu_ptr(entry->pool->acomp_req);
+	if (!req) {
+		put_cpu_ptr(entry->pool->acomp_req);
+		return -1;
+	}
 	dlen = PAGE_SIZE;
 	src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
 			ZPOOL_MM_RO) + sizeof(struct zswap_header);
 	dst = kmap_atomic(page);
-	tfm = *get_cpu_ptr(entry->pool->tfm);
-	ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
-	put_cpu_ptr(entry->pool->tfm);
+
+	sg_init_one(&input, src, entry->length);
+	sg_init_one(&output, dst, dlen);
+	acomp_request_set_params(req, &input, &output, entry->length, dlen);
+	acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG, NULL,
+				   NULL);
+
+	ret = crypto_acomp_decompress(req);
+
+	put_cpu_ptr(entry->pool->acomp_req);
 	kunmap_atomic(dst);
 	zpool_unmap_handle(entry->pool->zpool, entry->handle);
 	BUG_ON(ret);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
