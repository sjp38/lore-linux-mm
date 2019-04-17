Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C65FFC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:36:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D12F21773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:36:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R1IRcJSV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D12F21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07DAA6B0007; Wed, 17 Apr 2019 04:36:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006D46B000A; Wed, 17 Apr 2019 04:36:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEC1C6B000D; Wed, 17 Apr 2019 04:36:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D52A6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:36:38 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id o17so4744930ljd.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:36:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H8CKRiQBJrU9wnvoQVT3UbKuoETyr+5Jz1SZnQKUh/k=;
        b=d6bR7/ARk7/SSsjZeZ8IndUq/SkksrIsEdYlYvk9VNBCOYs+dJ1fS26L2mh3HRG6Ex
         wdrOg/HWr+XdgfIQG+AUwNL8oIwFdGL07Czon5rK5wB45NaMcRBq8wSG3HWW9K3Ab5lu
         oyPFbJwneU93p+7UqxrRf+iQz/bUvD6x4iW0QrG5phnZOmbHqcHDtOm2JCyTBPLfYa10
         zS/4/pQs39KCRIBgO68Px5pSQN4GQV0F8CpPpxR2AT/feYFnUXFghGXYuFcaSUtLfLgx
         35kOKWv6VmqCBEj0ux86913ePL+x7Fs5pjdurnvvLQofQrVFn2Vr8DkiOIOs2Bh3KGJu
         yB2Q==
X-Gm-Message-State: APjAAAWshBD3utWmxkdFt6olWgq7eYrhpQam7sJECZxjnoc0fMBDUHUm
	jw6XO+/r4CQL87Pty0YFsu3w2eSYRHHH8Gau1/dR0aIEO4KjIMvv+Wp7qXVML5IAIs3qiv9RvKt
	HMRO2s67bNTtM9SF+DSf4hSiY4M5FimzT3gwiTzZJXyfquZrTvQtXaEk5YmnKfOmpoA==
X-Received: by 2002:a2e:9e47:: with SMTP id g7mr8518801ljk.48.1555490197750;
        Wed, 17 Apr 2019 01:36:37 -0700 (PDT)
X-Received: by 2002:a2e:9e47:: with SMTP id g7mr8518736ljk.48.1555490196173;
        Wed, 17 Apr 2019 01:36:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490196; cv=none;
        d=google.com; s=arc-20160816;
        b=UHhr1c+miujERcFLb/DqmzJPm1eNJzrpzYYLC7D0Knn/BlJN0elBTVN56nvLMGf4Sb
         +hwarfsBeZh2lwUBZjVf2RQmCiTmUJoQnc3j0Ue9OrIyd9bgSPFFEL+mQfOQWt+Kzk5P
         HGHuEX2giUxUaszCfdjHBFU03DriLB1zooVPP+mns/mvKQ/m+Yme9hEEbKicLowFkKJ8
         WVT8ve65BY3nRjn1KzqtOwX6N+twevYc0VD/yEfoI8sV/Iuypkus998ahDi8tcZ2jSW9
         bsVYZArYn/PGF0AdbdO8REI4cl27VnXAALc9oZvplcDuOm+2SOhlUENX0nnUw49fQIq+
         8dpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=H8CKRiQBJrU9wnvoQVT3UbKuoETyr+5Jz1SZnQKUh/k=;
        b=ZutmdyJMN2gOb6JDktFcJ9LE1We6gWLUMnh7L/MtkTW1k1ICDS5YpqF/O97cYkfmU4
         SF43h+FNYQ7Tnc/6oI8coUFSuM+u4vJ7oQQKBq0Znr5yyUUhiTl5/ZK7+tuJeMRYRTxj
         3Y1lvHh25Ma5FvSEoZbZuUkUfpTj6/90kLmtn+0iNBz9bocEhN7oUTbQiczOVcWeNLCw
         5l77iiMilLaSuyXbX7JOjp6onKM/OBZkY9cuv6TVyoDINmx0rsnHRbOCwmnJGjphbYfJ
         LZqpiO4WgvxFIyk4sZBoPS+dOp0BH6ZI0DTRDgqA4NRgip2QykqKl0qUiM4BYJCXTxYU
         j1dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R1IRcJSV;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q15sor32994604lji.37.2019.04.17.01.36.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:36:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R1IRcJSV;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=H8CKRiQBJrU9wnvoQVT3UbKuoETyr+5Jz1SZnQKUh/k=;
        b=R1IRcJSVKlPeG1OzA5UM0heY9883GHBOCEJII5rnA43y+Hql2xG5lkLSjzFDtahSXu
         1ma+PUr7KSIMLlypnMKJwmoTJpQJp9vo6zdW8YiJm2UnkCvK6N22CErV2gvJRKcxd/Bj
         rIvLA+VkZNpPRnlLUTIEsV/PlYEKIGOlIhZIUP3MBQ2vYt7AjaOTR90eCJKgGfEx3VkS
         LBFDFLbG02BvXQxDr6gp1GWZfMLZCsNwYM9jPRtQ4s+hJwCwBIKXJuGk5Oxm3ti7xwD3
         nBJhv+1fKHAOUytEruKO9kvx4NMrBepjRLUU5GBOn7KaJgnkQSzl1n/vf64DEK3fqNKs
         M1UA==
