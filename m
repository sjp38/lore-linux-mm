Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B04F86B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 11:53:12 -0500 (EST)
Date: Tue, 22 Nov 2011 10:53:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: slub: Lockout validation scans during freeing of object
In-Reply-To: <alpine.DEB.2.00.1111221040300.28197@router.home>
Message-ID: <alpine.DEB.2.00.1111221052130.28197@router.home>
References: <alpine.DEB.2.00.1111221033350.28197@router.home> <alpine.DEB.2.00.1111221040300.28197@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

A bit heavy handed locking but this should do the trick.

Subject: slub: Lockout validation scans during freeing of object

Slab validation can run right now while the slab free paths prepare
the redzone fields etc around the objects in preparation of the
actual freeing of the object. This can lead to false positives.

Take the node lock unconditionally during free so that the validation
can examine objects without them being disturbed by freeing operations.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-22 10:42:19.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-11-22 10:44:34.000000000 -0600
@@ -2391,8 +2391,15 @@ static void __slab_free(struct kmem_cach

 	stat(s, FREE_SLOWPATH);

-	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
-		return;
+	if (kmem_cache_debug(s)) {
+
+		/* Lock out any concurrent validate_slab calls */
+		n = get_node(s, page_to_nid(page));
+		spin_lock_irqsave(&n->list_lock, flags);
+
+		if (!free_debug_processing(s, page, x, addr))
+			goto out;
+	}

 	do {
 		prior = page->freelist;
@@ -2471,6 +2478,7 @@ static void __slab_free(struct kmem_cach
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
+out:
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
