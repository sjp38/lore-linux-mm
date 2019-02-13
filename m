Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFECBC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80A6F222CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p4gWTZtr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80A6F222CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F2908E0007; Wed, 13 Feb 2019 08:58:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 530D38E0004; Wed, 13 Feb 2019 08:58:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32F018E0007; Wed, 13 Feb 2019 08:58:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D00878E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:43 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id o5so968602wmf.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S1MEkkxvqC9R885OkIU7HQfuqGvidJi6l2IAbLfaU7c=;
        b=iWhh3xjjWRt3fvxSam81l8902ISfuE/0f/hKOCstbSZJ6T75DAepIU5/RfpFZ9I7bd
         sRLPT08EzJkMTtkqNr6QmU6Srk1YlaaZGwC5SiBzyjln35MUQdP4OE4xaJMJYipdZqse
         cXmUHs/0l8EPHPZFa/D1WHGfMQmaN3HzzraNgZAmhHJib+xIXgeuRhf3dQ1EooJofjjb
         /6+lidcIajOMR4VMjQ1OTDjz28tT3+4jRtv06k60bk0nuDhQDZ/DsxXjxW2fNZCwdPOa
         ECmLY4sWclinitXbtKsIRVlPMjYer+wvksf6e3ZVnzW/c9m+pyYTTboXuU/cHE0TTsS0
         bDIg==
X-Gm-Message-State: AHQUAubDU9/3dGY36s4by/LydR/AXrDzFACEHOKICUzRHqeuxtlb3PHV
	FV47YojRFiExj1RfV3LqKr+BI/aXjcNvt6CbpPqsBWcczFPo44P5xG+KEofE5GXVmRNamIR+Nlv
	AuNe9R6LkG4Um7Y6mk42Gg5awSmuc8XK8PbLmshBrg83f8PuXjtQZIJc55fdLqIkTOmDoGcnnlW
	nUpCFkAJ9dMhnU0r6cloWCFkOLyJspsmnsaNrIhmaAa7wtizi7tpYwwU40DxXsO5jevhEqDLFuj
	lT+YeFXnHuqzyR00TazBSHkmHxLqhHfVLnFcakcUzXMT3QnUOIEh4NxS37znGOCrMo+V8rBD6NU
	VMdvwWb4kJo9qNdQLcODB75dJhpFzi2II0+PlzQ2Dt+2VtTb9KgmgfxsPd3whSKk/vMH83cyWEI
	R
X-Received: by 2002:a1c:4155:: with SMTP id o82mr427849wma.122.1550066323258;
        Wed, 13 Feb 2019 05:58:43 -0800 (PST)
X-Received: by 2002:a1c:4155:: with SMTP id o82mr427790wma.122.1550066322247;
        Wed, 13 Feb 2019 05:58:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066322; cv=none;
        d=google.com; s=arc-20160816;
        b=DzwqiRaAEaQBwBqmgsctK6qF6riDf34iblAxpcv1Em/sNft9itjbratPEXW+FBbJM+
         15A9G/VOQdUUOjSH8Se6frqhD24TnN5WqkhnEbHjSnggbGvYLQUST5f9sDyRnw16Yd4c
         qLWoFSkG2Q5POaNYqWDfk/FYdZkPbFLE4Edt+CRuROHoU9rMhEAwvHES5R3JtP8dfHfO
         emvqYc8nmyr65x937Y63Rc8Z484HnKgxcLOSwn1qip+vrGPa/a15XG5ki4Dj8f+klkoA
         36mCjHAS2yT28wFHkoNioJGvwrO+LE/ZQZwgipAlG61vsjTEBPv1FHO1oe0pqvJT+pv1
         MjZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=S1MEkkxvqC9R885OkIU7HQfuqGvidJi6l2IAbLfaU7c=;
        b=giy+WOqKbGtT/HZF8RvcD9UdvWBavaekhLzzRVBHXzyaPIP/EjyRoxfFtPDOo4nAQm
         bmWpiwzaShqUsvXunDuy+B4cTLX+4ev4V3uwj3fz6JWezCJX6XzHuwLqEXo5jKsGsm1Q
         Q4+9F8QKb5zJA9nCnsCZznUsgbVe1UeuyBdi+l9g2RZGbziFk7zU3BjIxHinSBXY3Hff
         K6WUINafI/DvY8fYb4LbUEN/B6Ck5gMgFmJeiaTmkRe8ImAhk871fcdWUEMEIXv2tFBU
         0SzGATV2AcCMlcdmOkx5uVSzSOAeXXpIXvgL3cj4rgMc15EZIfyoPLuxYjHnDJyL4NFs
         HMKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p4gWTZtr;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor3281783wmh.19.2019.02.13.05.58.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:42 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p4gWTZtr;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S1MEkkxvqC9R885OkIU7HQfuqGvidJi6l2IAbLfaU7c=;
        b=p4gWTZtrw9t1J2YewM74IoZolPi7VQOnG/RK8ZQZiZ/MwIJe/QojBdLDC0S26B8FQG
         sJ4Fc7OS2U+qrzDTtBlUkcxXKRCWNf1c5K/bS7z16u9lokG1ooOi7P77c7/vamnDG7Df
         2d918grgBusikS9jEYCuEuUdFT/Necs62nCZY3mg2ogWOz/b528vJ27LAPrsdjujFfzC
         S36qTciiQccAXgi+hQRaoQrYY5G/+zZLgQq10wBRmjFy+iVN02dNNsOk8FgKCjX97iFc
         cA1T6HSt+VFQ0dTj0xVahAedsFj4iI5IeV6B7tiQWfAl9TJtccR3FaUza3yCVly+NVX7
         V90A==
