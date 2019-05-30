Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8C41C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9541A25D2B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="QxUyMepP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9541A25D2B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0286B0271; Thu, 30 May 2019 00:50:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23A006B0273; Thu, 30 May 2019 00:50:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B4076B0272; Thu, 30 May 2019 00:50:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3B086B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 00:50:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j26so1528150pgj.6
        for <linux-mm@kvack.org>; Wed, 29 May 2019 21:50:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=ro0eZo0iqlYxkBqPnVWAwPHhTLd6Yb2usUf2C4gK6mE=;
        b=qrGFTH1/lEt1ylpB2XPzVMjU6ir6HR32+gRTlGHhy+D4E9ab0naW4Vgo1by/y1OCuN
         MjY1mpsB6Z3KwyS1TGXjy6k1JvnpJXjncA2stplczbG+G3ReVml9Bcq5gDm+ri3FEGH/
         zYgcu89D0oFGyjuoxYvAKTsUjrTITNrpf4k0S68dHtpL0v4YWMwwapeL04l4fSxlMCnK
         N3y1DCDtVBdFbVECrb5B3RRWE26n6HmW9cWoYKqnLHLig8jDKWNSA7Eqjz66dYPBJ/wy
         SWo+nAWwuBKDWFNTedl0T622PZJ0YU4SyxeTDs83PzBshLVV+JKPK7NgwGQ3I43qL6CH
         BNwg==
X-Gm-Message-State: APjAAAXl6vlMgv55K4UPYB8DPV8PffXf3o4znAVWQsWp88uor/Y9tmND
	rARLvlt5xzMoFtZSUOR8Zooy8ot5W+6RxDWwJ21CeiMmjNdz/hyeLvJt0bIThBAJn4MQT/ZL+8h
	MhpzHMC59QZ5QZ0h1oWp7aBIEWPSQqwAltzNetIfHJ9j83yBqXUH9AfSqr9hfsrHsaA==
X-Received: by 2002:a63:2c50:: with SMTP id s77mr1953501pgs.175.1559191826360;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
X-Received: by 2002:a63:2c50:: with SMTP id s77mr1953464pgs.175.1559191825507;
        Wed, 29 May 2019 21:50:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559191825; cv=none;
        d=google.com; s=arc-20160816;
        b=GGy/M8XulyuwTjrfi4SdcCX8FGDS84yiSp2x7Dciws6Z3a6TKEONgyUghQRruhMKP1
         3t4zUL/JyWCpRvt8lciZc/Uy/6jgCMyp+X7AZPuiTkRu4kGegbmy2hCJlWFHmkjq+mGy
         GKbLgfL6kejknHgxsadIQyBTPoUiiNs3tLd1ymjc/0XX9o2+5/VgEz/YviYq0raLAIZy
         9K60w5ptWOCjb8/2nWZySr6TZdjIRsAcLOojDdQsIr53V0FrkLe5IqITEWI0zhVRNg8/
         WwkbEPok4YHuU4LZ9kEbQwmM+58kklc2OYN4GRKV9cjC5M9wJtykUuaTL+Ltfh9vADuh
         nHKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=ro0eZo0iqlYxkBqPnVWAwPHhTLd6Yb2usUf2C4gK6mE=;
        b=DJMBGCIqU6oIburBmELvhCEpO2yK7SycmSYlgtH6/9GQa9KNP1NszCzwifWJRji9vb
         YHkzJ0vRa3qGLpgJ0d0jLtAq1fRavh/pgPI4G7yQCNXjnZ2WJzCfvMzxzeD24XcYhf/N
         8l0LxcPjDdhX+9IyQZeLkS6O/pG7U0d0QcIn7NpCuaSfeRtVU+sFJuDV1wELxAQZaCs7
         K2tLyavoYR351gDBSwQmiD5vBFVzQkWxbuMGdkFgvVApZP5bNYih3Pd5vW6BmDDajsDj
         O0aBP6RIB0Y6h+TkBRwPt1ICZmsYojEURonpGozqoX9ZXLyfgLsHKdcFsHJCXErFxhvY
         HaSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QxUyMepP;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor1770913pgg.80.2019.05.29.21.50.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 21:50:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QxUyMepP;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=ro0eZo0iqlYxkBqPnVWAwPHhTLd6Yb2usUf2C4gK6mE=;
        b=QxUyMepPmuFlBPWIdyq+hDUvIJEUHMM8hSMqXOaU5d+qk1TA2YsVTjyuk0Nq3LDdod
         JjwD0ZGD8M+YE/Y6QaRqXLENweWTFQfFepMCtYGmzHPzsVLJQ2RWsJ21V8QjF5O2Mqix
         c+CfgfD3OKGNqSm1uCtBNhVSJThW/A2BIVKxQ=
