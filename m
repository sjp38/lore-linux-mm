Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DFCAC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11DDD207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pV6zDQgV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11DDD207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7ABC6B0276; Tue,  2 Apr 2019 19:06:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04026B0277; Tue,  2 Apr 2019 19:06:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CAB26B0278; Tue,  2 Apr 2019 19:06:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79DB76B0276
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:47 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 75so13061125qki.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qs5oMJVG8T7y17a75wRO6haSj5HkqCPcGJrvYSSveK4=;
        b=d8R2MfXC8xAOCT92KmX1Ry8I9pcqOSKd3oquMJ/Qr14tUp/BKKao0/H1GThn3ljwl9
         iYo9mqjTzDL+f8l9GLUjcMSHtTSFoQnob3ersagKzgiEdyYXzgsZCG4abgzsxN7BVf+3
         Z6hrgtStUlnO+hY70KpYo3wH8S3JmZ/+gpF93lePqJyuBxeFMUeTk5iL0ikQkXq+ANc6
         iXcuyQtECvM1n69SpmvX15bq8A/HKx+16FdsU5ybAP7zQl/EjG93rrpEX5zsT92/jzwl
         RktY65U7IQ/e7lh4MNTxYN6ZJ491JQTB4rZWZPMi09vdj/OaRNfklX74OYFuCKTcHFwJ
         zJfg==
X-Gm-Message-State: APjAAAXZkI7+Y5EUqa5SBzdJLCJNuB0gZPmK+pTVGk/ADEYhWmcGEJuv
	DbI4w71tYJXhFTicPU2YGTlyA6VeYoqjklT+P4KQlTXm6VgRTGMrXa5x9flM+1Yhax4caFVqvKS
	FpIO4V+1Wk50P7uDC+OGopO7ZCpfNiun7HcxTM6yryblt1mNOfKcC0iXTIxXKCY0=
X-Received: by 2002:ac8:3042:: with SMTP id g2mr61243832qte.1.1554246407250;
        Tue, 02 Apr 2019 16:06:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyofg6J/MrO7/9PKUqWp7chzCOlnLDmeKoIJHYNeAiW7xtMVKowSzyQbyM31uBdtQ3X2WyZ
X-Received: by 2002:ac8:3042:: with SMTP id g2mr61243774qte.1.1554246406453;
        Tue, 02 Apr 2019 16:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246406; cv=none;
        d=google.com; s=arc-20160816;
        b=SM+wPBcMwxacEqJhRWYOZ36qEfEpyEkahZ/vNk3V6pD3T0Dwte3iXPWXQY7BmZnSec
         GWCwjOeO/FtfZgNpx39B+PCv0JbvGlA/E83N9puktu2rCBXy2xAjLYI6q7q16+iJ16tM
         ezph6cd5SxdbigfDI++5cxs4zuw354+9G/XHfO8mXRxxa5LjkWJbGc25cpFJfqYCrblE
         lW+cFqyreJkeW8dRqxSPFlIavtm7+tlBUGvJbR//2e/7ZqM48UUZrcY//Ff7z8eIG74O
         3yNY4zRUwT1BSvwWdWPHxGIc4nZL3bhEkgukIyPbnPoFg6BvbdIheNSJf+WrlFx+t6DD
         2nzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qs5oMJVG8T7y17a75wRO6haSj5HkqCPcGJrvYSSveK4=;
        b=lLyboLqx/mm144tWgv08QU5MlMIBt5GMATEmk1Dk3UdESS+nEL/wg3FutSJ3XN+F60
         0DHqAR2Qtr95C4C5PCEFnHE10eg5/gaemztwRD5q++sUBtzyiJuI0RPFMVt44mX9Sf9s
         2ceVxhbvvzT9XLXCPC/wQ0bbrS+qj81vVdUQLNuDzLwe3INr9lbfkqoNbWzkSLT75eDA
         eqChs0yw+RLwNd4wKGEbgJVYfH2y3xxXPR5BLigfl/XxnHhKJuPrpdQY9rCROZxDH2iI
         jEkjXj0PkGdnxOUmVnvC8+/iseQPuSsYxAzvm5gf5/1WO7kxSfAFgdIWHRKiG/OlEdMu
         +aDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=pV6zDQgV;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 41si731960qtp.20.2019.04.02.16.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=pV6zDQgV;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2E6F922028;
	Tue,  2 Apr 2019 19:06:46 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=qs5oMJVG8T7y17a75wRO6haSj5HkqCPcGJrvYSSveK4=; b=pV6zDQgV
	51S0o14N/YzIUe8qXuA4ZYzNP+4WSpAt6O1Ajm4OXfNBL7Un91tHrOEUkAYEhWuV
	ibh92Ph0jEEgXTt9xwZMRA3fe6ieF+eAMuTCOkI8nol0w8u9DsqfoonHxylHwnsp
	mZ5wQpifhQLm1HMmytXFypzRiQBX2FvR2sRDdHbtM09YUmgNGh5lT/lA6JZKOeSd
	PYhiE3akqRYcGl6rAqDDA7WG5QONjrbvhGp2Cs+g5DLhRAzz+gLhNvTdrR6cwqqm
	5IiSZ6o3jpjrUgfYp3lCXeN1+4Jcv+QADAaRbG4+CddgCozvEdmXluxEv4JibnIO
	PjptbIuavnfNdg==
