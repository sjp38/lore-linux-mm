Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8DC5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:46:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A3E5214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:46:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="h5q9nk8t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A3E5214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134566B027E; Fri,  9 Aug 2019 12:46:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5156B0281; Fri,  9 Aug 2019 12:46:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F15176B0289; Fri,  9 Aug 2019 12:46:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD4F76B027E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:46:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x1so15250638plm.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:46:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=kplyFBVLfjKpkfsvr+g9LWPdkB2amai/k5Uo/Q9auD8=;
        b=BUdPaEt9hfmEhzG0zu2Ptx9INBJ9uOEz4XfY5I2ARc3jWykF42r+87upMMmPBzxFR3
         t34LcJAwyLhbG+ne6Ewwq9waTWp9O/rJL5+vkunDdYuBT19Q+5tYcJiiHVRWqIoJW/wC
         WyUyUy0+P57xN/4lx8Qo+sOl8XclYECgihyxuWmEMwepWjm01x1E28vzjQ3O5N5RWB3w
         nLvaoNaZvykQXE4s7DYRjDc6Sn4SufChgjsuhfajSunDBDUNNs3kO0gYkGWiOAv2AVUW
         4tqw9jExNGNZaRTYwyafo+CXDcHjtwZkO28YwAbJEZJ22BwfWmBoUhZmk1bizJq0xE30
         LQ6A==
X-Gm-Message-State: APjAAAVtW5VGSvn5GYNFpIYVMR/Yg3WY8yJLR86dKo+u4cR1c2IAI4fC
	uO+tTqZc/f2MlLq4U3PASJH8vauM3IIvW4Dvbqu5e122tSOCMowt9DmxmJL7knXn+6hgHnR82Xx
	aR4/CQaUe6kQNeUHUNlq/YQp5jDiqmxLmi5nQzIXoXaw53PGeu9TpN8pT8jPdqSAMPQ==
X-Received: by 2002:a62:87c8:: with SMTP id i191mr22438038pfe.133.1565369209325;
        Fri, 09 Aug 2019 09:46:49 -0700 (PDT)
