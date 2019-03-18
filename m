Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12698C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3DBF2086A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="n1HYWHWm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3DBF2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FBFE6B000C; Sun, 17 Mar 2019 20:03:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45C516B000D; Sun, 17 Mar 2019 20:03:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325366B000E; Sun, 17 Mar 2019 20:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF876B000C
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:51 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k29so13414218qkl.14
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=;
        b=pY1WEaDa7/4RDpBOPHSd4KX5Q07Qi9t6zX6JOLZD9fAjJ3Ujhf3/ot/y1MAMoJbM/6
         xhEoHP7nlvYn0xL7EAE/xJvdAl1OsKVnTQ4X4nsonuH8jFd5OIWR0h+T3gwDcKZ8k5Wl
         aWaBy3dgL8jO38P432JQzsliBfH0cOX32/NSoZvXlcecDLZPl6E2Y3LZIcjT6QJziOic
         ejsrl2BrPIaU6EDNwKSA2uzoRleUr9ktfkC2rYSV2YBZz+y3GCkUEyaIgJR783eSFdjE
         pMf+vtL/Y3iM62X6zX/6/aWDfh/WevWgFYpR4Oc5SC1jN+5aSDujL4kHME01sb2rwOja
         k87w==
X-Gm-Message-State: APjAAAX1aOjxI7BbvDk7aRqHQvZtVXwtSlrVVvTI7DEblsau/Rneky0n
	sCmgc4lAZlN5ckbX/7FXmokTZR33uNsxifLwPwDuoScSf0aLP2jIe7gAEYTYsmrG1l4MFBlv+8q
	lWO7N7pWHG4Xz96bs34dzG8aETetUl8QnrNH/eDUPNmPuPtDNS3+oMO7DM5P7Uvg=
X-Received: by 2002:a37:4e0f:: with SMTP id c15mr11228037qkb.267.1552867430755;
        Sun, 17 Mar 2019 17:03:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxB0EZF+wPykJ38UjdD9VFyY93ZC7+HbTb2X+/v8g1twHqeZaxijOgYE7n3kot93Go3+hI4
X-Received: by 2002:a37:4e0f:: with SMTP id c15mr11227966qkb.267.1552867429363;
        Sun, 17 Mar 2019 17:03:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867429; cv=none;
        d=google.com; s=arc-20160816;
        b=htKYpbjjlIvaCtPdzDRb/iUA6D+Ut+8jIEnu64QZL4kiX8TmRRjYFbXn1TZSDi5CdP
         ibLu2noRnH7CtCr5KW4WU9O2D60gE0SP8fGyZb8/XzFphMQ/9Oxs98LLqo+cWY7RjfNx
         7lv4nTetVYmuGlAvUTpkxFX7V/5uEBStFbZzna3oillAm+7YiBbsp7xSVDcfqwxHl38q
         k+DC3J6K+39Z0PxTOUmnUIxQZRn+Vu/fu55nzUjNcqFK+VkD5ah5xhUoOBw6bw3vU70m
         ITEB/Bd2mF20AOkQ4VcVyJibL+X0M4UaiI6Ze8OscZliPdrswNG8e98uPPzDOOoQvf85
         FLow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=;
        b=pw2hP7lbt6dD+nh3JKO7RsrT0jvPYhWwcNjH7s97L3PloIkWQYklJDMz2yJjz+cC0L
         4S6uADM3Ud+FnhcGkmHEvgCXqA6xOLC/4kn4UsoyoT9TMVYAAMrC8LZgk7FK8T1NGUv5
         raPJnq4w1tvOxPO59Yt7bbPQGw6z2Np+CT/WG5zk82uueK36clyOKbXbohoUq/lbkc5s
         utC/tq57htErffD/MyYQdPJrQH0wCRoMabhNtB7Mrx3bODUVI9yMOd4e+4JKnNcgpkWt
         5cJ6YlBsfZo4akDOcZLggn4yp4RRK1/pA/0kj5lcGGjYAV/kWenBAKIaiC5lw3C9i/3B
         S3ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=n1HYWHWm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 23si3171707qtr.57.2019.03.17.17.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=n1HYWHWm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 1970221820;
	Sun, 17 Mar 2019 20:03:49 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=; b=n1HYWHWm
	5onIezhZH34mWPnV5UyDBgxW37ch7bs69caujnMC5qlcc7VnRg5irK8MPTdWO/yZ
	lWjQmK8AsLlfzgymz/u6+VP6GQgxEVA2Tva9ec0j9iHhBM9Gm19hJFLpFExgfHe4
	264wlGye6YPRpjAaxsYwiWdHvazsWMLKGO7rzqng2qdgHKTieZBgf7pI+Px0bhhW
	4p+J0RiLQUi8oJBXM+UaM+JtOr1A3oYigsmxRIcbmX+CacDW8qLkq0K9/eO4eWSc
	56mq+fi10boqD3R8/fbtneUeb8Atxu5wBTakcmpnhrmui/p7Fl3haIHNtQQJFE9e
	QNqSzF4GO8cRTw==
X-ME-Sender: <xms:ZOCOXJVYHMuEWyK6dJ-FRwY9qUynqoJIplsLsz5_4DiOTfhbQeEvug>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:ZOCOXByqPK4pb5R-dDy9Tn8Ci9qDuco3tZ1xWpoThiDzRGg52nW0GA>
    <xmx:ZOCOXNdBHq3R19s3faBb2dHChNHLTOp4FNF7BYH_C9e1YkrpVKQoBA>
    <xmx:ZOCOXCeZDQ40CXyKbJpIU4nSvuBqZI6D2ogLW0cf5vXAQsRFVFlxmA>
    <xmx:ZeCOXIZUFOQv1NdbXbux5cqgWvuQFYTa5grLDrNwQ9M5rsXGomQU9A>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id 96DBBE4753;
	Sun, 17 Mar 2019 20:03:45 -0400 (EDT)
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
Subject: [PATCH v4 6/7] slab: Use slab_list instead of lru
Date: Mon, 18 Mar 2019 11:02:33 +1100
Message-Id: <20190318000234.22049-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318000234.22049-1-tobin@kernel.org>
References: <20190318000234.22049-1-tobin@kernel.org>
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

