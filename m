Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD9916B00F3
	for <linux-mm@kvack.org>; Sat, 30 May 2009 15:30:26 -0400 (EDT)
Date: Sat, 30 May 2009 12:28:29 -0700
From: "Larry H." <research@subreption.com>
Subject: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
Message-ID: <20090530192829.GK6535@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

[PATCH] Change ZERO_SIZE_PTR to point at unmapped space

This patch changes the ZERO_SIZE_PTR address to point at top memory
unmapped space, instead of the original location which could be
mapped from userland to abuse a NULL (or offset-from-null) pointer
dereference scenario.

The ZERO_OR_NULL_PTR macro is changed accordingly. This patch does
not modify its behavior nor has any performance nor functionality
impact.

The original change was written first by the PaX team for their
patch.

Signed-off-by: Larry Highsmith <larry@subreption.com>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -73,10 +73,9 @@
  * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
  * Both make kfree a no-op.
  */
-#define ZERO_SIZE_PTR ((void *)16)
+#define ZERO_SIZE_PTR ((void *)-1024L)
 
-#define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
-				(unsigned long)ZERO_SIZE_PTR)
+#define ZERO_OR_NULL_PTR(x) (!(x) || (x) == ZERO_SIZE_PTR)
 
 /*
  * struct kmem_cache related prototypes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
