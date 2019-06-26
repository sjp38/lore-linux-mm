Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F554C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAACE20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WjjQYoJW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAACE20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5682F8E0008; Wed, 26 Jun 2019 08:23:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 518C88E0002; Wed, 26 Jun 2019 08:23:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E18F8E0008; Wed, 26 Jun 2019 08:23:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D04D8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:23:23 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id j186so409623vsc.11
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:23:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=kb82UguIVlhbKp5QqiDOlo6WFZGIh55p/2yvAOGPdkY=;
        b=VLx9s27Pd0BK5WJ3SgTQv/9ilxJyyoSPVYvycHJL0mVVVJWsB/H75glX3ay587zzQ9
         afYIQVDcHVv2kulzroa/1Rr2W9blakzHSKLfHm1WVmVjzGuIYDXKxI7ahFLZR6x37yX0
         6oBqtx6yWDswfNHrs3OUZjw7HXkatn9auWsojdJep+4SPM0S41D77yLVq5DiCdjNLCpx
         TgYhPFE++cpNHUPuoyKnSWyCVwluNBDLqDtntQ+WakJip6TqGj9xLCKPqkTikm7HEyiJ
         y0rd96QShhOnh/uw0QW+wzFyXkfdz5shbyoSAxvLTfOON1zlX5VoFB/T1VN9MPVzY9av
         p6/g==
X-Gm-Message-State: APjAAAXs1ebd138NLX+5shlWpqnr6emzFNCIewkJWGfF4C3++t9QJP3v
	c34/nL5OR7sdG6GRJMPF9SyzRbmQVccrDUhqXCnanYV1TH6UMQkluifMQoaeBRlrss1Y3nPioI0
	2HaM3PAIy4nm9OY5JAUA8QvXIdDYyZJaCqZnBiW8wLsq1g6sSE4FwPUAzcbsCJoPTyw==
X-Received: by 2002:a67:7d13:: with SMTP id y19mr2747343vsc.232.1561551802710;
        Wed, 26 Jun 2019 05:23:22 -0700 (PDT)
