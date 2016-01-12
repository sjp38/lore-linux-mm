Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DBF94403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:13:52 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id 6so352047953qgy.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:13:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k88si107053404qgf.120.2016.01.12.07.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:13:51 -0800 (PST)
Subject: [PATCH V2 01/11] slub: cleanup code for kmem cgroup support to
 kmem_cache_free_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:13:47 +0100
Message-ID: <20160112151336.31725.88215.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This change is primarily an attempt to make it easier to realize the
optimizations the compiler performs in-case CONFIG_MEMCG_KMEM is not
enabled.

Performance wise, even when CONFIG_MEMCG_KMEM is compiled in, the
overhead is zero. This is because, as long as no process have
enabled kmem cgroups accounting, the assignment is replaced by
asm-NOP operations.  This is possible because memcg_kmem_enabled()
uses a static_key_false() construct.

It also helps readability as it avoid accessing the p[] array like:
p[size - 1] which "expose" that the array is processed backwards
inside helper function build_detached_freelist().

Lastly this also makes the code more robust, in error case like
passing NULL pointers in the array. Which were previously handled
before commit 033745189b1b ("slub: add missing kmem cgroup
support to kmem_cache_free_bulk").

Fixes: 033745189b1b ("slub: add missing kmem cgroup support to kmem_cache_free_bulk")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2: used Joonsoo Kim's suggestion to store "s" in struct detached_freelist.
 - Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
 - Verified ASM code generated is still optimal, with different ifdef config's

 mm/slub.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 46997517406e..65d5f92d51d2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2819,6 +2819,7 @@ struct detached_freelist {
 	void *tail;
 	void *freelist;
 	int cnt;
+	struct kmem_cache *s;
 };
 
 /*
@@ -2833,8 +2834,9 @@ struct detached_freelist {
  * synchronization primitive.  Look ahead in the array is limited due
  * to performance reasons.
  */
-static int build_detached_freelist(struct kmem_cache *s, size_t size,
-				   void **p, struct detached_freelist *df)
+static inline
+int build_detached_freelist(struct kmem_cache *s, size_t size,
+			    void **p, struct detached_freelist *df)
 {
 	size_t first_skipped_index = 0;
 	int lookahead = 3;
@@ -2850,8 +2852,11 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 	if (!object)
 		return 0;
 
+	/* Support for memcg, compiler can optimize this out */
+	df->s = cache_from_obj(s, object);
+
 	/* Start new detached freelist */
-	set_freepointer(s, object, NULL);
+	set_freepointer(df->s, object, NULL);
 	df->page = virt_to_head_page(object);
 	df->tail = object;
 	df->freelist = object;
@@ -2866,7 +2871,7 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 		/* df->page is always set at this point */
 		if (df->page == virt_to_head_page(object)) {
 			/* Opportunity build freelist */
-			set_freepointer(s, object, df->freelist);
+			set_freepointer(df->s, object, df->freelist);
 			df->freelist = object;
 			df->cnt++;
 			p[size] = NULL; /* mark object processed */
@@ -2885,25 +2890,20 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 	return first_skipped_index;
 }
 
-
 /* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
 	if (WARN_ON(!size))
 		return;
 
 	do {
 		struct detached_freelist df;
-		struct kmem_cache *s;
-
-		/* Support for memcg */
-		s = cache_from_obj(orig_s, p[size - 1]);
 
 		size = build_detached_freelist(s, size, p, &df);
 		if (unlikely(!df.page))
 			continue;
 
-		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
+		slab_free(df.s, df.page, df.freelist, df.tail, df.cnt,_RET_IP_);
 	} while (likely(size));
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
