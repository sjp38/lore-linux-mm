Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802C1C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39C7C20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:18:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rP5d8uUt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39C7C20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86D66B0007; Fri,  9 Aug 2019 14:18:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C37476B000C; Fri,  9 Aug 2019 14:18:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFF4A6B0010; Fri,  9 Aug 2019 14:18:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 781AE6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:18:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5so60207668pgq.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:18:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=vCc93vaFXwMRZ3fSZ6FSA2GqVkDbS0j1jfgTmaZ8aBc=;
        b=M57QzghdzjVnDqI6QdtU6+EC+KzfJyUrt6jAX1O4VUlk+TvdQxDF4KInXaCfqqYNXg
         m8vHMFBiEO5tKnfzweucqJg6GXdIxTir0Z23cxV/K4MfiA0WawaJvEvad89HlrWjXY5U
         +sArxUD09KGzjdgE7mO+Y3EIQ3us73GZx/d1CcgY9VnZMXPs8A4Oaczz1h0TBk7UERjp
         awVxgGQ6CFo/R81oyGA2qcVh2a2F8ac2kGysd9A/YQI4XLoro7hhpZWoDcTYZjeP5Q2v
         dUoMM6fN58df0FjcwVC48KmHgxqM7NF5fIa2Z+wWDCg5cDhV3a9tva2hm0ZdpPKFKwtG
         QD0A==
X-Gm-Message-State: APjAAAUDgijIrxgFigtVcfn2dTXPtB0Uvb+KGPg7130+DgjWhiaAyp+w
	ql+qtqZFsEPReJjvID+C5c8fI/7fUI6diiDQ/lTE41aiCHL7zSP/eLkxsv4EF08BIy8spKSO9MN
	PV2NVom4N6U3SAosGfPWBqh3j7dAETLL7S5ktl1D53RctR2x+GnOOKKS/k5gcJo18lA==
X-Received: by 2002:a63:381d:: with SMTP id f29mr19122892pga.101.1565374722922;
        Fri, 09 Aug 2019 11:18:42 -0700 (PDT)
