Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C90FC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C590520820
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vosRPmYO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C590520820
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DF0C6B0003; Mon, 24 Jun 2019 07:06:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18EC38E0003; Mon, 24 Jun 2019 07:06:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0884B8E0002; Mon, 24 Jun 2019 07:06:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAF5D6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:06:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so16574484qti.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:06:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=PHd5TU1tSErJuln8CLwgi6IjxpHufjIY0VZFaXkHGNk=;
        b=gRToF/LuPxDeeIQcTqgGRjIQ+gGwg1n22P9stzEgGF5mQmfhvFqaGrHSSAOITeSJzE
         NnQRTcicayUCdpMHEEML1FxpFebA66ORGDoz/cTsd34OzpY5yB4D1hIaPjYW9tfwatH+
         oDiMcMWEgZAaYNkTcVeEjasYpj/Th+6RVLx53xvA/p/Sq731A5i5MKoyn7OntI/CmORW
         OiBUdNCZNghp798Cw2JtPo9WLbuwio1XmycuQakO/mU1qAM3Zprva7p1fLw4YFcr+hP5
         xT7iUzJqoKKxek9wmG5LIJxWYC4JRSSvjFz9JAYE92MWNCiw2Mh8k6In9WNJEf+u2EQ2
         oNdA==
X-Gm-Message-State: APjAAAWGEdgqnOTVsrILfvKotqrEYVlD7SUzf75xW8PDKiMnZiGH64CR
	WL36MwGfZgU7IFAGeK1CTh3zs4thk9ye5RJM9/RKiclsSltp1b5dBPig8BTPrBdBaAxMLgAXZ8d
	rOu8lhgfwQMAKxQl0klR9ML6YzFIkiGYP2djErxmwwQEahvgwQQFy3e/pL1uYG5ewjA==
X-Received: by 2002:ac8:5458:: with SMTP id d24mr88163480qtq.329.1561374360597;
        Mon, 24 Jun 2019 04:06:00 -0700 (PDT)