X-ME-Sender: <xms:BeujXIvcjg0lpOQF2yMnbc1kNTahBN7yDU5FhrgQcEtVWOmrTfzgIA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeeg
X-ME-Proxy: <xmx:BuujXEtqGVkSyKeCF4eq8RAYqgoL03vWYJI5qELYLRlqfHsPTspL4w>
    <xmx:BuujXP841gpJWmvt6brl_P9kjQtz5YS4dLmi8oIKjokCkKQiYCsEDg>
    <xmx:BuujXF-XcF0q4hPNN_X0IR4Q0sD763Ss_FSItJ48LPkcjsw6pQbfeQ>
    <xmx:BuujXA5RJSrAhLyM7zirQbDwc_gUbenz0QoP7GN5DmVPHABdxVoGyA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8D856100E5;
	Tue,  2 Apr 2019 19:06:42 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 5/7] slub: Use slab_list instead of lru
Date: Wed,  3 Apr 2019 10:05:43 +1100
Message-Id: <20190402230545.2929-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list in the page structure (slab_list) that can be used for this
purpose.  Doing so makes the code cleaner since we are not overloading
the lru list.

Use the slab_list instead of the lru list for maintaining lists of
slabs.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8fbba4ff6c67..d17f117830a9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1023,7 +1023,7 @@ static void add_full(struct kmem_cache *s,
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_add(&page->lru, &n->full);
+	list_add(&page->slab_list, &n->full);
 }
 
 static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
@@ -1032,7 +1032,7 @@ static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 }
 
 /* Tracking of the number of slabs for debugging purposes */
@@ -1773,9 +1773,9 @@ __add_partial(struct kmem_cache_node *n, struct page *page, int tail)
 {
 	n->nr_partial++;
 	if (tail == DEACTIVATE_TO_TAIL)
-		list_add_tail(&page->lru, &n->partial);
+		list_add_tail(&page->slab_list, &n->partial);
 	else
-		list_add(&page->lru, &n->partial);
+		list_add(&page->slab_list, &n->partial);
 }
 
 static inline void add_partial(struct kmem_cache_node *n,
@@ -1789,7 +1789,7 @@ static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	n->nr_partial--;
 }
 
@@ -1863,7 +1863,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 		return NULL;
 
 	spin_lock(&n->list_lock);
-	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+	list_for_each_entry_safe(page, page2, &n->partial, slab_list) {
 		void *t;
 
 		if (!pfmemalloc_match(page, flags))
@@ -2407,7 +2407,7 @@ static unsigned long count_partial(struct kmem_cache_node *n,
 	struct page *page;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
+	list_for_each_entry(page, &n->partial, slab_list)
 		x += get_count(page);
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return x;
@@ -3705,10 +3705,10 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 
 	BUG_ON(irqs_disabled());
 	spin_lock_irq(&n->list_lock);
-	list_for_each_entry_safe(page, h, &n->partial, lru) {
+	list_for_each_entry_safe(page, h, &n->partial, slab_list) {
 		if (!page->inuse) {
 			remove_partial(n, page);
-			list_add(&page->lru, &discard);
+			list_add(&page->slab_list, &discard);
 		} else {
 			list_slab_objects(s, page,
 			"Objects remaining in %s on __kmem_cache_shutdown()");
@@ -3716,7 +3716,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 	}
 	spin_unlock_irq(&n->list_lock);
 
-	list_for_each_entry_safe(page, h, &discard, lru)
+	list_for_each_entry_safe(page, h, &discard, slab_list)
 		discard_slab(s, page);
 }
 
@@ -3996,7 +3996,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		 * Note that concurrent frees may occur while we hold the
 		 * list_lock. page->inuse here is the upper limit.
 		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
+		list_for_each_entry_safe(page, t, &n->partial, slab_list) {
 			int free = page->objects - page->inuse;
 
 			/* Do not reread page->inuse */
@@ -4006,10 +4006,10 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 			BUG_ON(free <= 0);
 
 			if (free == page->objects) {
-				list_move(&page->lru, &discard);
+				list_move(&page->slab_list, &discard);
 				n->nr_partial--;
 			} else if (free <= SHRINK_PROMOTE_MAX)
-				list_move(&page->lru, promote + free - 1);
+				list_move(&page->slab_list, promote + free - 1);
 		}
 
 		/*
@@ -4022,7 +4022,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, &discard, lru)
+		list_for_each_entry_safe(page, t, &discard, slab_list)
 			discard_slab(s, page);
 
 		if (slabs_node(s, node))
@@ -4214,11 +4214,11 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	for_each_kmem_cache_node(s, node, n) {
 		struct page *p;
 
-		list_for_each_entry(p, &n->partial, lru)
+		list_for_each_entry(p, &n->partial, slab_list)
 			p->slab_cache = s;
 
 #ifdef CONFIG_SLUB_DEBUG
-		list_for_each_entry(p, &n->full, lru)
+		list_for_each_entry(p, &n->full, slab_list)
 			p->slab_cache = s;
 #endif
 	}
@@ -4435,7 +4435,7 @@ static int validate_slab_node(struct kmem_cache *s,
 
 	spin_lock_irqsave(&n->list_lock, flags);
 
-	list_for_each_entry(page, &n->partial, lru) {
+	list_for_each_entry(page, &n->partial, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4446,7 +4446,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
 
-	list_for_each_entry(page, &n->full, lru) {
+	list_for_each_entry(page, &n->full, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4642,9 +4642,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(page, &n->partial, lru)
+		list_for_each_entry(page, &n->partial, slab_list)
 			process_slab(&t, s, page, alloc, map);
-		list_for_each_entry(page, &n->full, lru)
+		list_for_each_entry(page, &n->full, slab_list)
 			process_slab(&t, s, page, alloc, map);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
-- 
2.21.0

