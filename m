Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1718EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B00132184D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="N7vIeiZD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B00132184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E2FB8E0009; Thu, 14 Mar 2019 01:32:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 590178E0001; Thu, 14 Mar 2019 01:32:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40B698E0009; Thu, 14 Mar 2019 01:32:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10F538E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:32 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h11so3714361qkg.18
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1y7C0tdFU3/mxaXs9LeF2IpcwQv3uoHEyFfzQ8TmT8k=;
        b=BQeKkRHnKOgIVZgYDU+s4qI3UIDBDRQGlpqKNM4m1lRCLJc+neXos13ZBEXUoezpIQ
         ejdfv02HFIuEs1eV7IE3XC5GxMIDCALDr1xUbXxPyBcykYqAg3a9lr12CbRJLifvOMXK
         UlGnk3qKmTFSygkzpjsJhpES9vtbNhoYxOegHN5IdOqE2T/O62cAt/M5o51uMXlOCw8O
         s5OJ8zrIxhMDsG3q/RXvvW4O3c5UXZ4Nz88/Do49MkhSYVp1FLlwdYg/ITnO8ZqqMwGi
         0YA74Xb9avS8AXY4unm9gmqBcG1ZK6crJP+CmQ259Fe/HKl30rOJJswweaBdabu9zWBt
         R3gw==
X-Gm-Message-State: APjAAAW8AC8Jox61uIteqdgXam+YFCTcinQMTD8DPiDGRifSYYuu7mxs
	pJvA9wbCxPRusRRksqwFWZezj2oPl9DIj8pnovXsOc5OW4Hy4sY6fxBAvE1k29X4MtgJ1ftAIum
	rHDSjzd8VuxEgs9bw5EBB1LVSU/0qxi6Tp6No8DgcFjMkYKZV5pgey/rabe8Izcc=
X-Received: by 2002:aed:3829:: with SMTP id j38mr37159836qte.385.1552541551841;
        Wed, 13 Mar 2019 22:32:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2eCo4bPEu4DhH1i12VEfEs/F7pK+iBIRPbQtAxQzVJTaxu8hCOr+pALBO0RNW8gMLqPsv
X-Received: by 2002:aed:3829:: with SMTP id j38mr37159774qte.385.1552541550435;
        Wed, 13 Mar 2019 22:32:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541550; cv=none;
        d=google.com; s=arc-20160816;
        b=YqjNipzS0GrJChlD2da6JpMTSU6OeBbH81q9X13dJMenk2vuOvv7RDtHEIoLeUefFE
         MqXlZU7yyFoGGSTaAkfeBcnn5uHO+26mm57n8w8ZzjJixr5/yKGNJSFbZrm6BlfBObgn
         RJQwTbGgmFErB2z6mr8/ywaLep7EXU//8fm5QtO7ZjWyEmqfMYUQSNo5z2swsJVEgfVj
         MY2cek22ZQSrjifLQ4ntwoOHC7LrVmUygXubSprOJ3gethDfKh6Q69+1vZvmluamybC7
         Xf3vDAgyW+CswYdW/m/tK+QSE+ee8OurQ0eJTxvdrcVaIe8jUxBHeFRYZfks8bT5LUOc
         8OaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1y7C0tdFU3/mxaXs9LeF2IpcwQv3uoHEyFfzQ8TmT8k=;
        b=fOrZcSL2TZ1xzQXueau8DI2e0nYyfllqG0pMwArOtqtzwGSe1ryA5WySSYp9B25ruI
         UEfYa0HkgUtyq06CHpMsCNi/GBd2QrbDJiOj82JjQQFyusU5q5K8GI5R9p51Iq1+wdhl
         IWBLPdghhIU1qM25+imAX+l/kmogr4BIYZ7UZyvKmI/nmBiafUAt1dZcHO1afjNtZy5L
         d6MTQKMnBkpqJi62ndstPVbPw/CygXGBbMKlCdiV3oMThA0NIC7cyUUQ8jARCcXsRP33
         yM/f+/p2lJ7lPJAlbdhEjgPL3u0+p2NxtplZQVQ8tySar6bogWCPbTD+Tg3lJKqRQ8fF
         47AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=N7vIeiZD;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id b30si242711qta.403.2019.03.13.22.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=N7vIeiZD;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 31AD1213BD;
	Thu, 14 Mar 2019 01:32:30 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=1y7C0tdFU3/mxaXs9LeF2IpcwQv3uoHEyFfzQ8TmT8k=; b=N7vIeiZD
	TRu7cRIuvMwTopOORGhfFmMU0vXAGra/koqnsuvMLL2Z5R2qhWkWq+10R7IavvPE
	buvGMcRg4152wIchozMMGg1wRktvn/oknWcAXIPrezbKR1EDd2Zs4Er2bakZ4AP3
	7KzlBH6MJKFjqyOO98RhZDpHbO6EG3YenUGc8uRJ/zK8hvFXcSibNDCqirxhSp7q
	N79k3QtPkrQb+nZ003cT2WUPYMaOExEkDH+i0rBdCQlChoga8Il+oUgSaI30f4z2
	XolnG/ALhRcd90G71D4wDE/z91kBVwwoMsvhBhNyPonZiEGM8oEPaHDiDckDqLv5
	yxvYKtOA37ZQpQ==
