Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A02CC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCE5D20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Y59tExhx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCE5D20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6072A8E0007; Wed, 13 Mar 2019 01:21:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B4D48E0002; Wed, 13 Mar 2019 01:21:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 455BD8E0007; Wed, 13 Mar 2019 01:21:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDB98E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:23 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b40so820128qte.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aR78W31q72vxmgugCUO4zRYVwt/hNV8R2x/8ymYFgIU=;
        b=Z7kG68/lSeMVf6IX/W8OX8fammfRfY9zAQCuHqrtBTED9EiGJnhLoaRyLo3I1zdVq4
         Z9s6rsv7mskQEEUbrlO5+tMrrMj8voyEKayPOha9yRQY5BhAXrmFUo96HqWWaejAraox
         N9qGfpMonYYfGUG7tkuo9biol/KxQod6Pb9Ej/wgBCQ9otZ80INac7+3i/fMPA/AoXN6
         Vkpo7pdghTQ/3pTQWL2tr4kKByHrdmEqi19WpmlCX8FPTOxUAgx9zDo7aXxTUN8LvW0o
         sdLj2wwbz0k5/0WAdeshPg6EAzmuWcOuTYFP1knN0j2NVnSRQ1d2/pJvCG8aCtalilIy
         I8Gg==
X-Gm-Message-State: APjAAAV9QqDR8cnHEh6tSOKlAmAQbcNfPGJofca1mH5mC2GoG9Ui3FBp
	2z4cUkQ18aj8ousDnAyBM4NnRqDqY6lgweNMqefOEOreQdVikB+G7UzvhKtaEu95fibaPpm2Bf9
	42EEzWm2RaOyyiScd9ichIjOq08KrSBxTrYuAutfQgPWa0AAGqXOK8ZusiyrlC3Q=
X-Received: by 2002:ac8:3092:: with SMTP id v18mr9751715qta.41.1552454482928;
        Tue, 12 Mar 2019 22:21:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsw6rjlOwc9+zv1uAfIjhRBrH0T4TWogpoSA27YXyEMyRnNnO+6rgmGe3SBnpwFlHDElB4
X-Received: by 2002:ac8:3092:: with SMTP id v18mr9751688qta.41.1552454482176;
        Tue, 12 Mar 2019 22:21:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454482; cv=none;
        d=google.com; s=arc-20160816;
        b=namoafoJ/8MhSEN//ynjDoRZHaOIS+/UnBz+PEIqkJwbZXfMgoCStAAbLUtzt5/h0x
         s0EhKypGYxn4oZ5j+0cj+NfQf7UyB6RaUDi8ShNRVGBTsc8PArx594jDEU/MPxxNnctx
         wKdoxWarZUM0F/soJbHEbicYr/vqMzrTSWzhP+Nh3rLqDEfj256rWRB/SdqFUOKxeaxa
         FX/voPm+hPiFJDFFSv3wTaXg5HS8T0pFHattLcDmbAU0WcSsmOtZ67LzNgMTrwx4yHQS
         BFjOS5kKkH/45ETY+ccdfjqLKc5e4qYmPkT81EbDouvWHFPmQDRiXRbq85uqRJPwUU5Y
         Qwxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aR78W31q72vxmgugCUO4zRYVwt/hNV8R2x/8ymYFgIU=;
        b=uuPEhJpluzvoD50dumrmezaZY2P6hFNY7rD4/v+cfGo+DtBkk2LqlSW8/GoZXZQv3p
         iZeShTdcghYXYlaoZEyIkeqgNh0v5vsYiC//JJhgdumwQEXDmqEkrSgVvnNoYZX/vDgR
         a5xtph/5k+RLfoMmrEMq73io2CtJVLXKwxPWRuwFomIbBqXxIubNfj+KlC2MA/jUVYtU
         4jxypvmB7atREOrxTtXV74qSQEPo/l0uRofDqC2ryxzSfl96+n3mkdOS8JzVa2C6ryI/
         AA09JVkTaJBrWY8xUnsujVrZMJ4uZM4Uk0yg3xRE/AQMyQnE1b0jtfjmudY/6sMlhgie
         gJ4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Y59tExhx;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id l31si6729016qtc.4.2019.03.12.22.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Y59tExhx;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 9D02838BD;
	Wed, 13 Mar 2019 01:21:20 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aR78W31q72vxmgugCUO4zRYVwt/hNV8R2x/8ymYFgIU=; b=Y59tExhx
	GKNS4b5q5bZQhE8JfLu/yue+mnCE/qtxShZS6ONFIZCadUJmGwilY3O+AiZOo73g
	b6XQskb8KQcazK1o0Z9CCq5rHVGJv3fk4KfTwZWAw+cnC2Oxw9bSEGI9cdQKd8Rm
	BnlrynlD0UX/DNKn7kPHai/+kIufKApqtMtsEUlV/3i9jLyxk5jHjuykM7Z39/v6
	Y0TybJ/0+fOy8/+josus7cXyZ0N4e2lV/CTWgnkwDCDLcMnKmE6LorOlGsy7TOWP
	4vpxWGoWdYSYKjL18kPzkOXOgj0DA3OrHpOJNR+2y5hl1bx/3vrY9alD0UVeLpOD
	079JXKsVGxtmCQ==
