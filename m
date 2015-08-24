Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8716B0254
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 20:59:08 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so59271194qkb.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 17:59:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a108si25759486qga.15.2015.08.23.17.59.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 17:59:07 -0700 (PDT)
Subject: [PATCH V2 2/3] slub: optimize bulk slowpath free by detached
 freelist
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 24 Aug 2015 02:59:04 +0200
Message-ID: <20150824005857.2947.51229.stgit@localhost>
In-Reply-To: <20150824005727.2947.36065.stgit@localhost>
References: <20150824005727.2947.36065.stgit@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org
Cc: aravinda@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

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
---
 mm/slub.c |   48 +++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 41 insertions(+), 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 10b57a3bb895..40e4b5926311 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2756,12 +2756,26 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
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
@@ -2778,22 +2792,42 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 
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
