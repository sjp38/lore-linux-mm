Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C85BE6B0093
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:34 -0500 (EST)
Message-Id: <20111111200731.765795755@linux.com>
Date: Fri, 11 Nov 2011 14:07:21 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 10/18] slub: Enable use of get_partial with interrupts enabled
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=irq_enabled_acquire_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Need to disable interrupts when taking the nodelist lock.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:48.831693571 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:53.611721013 -0600
@@ -1532,6 +1532,7 @@ static void *get_partial_node(struct kme
 {
 	struct page *page, *page2;
 	void *object = NULL;
+	unsigned long flags;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1542,7 +1543,7 @@ static void *get_partial_node(struct kme
 	if (!n || !n->nr_partial)
 		return NULL;
 
-	spin_lock(&n->list_lock);
+	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
 		void *t = acquire_slab(s, n, page, object == NULL);
 		int available;
@@ -1563,7 +1564,7 @@ static void *get_partial_node(struct kme
 			break;
 
 	}
-	spin_unlock(&n->list_lock);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 	return object;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