X-Received: by 2002:ac8:5458:: with SMTP id d24mr88163409qtq.329.1561374359700;
        Mon, 24 Jun 2019 04:05:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561374359; cv=none;
        d=google.com; s=arc-20160816;
        b=1CMtEmDk07r59L4shtn4R/2jnh7sq/hVA5iuJ2EJjDs0FzwioK31K6cASaz6ILpP75
         fV7kI9zgUV/dJ9OmDk5mKAEeBfQsIqmegd74fwA6fnLIYJo3LUl3dQ+/cl0mm4nVcEom
         nRgMOwT8KthU87kh9IeRL7mHCcu8LdQZicFEcGYAdPzPMCzYZ+gTA+QdEdAeuSgM7AYt
         EqKvBcWqkJUczZ48HU6qJqytjfDhbEunmhg9JSOmerZrCbpHaFuidgeZT6oCRz0satgJ
         DuVaPAN44uD0SSRWAE+9QrQPAMPFcXwexsxB/2tuVdjzq2LFpGoWHVMdRSF2BWs91FQe
         MjoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=PHd5TU1tSErJuln8CLwgi6IjxpHufjIY0VZFaXkHGNk=;
        b=hMIPIIn4eEOgy00RI11JbESBkXlZfTkiyJB+egpEi4LvoLtOt24CLgFon4ehYepA2t
         p7Nc5qhMvtRrXyGNF6ubhd0LVV0zKDM2LMFlgUwfVErpfJPSvQJSZqgYdjA7Xhpb0U09
         mGHz3AlwZFV2FvmsqUnt5KY/6ARGKcBSWaR1FuHz5mo7ZjkLq/tFcroAfn2QVHqUlIhA
         aTjgqoVINhMKYz44/H8SDmknpzUmyglhd5CUkXIXDDDgGx9cFZ48sFbIk6n5g1wCsqH2
         6HCr040b+pS/vGjgVTQp/lQ4i7TxEH+fDfyAUzdpnPcbvi0NG44iECSq32/iOVja6MnV
         oWPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vosRPmYO;
       spf=pass (google.com: domain of 3l64qxqukccygnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3l64QXQUKCCYGNXGTIQQING.EQONKPWZ-OOMXCEM.QTI@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d78sor5966633qkc.198.2019.06.24.04.05.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 04:05:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3l64qxqukccygnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vosRPmYO;
       spf=pass (google.com: domain of 3l64qxqukccygnxgtiqqing.eqonkpwz-oomxcem.qti@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3l64QXQUKCCYGNXGTIQQING.EQONKPWZ-OOMXCEM.QTI@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=PHd5TU1tSErJuln8CLwgi6IjxpHufjIY0VZFaXkHGNk=;
        b=vosRPmYOoKEVRZZMh5n78maBJpGu9JU/xpF6TD3FlIpepWnIPkIDSseYdS/kli9c23
         En9IpdwouPvux+1HD/GtnHn7igk+wht09bMoFi38Fhk1GIyCePRSO09mvSYfIymVD0px
         lHIi558uyfcZIkRjsy4NiWcehmrN9cfFF1+IP/yEA4gbnw4S8rAYxTN2dufQdWS4+P8l
         uCCQIqe0HQa1cCK9pnMMWmOlhAZ7uQcMBXA7GWVQUITkc71GUeJprSIEW4sS7Z2dnDk3
         Qw7KiZFFuR9bquQZBhJMbB7FrA9VsuY8rrNpWoYcqhryopYvpFLFmA9a+2OU9yAPvTUq
         4Pag==
X-Google-Smtp-Source: APXvYqzed8xxggaQRg/+ic0BLsdTYDC0epTsxdulJgxPeeCwXFWeEbWlaqpgELg0b+3ya6R95iIR3lAqAQ==
X-Received: by 2002:a37:805:: with SMTP id 5mr15123706qki.385.1561374359272;
 Mon, 24 Jun 2019 04:05:59 -0700 (PDT)
Date: Mon, 24 Jun 2019 13:05:32 +0200
Message-Id: <20190624110532.41065-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm/kasan: Add shadow memory validation in ksize()
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

ksize() has been unconditionally unpoisoning the whole shadow memory region
associated with an allocation. This can lead to various undetected bugs,
for example, double-kzfree().

kzfree() uses ksize() to determine the actual allocation size, and
subsequently zeroes the memory. Since ksize() used to just unpoison the
whole shadow memory region, no invalid free was detected.

This patch addresses this as follows:

1. For each SLAB and SLUB allocators: add a check in ksize() that the
   pointed to object's shadow memory is valid, and only then unpoison
   the memory region.

2. Update kasan_unpoison_slab() to explicitly unpoison the shadow memory
   region using the size obtained from ksize(); it is possible that
   double-unpoison can occur if the shadow was already valid, however,
   this should not be the general case.

Tested:
1. With SLAB allocator: a) normal boot without warnings; b) verified the
   added double-kzfree() is detected.
