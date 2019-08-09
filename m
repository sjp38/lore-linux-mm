Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAC3CC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8BC2086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fA4UXBof"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8BC2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EF516B0003; Fri,  9 Aug 2019 17:38:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 279826B0006; Fri,  9 Aug 2019 17:38:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3CF6B0007; Fri,  9 Aug 2019 17:38:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7CB16B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 17:38:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j96so12285216plb.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 14:38:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=xA4sS4X8FQOcKXsaLmxwZyVjI3eJo4lwqwVNVh8IS+4=;
        b=OrmtJkJL0bZZ7tOR8TLL3tgoNa08mT/PyhduvPb0PZrXBkbe7yL9RD1we12z5niLs2
         SchFKU320lRysClHmpUQifDPRdEzTvzfx0csMB769DniNhpE9JfRlJyDTd827yvoziuS
         JEOD7hf7NVve+tJHZxFIDSIYwThQpGayi6GE2wXRRjWAw/Ym5OojztFlwAEtAMaav2pG
         exAAXsiUBXw0yv3yaJm4Zmz4UmU5/3XhaHkwJ9aOx1e0zGuvXt/ZLxo3XmTsyGhr6qTw
         SB/cuF1/E3FR56AfvOWyXpuZwn2IBi3NTtnk286B6g7IyK8eOQHZRE80O3BZi010vkUv
         7vew==
X-Gm-Message-State: APjAAAWAVvRjoX2N7N0Xxon+OJcKQyRSJAhLVVuRMvrfe2c26wRcePNB
	NGOAm5Gsq5uOQk2+aKeOVWUmXa8d85ovlIA5dpapGAfXU/mzdXUkT2f31TDoLumuxywkOazF4UJ
	980vGGS5DQhF0pSCTHjAOGi4ZAG97GVHP49FShbeLVmipVo+EzYS2wFUe0ZRkXQPXlA==
X-Received: by 2002:a62:198d:: with SMTP id 135mr23482802pfz.169.1565386714302;
        Fri, 09 Aug 2019 14:38:34 -0700 (PDT)
