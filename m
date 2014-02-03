Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF4D6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 15:39:38 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so7544568pbb.9
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 12:39:38 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id n8si21858342pax.15.2014.02.03.12.39.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 12:39:36 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so7272878pdj.18
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 12:39:36 -0800 (PST)
Date: Mon, 3 Feb 2014 12:39:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Kernel WARNING splat in 3.14-rc1
In-Reply-To: <52EFF658.2080001@lwfinger.net>
Message-ID: <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
References: <52EFF658.2080001@lwfinger.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>, Pekka Enberg <penberg@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Commit c65c1877bd68 ("slub: use lockdep_assert_held") incorrectly required 
that add_full() and remove_full() hold n->list_lock.  The lock is only 
taken when kmem_cache_debug(s), since that's the only time it actually 
does anything.

Require that the lock only be taken under such a condition.

Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1004,21 +1004,19 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 static void add_full(struct kmem_cache *s,
 	struct kmem_cache_node *n, struct page *page)
 {
-	lockdep_assert_held(&n->list_lock);
-
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
+	lockdep_assert_held(&n->list_lock);
 	list_add(&page->lru, &n->full);
 }
 
 static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
 {
-	lockdep_assert_held(&n->list_lock);
-
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
+	lockdep_assert_held(&n->list_lock);
 	list_del(&page->lru);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