X-ME-Sender: <xms:beeJXJChdGf4rSXjXPLQv7ODz_F5QlqkgBazn_0ps-C2eNSgbG7jzw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeeh
X-ME-Proxy: <xmx:bueJXMpANDAf37_MZT4yZfQlomsoJGpmynb3SAjyq7RPa5WeZuRiUQ>
    <xmx:bueJXL0bXq44s49OmGau42SsFn9a_equg4nVNHrauo8UIlifiJpQFg>
    <xmx:bueJXLV-50A3CtxWtpswk8KMDRRtxyrdslV4OAvzF0fsw4bc3g_mkg>
    <xmx:bueJXLRC8MVZHFIvQOueFQrRImQRc-5pqUal2xShjgZGhZJoF6sUkg>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9C007E408B;
	Thu, 14 Mar 2019 01:32:26 -0400 (EDT)
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
Subject: [PATCH v3 6/7] slab: Use slab_list instead of lru
Date: Thu, 14 Mar 2019 16:31:34 +1100
Message-Id: <20190314053135.1541-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190314053135.1541-1-tobin@kernel.org>
References: <20190314053135.1541-1-tobin@kernel.org>
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

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slab.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 28652e4218e0..09cc64ef9613 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1710,8 +1710,8 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
 {
 	struct page *page, *n;
 
-	list_for_each_entry_safe(page, n, list, lru) {
-		list_del(&page->lru);
+	list_for_each_entry_safe(page, n, list, slab_list) {
+		list_del(&page->slab_list);
 		slab_destroy(cachep, page);
 	}
 }
@@ -2265,8 +2265,8 @@ static int drain_freelist(struct kmem_cache *cache,
 			goto out;
 		}
 
-		page = list_entry(p, struct page, lru);
-		list_del(&page->lru);
+		page = list_entry(p, struct page, slab_list);
+		list_del(&page->slab_list);
 		n->free_slabs--;
 		n->total_slabs--;
 		/*
@@ -2726,13 +2726,13 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
 	if (!page)
 		return;
 
-	INIT_LIST_HEAD(&page->lru);
+	INIT_LIST_HEAD(&page->slab_list);
 	n = get_node(cachep, page_to_nid(page));
 
 	spin_lock(&n->list_lock);
 	n->total_slabs++;
 	if (!page->active) {
-		list_add_tail(&page->lru, &(n->slabs_free));
+		list_add_tail(&page->slab_list, &n->slabs_free);
 		n->free_slabs++;
 	} else
 		fixup_slab_list(cachep, n, page, &list);
@@ -2841,9 +2841,9 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 				void **list)
 {
 	/* move slabp to correct slabp list: */
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	if (page->active == cachep->num) {
-		list_add(&page->lru, &n->slabs_full);
+		list_add(&page->slab_list, &n->slabs_full);
 		if (OBJFREELIST_SLAB(cachep)) {
 #if DEBUG
 			/* Poisoning will be done without holding the lock */
@@ -2857,7 +2857,7 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 			page->freelist = NULL;
 		}
 	} else
-		list_add(&page->lru, &n->slabs_partial);
+		list_add(&page->slab_list, &n->slabs_partial);
 }
 
 /* Try to find non-pfmemalloc slab if needed */
