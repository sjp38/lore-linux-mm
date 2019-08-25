Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB34C3A5A3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 519F02190F
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0PzduUZ4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 519F02190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 094286B04F5; Sat, 24 Aug 2019 20:54:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06BD56B04F7; Sat, 24 Aug 2019 20:54:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3D36B04F8; Sat, 24 Aug 2019 20:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id CD4BC6B04F5
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:39 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7659E4853
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:39 +0000 (UTC)
X-FDA: 75859129878.09.crack99_45b2fe51f9439
X-HE-Tag: crack99_45b2fe51f9439
X-Filterd-Recvd-Size: 7231
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:38 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 945E0206E0;
	Sun, 25 Aug 2019 00:54:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694477;
	bh=CBZu2oc704LYAmtVnL2Z4143B5NGtHX1hgCERy8iZIA=;
	h=Date:From:To:Subject:From;
	b=0PzduUZ4UtAUI6UrMdJDxtgNvAZRwMz7kbDXQJ6PEK5Rvs5Bq02D2rnpbXcZIerUN
	 vVz4DTeVxGXEXA2mz8BeK2IuftVPoGDXVIqMF4SdZe4bV9pWASnJy+RufnbRBzOT14
	 OA51oftvtj9Cx/AbX7DlULzYdRbB+TLk/QUOk5Ys=
Date: Sat, 24 Aug 2019 17:54:37 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, henryburns@google.com,
 henrywolfeburns@gmail.com, jwadams@google.com, linux-mm@kvack.org,
 mm-commits@vger.kernel.org, shakeelb@google.com, stable@vger.kernel.org,
 torvalds@linux-foundation.org, vitalywool@gmail.com
Subject:  [patch 01/11] mm/z3fold.c: fix race between migration and
 destruction
Message-ID: <20190825005437.EXZurMmNL%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Henry Burns <henryburns@google.com>
Subject: mm/z3fold.c: fix race between migration and destruction

In z3fold_destroy_pool() we call destroy_workqueue(&pool->compact_wq). 
However, we have no guarantee that migration isn't happening in the
background at that time.

Migration directly calls queue_work_on(pool->compact_wq), if destruction
wins that race we are using a destroyed workqueue.

Link: http://lkml.kernel.org/r/20190809213828.202833-1-henryburns@google.com
Signed-off-by: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Jonathan Adams <jwadams@google.com>
Cc: Henry Burns <henrywolfeburns@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/z3fold.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

--- a/mm/z3fold.c~mm-z3foldc-fix-race-between-migration-and-destruction
+++ a/mm/z3fold.c
@@ -41,6 +41,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/wait.h>
 #include <linux/zpool.h>
 #include <linux/magic.h>
 
