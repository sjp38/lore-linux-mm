Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C29ECDE20
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 878432085B
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="g70fJyo1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 878432085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69C0C6B0006; Wed, 11 Sep 2019 22:31:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625066B0007; Wed, 11 Sep 2019 22:31:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49FD16B0008; Wed, 11 Sep 2019 22:31:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0083.hostedemail.com [216.40.44.83])
	by kanga.kvack.org (Postfix) with ESMTP id 241046B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:31:19 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C821A2C89
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:18 +0000 (UTC)
X-FDA: 75924691836.18.hill84_459fa2a360b17
X-HE-Tag: hill84_459fa2a360b17
X-Filterd-Recvd-Size: 10014
Received: from mail-yw1-f74.google.com (mail-yw1-f74.google.com [209.85.161.74])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:18 +0000 (UTC)
Received: by mail-yw1-f74.google.com with SMTP id a144so19625518ywe.17
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:31:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ojJ7cMXPrEiz/FyLr9IQHwY3KlzuwRhifydshmfR8I0=;
        b=g70fJyo13BA1SXnh7P2t5j+psqVthBSTait77IbUPz5S/ugHncKb8NdHARQU7D+yHV
         DH1m/luteU9Lh6efd+9JaPISUkB4s7qnKuxFdF/8hjRthqdzrfsBnNxp6FsCQgYw3MrN
         xPnD7ikF/rma/1+/ECGTyoWQz0t2HhS6P59KZW1laQOd2bsxR2pMxo65jKJAfOMLUFPn
         I56eFmQbSHkyt3bAmYbs1IkL+nad1hunZWr43vropeMB7GCFL2PuMSdMLxVGBYqb36uP
         8EKua6gMR4PjylhKKoOGkC7Ey2d98UliNcm27tLZjvUDnPUE6rD7Gnl/B2WO0D03b24/
         MZ5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=ojJ7cMXPrEiz/FyLr9IQHwY3KlzuwRhifydshmfR8I0=;
        b=PnBZHeKIWdmBiPrwZrKMBwuG4BKfWZPyEjcW1WnjaxViHu5B8uin4SZhIjNlrBsBM5
         33E2RV2Cae6veHZOjh3iU1RwbH1H14ftipfDcTduFGXOOzYOH3o/Ct80XjePEaf0memO
         1/KxXVXGT7qZ+1DwzDGxYRbQVlWzI6vXctoKpAVG7+b3GTPJ2ZOI/R//4hYdr6YHbGRk
         3JsuwQWL9ifhiFi0598MT4juVSPnsOpHZXJTuHtOaRe9+cVV7wMW0Z+f4cVpRpMEKZWy
         IDgpB3Ipi1ZI+yPXgQZWld8FCjlweWmx5v2A5DoVmx3SEUhigHbwVUKvRGDwfl/4sASS
         MGHA==
X-Gm-Message-State: APjAAAULUp4fcmDHVWKsqDHdu1v06D3vrwJtQ5PrTEy2VJNxIjrEcV9B
	JhU0K+Row6FlQEdvptge3z41uqoACZg=
X-Google-Smtp-Source: APXvYqyN8W0NkYp7bgByDnua+Ana3vwfRAMK8BwsDNoKd2gpjIGh08yVuV1JR7vlGcnBDJyX+XKuNtv/kJU=
X-Received: by 2002:a81:4788:: with SMTP id u130mr26980216ywa.287.1568255477484;
 Wed, 11 Sep 2019 19:31:17 -0700 (PDT)
Date: Wed, 11 Sep 2019 20:31:10 -0600
In-Reply-To: <20190912023111.219636-1-yuzhao@google.com>
Message-Id: <20190912023111.219636-3-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912004401.jdemtajrspetk3fh@box> <20190912023111.219636-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v2 3/4] mm: avoid slub allocation while holding list_lock
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we are already under list_lock, don't call kmalloc(). Otherwise we
will run into deadlock because kmalloc() also tries to grab the same
lock.

