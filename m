Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 39BE228027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:02:45 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so31325547qkb.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:02:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p71si5906154qkp.16.2015.07.15.09.02.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:02:44 -0700 (PDT)
Subject: [PATCH 2/3] slub: optimize bulk slowpath free by detached freelist
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 15 Jul 2015 18:02:02 +0200
Message-ID: <20150715160145.17525.6500.stgit@devil>
In-Reply-To: <20150715155934.17525.2835.stgit@devil>
References: <20150715155934.17525.2835.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Jesper Dangaard Brouer <brouer@redhat.com>

This change focus on improving the speed of object freeing in the
"slowpath" of kmem_cache_free_bulk.

The slowpath call __slab_free() have been extended with support for
bulk free, which amortize the overhead of the locked cmpxchg_double_slab.

To use the new bulking feature of __slab_free(), we build what I call
a detached freelist.  The detached freelist takes advantage of three
properties:

 1) the free function call owns the object that is about to be freed,
    thus writing into this memory is synchronization-free.

 2) many freelist's can co-exist side-by-side in the same page each
    with a separate head pointer.

 3) it is the visibility of the head pointer that needs synchronization.

Given these properties, the brilliant part is that the detached
freelist can be constructed without any need for synchronization.
The freelist is constructed directly in the page objects, without any
synchronization needed.  The detached freelist is allocated on the
stack of the function call kmem_cache_free_bulk.  Thus, the freelist
head pointer is not visible to other CPUs.

This implementation is fairly simple, as it only builds the detached
freelist if two consecutive objects belongs to the same page.  When
detecting object page does not match, it simply flushes the local
freelist, and starts a new local detached freelist.  It will not
look-ahead to see if further opputunities exists in the

The next patch have a more advanced look-ahead approach, but is also
more complicated. Splitting them up, because I want to be able to
benchmark the simple against the advanced approach.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
bulk- Fallback                  - Bulk API
  1 -  64 cycles(tsc) 16.109 ns - 47 cycles(tsc) 11.894 - improved 26.6%
  2 -  56 cycles(tsc) 14.158 ns - 45 cycles(tsc) 11.274 - improved 19.6%
  3 -  54 cycles(tsc) 13.650 ns - 23 cycles(tsc)  6.001 - improved 57.4%
  4 -  53 cycles(tsc) 13.268 ns - 21 cycles(tsc)  5.262 - improved 60.4%
  8 -  51 cycles(tsc) 12.841 ns - 18 cycles(tsc)  4.718 - improved 64.7%
 16 -  50 cycles(tsc) 12.583 ns - 19 cycles(tsc)  4.896 - improved 62.0%
 30 -  85 cycles(tsc) 21.357 ns - 26 cycles(tsc)  6.549 - improved 69.4%
 32 -  82 cycles(tsc) 20.690 ns - 25 cycles(tsc)  6.412 - improved 69.5%
 34 -  81 cycles(tsc) 20.322 ns - 25 cycles(tsc)  6.365 - improved 69.1%
 48 -  93 cycles(tsc) 23.332 ns - 28 cycles(tsc)  7.139 - improved 69.9%
 64 -  98 cycles(tsc) 24.544 ns - 62 cycles(tsc) 15.543 - improved 36.7%
128 -  96 cycles(tsc) 24.219 ns - 68 cycles(tsc) 17.143 - improved 29.2%
158 - 107 cycles(tsc) 26.817 ns - 69 cycles(tsc) 17.431 - improved 35.5%
250 - 107 cycles(tsc) 26.824 ns - 70 cycles(tsc) 17.730 - improved 34.6%

 mm/slub.c |   48 +++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 41 insertions(+), 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d0841a4c61ea..ce4118566761 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2755,12 +2755,26 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+struct detached_freelist {
+	struct page *page;
+	void *freelist;
+	void *tail_object;
+	int cnt;
+};
+
 /* Note that interrupts must be enabled when calling this function. */
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
 	struct kmem_cache_cpu *c;
 	struct page *page;
 	int i;
+	/* Opportunistically delay updating page->freelist, hoping
+	 * next free happen to same page.  Start building the freelist
+	 * in the page, but keep local stack ptr to freelist.  If
+	 * successful several object can be transferred to page with a
+	 * single cmpxchg_double.
+	 */
+	struct detached_freelist df = {0};
 
 	local_irq_disable();
 	c = this_cpu_ptr(s->cpu_slab);
@@ -2777,22 +2791,42 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 
 		page = virt_to_head_page(object);
 
-		if (c->page == page) {
+		if (page == df.page) {
+			/* Oppotunity to delay real free */
+			set_freepointer(s, object, df.freelist);
+			df.freelist = object;
+			df.cnt++;
+		} else if (c->page == page) {
 			/* Fastpath: local CPU free */
 			set_freepointer(s, object, c->freelist);
 			c->freelist = object;
 		} else {
-			c->tid = next_tid(c->tid);
-			local_irq_enable();
-			/* Slowpath: overhead locked cmpxchg_double_slab */
-			__slab_free(s, page, object, _RET_IP_, NULL, 1);
-			local_irq_disable();
-			c = this_cpu_ptr(s->cpu_slab);
+			/* Slowpath: Flush delayed free */
+			if (df.page) {
+				c->tid = next_tid(c->tid);
+				local_irq_enable();
+				__slab_free(s, df.page, df.tail_object,
+					    _RET_IP_, df.freelist, df.cnt);
+				local_irq_disable();
+				c = this_cpu_ptr(s->cpu_slab);
+			}
+			/* Start new round of delayed free */
+			df.page = page;
+			df.tail_object = object;
+			set_freepointer(s, object, NULL);
+			df.freelist = object;
+			df.cnt = 1;
 		}
 	}
 exit:
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
+
+	/* Flush detached freelist */
+	if (df.page) {
+		__slab_free(s, df.page, df.tail_object,
+			    _RET_IP_, df.freelist, df.cnt);
+	}
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