2. With SLUB allocator: a) normal boot without warnings; b) verified the
   added double-kzfree() is detected.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=199359
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
 include/linux/kasan.h | 20 +++++++++++++++++++-
 lib/test_kasan.c      | 17 +++++++++++++++++
 mm/kasan/common.c     | 15 ++++++++++++---
 mm/slab.c             | 12 ++++++++----
 mm/slub.c             | 11 +++++++----
 5 files changed, 63 insertions(+), 12 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b40ea104dd36..9778a68fb5cf 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -63,6 +63,14 @@ void * __must_check kasan_krealloc(const void *object, size_t new_size,
 
 void * __must_check kasan_slab_alloc(struct kmem_cache *s, void *object,
 					gfp_t flags);
+
+/**
+ * kasan_shadow_invalid - Check if shadow memory of object is invalid.
+ * @object: The pointed to object; the object pointer may be tagged.
+ * @return: true if shadow is invalid, false if valid.
+ */
+bool kasan_shadow_invalid(const void *object);
+
 bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long ip);
 
 struct kasan_cache {
@@ -77,7 +85,11 @@ int kasan_add_zero_shadow(void *start, unsigned long size);
 void kasan_remove_zero_shadow(void *start, unsigned long size);
 
 size_t ksize(const void *);
-static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
+static inline void kasan_unpoison_slab(const void *ptr)
+{
+	/* Force unpoison: ksize() only unpoisons if shadow of ptr is valid. */
+	kasan_unpoison_shadow(ptr, ksize(ptr));
+}
 size_t kasan_metadata_size(struct kmem_cache *cache);
 
 bool kasan_save_enable_multi_shot(void);
@@ -133,6 +145,12 @@ static inline void *kasan_slab_alloc(struct kmem_cache *s, void *object,
 {
 	return object;
 }
+
+static inline bool kasan_shadow_invalid(const void *object)
+{
+	return false;
+}
+
 static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
 				   unsigned long ip)
 {
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 7de2702621dc..9b710bfa84da 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -623,6 +623,22 @@ static noinline void __init kasan_strings(void)
 	strnlen(ptr, 1);
 }
 
+static noinline void __init kmalloc_pagealloc_double_kzfree(void)
+{
+	char *ptr;
+	size_t size = 16;
+
+	pr_info("kmalloc pagealloc allocation: double-free (kzfree)\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kzfree(ptr);
+	kzfree(ptr);
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -664,6 +680,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_memchr();
 	kasan_memcmp();
 	kasan_strings();
+	kmalloc_pagealloc_double_kzfree();
 
 	kasan_restore_multi_shot(multishot);
 
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 242fdc01aaa9..357e02e73163 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -413,10 +413,20 @@ static inline bool shadow_invalid(u8 tag, s8 shadow_byte)
 		return tag != (u8)shadow_byte;
 }
 
+bool kasan_shadow_invalid(const void *object)
+{
+	u8 tag = get_tag(object);
+	s8 shadow_byte;
+
+	object = reset_tag(object);
+
+	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
+	return shadow_invalid(tag, shadow_byte);
+}
+
 static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 			      unsigned long ip, bool quarantine)
 {
-	s8 shadow_byte;
 	u8 tag;
 	void *tagged_object;
 	unsigned long rounded_up_size;
@@ -435,8 +445,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return false;
 
-	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
-	if (shadow_invalid(tag, shadow_byte)) {
+	if (kasan_shadow_invalid(tagged_object)) {
 		kasan_report_invalid_free(tagged_object, ip);
 		return true;
 	}
diff --git a/mm/slab.c b/mm/slab.c
index f7117ad9b3a3..3595348c401b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4226,10 +4226,14 @@ size_t ksize(const void *objp)
 		return 0;
 
 	size = virt_to_cache(objp)->object_size;
-	/* We assume that ksize callers could use the whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(objp, size);
+
+	if (!kasan_shadow_invalid(objp)) {
+		/*
+		 * We assume that ksize callers could use the whole allocated
+		 * area, so we need to unpoison this area.
+		 */
+		kasan_unpoison_shadow(objp, size);
+	}
 
 	return size;
 }
diff --git a/mm/slub.c b/mm/slub.c
index cd04dbd2b5d0..28231d30358e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3921,10 +3921,13 @@ static size_t __ksize(const void *object)
 size_t ksize(const void *object)
 {
 	size_t size = __ksize(object);
-	/* We assume that ksize callers could use whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(object, size);
+	if (!kasan_shadow_invalid(object)) {
+		/*
+		 * We assume that ksize callers could use whole allocated area,
+		 * so we need to unpoison this area.
+		 */
+		kasan_unpoison_shadow(object, size);
+	}
 	return size;
 }
 EXPORT_SYMBOL(ksize);
-- 
2.22.0.410.gd8fdbe21b5-goog