@@ -2880,20 +2880,20 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
 	}
 
 	/* Move pfmemalloc slab to the end of list to speed up next search */
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	if (!page->active) {
-		list_add_tail(&page->lru, &n->slabs_free);
+		list_add_tail(&page->slab_list, &n->slabs_free);
 		n->free_slabs++;
 	} else
-		list_add_tail(&page->lru, &n->slabs_partial);
+		list_add_tail(&page->slab_list, &n->slabs_partial);
 
-	list_for_each_entry(page, &n->slabs_partial, lru) {
+	list_for_each_entry(page, &n->slabs_partial, slab_list) {
 		if (!PageSlabPfmemalloc(page))
 			return page;
 	}
 
 	n->free_touched = 1;
-	list_for_each_entry(page, &n->slabs_free, lru) {
+	list_for_each_entry(page, &n->slabs_free, slab_list) {
 		if (!PageSlabPfmemalloc(page)) {
 			n->free_slabs--;
 			return page;
@@ -2908,11 +2908,12 @@ static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
 	struct page *page;
 
 	assert_spin_locked(&n->list_lock);
-	page = list_first_entry_or_null(&n->slabs_partial, struct page, lru);
+	page = list_first_entry_or_null(&n->slabs_partial, struct page,
+					slab_list);
 	if (!page) {
 		n->free_touched = 1;
 		page = list_first_entry_or_null(&n->slabs_free, struct page,
-						lru);
+						slab_list);
 		if (page)
 			n->free_slabs--;
 	}
@@ -3413,29 +3414,29 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		objp = objpp[i];
 
 		page = virt_to_head_page(objp);
-		list_del(&page->lru);
+		list_del(&page->slab_list);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp);
 		STATS_DEC_ACTIVE(cachep);
 
 		/* fixup slab chains */
 		if (page->active == 0) {
-			list_add(&page->lru, &n->slabs_free);
+			list_add(&page->slab_list, &n->slabs_free);
 			n->free_slabs++;
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
-			list_add_tail(&page->lru, &n->slabs_partial);
+			list_add_tail(&page->slab_list, &n->slabs_partial);
 		}
 	}
 
 	while (n->free_objects > n->free_limit && !list_empty(&n->slabs_free)) {
 		n->free_objects -= cachep->num;
 
-		page = list_last_entry(&n->slabs_free, struct page, lru);
-		list_move(&page->lru, list);
+		page = list_last_entry(&n->slabs_free, struct page, slab_list);
+		list_move(&page->slab_list, list);
 		n->free_slabs--;
 		n->total_slabs--;
 	}
@@ -3473,7 +3474,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		int i = 0;
 		struct page *page;
 
-		list_for_each_entry(page, &n->slabs_free, lru) {
+		list_for_each_entry(page, &n->slabs_free, slab_list) {
 			BUG_ON(page->active);
 
 			i++;
@@ -4336,9 +4337,9 @@ static int leaks_show(struct seq_file *m, void *p)
 			check_irq_on();
 			spin_lock_irq(&n->list_lock);
 
-			list_for_each_entry(page, &n->slabs_full, lru)
+			list_for_each_entry(page, &n->slabs_full, slab_list)
 				handle_slab(x, cachep, page);
-			list_for_each_entry(page, &n->slabs_partial, lru)
+			list_for_each_entry(page, &n->slabs_partial, slab_list)
 				handle_slab(x, cachep, page);
 			spin_unlock_irq(&n->list_lock);
 		}
-- 
2.21.0

