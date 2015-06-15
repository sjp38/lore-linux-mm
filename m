Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id F12866B0074
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:42 -0400 (EDT)
Received: by qcsf5 with SMTP id f5so4755422qcs.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 202si2279309qhg.2.2015.06.15.08.52.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:42 -0700 (PDT)
Subject: [PATCH 5/7] slub: kmem_cache_alloc_bulk() move clearing outside IRQ
 disabled section
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:36 +0200
Message-ID: <20150615155236.18824.56477.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Move clearing of objects outside IRQ disabled section,
to minimize time spend with local IRQs off.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d10de5a33c03..26f64005a347 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2781,13 +2781,18 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
-
-		if (unlikely(flags & __GFP_ZERO))
-			memset(object, 0, s->object_size);
 	}
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
 
+	/* Clear memory outside IRQ disabled fastpath loop */
+	if (unlikely(flags & __GFP_ZERO)) {
+		int j;
+
+		for (j = 0; j < i; j++)
+			memset(p[j], 0, s->object_size);
+	}
+
 	/* Fallback to single elem alloc */
 	for (; i < size; i++) {
 		void *x = p[i] = kmem_cache_alloc(s, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