X-Received: by 2002:a62:87c8:: with SMTP id i191mr22437981pfe.133.1565369208514;
        Fri, 09 Aug 2019 09:46:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565369208; cv=none;
        d=google.com; s=arc-20160816;
        b=ej3psQDrqeH93iAjyJHi5WBeu5xr0Fg+3DFINH67EHpRi2yU3SMhwSH0SIkFxGga3W
         GEDxMTjBT3/fRu+RU/0fo4r67GGbsyE/qflZ6pRQlpQ1ZCxUF5EDnsU6dcthj9/6TZvR
         DYaxgantGrO3i0g4sjyZ98PQjlEoOn7dNZ95l5d2pF/zRa+mCVmfbs3EEMZ7FOsX0JJ4
         Ra/3a8l2EQ6xWIWQctA5qcyAQAk2SQKP/mH4lOcsCLC1y8SnASrT5gu+X5nN5mtcsuyo
         2PkexdCPO/GKjDRMt3vFeaOE6QKLagDwd6ZqoVjgoUXR8wpzw1ddmBLqsp2pA4u4ccHo
         aBxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=kplyFBVLfjKpkfsvr+g9LWPdkB2amai/k5Uo/Q9auD8=;
        b=ssXxZIhscp8Y6pmTIFJq05IaVl5E31IJy819frg/5s4Jk58/+qFhbJbmCl0MuV2UOU
         jJpzK6jTLeVnvX/UZiRO29N89PiBiUCH7sIG3eBJUIAx3vAXIo5/dk3kcoiXuj+Ngby+
         lVnRXyNxdhEJRLCWAmzqoMMZbdWyGoXOidVL+lSyZ4AhyMbtis9mxSDM2iYhS3rLtSiV
         BPAv51PQVjsUJ6D/lZdu8GmMk9gdsmikId8kuHj9F6dZ9aQnoW8o6tcSAhKVWXTNthJp
         BKa3H9+qr9XHA1xXvLMgL4e4xCbipYgp6yuT7FInKj6AOASibjuNJjHrbtMKBXA1cQqJ
         F82g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h5q9nk8t;
       spf=pass (google.com: domain of 3d6nnxqokcoqnktxehaxtymuumrk.iusrotad-ssqbgiq.uxm@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3d6NNXQoKCOQNKTXeHaXTYMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y22sor26164775pgl.49.2019.08.09.09.46.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 09:46:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3d6nnxqokcoqnktxehaxtymuumrk.iusrotad-ssqbgiq.uxm@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h5q9nk8t;
       spf=pass (google.com: domain of 3d6nnxqokcoqnktxehaxtymuumrk.iusrotad-ssqbgiq.uxm@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3d6NNXQoKCOQNKTXeHaXTYMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=kplyFBVLfjKpkfsvr+g9LWPdkB2amai/k5Uo/Q9auD8=;
        b=h5q9nk8tAZfenmZ9nj7f5DB5oIskrbAkgH1SUH6gc/dL9++Do8uiSM7Hh8La2YdhUr
         c98OMPd7HtrSuUYueAjsNgPsYn0tZRK/5HaykIpTugn6BG5+Vza6P/OsAgMFjkqbX1jb
         tKDl834IzGHcGXrnYRgJRmTFadPUx3REtsWU81DVqjN2jN5FDozEZFjlmyU/hBBXbLJw
         ih9km7R2a/yMONai2mjBAVT5BYQDwqVyE8IBYdzOCEpuj+Mpro6pHR2JAgxY5pDIXht1
         PLk/YyZZ8j9SAXEnGBIuDAzGcW9+kc7EpkUM3SSLFCJSLBJNDHIyfL5sXiJ1vvh7SCy/
         GzWw==
X-Google-Smtp-Source: APXvYqx/T4pUV4w673pBYfyL91Im0CVeVEr8FGQeETHGkS2gMOK6RWfCsg0q/8JeJa1WpxxrqXiPwnZ99ymqgwMp
X-Received: by 2002:a63:7205:: with SMTP id n5mr18128177pgc.443.1565369207803;
 Fri, 09 Aug 2019 09:46:47 -0700 (PDT)
Date: Fri,  9 Aug 2019 09:46:43 -0700
Message-Id: <20190809164643.5978-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH] mm/z3fold.c: Fix race between migration and destruction
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In z3fold_destroy_pool() we call destroy_workqueue(&pool->compact_wq).
However, we have no guarantee that migration isn't happening in the
background at that time.

Migration directly calls queue_work_on(pool->compact_wq), if destruction
wins that race we are using a destroyed workqueue.

Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 78447cecfffa..e136d97ce56e 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -40,6 +40,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/wait.h>
 #include <linux/zpool.h>
 
 /*
@@ -161,8 +162,10 @@ struct z3fold_pool {
 	const struct zpool_ops *zpool_ops;
 	struct workqueue_struct *compact_wq;
 	struct workqueue_struct *release_wq;
+	struct wait_queue_head isolate_wait;
 	struct work_struct work;
 	struct inode *inode;
+	int isolated_pages;
 };
 
 /*
@@ -772,6 +775,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 		goto out_c;
 	spin_lock_init(&pool->lock);
 	spin_lock_init(&pool->stale_lock);
+	init_waitqueue_head(&pool->isolate_wait);
 	pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
 	if (!pool->unbuddied)
 		goto out_pool;
@@ -811,6 +815,15 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 	return NULL;
 }
 
+static bool pool_isolated_are_drained(struct z3fold_pool *pool)
+{
+	bool ret;
+
+	spin_lock(&pool->lock);
+	ret = pool->isolated_pages == 0;
+	spin_unlock(&pool->lock);
+	return ret;
+}
 /**
  * z3fold_destroy_pool() - destroys an existing z3fold pool
  * @pool:	the z3fold pool to be destroyed
@@ -821,6 +834,13 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
 
+	/*
+	 * We need to ensure that no pages are being migrated while we destroy
+	 * these workqueues, as migration can queue work on either of the
+	 * workqueues.
+	 */
+	wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
+
 	/*
 	 * We need to destroy pool->compact_wq before pool->release_wq,
 	 * as any pending work on pool->compact_wq will call
@@ -1317,6 +1337,28 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
 	return atomic64_read(&pool->pages_nr);
 }
 
+/*
+ * z3fold_dec_isolated() expects to be called while pool->lock is held.
+ */
+static void z3fold_dec_isolated(struct z3fold_pool *pool)
+{
+	assert_spin_locked(&pool->lock);
+	VM_BUG_ON(pool->isolated_pages <= 0);
+	pool->isolated_pages--;
+
+	/*
+	 * If we have no more isolated pages, we have to see if
+	 * z3fold_destroy_pool() is waiting for a signal.
+	 */
+	if (pool->isolated_pages == 0 && waitqueue_active(&pool->isolate_wait))
+		wake_up_all(&pool->isolate_wait);
+}
+
+static void z3fold_inc_isolated(struct z3fold_pool *pool)
+{
+	pool->isolated_pages++;
+}
+
 static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct z3fold_header *zhdr;
@@ -1343,6 +1385,7 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 		spin_lock(&pool->lock);
 		if (!list_empty(&page->lru))
 			list_del(&page->lru);
+		z3fold_inc_isolated(pool);
 		spin_unlock(&pool->lock);
 		z3fold_page_unlock(zhdr);
 		return true;
@@ -1417,6 +1460,10 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 
 	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
 
+	spin_lock(&pool->lock);
+	z3fold_dec_isolated(pool);
+	spin_unlock(&pool->lock);
+
 	page_mapcount_reset(page);
 	put_page(page);
 	return 0;
@@ -1436,10 +1483,14 @@ static void z3fold_page_putback(struct page *page)
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
-- 
2.22.0.770.g0f2c4a37fd-goog

