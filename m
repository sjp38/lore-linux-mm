Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A044DC48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DB2A2080C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CDW3O1rc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DB2A2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F15A98E0008; Thu, 27 Jun 2019 05:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E77168E0002; Thu, 27 Jun 2019 05:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8C1B8E0008; Thu, 27 Jun 2019 05:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1F738E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:17 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id a185so527328vkb.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=oH7fG20ofuChwybQZlZvB4s9y/2FFyk/2/68TRC/+KsyuE+fKFPnBEEWlxLFDeyBwp
         NKlrHir6S/WN26bysM+jbE4VJ5xYpkAw8GQNB+NsnkQ1tNDOAaVPR9jFlONRHb8Ts+mN
         u/WQEMQ7ulWFO0IuJb7PJaxOGCD6zxC0uuLTvOD0YzSPUTf/qbzm3odhhCZG1GoRcnad
         KzwAHbyChczSWuQQ/Vuzy6nMlfldfLcna4ON3ovDivnTDNoHx4z0d//tTMMt6L9AJhaY
         ORVpGZK28s/fP9otcy14v1tGUzofMOXXHr3IBm7JGFbdL9X9K/owWOnwgzXmO+tvy3D2
         oVYg==
X-Gm-Message-State: APjAAAXaarZEEtvjZ2q+XsdVnew1BoihOAumxAklwNmS1d4nO25UlUnW
	7fOfr83gvWZcrlAm99QvBJQgM5eXPAHG1iLP4Nts4BZ3eT2jHcxWF3ltDO2ZHqOAExX8C22jHak
	UG02Chk3UOimhySIwCPRYpUdwpTc3o+AIEsmk3/xt5zNLrnGkSF95IxmietX5qiQykQ==
X-Received: by 2002:a05:6102:db:: with SMTP id u27mr1968073vsp.83.1561628717447;
        Thu, 27 Jun 2019 02:45:17 -0700 (PDT)
X-Received: by 2002:a05:6102:db:: with SMTP id u27mr1968048vsp.83.1561628716862;
        Thu, 27 Jun 2019 02:45:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628716; cv=none;
        d=google.com; s=arc-20160816;
        b=jssQXOiuSDYJVhsulPDQ8QrynMdiVIvKIOXktMkZWN5MLlQ4Pf++0mRN2OqFrWPR5W
         l431PuL//pOyXT5mQpJyIv8W4aNzkM6LT/LWMbhN7b+cozhQlR65vhAs/Bb5cmGUCd4Q
         +2nSw/M3iTRhXu2BAxQdcs2qa1fT3IBMnZepSGue4Nso7L6lVRnjB6smT7h3UcDiiBpD
         3LYSN5FoaQIdGOpccTjk/F0zxZDYtc6CKSwNtGlMfefeKbiI+JirvsuXgl4psBtohEqp
         xfixOARll3DcQf87buFPVAw9eXDn4TcOaHqpWwsgIqc6Ky6TxI2+byjsvnQwJ2Tt8QRD
         R3Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=K5w+unD7T0pVrenV0LNGvkucdLY95LFv4UdZ3tsN9Gog5ObO4OKObmsFZmRfQXXcY0
         ohoYaE1B5kZnX4rsS74Jfk38T8vJeQW+qhs5/r08EvbJMk5O9wU+g2te7fwYaUXK8dDn
         c2/pVg5/0gSTygfVF1IGm/9n9RT8yfJ+s/7nZsX+1AAIZ89NxdpV+PbK9c2nyp7uXd0e
         aguNmOZvbZpu7c6+veXs1pl2FmgJY4p7e/xaYKc9hqB4rT0q/qJ+iUMFRZ9x7tMjevzV
         cyirgYb3JVET0oI/HJSWad4jtzNoDCwYyGOb4/oi8cq6KvMbeeb1BdL9oB9yxg+cfG4R
         Lyqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CDW3O1rc;
       spf=pass (google.com: domain of 3ljauxqukci0v2cv8x55x2v.t532z4be-331crt1.58x@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LJAUXQUKCI0v2Cv8x55x2v.t532z4BE-331Crt1.58x@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o20sor804545ual.12.2019.06.27.02.45.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ljauxqukci0v2cv8x55x2v.t532z4be-331crt1.58x@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CDW3O1rc;
       spf=pass (google.com: domain of 3ljauxqukci0v2cv8x55x2v.t532z4be-331crt1.58x@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LJAUXQUKCI0v2Cv8x55x2v.t532z4BE-331Crt1.58x@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=CDW3O1rcoY4KC5X8v7CnZfCBKNlszgPAXmMim6QnSJLHB2FvypgwfFeyxvZwkjshAT
         NYkIEFDnXYo2OPrAB+NZMN0XeufHpI0aArN8OIWcXgxUUxzyt/As39iSabbDecmCok66
         1GlpOjUwOjx08OQTiJC84NV+xWtQvHLk4cK56xLxJn/7JhxyywvnurM2xkT4zpajSVQ9
         Xk4ZCLJmrlDDuokgNuAOAy3SHbdqSr0OAmgr3uIGV9MOFUFqTuwZZ4wk91clhD4nRKVT
         zIWom/rDBuJizXsYze+NXDx0nRqZZNjw6aRE9+/DLvq0WZwPqSmzvUKmog18ZmwAnJGq
         juwg==
X-Google-Smtp-Source: APXvYqwn/gtVJbLpqQl+FnIy4IdAkHfEQzBvpEllKgR3L5YlFzAi8dr/fNtBE4bKwcMfpZhNOB3+p2DymQ==
X-Received: by 2002:ab0:184e:: with SMTP id j14mr1746917uag.91.1561628716321;
 Thu, 27 Jun 2019 02:45:16 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:44 +0200
In-Reply-To: <20190627094445.216365-1-elver@google.com>
Message-Id: <20190627094445.216365-5-elver@google.com>
Mime-Version: 1.0
References: <20190627094445.216365-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 4/5] mm/slab: Refactor common ksize KASAN logic into slab_common.c
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
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
Cc: Mark Rutland <mark.rutland@arm.com>
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

