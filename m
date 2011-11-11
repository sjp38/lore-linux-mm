Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 881566B008C
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:34 -0500 (EST)
Message-Id: <20111111200732.417476845@linux.com>
Date: Fri, 11 Nov 2011 14:07:22 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 11/18] slub: Acquire_slab() avoid loop
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=simplify
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Avoid the loop in acquire slab and simply fail if there is a conflict.

This will cause the next page on the lisdt to be considered.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 16:05:42.632059449 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 16:06:06.802192215 -0600
@@ -1503,22 +1503,25 @@ static inline void *acquire_slab(struct
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	do {
-		freelist = page->freelist;
-		counters = page->counters;
-		new.counters = counters;
-		if (mode)
-			new.inuse = page->objects;
+	freelist = page->freelist;
+	counters = page->counters;
+	new.counters = counters;
+	new.inuse = page->objects;
+	if (mode)
+		new.inuse = page->objects;
 
-		VM_BUG_ON(new.frozen);
-		new.frozen = 1;
+	VM_BUG_ON(new.frozen);
+	new.frozen = 1;
 
-	} while (!__cmpxchg_double_slab(s, page,
+	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
 			NULL, new.counters,
-			"lock and freeze"));
+			"acquire_slab"))
+
+		return NULL;
 
 	remove_partial(n, page);
+	WARN_ON(!freelist);
 	return freelist;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
