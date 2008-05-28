Date: Wed, 28 May 2008 10:32:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slub: Add check for kfree() of non slab objects.
Message-ID: <Pine.LNX.4.64.0805281031120.22637@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We can detect kfree()s on non slab objects by checking for PageCompound().
Works in the same way as for ksize. This helped me catch an invalid 
kfree().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-05-27 21:28:55.000000000 -0700
+++ linux-2.6/mm/slub.c	2008-05-28 00:04:14.000000000 -0700
@@ -2765,6 +2765,7 @@
 
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
+		BUG_ON(!PageCompound(page));
 		put_page(page);
 		return;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
