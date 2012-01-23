Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A50216B005A
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:08 -0500 (EST)
Message-Id: <20120123201706.547465637@linux.com>
Date: Mon, 23 Jan 2012 14:16:48 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 2/9] slub: Add frozen check in __slab_alloc
References: <20120123201646.924319545@linux.com>
Content-Disposition: inline; filename=frozen_check_in_slab_free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Verify that objects returned from __slab_alloc come from slab pages
in the correct state.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-01-13 08:47:07.498748874 -0600
+++ linux-2.6/mm/slub.c	2012-01-13 08:47:10.938748802 -0600
@@ -2220,6 +2220,12 @@ redo:
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
+	/*
+	 * freelist is pointing to the list of objects to be used.
+	 * page is pointing to the page from which the objects are obtained.
+	 * That page must be frozen for per cpu allocations to work.
+	 */
+	VM_BUG_ON(!c->page->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