X-Google-Smtp-Source: APXvYqya60Kq55uGra+BVlxGzHEw6mm4ntwjQ+Ryeh+DdqnFhJIqgXVA4baUPQVnD5FBK8GEVLMgnQ==
X-Received: by 2002:a2e:5d56:: with SMTP id r83mr46839339ljb.74.1555490195243;
        Wed, 17 Apr 2019 01:36:35 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id l13sm7773830ljj.96.2019.04.17.01.36.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:36:34 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:36:33 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Krzysztof Kozlowski
 <k.kozlowski@samsung.com>
Subject: [PATCHV2 1/4] z3fold: introduce helper functions
Message-Id: <20190417103633.a4bb770b5bf0fb7e43ce1666@gmail.com>
In-Reply-To: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
References: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduces a separate helper function for object
allocation, as well as 2 smaller helpers to add a buddy to the list
and to get a pointer to the pool from the z3fold header. No
functional changes here.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 184 ++++++++++++++++++++++++++++------------------------
 1 file changed, 100 insertions(+), 84 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index aee9b0b8d907..7a59875d880c 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -255,10 +255,15 @@ static enum buddy handle_to_buddy(unsigned long handle)
 	return (handle - zhdr->first_num) & BUDDY_MASK;
 }
 
+static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
+{
+	return zhdr->pool;
+}
+
 static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 {
 	struct page *page = virt_to_page(zhdr);
-	struct z3fold_pool *pool = zhdr->pool;
+	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
 
 	WARN_ON(!list_empty(&zhdr->buddy));
 	set_bit(PAGE_STALE, &page->private);
@@ -295,9 +300,10 @@ static void release_z3fold_page_locked_list(struct kref *ref)
 {
 	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
 					       refcount);
-	spin_lock(&zhdr->pool->lock);
+	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	spin_lock(&pool->lock);
 	list_del_init(&zhdr->buddy);
-	spin_unlock(&zhdr->pool->lock);
+	spin_unlock(&pool->lock);
 
 	WARN_ON(z3fold_page_trylock(zhdr));
 	__release_z3fold_page(zhdr, true);
@@ -349,6 +355,23 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	return nfree;
 }
 
+/* Add to the appropriate unbuddied list */
+static inline void add_to_unbuddied(struct z3fold_pool *pool,
+				struct z3fold_header *zhdr)
+{
+	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
+			zhdr->middle_chunks == 0) {
+		struct list_head *unbuddied = get_cpu_ptr(pool->unbuddied);
+
+		int freechunks = num_free_chunks(zhdr);
+		spin_lock(&pool->lock);
+		list_add(&zhdr->buddy, &unbuddied[freechunks]);
+		spin_unlock(&pool->lock);
+		zhdr->cpu = smp_processor_id();
+		put_cpu_ptr(pool->unbuddied);
+	}
+}
+
 static inline void *mchunk_memmove(struct z3fold_header *zhdr,
 				unsigned short dst_chunk)
 {
@@ -406,10 +429,8 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 
 static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 {
-	struct z3fold_pool *pool = zhdr->pool;
+	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
 	struct page *page;
-	struct list_head *unbuddied;
-	int fchunks;
 
 	page = virt_to_page(zhdr);
 	if (locked)
@@ -430,18 +451,7 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 	}
 
 	z3fold_compact_page(zhdr);
-	unbuddied = get_cpu_ptr(pool->unbuddied);
-	fchunks = num_free_chunks(zhdr);
-	if (fchunks < NCHUNKS &&
-	    (!zhdr->first_chunks || !zhdr->middle_chunks ||
-			!zhdr->last_chunks)) {
-		/* the page's not completely free and it's unbuddied */
-		spin_lock(&pool->lock);
-		list_add(&zhdr->buddy, &unbuddied[fchunks]);
-		spin_unlock(&pool->lock);
-		zhdr->cpu = smp_processor_id();
-	}
-	put_cpu_ptr(pool->unbuddied);
+	add_to_unbuddied(pool, zhdr);
 	z3fold_page_unlock(zhdr);
 }
 
@@ -453,6 +463,67 @@ static void compact_page_work(struct work_struct *w)
 	do_compact_page(zhdr, false);
 }
 