@@ -145,6 +146,8 @@ struct z3fold_header {
  * @release_wq:	workqueue for safe page release
  * @work:	work_struct for safe page release
  * @inode:	inode for z3fold pseudo filesystem
+ * @destroying: bool to stop migration once we start destruction
+ * @isolated: int to count the number of pages currently in isolation
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -163,8 +166,11 @@ struct z3fold_pool {
 	const struct zpool_ops *zpool_ops;
 	struct workqueue_struct *compact_wq;
 	struct workqueue_struct *release_wq;
+	struct wait_queue_head isolate_wait;
 	struct work_struct work;
 	struct inode *inode;
+	bool destroying;
+	int isolated;
 };
 
 /*
@@ -769,6 +775,7 @@ static struct z3fold_pool *z3fold_create
 		goto out_c;
 	spin_lock_init(&pool->lock);
 	spin_lock_init(&pool->stale_lock);
+	init_waitqueue_head(&pool->isolate_wait);
 	pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
 	if (!pool->unbuddied)
 		goto out_pool;
@@ -808,6 +815,15 @@ out:
 	return NULL;
 }
 
+static bool pool_isolated_are_drained(struct z3fold_pool *pool)
+{
+	bool ret;
+
+	spin_lock(&pool->lock);
+	ret = pool->isolated == 0;
+	spin_unlock(&pool->lock);
+	return ret;
+}
 /**
  * z3fold_destroy_pool() - destroys an existing z3fold pool
  * @pool:	the z3fold pool to be destroyed
@@ -817,6 +833,22 @@ out:
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
+	/*
+	 * We set pool-> destroying under lock to ensure that
+	 * z3fold_page_isolate() sees any changes to destroying. This way we
+	 * avoid the need for any memory barriers.
+	 */
+
+	spin_lock(&pool->lock);
+	pool->destroying = true;
+	spin_unlock(&pool->lock);
+
+	/*
+	 * We need to ensure that no pages are being migrated while we destroy
+	 * these workqueues, as migration can queue work on either of the
+	 * workqueues.
+	 */
+	wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
 
 	/*
 	 * We need to destroy pool->compact_wq before pool->release_wq,
@@ -1307,6 +1339,28 @@ static u64 z3fold_get_pool_size(struct z
 	return atomic64_read(&pool->pages_nr);
 }
 
+/*
+ * z3fold_dec_isolated() expects to be called while pool->lock is held.
+ */
+static void z3fold_dec_isolated(struct z3fold_pool *pool)
+{
+	assert_spin_locked(&pool->lock);
+	VM_BUG_ON(pool->isolated <= 0);
+	pool->isolated--;
+
+	/*
+	 * If we have no more isolated pages, we have to see if
+	 * z3fold_destroy_pool() is waiting for a signal.
+	 */
+	if (pool->isolated == 0 && waitqueue_active(&pool->isolate_wait))
+		wake_up_all(&pool->isolate_wait);
+}
+
+static void z3fold_inc_isolated(struct z3fold_pool *pool)
+{
+	pool->isolated++;
+}
+
 static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct z3fold_header *zhdr;
@@ -1333,6 +1387,33 @@ static bool z3fold_page_isolate(struct p
 		spin_lock(&pool->lock);
 		if (!list_empty(&page->lru))
 			list_del(&page->lru);
+		/*
+		 * We need to check for destruction while holding pool->lock, as
+		 * otherwise destruction could see 0 isolated pages, and
+		 * proceed.
+		 */
+		if (unlikely(pool->destroying)) {
+			spin_unlock(&pool->lock);
+			/*
+			 * If this page isn't stale, somebody else holds a
+			 * reference to it. Let't drop our refcount so that they
+			 * can call the release logic.
+			 */
+			if (unlikely(kref_put(&zhdr->refcount,
+					      release_z3fold_page_locked))) {
+				/*
+				 * If we get here we have kref problems, so we
+				 * should freak out.
+				 */
+				WARN(1, "Z3fold is experiencing kref problems\n");
+				return false;
+			}
+			z3fold_page_unlock(zhdr);
+			return false;
+		}
+
+
+		z3fold_inc_isolated(pool);
 		spin_unlock(&pool->lock);
 		z3fold_page_unlock(zhdr);
 		return true;
@@ -1401,6 +1482,10 @@ static int z3fold_page_migrate(struct ad
 
 	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
 
+	spin_lock(&pool->lock);
+	z3fold_dec_isolated(pool);
+	spin_unlock(&pool->lock);
+
 	page_mapcount_reset(page);
 	put_page(page);
 	return 0;
@@ -1420,10 +1505,14 @@ static void z3fold_page_putback(struct p
 	INIT_LIST_HEAD(&page->lru);
 	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
 		atomic64_dec(&pool->pages_nr);
+		spin_lock(&pool->lock);
+		z3fold_dec_isolated(pool);
+		spin_unlock(&pool->lock);
 		return;
 	}
 	spin_lock(&pool->lock);
 	list_add(&page->lru, &pool->lru);
+	z3fold_dec_isolated(pool);
 	spin_unlock(&pool->lock);
 	z3fold_page_unlock(zhdr);
 }
_