X-Received: by 2002:a63:381d:: with SMTP id f29mr19122831pga.101.1565374721897;
        Fri, 09 Aug 2019 11:18:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565374721; cv=none;
        d=google.com; s=arc-20160816;
        b=Bm2b801EDdc/cw6uUGG5UJa+PG+DSIjn3eYvOw93s3vYWc8BeHDO8bg6+o0gkUZnko
         PGwuBzH2RMpwALurV1lt18IiZ+9t6UKWUdvLFSrqlCRChnAwy4huuoF9RCj0giiVfihf
         M0Bl0PT+EsnCJAmk6IJRtez0Fz4VTjPZnnnMiA6rYOWWxQ0U0z26D9bQ/KirUQSIlgVX
         oUqpKG9koEAmm+M8bLgO6wbzIXZU1rqvh6+DOcYQyICbhjzx1Ne60Kzwh4rcWiRctOBe
         R2/oegpA++VSi6wyp+OFADpIQDomWruJWRjF+X93uQxnD0TfE7Rgf19fU9R3rPdRaqdm
         FpEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=vCc93vaFXwMRZ3fSZ6FSA2GqVkDbS0j1jfgTmaZ8aBc=;
        b=OUjCAkiVuMRN4dn/baOzCGckM46lWUH2XypX9r7OM2Ze+JtS4hQIyk+x0IqO+keVhq
         DkY/E7HkforilHWTwbE1yZWX0bWCBry9cGzGZbWoxT6gxh+7NLc+Fo9bUMHz8bqEDEzK
         /vq4b3A8gtihEvUtxAe/p7sMLUXi4e9vsiy0BsvuGLqiSnNBHsTAmZg9u7LHxg02S5Uc
         jiOkqtVGwixXjKkBFfIXeF0US64Ju1tneTmdYffXas0IUomUNEr/hsr+6Gkfw6jN5esF
         fp8vJobUTVVI6JFyGk7OcAGR+LRv5VnkQN/ulBVPPs+T997nABcyQjGbbPXd9Rmx/1/O
         MQRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rP5d8uUt;
       spf=pass (google.com: domain of 3ablnxqokcjob8hls5olhmaiiaf8.6igfchor-ggep46e.ila@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AblNXQoKCJoB8HLS5OLHMAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l13sor69802808pgq.30.2019.08.09.11.18.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 11:18:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ablnxqokcjob8hls5olhmaiiaf8.6igfchor-ggep46e.ila@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rP5d8uUt;
       spf=pass (google.com: domain of 3ablnxqokcjob8hls5olhmaiiaf8.6igfchor-ggep46e.ila@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AblNXQoKCJoB8HLS5OLHMAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=vCc93vaFXwMRZ3fSZ6FSA2GqVkDbS0j1jfgTmaZ8aBc=;
        b=rP5d8uUtgyhIBDjs3pOQIuKA7CqPkZD87wr6U31d5zfiCN3+zpqMplqHMlAAaxJv5Y
         mtLjOGMMCHDiDW4eRm5ZqTb8YJp+nUsl6X/dXmaQ6YKC99OzzbfXbosMyYikyKx+YxMK
         WddcEWcZjamXOX0SzMHQLdh6BYQBctAuMgDwUuBx680TIuZbqFChFDUmuzsNIgJUX4V1
         RnVJoLfKEjC50m/1xX+078kcG9btrDBeIVgagoOHFJ/JTOZdPj65IWvBOIniw94xrSA6
         8LmhqGentKO3nOnsG63CBC0FeconSn075YP0D8gwkVY5TLhtdAab5zV1IozxKfU/txpL
         c6Nw==
X-Google-Smtp-Source: APXvYqyg54n0lDkaOi6YoNCD+Q2chFnQmSkX+NV/dn8iBvhAgc9UN9MRDpw/360/Y3bVmdFJO7zx9N1Mqe5obIpC
X-Received: by 2002:a63:e807:: with SMTP id s7mr18031604pgh.194.1565374721199;
 Fri, 09 Aug 2019 11:18:41 -0700 (PDT)
Date: Fri,  9 Aug 2019 11:17:51 -0700
In-Reply-To: <20190809181751.219326-1-henryburns@google.com>
Message-Id: <20190809181751.219326-2-henryburns@google.com>
Mime-Version: 1.0
References: <20190809181751.219326-1-henryburns@google.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH 2/2 v2] mm/zsmalloc.c: Fix race condition in zs_destroy_pool
From: Henry Burns <henryburns@google.com>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, HenryBurns <henrywolfeburns@gmail.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
have no guarantee that migration isn't happening in the background
at that time.

Since migration can't directly free pages, it relies on free_work
being scheduled to free the pages.  But there's nothing preventing an
in-progress migrate from queuing the work *after*
zs_unregister_migration() has called flush_work().  Which would mean
pages still pointing at the inode when we free it.

Since we know at destroy time all objects should be free, no new
migrations can come in (since zs_page_isolate() fails for fully-free
zspages).  This means it is sufficient to track a "# isolated zspages"
count by class, and have the destroy logic ensure all such pages have
drained before proceeding.  Keeping that state under the class
spinlock keeps the logic straightforward.

Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
Signed-off-by: Henry Burns <henryburns@google.com>
---
 Changelog since v1:
 - Changed the class level isolated count to a pool level isolated count
   (of zspages). Also added a pool level flag for when destruction
   starts and a memory barrier to ensure this flag has global
   visibility.

 mm/zsmalloc.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 59 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 5105b9b66653..08def3a0d200 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -54,6 +54,7 @@
 #include <linux/mount.h>
 #include <linux/pseudo_fs.h>
 #include <linux/migrate.h>
+#include <linux/wait.h>
 #include <linux/pagemap.h>
 #include <linux/fs.h>
 
@@ -268,6 +269,10 @@ struct zs_pool {
 #ifdef CONFIG_COMPACTION
 	struct inode *inode;
 	struct work_struct free_work;
+	/* A wait queue for when migration races with async_free_zspage() */
+	struct wait_queue_head migration_wait;
+	atomic_long_t isolated_pages;
+	bool destroying;
 #endif
 };
 
@@ -1874,6 +1879,19 @@ static void putback_zspage_deferred(struct zs_pool *pool,
 
 }
 
+static inline void zs_pool_dec_isolated(struct zs_pool *pool)
+{
+	VM_BUG_ON(atomic_long_read(&pool->isolated_pages) <= 0);
+	atomic_long_dec(&pool->isolated_pages);
+	/*
+	 * There's no possibility of racing, since wait_for_isolated_drain()
+	 * checks the isolated count under &class->lock after enqueuing
+	 * on migration_wait.
+	 */
+	if (atomic_long_read(&pool->isolated_pages) == 0 && pool->destroying)
+		wake_up_all(&pool->migration_wait);
+}
+
 static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 				struct page *newpage, struct page *oldpage)
 {
@@ -1943,6 +1961,7 @@ static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	 */
 	if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
 		get_zspage_mapping(zspage, &class_idx, &fullness);
+		atomic_long_inc(&pool->isolated_pages);
 		remove_zspage(class, zspage, fullness);
 	}
 
