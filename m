Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D53166B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 01:44:59 -0500 (EST)
Subject: [patch]slub: add missed accounting
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Nov 2011 14:54:14 +0800
Message-ID: <1320994454.22361.259.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

With per-cpu partial list, slab is added to partial list first and then moved
to node list. The __slab_free() code path for add/remove_partial is almost
deprecated(except for slub debug). But we forget to account add/remove_partial
when move per-cpu partial pages to node list, so the statistics for such events
are always 0. Add corresponding accounting.

This is against the patch "slub: use correct parameter to add a page to
partial list tail"

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/slub.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-11-11 14:43:38.000000000 +0800
+++ linux/mm/slub.c	2011-11-11 14:43:40.000000000 +0800
@@ -1901,11 +1901,14 @@ static void unfreeze_partials(struct kme
 			}
 
 			if (l != m) {
-				if (l == M_PARTIAL)
+				if (l == M_PARTIAL) {
 					remove_partial(n, page);
-				else
+					stat(s, FREE_REMOVE_PARTIAL);
+				} else {
 					add_partial(n, page,
 						DEACTIVATE_TO_TAIL);
+					stat(s, FREE_ADD_PARTIAL);
+				}
 
 				l = m;
 			}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
