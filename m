Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 470F06B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:44:03 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so7689049pab.19
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:44:02 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id xk2si22263358pab.129.2014.02.03.15.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 15:44:02 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so7641755pbb.6
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:44:02 -0800 (PST)
Date: Mon, 3 Feb 2014 15:44:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.14] mm, slub: list_lock may not be held in some
 circumstances
In-Reply-To: <20140203234105.GA10614@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402031542280.7643@chino.kir.corp.google.com>
References: <52EFF658.2080001@lwfinger.net> <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com> <52F0215B.5040209@lwfinger.net> <20140203234105.GA10614@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Commit c65c1877bd68 ("slub: use lockdep_assert_held") incorrectly required 
that add_full() and remove_full() hold n->list_lock.  The lock is only 
taken when kmem_cache_debug(s), since that's the only time it actually 
does anything.

Require that the lock only be taken under such a condition.

Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Tested-by: Larry Finger <Larry.Finger@lwfinger.net>
Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Christoph Lameter <cl@linux.com>
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