@@ -2042,8 +2061,16 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * Page migration is done so let's putback isolated zspage to
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
-	if (!is_zspage_isolated(zspage))
+	if (!is_zspage_isolated(zspage)) {
+		/*
+		 * We cannot race with zs_destroy_pool() here because we wait
+		 * for isolation to hit zero before we start destroying.
+		 * Also, we ensure that everyone can see pool->destroying before
+		 * we start waiting.
+		 */
 		putback_zspage_deferred(pool, class, zspage);
+		zs_pool_dec_isolated(pool);
+	}
 
 	reset_page(page);
 	put_page(page);
@@ -2094,8 +2121,8 @@ static void zs_page_putback(struct page *page)
 		 * so let's defer.
 		 */
 		putback_zspage_deferred(pool, class, zspage);
+		zs_pool_dec_isolated(pool);
 	}
-
 	spin_unlock(&class->lock);
 }
 
@@ -2118,8 +2145,36 @@ static int zs_register_migration(struct zs_pool *pool)
 	return 0;
 }
 
+static bool pool_isolated_are_drained(struct zs_pool *pool)
+{
+	return atomic_long_read(&pool->isolated_pages) == 0;
+}
+
+/* Function for resolving migration */
+static void wait_for_isolated_drain(struct zs_pool *pool)
+{
+
+	/*
+	 * We're in the process of destroying the pool, so there are no
+	 * active allocations. zs_page_isolate() fails for completely free
+	 * zspages, so we need only wait for the zs_pool's isolated
+	 * count to hit zero.
+	 */
+	wait_event(pool->migration_wait,
+		   pool_isolated_are_drained(pool));
+}
+
 static void zs_unregister_migration(struct zs_pool *pool)
 {
+	pool->destroying = true;
+	/*
+	 * We need a memory barrier here to ensure global visibility of
+	 * pool->destroying. Thus pool->isolated pages will either be 0 in which
+	 * case we don't care, or it will be > 0 and pool->destroying will
+	 * ensure that we wake up once isolation hits 0.
+	 */
+	smp_mb();
+	wait_for_isolated_drain(pool); /* This can block */
 	flush_work(&pool->free_work);
 	iput(pool->inode);
 }
@@ -2357,6 +2412,8 @@ struct zs_pool *zs_create_pool(const char *name)
 	if (!pool->name)
 		goto err;
 
+	init_waitqueue_head(&pool->migration_wait);
+
 	if (create_cache(pool))
 		goto err;
 
-- 
2.23.0.rc1.153.gdeed80330f-goog