X-Google-Smtp-Source: APXvYqx6yhz7sBMRnROF3lrt43atOsL36IzpXQDT7eajC7OfATKiWWEfU232CwKhSVYrVQa1CAtd9Q==
X-Received: by 2002:a63:3141:: with SMTP id x62mr2022883pgx.282.1559191825131;
        Wed, 29 May 2019 21:50:25 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id l141sm1451014pfd.24.2019.05.29.21.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 21:50:24 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Popov <alex.popov@linux.com>,
	Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 2/3] mm/slab: Sanity-check page type when looking up cache
Date: Wed, 29 May 2019 21:50:16 -0700
Message-Id: <20190530045017.15252-3-keescook@chromium.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190530045017.15252-1-keescook@chromium.org>
References: <20190530045017.15252-1-keescook@chromium.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This avoids any possible type confusion when looking up an object. For
example, if a non-slab were to be passed to kfree(), the invalid
slab_cache pointer (i.e. overlapped with some other value from the struct
page union) would be used for subsequent slab manipulations that could
lead to further memory corruption.

Since the page is already in cache, adding the PageSlab() check will
have nearly zero cost, so add a check and WARN() to virt_to_cache().
Additionally replaces an open-coded virt_to_cache(). To support the failure
mode this also updates all callers of virt_to_cache() and cache_from_obj()
to handle a NULL cache pointer return value (though note that several
already handle this case gracefully).

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.c | 14 +++++++-------
 mm/slab.h | 17 +++++++++++++----
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index f7117ad9b3a3..9e3eee5568b6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -371,12 +371,6 @@ static void **dbg_userword(struct kmem_cache *cachep, void *objp)
 static int slab_max_order = SLAB_MAX_ORDER_LO;
 static bool slab_max_order_set __initdata;
 
-static inline struct kmem_cache *virt_to_cache(const void *obj)
-{
-	struct page *page = virt_to_head_page(obj);
-	return page->slab_cache;
-}
-
 static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
 				 unsigned int idx)
 {
@@ -3715,6 +3709,8 @@ void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
 			s = virt_to_cache(objp);
 		else
 			s = cache_from_obj(orig_s, objp);
+		if (!s)
+			continue;
 
 		debug_check_no_locks_freed(objp, s->object_size);
 		if (!(s->flags & SLAB_DEBUG_OBJECTS))
@@ -3749,6 +3745,8 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
+	if (!c)
+		return;
 	debug_check_no_locks_freed(objp, c->object_size);
 
 	debug_check_no_obj_freed(objp, c->object_size);
@@ -4219,13 +4217,15 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
  */
 size_t ksize(const void *objp)
 {
+	struct kmem_cache *c;
 	size_t size;
 
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	size = virt_to_cache(objp)->object_size;
+	c = virt_to_cache(objp);
+	size = c ? c->object_size : 0;
 	/* We assume that ksize callers could use the whole allocated area,
 	 * so we need to unpoison this area.
 	 */
diff --git a/mm/slab.h b/mm/slab.h
index 4dafae2c8620..739099af6cbb 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -350,10 +350,20 @@ static inline void memcg_link_cache(struct kmem_cache *s)
 
 #endif /* CONFIG_MEMCG_KMEM */
 
+static inline struct kmem_cache *virt_to_cache(const void *obj)
+{
+	struct page *page;
+
+	page = virt_to_head_page(obj);
+	if (WARN_ONCE(!PageSlab(page), "%s: Object is not a Slab page!\n",
+					__func__))
+		return NULL;
+	return page->slab_cache;
+}
+
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
-	struct page *page;
 
 	/*
 	 * When kmemcg is not being used, both assignments should return the
@@ -367,9 +377,8 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	    !unlikely(s->flags & SLAB_CONSISTENCY_CHECKS))
 		return s;
 
-	page = virt_to_head_page(x);
-	cachep = page->slab_cache;
-	WARN_ONCE(!slab_equal_or_root(cachep, s),
+	cachep = virt_to_cache(x);
+	WARN_ONCE(cachep && !slab_equal_or_root(cachep, s),
 		  "%s: Wrong slab cache. %s but object is from %s\n",
 		  __func__, s->name, cachep->name);
 	return cachep;
-- 
2.17.1

