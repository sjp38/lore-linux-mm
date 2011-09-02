Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8AF0E900150
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:47 -0400 (EDT)
Message-Id: <20110902204744.967258513@linux.com>
Date: Fri, 02 Sep 2011 15:47:07 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 10/12] slub: Enable use of get_partial with interrupts enabled
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=irq_enabled_acquire_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Need to disable interrupts when taking the node list lock.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 10:12:03.601176577 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 10:12:25.981176437 -0500
@@ -1609,6 +1609,7 @@ static struct page *get_partial_node(str
 					struct kmem_cache_node *n)
 {
 	struct page *page;
+	unsigned long flags;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1619,13 +1620,13 @@ static struct page *get_partial_node(str
 	if (!n || !n->nr_partial)
 		return NULL;
 
-	spin_lock(&n->list_lock);
+	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry(page, &n->partial, lru)
 		if (acquire_slab(s, n, page))
 			goto out;
 	page = NULL;
 out:
-	spin_unlock(&n->list_lock);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
