Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 347C5C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D255721670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="u/9U+nio"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D255721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 731CB8E0014; Wed, 26 Jun 2019 10:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6687E8E0002; Wed, 26 Jun 2019 10:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50BB48E0014; Wed, 26 Jun 2019 10:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9738E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:28:07 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id a29so242692uah.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:28:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=T1lUMGtWFiAZn1MYhUM0cKO/6yhm/rxR6box+5QA6XyFdCkjBlopvvJzf9rlmrggff
         SKSSRyFjrHaiOffU2daPpI/xwRxqmku3+yheQAIzDOx3avOBwddJO9dLxJIXXKmOV2JC
         38b3PAPjlqmO/5VXKfP0fG3KaUUqXfVJV8wrv8juMXvECFeZniN2iO1KhVCt272xXAFY
         U/JthH2qOqKLV6xhJ13iEJVZBGAvFcWZ6ifY4W8HVrN5iHbPcfM5e6mcS/xWEdUwZcNb
         dN1+e9YD+uMx1vrPv+rYA1OECSdQOjbEiQIp5Yg5fyKsfle8WxELqli8qSbkmXg8ucXb
         gKTA==
X-Gm-Message-State: APjAAAW0I4G0XGFyIw4h9hBiHRBVXfNk2xzCJhtQ4zM/2zruE+/TT1tu
	vk2NnxwZEQVszntRxWL4n1tNnmJpvsRrhB1Wz6dNr2Nj0Ty07BPB/yo1rWgyHjCcSBD9Y0kJ2zx
	+Wj0X9PxMcy6XJu9Y1nOo3RBMBQSvj3x2XwwjyxNhW+klgjHx3CZppBxnoEP2DpqRyQ==
X-Received: by 2002:a67:e9d9:: with SMTP id q25mr3090762vso.74.1561559286875;
        Wed, 26 Jun 2019 07:28:06 -0700 (PDT)
X-Received: by 2002:a67:e9d9:: with SMTP id q25mr3090725vso.74.1561559286272;
        Wed, 26 Jun 2019 07:28:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559286; cv=none;
        d=google.com; s=arc-20160816;
        b=D2THdBpV8CYu9TCZJypiItEk2UJ9pm5sNiXKr3fcJD/PFzXI5R3VTJxZoyZvsotPxl
         QsT+BALv6MplipfgR4bAVzVNOMQrLok9uyEKbvul7sFAhwCqc6YzPvX/Pc+rAk1e8dF3
         /vkLF1R2BYyW9p7AdE9TRWjYMS3vJtYa/ZwyWRy8bUQ8f10UFJ+cQSQT02MINwclAmDw
         NzafGc9B5CS+k+oQLGV519YTA6NyXGZkMfeTPZmPmdt7dFswL5rnLG7WLGFWANxGk68J
         vppgUnI25rpx2inlsn0/hVfxaN7wdRGusoNOn0VjqsuL9K9Up+ShLLapcTYoVxBo4Awi
         8r/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=i5KayI0oOCYIVUwCecfR1hdU9iRYjEJeVSn93QgB3b1ubNRurqCMngzjhU/nDEJdSh
         aeen/BImIdRqVcAz0pFgBU5qwYd9zDYXYx2zfMGP1Dmnt5qBqr1Ede0i82LJ7vanbsgQ
         r2XrpIu/hGMVYwh2E12QRiTRIU7i4MLIAzNhyxwkRvLhblrD2hw+ZsD5Av9WL1HrJMrX
         v/f7rvlKi1OUy0NCf/NZH5xEjy0UoPyaJvEFfPPV1kFidBeYLrkHLQSf5SLCbn23ejiO
         MYo4IIG+/M+4QZgfowiWxCA9VrdwcSoF+XxGOycN4cW/yOzKKdlBegivR06Y+pASFvy/
         SSsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u/9U+nio";
       spf=pass (google.com: domain of 39yatxqukcdqubluhweewbu.secbydkn-ccalqsa.ehw@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=39YATXQUKCDQUblUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l64sor5409218vkg.23.2019.06.26.07.28.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:28:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 39yatxqukcdqubluhweewbu.secbydkn-ccalqsa.ehw@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u/9U+nio";
       spf=pass (google.com: domain of 39yatxqukcdqubluhweewbu.secbydkn-ccalqsa.ehw@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=39YATXQUKCDQUblUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=u/9U+nio0GSQlTuwXQJYoLEcLF76o87YU8PcOckc4P78mxdxcX2UHm9EJLgXpLkXI5
         HQt7VNp7dkReXf/MW6OH7DXj8PZkvAKjLN1R9ZAJ3mJ/d13kIUhoP7HmTZrewr22chyt
         T309sesiuUjKxYHbwNl0ml81KCv75+HCSipQYmUn34aqKbM465NC1YTY0rRGd/fuqGH4
         l91CX114soALpbHKmRDF0xGDcGJfDc5o4imbC3mAOQPLzLPWoFHSWX8OvNtpv4uhs/3s
         7dkzwq+JudTY0lRiJUeHcINv/obrEvTfimyBai//ek9cE1vxy9hLCL9Uji+qwgilNtbz
         Hzqw==
X-Google-Smtp-Source: APXvYqztp05jq/iKevbZ1lrkTr3y4FJp0BJcho7hQ2605KOA4eSE2mE8lLNh3stpTm9Ss5/+9xiosgWh9w==
X-Received: by 2002:a1f:14c1:: with SMTP id 184mr1327869vku.69.1561559285813;
 Wed, 26 Jun 2019 07:28:05 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:13 +0200
In-Reply-To: <20190626142014.141844-1-elver@google.com>
Message-Id: <20190626142014.141844-5-elver@google.com>
Mime-Version: 1.0
References: <20190626142014.141844-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 4/5] mm/slab: Refactor common ksize KASAN logic into slab_common.c
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

