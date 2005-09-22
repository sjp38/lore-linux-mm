Received: from hastur.corp.sgi.com (hastur.corp.sgi.com [198.149.32.33])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j8MJWaxT023650
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 14:32:37 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by hastur.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j8MJWUeS195365221
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 12:32:30 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j8MJWasT90919333
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 12:32:36 -0700 (PDT)
Date: Thu, 22 Sep 2005 12:32:36 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] __kmalloc: Generate BUG if size requested is too large.
Message-ID: <Pine.LNX.4.62.0509221232140.17975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I had an issue on ia64 where I got a bug in kernel/workqueue because kzalloc
returned a NULL pointer due to the task structure getting too big for the slab
allocator. Usually these cases are caught by the kmalloc macro in include/linux/slab.h.
Compilation will fail if a too big value is passed to kmalloc.

However, kzalloc uses __kmalloc which has no check for that. This patch makes __kmalloc
bug if a too large entity is requested.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/mm/slab.c
===================================================================
--- linux-2.6.14-rc2.orig/mm/slab.c	2005-09-22 11:21:07.000000000 -0700
+++ linux-2.6.14-rc2/mm/slab.c	2005-09-22 11:58:45.000000000 -0700
@@ -2906,8 +2906,7 @@ void *__kmalloc(size_t size, unsigned in
 	 * functions.
 	 */
 	cachep = __find_general_cachep(size, flags);
-	if (unlikely(cachep == NULL))
-		return NULL;
+	BUG_ON(!cachep);		/* Allocation size too large for kmalloc */
 	return __cache_alloc(cachep, flags);
 }
 EXPORT_SYMBOL(__kmalloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
