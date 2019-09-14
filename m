Return-Path: <SRS0=RN4K=XJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DD8CC4CEC8
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 00:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6E0420692
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 00:08:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nCsNpYe/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6E0420692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5259B6B0006; Fri, 13 Sep 2019 20:08:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B1976B0007; Fri, 13 Sep 2019 20:08:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DB916B0008; Fri, 13 Sep 2019 20:08:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 04E846B0006
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 20:08:00 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A8BAD8130
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 00:08:00 +0000 (UTC)
X-FDA: 75931588320.12.print47_62feb5d9f3810
X-HE-Tag: print47_62feb5d9f3810
X-Filterd-Recvd-Size: 10140
Received: from mail-qt1-f201.google.com (mail-qt1-f201.google.com [209.85.160.201])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 00:08:00 +0000 (UTC)
Received: by mail-qt1-f201.google.com with SMTP id h9so32470394qtq.11
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 17:08:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=eSHRB7BNRAQjZ8uOT74LwmF1qSdwZ1EsDMvtSpmherU=;
        b=nCsNpYe/6KqHpMNRxTWQSm36GhAd/TQqT/u+hyBjqv5q++O+z7hRA907BTeAwRtE3f
         uXxfN18IUgOoyuppP0/7e+DWMRLFJTnnyrqRVxjc2mLWiShEHYSaya4M3bsBScpMd9Lh
         lCfJ/yUXMTebKHrCYbQ0FoPWwvJDPzF8XHHl9wCOcc5TETb6uPGWyI+J+k6R/JelXIWj
         3IFew4APUDJ8+ytXmGvPyaQhjJ5CgNqNDYOJ9RW/hmU0mzQzbTCk7dOSRn7g0k58qBn5
         Hm5HXC1Bogc8H18OaSTFVbF707MLbJ9iXaFH+PgQIwrYhuBNshmVTOvHUyeJSoD85Isc
         Ydug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=eSHRB7BNRAQjZ8uOT74LwmF1qSdwZ1EsDMvtSpmherU=;
        b=qc1XNnT+Hp36Ne6BAzABE6mK/NGVx1v4kD3oPZNJZkV4+wd86wzdBbZ5p4EViP65BS
         cPJBvz5gvF5sOTIzhjHGkcAfyel59PPhGgI3hk9WhGIANyXp+3Qq6WJSATkVZoVaGpYK
         q/OcEaYVK06HcpoLfU6NMoXaNSeL4ko3p3zXxb+97M4TxCxMk7VsF+vt092LwOOE5ACm
         8es4ukDwJQdQ/iBn3KyvapnIEYWi3JmkdDrbe8j3b1ZTiR6fSCxcZ7uB6gFDq8HXIXDP
         Ocrc3E/0ARS6XwrUHipqmnOw9NO5tbv27ST7qtImzGx+CHgKqemPRprjw7UiwOfzyw9v
         556A==
X-Gm-Message-State: APjAAAWkSdHearX5sECd/WKq5M0Y9Q0oolFsmTMgO5+eTMqVVlx0epl2
	rsIpP9llNRdULwPGPx0aa1SWisPeNao=
X-Google-Smtp-Source: APXvYqw9r6lB2sNBc8bws+nMXoM4vPyiWs/GTrDzesTgrFRp8vvBA97bU0iZau772H5mogbbRtmAFysjWY8=
X-Received: by 2002:ac8:6b93:: with SMTP id z19mr6328929qts.48.1568419679504;
 Fri, 13 Sep 2019 17:07:59 -0700 (PDT)
Date: Fri, 13 Sep 2019 18:07:43 -0600
In-Reply-To: <20190914000743.182739-1-yuzhao@google.com>
Message-Id: <20190914000743.182739-2-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912023111.219636-1-yuzhao@google.com> <20190914000743.182739-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.237.gc6a4ce50a0-goog
Subject: [PATCH v3 2/2] mm: avoid slub allocation while holding list_lock
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 88 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 47 insertions(+), 41 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 445ef8b2aec0..c1de01730648 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -441,19 +441,38 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
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
@@ -3683,13 +3702,12 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
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
@@ -3697,8 +3715,9 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 			print_tracking(s, p);
 		}
 	}
+	put_map(map);
+
 	slab_unlock(page);
-	bitmap_free(map);
 #endif
 }
 
@@ -4384,19 +4403,19 @@ static int count_total(struct page *page)
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
@@ -4404,18 +4423,13 @@ static void validate_slab(struct kmem_cache *s, struct page *page,
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
@@ -4424,7 +4438,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	spin_lock_irqsave(&n->list_lock, flags);
 
 	list_for_each_entry(page, &n->partial, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab(s, page);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -4435,7 +4449,7 @@ static int validate_slab_node(struct kmem_cache *s,
 		goto out;
 
 	list_for_each_entry(page, &n->full, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab(s, page);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -4452,15 +4466,11 @@ static long validate_slab_cache(struct kmem_cache *s)
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
@@ -4590,18 +4600,17 @@ static int add_location(struct loc_track *t, struct kmem_cache *s,
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
@@ -4612,11 +4621,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
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
@@ -4631,9 +4638,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->partial, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		list_for_each_entry(page, &n->full, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
 
@@ -4682,7 +4689,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	}
 
 	free_loc_track(&t);
-	bitmap_free(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
-- 
2.23.0.237.gc6a4ce50a0-goog