X-Received: by 2002:a62:198d:: with SMTP id 135mr23482723pfz.169.1565386713346;
        Fri, 09 Aug 2019 14:38:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565386713; cv=none;
        d=google.com; s=arc-20160816;
        b=BhHGcI9kGwZKQhRu2KOgZohZfsoCW1Bw7KfCvqEdS0oNFp3Mh5MnTeKSmKFgdlYz2+
         bbht2G5gDv8tP2okTJFkyXGR9dXN9ttrGueFauIgjwWZpMpKHc2HRvMMcJc/H21uYUpV
         +EidDG02HpkxOTL8+CBGreLyo0lJlj3khlYwpVZoqPtXAqfzCYDtvkb27YmoHmbvEp/3
         KfdDRyxMLn8a0I8T03vDdxUT2qZSCoVqw8IjpkrFP6htkqC22YbrH1Mu0bslNtxWgOgR
         dbTMdCSmSBX7wbwG8Skf0zxfza1+uNpJ31eclTlZDASiO766SiW6bqOMNTVl8rXdxNLp
         legA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=xA4sS4X8FQOcKXsaLmxwZyVjI3eJo4lwqwVNVh8IS+4=;
        b=o5KdfBdSKLiCQoG6zlXvCf2NRCFmOMUgwmd96WOH9GzXcpQpRdz7cTfTB8+z9w5Y+a
         hNH8afPxblIa5WOiN9HmJ6zMHBQ9yaHNIflejlMjN6RntPlHqKTQpyrGwrv6SlgWxSK1
         OVvJnuXbhDObtRetm2J7mfVK3ETr/4nk5k0bq0rcA7s9TzqplF+7C1qINYxaK6RPOSc6
         HWz2tFNGccVekdNWZEUBpTB0Lo6epvikqdmFKTlKLTkup6pb8V9lJ5ToygScEc29qgLh
         kwxRxahch1M6j03jIu2MljJQqn8NKZJAi1yn8HE0J7nIcRfFHQPx+g4psct4ZQKgsSiu
         jUvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fA4UXBof;
       spf=pass (google.com: domain of 32odnxqokcm82z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32OdNXQoKCM82z8CJwFC8D19916z.x97638FI-775Gvx5.9C1@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a2sor44836861pgv.3.2019.08.09.14.38.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 14:38:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 32odnxqokcm82z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fA4UXBof;
       spf=pass (google.com: domain of 32odnxqokcm82z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32OdNXQoKCM82z8CJwFC8D19916z.x97638FI-775Gvx5.9C1@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=xA4sS4X8FQOcKXsaLmxwZyVjI3eJo4lwqwVNVh8IS+4=;
        b=fA4UXBofzcCuH8Ox2KDQK0BxsPfpGm7973kzLcneUP3vYQowr/+NJ+nNUg5QRpKn8Y
         3W68DrLgQdzpAFciU5sYMCVnhzZ3KswD/8BJDIRwTo6TUjOLK3K2dZFE66tQSD1h2AA4
         zy9iDurswmTQS/NNCJWI6FZbV6Gsrb3Mqc6InzTFO79yVNpfuIbUNxPRqY4FC2nmTmdY
         VnfiDHzpltInJ88rHqirfJ54cJIn3QWGf1oDK3aJ3hNmClHJY5s8u8zC3zV37UtRnld7
         5pecTAQ3ygzGi1caKsDJgyonQMCEYGYntdtEeU8mX8Gy2zBk8VQ6zL2avzbsfAHoN2gH
         WrYg==
X-Google-Smtp-Source: APXvYqwxBo8gk0xscIsZMbqcPDBwOjLUfEANF/KXXEv5uX61h79LJVfKhfhgmzb5/EeNB3vwZs2c8qk79C+kWMH0
X-Received: by 2002:a63:3281:: with SMTP id y123mr18805072pgy.72.1565386712674;
 Fri, 09 Aug 2019 14:38:32 -0700 (PDT)
Date: Fri,  9 Aug 2019 14:38:28 -0700
Message-Id: <20190809213828.202833-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH v2] mm/z3fold.c: Fix race between migration and destruction
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Henry Burns <henrywolfeburns@gmail.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
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
 Changelog since v1:
 - Fixed a bug where migration could still queue work after we have
   waited for it to drain. (added z3fold_pool->destroying in the
   process)

 mm/z3fold.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 78447cecfffa..6b32c94c4ca1 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -40,6 +40,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/wait.h>
 #include <linux/zpool.h>
 
 /*
@@ -143,6 +144,8 @@ struct z3fold_header {
  * @release_wq:	workqueue for safe page release
  * @work:	work_struct for safe page release
  * @inode:	inode for z3fold pseudo filesystem
+ * @destroying: bool to stop migration once we start destruction
+ * @isolated: int to count the number of pages currently in isolation
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -161,8 +164,11 @@ struct z3fold_pool {
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
@@ -772,6 +778,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 		goto out_c;
 	spin_lock_init(&pool->lock);
 	spin_lock_init(&pool->stale_lock);
+	init_waitqueue_head(&pool->isolate_wait);
 	pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
 	if (!pool->unbuddied)
 		goto out_pool;
@@ -811,6 +818,15 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
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
@@ -820,6 +836,22 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
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
@@ -1317,6 +1349,28 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
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
@@ -1343,6 +1397,33 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
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
@@ -1417,6 +1498,10 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 
 	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
 
+	spin_lock(&pool->lock);
+	z3fold_dec_isolated(pool);
+	spin_unlock(&pool->lock);
+
 	page_mapcount_reset(page);
 	put_page(page);
 	return 0;
@@ -1436,10 +1521,14 @@ static void z3fold_page_putback(struct page *page)
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
2.23.0.rc1.153.gdeed80330f-goog