Fixing the problem by using a static bitmap instead.

  WARNING: possible recursive locking detected
  --------------------------------------------
  mount-encrypted/4921 is trying to acquire lock:
  (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437

  but task is already holding lock:
  (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb

  other info that might help us debug this:
   Possible unsafe locking scenario:

         CPU0
         ----
    lock(&(&n->list_lock)->rlock);
    lock(&(&n->list_lock)->rlock);

   *** DEADLOCK ***

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 88 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 47 insertions(+), 41 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7b7e1ee264ef..baa60dd73942 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -443,19 +443,38 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 }
 
 #ifdef CONFIG_SLUB_DEBUG
+static unsigned long object_map[BITS_TO_LONGS(MAX_OBJS_PER_PAGE)];
+static DEFINE_SPINLOCK(object_map_lock);
+
 /*
  * Determine a map of object in use on a page.
  *
  * Node listlock must be held to guarantee that the page does
  * not vanish from under us.
  */
-static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
+static unsigned long *get_map(struct kmem_cache *s, struct page *page)
 {
 	void *p;
 	void *addr = page_address(page);
 
+	VM_BUG_ON(!irqs_disabled());
+
+	spin_lock(&object_map_lock);
+
+	bitmap_zero(object_map, page->objects);
+
 	for (p = page->freelist; p; p = get_freepointer(s, p))
-		set_bit(slab_index(p, s, addr), map);
+		set_bit(slab_index(p, s, addr), object_map);
+
+	return object_map;
+}
+
+static void put_map(unsigned long *map)
+{
+	VM_BUG_ON(map != object_map);
+	lockdep_assert_held(&object_map_lock);
+
+	spin_unlock(&object_map_lock);
 }
 
 static inline unsigned int size_from_object(struct kmem_cache *s)
@@ -3685,13 +3704,12 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = bitmap_zalloc(page->objects, GFP_ATOMIC);
-	if (!map)
-		return;
+	unsigned long *map;
+
 	slab_err(s, page, text, s->name);
 	slab_lock(page);
 
-	get_map(s, page, map);
+	map = get_map(s, page);
 	for_each_object(p, s, addr, page->objects) {
 
 		if (!test_bit(slab_index(p, s, addr), map)) {
@@ -3699,8 +3717,9 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 			print_tracking(s, p);
 		}
 	}
+	put_map(map);
+
 	slab_unlock(page);
-	bitmap_free(map);
 #endif
 }
 
@@ -4386,19 +4405,19 @@ static int count_total(struct page *page)
 #endif
 
 #ifdef CONFIG_SLUB_DEBUG
-static void validate_slab(struct kmem_cache *s, struct page *page,
-						unsigned long *map)
+static void validate_slab(struct kmem_cache *s, struct page *page)
 {
 	void *p;
 	void *addr = page_address(page);
+	unsigned long *map;
+
+	slab_lock(page);
 
 	if (!check_slab(s, page) || !on_freelist(s, page, NULL))
-		return;
+		goto unlock;
 
 	/* Now we know that a valid freelist exists */
-	bitmap_zero(map, page->objects);
-
-	get_map(s, page, map);
+	map = get_map(s, page);
 	for_each_object(p, s, addr, page->objects) {
 		u8 val = test_bit(slab_index(p, s, addr), map) ?
 			 SLUB_RED_INACTIVE : SLUB_RED_ACTIVE;
@@ -4406,18 +4425,13 @@ static void validate_slab(struct kmem_cache *s, struct page *page,
 		if (!check_object(s, page, p, val))
 			break;
 	}
-}
-
-static void validate_slab_slab(struct kmem_cache *s, struct page *page,
-						unsigned long *map)
-{
-	slab_lock(page);
-	validate_slab(s, page, map);
+	put_map(map);
+unlock:
 	slab_unlock(page);
 }
 
 static int validate_slab_node(struct kmem_cache *s,
-		struct kmem_cache_node *n, unsigned long *map)
+		struct kmem_cache_node *n)
 {
 	unsigned long count = 0;
 	struct page *page;
@@ -4426,7 +4440,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	spin_lock_irqsave(&n->list_lock, flags);
 
 	list_for_each_entry(page, &n->partial, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab(s, page);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -4437,7 +4451,7 @@ static int validate_slab_node(struct kmem_cache *s,
 		goto out;
 
 	list_for_each_entry(page, &n->full, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab(s, page);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -4454,15 +4468,11 @@ static long validate_slab_cache(struct kmem_cache *s)
 	int node;
 	unsigned long count = 0;
 	struct kmem_cache_node *n;
-	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
-
-	if (!map)
-		return -ENOMEM;
 
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n)
-		count += validate_slab_node(s, n, map);
-	bitmap_free(map);
+		count += validate_slab_node(s, n);
+
 	return count;
 }
 /*
@@ -4592,18 +4602,17 @@ static int add_location(struct loc_track *t, struct kmem_cache *s,
 }
 
 static void process_slab(struct loc_track *t, struct kmem_cache *s,
-		struct page *page, enum track_item alloc,
-		unsigned long *map)
+		struct page *page, enum track_item alloc)
 {
 	void *addr = page_address(page);
 	void *p;
+	unsigned long *map;
 
-	bitmap_zero(map, page->objects);
-	get_map(s, page, map);
-
+	map = get_map(s, page);
 	for_each_object(p, s, addr, page->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			add_location(t, s, get_track(s, p, alloc));
+	put_map(map);
 }
 
 static int list_locations(struct kmem_cache *s, char *buf,
@@ -4614,11 +4623,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	struct loc_track t = { 0, 0, NULL };
 	int node;
 	struct kmem_cache_node *n;
-	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
 
-	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
-				     GFP_KERNEL)) {
-		bitmap_free(map);
+	if (!alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
+			     GFP_KERNEL)) {
 		return sprintf(buf, "Out of memory\n");
 	}
 	/* Push back cpu slabs */
@@ -4633,9 +4640,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->partial, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		list_for_each_entry(page, &n->full, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
 
@@ -4684,7 +4691,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	}
 
 	free_loc_track(&t);
-	bitmap_free(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
-- 
2.23.0.162.g0b9fbb3734-goog