X-ME-Sender: <xms:UJOIXG0LsPb3z2ZaDeWk8JKF8NWYyKh3JPzKpbzV1oezZVwLisuW-w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:UJOIXNXA2eICJnOZOSA6gv3tAHoEgsFw-Xq5UAeJreWzbl1nVQKSow>
    <xmx:UJOIXJ5l_XWyLFLeLNRhCR_CQUcr4fUtcnRJMOv1aeIgVrmYQCCesg>
    <xmx:UJOIXMJB16a2FKJnZCKZJid8OD9nXYc8txYj4xv_0rocCiSXHkYwgQ>
    <xmx:UJOIXISiqNWFZLn_S7xLeo7r2hUrUeGCiRs0md9rMFxWhrtwsOgW_w>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id A7752E427E;
	Wed, 13 Mar 2019 01:21:16 -0400 (EDT)
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
Subject: [PATCH v2 4/5] slob: Use slab_list instead of lru
Date: Wed, 13 Mar 2019 16:20:29 +1100
Message-Id: <20190313052030.13392-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190313052030.13392-1-tobin@kernel.org>
References: <20190313052030.13392-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list_head in the page structure (slab_list) that can be used for
this purpose.  Doing so makes the code cleaner since we are not
overloading the lru list.

The slab_list is part of a union within the page struct (included here
stripped down):

	union {
		struct {	/* Page cache and anonymous pages */
			struct list_head lru;
			...
		};
		struct {
			dma_addr_t dma_addr;
		};
		struct {	/* slab, slob and slub */
			union {
				struct list_head slab_list;
				struct {	/* Partial pages */
					struct page *next;
					int pages;	/* Nr of pages left */
					int pobjects;	/* Approximate count */
				};
			};
		...

Here we see that slab_list and lru are the same bits.  We can verify
that this change is safe to do by examining the object file produced from
slob.c before and after this patch is applied.

Steps taken to verify:

 1. checkout current tip of Linus' tree

    commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")

 2. configure and build (select SLOB allocator)

    CONFIG_SLOB=y
    CONFIG_SLAB_MERGE_DEFAULT=y

 3. dissasemble object file `objdump -dr mm/slub.o > before.s
 4. apply patch
 5. build
 6. dissasemble object file `objdump -dr mm/slub.o > after.s
 7. diff before.s after.s

Use slab_list list_head instead of the lru list_head for maintaining
lists of slabs.

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slob.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..ee68ff2a2833 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
 
 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->lru, list);
+	list_add(&sp->slab_list, list);
 	__SetPageSlobFree(sp);
 }
 
 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->lru);
+	list_del(&sp->slab_list);
 	__ClearPageSlobFree(sp);
 }
 
@@ -283,7 +283,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, slab_list) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -297,7 +297,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 			continue;
 
 		/* Attempt to alloc */
-		prev = sp->lru.prev;
+		prev = sp->slab_list.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
@@ -323,7 +323,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
-- 
2.21.0