X-Google-Smtp-Source: AHgI3IaTRjRBOpfqDQyCSkM0FCxrdwo/Gj5shg1xg359f+Atts3bPUEzKs/gM3ivkCgMfSuFGNws2w==
X-Received: by 2002:a1c:cc01:: with SMTP id h1mr494171wmb.18.1550066321635;
        Wed, 13 Feb 2019 05:58:41 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:40 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 3/5] kmemleak: account for tagged pointers when calculating pointer range
Date: Wed, 13 Feb 2019 14:58:28 +0100
Message-Id: <16e887d442986ab87fe87a755815ad92fa431a5f.1550066133.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1550066133.git.andreyknvl@google.com>
References: <cover.1550066133.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kmemleak keeps two global variables, min_addr and max_addr, which store
the range of valid (encountered by kmemleak) pointer values, which it
later uses to speed up pointer lookup when scanning blocks.

With tagged pointers this range will get bigger than it needs to be.
This patch makes kmemleak untag pointers before saving them to min_addr
and max_addr and when performing a lookup.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kmemleak.c    | 10 +++++++---
 mm/slab.h        |  1 +
 mm/slab_common.c |  1 +
 mm/slub.c        |  1 +
 4 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..707fa5579f66 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -574,6 +574,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	unsigned long flags;
 	struct kmemleak_object *object, *parent;
 	struct rb_node **link, *rb_parent;
+	unsigned long untagged_ptr;
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
 	if (!object) {
@@ -619,8 +620,9 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
 	write_lock_irqsave(&kmemleak_lock, flags);
 
-	min_addr = min(min_addr, ptr);
-	max_addr = max(max_addr, ptr + size);
+	untagged_ptr = (unsigned long)kasan_reset_tag((void *)ptr);
+	min_addr = min(min_addr, untagged_ptr);
+	max_addr = max(max_addr, untagged_ptr + size);
 	link = &object_tree_root.rb_node;
 	rb_parent = NULL;
 	while (*link) {
@@ -1333,6 +1335,7 @@ static void scan_block(void *_start, void *_end,
 	unsigned long *start = PTR_ALIGN(_start, BYTES_PER_POINTER);
 	unsigned long *end = _end - (BYTES_PER_POINTER - 1);
 	unsigned long flags;
+	unsigned long untagged_ptr;
 
 	read_lock_irqsave(&kmemleak_lock, flags);
 	for (ptr = start; ptr < end; ptr++) {
@@ -1347,7 +1350,8 @@ static void scan_block(void *_start, void *_end,
 		pointer = *ptr;
 		kasan_enable_current();
 
-		if (pointer < min_addr || pointer >= max_addr)
+		untagged_ptr = (unsigned long)kasan_reset_tag((void *)pointer);
+		if (untagged_ptr < min_addr || untagged_ptr >= max_addr)
 			continue;
 
 		/*
diff --git a/mm/slab.h b/mm/slab.h
index 638ea1b25d39..384105318779 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -438,6 +438,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 	flags &= gfp_allowed_mask;
 	for (i = 0; i < size; i++) {
 		p[i] = kasan_slab_alloc(s, p[i], flags);
+		/* As p[i] might get tagged, call kmemleak hook after KASAN. */
 		kmemleak_alloc_recursive(p[i], s->object_size, 1,
 					 s->flags, flags);
 	}
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fe524c8d0246..f9d89c1b5977 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1229,6 +1229,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	ret = kasan_kmalloc_large(ret, size, flags);
+	/* As ret might get tagged, call kmemleak hook after KASAN. */
 	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 4a3d7686902f..f5a451c49190 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1375,6 +1375,7 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
 static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	ptr = kasan_kmalloc_large(ptr, size, flags);
+	/* As ptr might get tagged, call kmemleak hook after KASAN. */
 	kmemleak_alloc(ptr, size, 1, flags);
 	return ptr;
 }
-- 
2.20.1.791.gb4d0f1c61a-goog

