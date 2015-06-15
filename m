Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 41E476B0078
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:53:03 -0400 (EDT)
Received: by qkfe185 with SMTP id e185so15408657qkf.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:53:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e9si13156875qka.58.2015.06.15.08.53.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:53:02 -0700 (PDT)
Subject: [PATCH 7/7] slub: initial bulk free implementation
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:56 +0200
Message-ID: <20150615155256.18824.42651.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
now both have bulk alloc and free implemented.

Play nice and reenable local IRQs while calling slowpath.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 98d0e6f73ec1..cc4f870677bb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
 
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
-	__kmem_cache_free_bulk(s, size, p);
+	struct kmem_cache_cpu *c;
+	struct page *page;
+	int i;
+
+	local_irq_disable();
+	c = this_cpu_ptr(s->cpu_slab);
+
+	for (i = 0; i < size; i++) {
+		void *object = p[i];
+
+		if (unlikely(!object))
+			continue; // HOW ABOUT BUG_ON()???
+
+		page = virt_to_head_page(object);
+		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
+
+		if (c->page == page) {
+			/* Fastpath: local CPU free */
+			set_freepointer(s, object, c->freelist);
+			c->freelist = object;
+		} else {
+			c->tid = next_tid(c->tid);
+			local_irq_enable();
+			/* Slowpath: overhead locked cmpxchg_double_slab */
+			__slab_free(s, page, object, _RET_IP_);
+			local_irq_disable();
+			c = this_cpu_ptr(s->cpu_slab);
+		}
+	}
+	c->tid = next_tid(c->tid);
+	local_irq_enable();
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
