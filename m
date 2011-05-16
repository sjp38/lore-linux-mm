Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 06EB290010C
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:26 -0400 (EDT)
Message-Id: <20110516202622.292494949@linux.com>
Date: Mon, 16 May 2011 15:26:07 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 02/25] slub: Fix control flow in slab_alloc
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=fixup44
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 13:00:39.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 13:01:40.171457827 -0500
@@ -1833,7 +1833,6 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-load_from_page:
 		c->node = page_to_nid(page);
 		c->page = page;
 		goto load_freelist;
@@ -1856,8 +1855,9 @@ load_from_page:
 
 		slab_lock(page);
 		__SetPageSlubFrozen(page);
-
-		goto load_from_page;
+		c->node = page_to_nid(page);
+		c->page = page;
+		goto load_freelist;
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
