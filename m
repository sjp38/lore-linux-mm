Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44FB7600806
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:30:48 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 30/31] Fix use of uninitialized variable in cache_grow()
Date: Thu,  1 Oct 2009 19:40:57 +0530
Message-Id: <1254406257-16735-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Miklos Szeredi <mszeredi@suse.cz>

This fixes a bug in reserve-slub.patch.

If cache_grow() was called with objp != NULL then the 'reserve' local
variable wasn't initialized. This resulted in ac->reserve being set to
a rubbish value.  Due to this in some circumstances huge amounts of
slab pages were allocated (due to slab_force_alloc() returning true),
which caused atomic page allocation failures and slowdown of the
system.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 mm/slab.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: mmotm/mm/slab.c
===================================================================
--- mmotm.orig/mm/slab.c
+++ mmotm/mm/slab.c
@@ -2760,7 +2760,7 @@ static int cache_grow(struct kmem_cache
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
-	int reserve;
+	int reserve = -1;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2816,7 +2816,8 @@ static int cache_grow(struct kmem_cache
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
-	slab_set_reserve(cachep, reserve);
+	if (reserve != -1)
+		slab_set_reserve(cachep, reserve);
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