X-Received: by 2002:a67:7d13:: with SMTP id y19mr2747312vsc.232.1561551802148;
        Wed, 26 Jun 2019 05:23:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551802; cv=none;
        d=google.com; s=arc-20160816;
        b=BLt0fcydNP97rgwr3DOcMSirqAcDtgL8YIZ9QdJ/CYv92SdHhzR0qm1nDpalD+Kh2j
         Ql7Hp8vKq5F6wwpEjRemltcNurq+zpPyAdHlPQSP9UyDnK7goRhnVLAU+8YlPqA9EMeZ
         R992BZSur+YJu3lnSp5yQpvzpAjwPQcJV3/HnxLRdd7bXJP63iona2EEL0PF6u54wLPX
         YNrkiFaay73EpqjY9GruQQTP0uf7ODQsC6UV1S8rVHJ9z3SJ2sPi+e25XZOcdh6y5/Ud
         ZX1rxLKe9x19og6XKjTgMrWhxm5S7u4aGzqvtnWQ7DDSkjd9oFqhLAHW0ndgrFg9Cq0j
         IoWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=kb82UguIVlhbKp5QqiDOlo6WFZGIh55p/2yvAOGPdkY=;
        b=av9W3zNmTu7Y96Qk2KyoyP0FQLLZJhpur3/P0OP8HMblmAKgbIbUh4a0LpZ4SSAFIE
         0W3vVvUUJ4LAgeCoQkcZAITErka6Iar4ixUlutXc5z96s+yhHYzKwPNqwNVifCKmLaOX
         bYgadyhlbn3GQ+o6s1/SaYVOxPk1lbiWUJl5ubXiLPxGwouYLn2td7S39bCKtyuJq0r+
         XKDwCQS4VQspcQS9AiIQXHlpgOF9Y55jOJMlxU4j+Hw400hNOzkvrTzoM1yaam24iufk
         2CsMHgK4mWu+e/eR04IdU5VXP0r9mhXiMlrzb0s9WEYUMvlah5kuaLrXB4qqrzyNNQC6
         DaOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WjjQYoJW;
       spf=pass (google.com: domain of 3uwmtxqukclwgnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uWMTXQUKCLwgnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f3sor9212040vsj.65.2019.06.26.05.23.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:23:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uwmtxqukclwgnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WjjQYoJW;
       spf=pass (google.com: domain of 3uwmtxqukclwgnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uWMTXQUKCLwgnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=kb82UguIVlhbKp5QqiDOlo6WFZGIh55p/2yvAOGPdkY=;
        b=WjjQYoJWiOmPv33Bic0W0y++ZuZxKevS4PRnsDAXFP8G47Wf6XnYegtUuf/80uBNWA
         A1gHpD+sg5TIHX/kp83aZObf/5z20091//S7ZBttJaGHsFfYXoITFJ5crbnl52Cl7taN
         HS/4rK2VgTFgQSW0pYKI8dD6wOBVYQG/1gUIrSCOXKRdXrT2eDHOm2TnUmEjxVX1Bt/L
         /iGFzuT5b21+vBbEOctuwelfg2prpD5QY0fFEoVkS0iRK0wK2GhvgC7N4aVxSNnJT/0o
         9KZ8sdg0JXjq04ZwR89bVN9iaoKBITJLBzoiMdOFDVSaxu4PqzodcfDwzntLAWh6vDYO
         rAQg==
X-Google-Smtp-Source: APXvYqyuVTkGLueWtiLfl1GW263+k4hhKtcADqRo9YvGS0HFR4ngSZ+4HGwSUbtAwlCHZIi3qN18GcRGgw==
X-Received: by 2002:a67:f2d3:: with SMTP id a19mr2676462vsn.240.1561551801607;
 Wed, 26 Jun 2019 05:23:21 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:20:18 +0200
In-Reply-To: <20190626122018.171606-1-elver@google.com>
Message-Id: <20190626122018.171606-4-elver@google.com>
Mime-Version: 1.0
References: <20190626122018.171606-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 3/4] mm/slab: Refactor common ksize KASAN logic into slab_common.c
From: Marco Elver <elver@google.com>
To: aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com, 
	andreyknvl@google.com
Cc: linux-kernel@vger.kernel.org, Marco Elver <elver@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This refactors common code of ksize() between the various allocators
into slab_common.c: __ksize() is the allocator-specific implementation
without instrumentation, whereas ksize() includes the required KASAN
logic.

Signed-off-by: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/slab.h |  1 +
 mm/slab.c            | 28 ++++++----------------------
 mm/slab_common.c     | 26 ++++++++++++++++++++++++++
 mm/slob.c            |  4 ++--
 mm/slub.c            | 14 ++------------
 5 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..98c3d12b7275 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -184,6 +184,7 @@ void * __must_check __krealloc(const void *, size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 void kzfree(const void *);
+size_t __ksize(const void *);
 size_t ksize(const void *);
 
 #ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
diff --git a/mm/slab.c b/mm/slab.c
index f7117ad9b3a3..394e7c7a285e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4204,33 +4204,17 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 #endif /* CONFIG_HARDENED_USERCOPY */
 
 /**
- * ksize - get the actual amount of memory allocated for a given object
- * @objp: Pointer to the object
+ * __ksize -- Uninstrumented ksize.
  *
- * kmalloc may internally round up allocations and return more memory
- * than requested. ksize() can be used to determine the actual amount of
- * memory allocated. The caller may use this additional memory, even though
- * a smaller amount of memory was initially specified with the kmalloc call.
- * The caller must guarantee that objp points to a valid object previously
- * allocated with either kmalloc() or kmem_cache_alloc(). The object
- * must not be freed during the duration of the call.
- *
- * Return: size of the actual memory used by @objp in bytes
+ * Unlike ksize(), __ksize() is uninstrumented, and does not provide the same
+ * safety checks as ksize() with KASAN instrumentation enabled.
  */
-size_t ksize(const void *objp)
+size_t __ksize(const void *objp)
 {
-	size_t size;
-
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	size = virt_to_cache(objp)->object_size;
-	/* We assume that ksize callers could use the whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(objp, size);
-
-	return size;
+	return virt_to_cache(objp)->object_size;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..b7c6a40e436a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1597,6 +1597,32 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+/**
+ * ksize - get the actual amount of memory allocated for a given object
+ * @objp: Pointer to the object
+ *
+ * kmalloc may internally round up allocations and return more memory
+ * than requested. ksize() can be used to determine the actual amount of
+ * memory allocated. The caller may use this additional memory, even though
+ * a smaller amount of memory was initially specified with the kmalloc call.
+ * The caller must guarantee that objp points to a valid object previously
+ * allocated with either kmalloc() or kmem_cache_alloc(). The object
+ * must not be freed during the duration of the call.
+ *
+ * Return: size of the actual memory used by @objp in bytes
+ */
+size_t ksize(const void *objp)
+{
+	size_t size = __ksize(objp);
+	/*
+	 * We assume that ksize callers could use whole allocated area,
+	 * so we need to unpoison this area.
+	 */
+	kasan_unpoison_shadow(objp, size);
+	return size;
+}
+EXPORT_SYMBOL(ksize);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
diff --git a/mm/slob.c b/mm/slob.c
index 84aefd9b91ee..7f421d0ca9ab 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -527,7 +527,7 @@ void kfree(const void *block)
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
-size_t ksize(const void *block)
+size_t __ksize(const void *block)
 {
 	struct page *sp;
 	int align;
@@ -545,7 +545,7 @@ size_t ksize(const void *block)
 	m = (unsigned int *)(block - align);
 	return SLOB_UNITS(*m) * SLOB_UNIT;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, slab_flags_t flags)
 {
diff --git a/mm/slub.c b/mm/slub.c
index cd04dbd2b5d0..05a8d17dd9b2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3901,7 +3901,7 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
-static size_t __ksize(const void *object)
+size_t __ksize(const void *object)
 {
 	struct page *page;
 
@@ -3917,17 +3917,7 @@ static size_t __ksize(const void *object)
 
 	return slab_ksize(page->slab_cache);
 }
-
-size_t ksize(const void *object)
-{
-	size_t size = __ksize(object);
-	/* We assume that ksize callers could use whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(object, size);
-	return size;
-}
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 void kfree(const void *x)
 {
-- 
2.22.0.410.gd8fdbe21b5-goog