+/* returns _locked_ z3fold page header or NULL */
+static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
+						size_t size, bool can_sleep)
+{
+	struct z3fold_header *zhdr = NULL;
+	struct page *page;
+	struct list_head *unbuddied;
+	int chunks = size_to_chunks(size), i;
+
+lookup:
+	/* First, try to find an unbuddied z3fold page. */
+	unbuddied = get_cpu_ptr(pool->unbuddied);
+	for_each_unbuddied_list(i, chunks) {
+		struct list_head *l = &unbuddied[i];
+
+		zhdr = list_first_entry_or_null(READ_ONCE(l),
+					struct z3fold_header, buddy);
+
+		if (!zhdr)
+			continue;
+
+		/* Re-check under lock. */
+		spin_lock(&pool->lock);
+		l = &unbuddied[i];
+		if (unlikely(zhdr != list_first_entry(READ_ONCE(l),
+						struct z3fold_header, buddy)) ||
+		    !z3fold_page_trylock(zhdr)) {
+			spin_unlock(&pool->lock);
+			zhdr = NULL;
+			put_cpu_ptr(pool->unbuddied);
+			if (can_sleep)
+				cond_resched();
+			goto lookup;
+		}
+		list_del_init(&zhdr->buddy);
+		zhdr->cpu = -1;
+		spin_unlock(&pool->lock);
+
+		page = virt_to_page(zhdr);
+		if (test_bit(NEEDS_COMPACTING, &page->private)) {
+			z3fold_page_unlock(zhdr);
+			zhdr = NULL;
+			put_cpu_ptr(pool->unbuddied);
+			if (can_sleep)
+				cond_resched();
+			goto lookup;
+		}
+
+		/*
+		 * this page could not be removed from its unbuddied
+		 * list while pool lock was held, and then we've taken
+		 * page lock so kref_put could not be called before
+		 * we got here, so it's safe to just call kref_get()
+		 */
+		kref_get(&zhdr->refcount);
+		break;
+	}
+	put_cpu_ptr(pool->unbuddied);
+
+	return zhdr;
+}
 
 /*
  * API Functions
@@ -546,7 +617,7 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
 static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			unsigned long *handle)
 {
-	int chunks = 0, i, freechunks;
+	int chunks = size_to_chunks(size);
 	struct z3fold_header *zhdr = NULL;
 	struct page *page = NULL;
 	enum buddy bud;
@@ -561,56 +632,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
 		bud = HEADLESS;
 	else {
-		struct list_head *unbuddied;
-		chunks = size_to_chunks(size);
-
-lookup:
-		/* First, try to find an unbuddied z3fold page. */
-		unbuddied = get_cpu_ptr(pool->unbuddied);
-		for_each_unbuddied_list(i, chunks) {
-			struct list_head *l = &unbuddied[i];
-
-			zhdr = list_first_entry_or_null(READ_ONCE(l),
-						struct z3fold_header, buddy);
-
-			if (!zhdr)
-				continue;
-
-			/* Re-check under lock. */
-			spin_lock(&pool->lock);
-			l = &unbuddied[i];
-			if (unlikely(zhdr != list_first_entry(READ_ONCE(l),
-					struct z3fold_header, buddy)) ||
-			    !z3fold_page_trylock(zhdr)) {
-				spin_unlock(&pool->lock);
-				put_cpu_ptr(pool->unbuddied);
-				goto lookup;
-			}
-			list_del_init(&zhdr->buddy);
-			zhdr->cpu = -1;
-			spin_unlock(&pool->lock);
-
-			page = virt_to_page(zhdr);
-			if (test_bit(NEEDS_COMPACTING, &page->private)) {
-				z3fold_page_unlock(zhdr);
-				zhdr = NULL;
-				put_cpu_ptr(pool->unbuddied);
-				if (can_sleep)
-					cond_resched();
-				goto lookup;
-			}
-
-			/*
-			 * this page could not be removed from its unbuddied
-			 * list while pool lock was held, and then we've taken
-			 * page lock so kref_put could not be called before
-			 * we got here, so it's safe to just call kref_get()
-			 */
-			kref_get(&zhdr->refcount);
-			break;
-		}
-		put_cpu_ptr(pool->unbuddied);
-
+retry:
+		zhdr = __z3fold_alloc(pool, size, can_sleep);
 		if (zhdr) {
 			if (zhdr->first_chunks == 0) {
 				if (zhdr->middle_chunks != 0 &&
@@ -630,8 +653,9 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 					z3fold_page_unlock(zhdr);
 				pr_err("No free chunks in unbuddied\n");
 				WARN_ON(1);
-				goto lookup;
+				goto retry;
 			}
+			page = virt_to_page(zhdr);
 			goto found;
 		}
 		bud = FIRST;
@@ -662,8 +686,12 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 
-	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page, pool);
+	if (!zhdr) {
+		__free_page(page);
+		return -ENOMEM;
+	}
+	atomic64_inc(&pool->pages_nr);
 
 	if (bud == HEADLESS) {
 		set_bit(PAGE_HEADLESS, &page->private);
@@ -680,19 +708,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->middle_chunks = chunks;
 		zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
 	}
-
-	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
-			zhdr->middle_chunks == 0) {
-		struct list_head *unbuddied = get_cpu_ptr(pool->unbuddied);
-
-		/* Add to unbuddied list */
-		freechunks = num_free_chunks(zhdr);
-		spin_lock(&pool->lock);
-		list_add(&zhdr->buddy, &unbuddied[freechunks]);
-		spin_unlock(&pool->lock);
-		zhdr->cpu = smp_processor_id();
-		put_cpu_ptr(pool->unbuddied);
-	}
+	add_to_unbuddied(pool, zhdr);
 
 headless:
 	spin_lock(&pool->lock);
-- 
2.17.1

