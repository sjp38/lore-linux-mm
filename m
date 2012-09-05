Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E15A26B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 22:33:28 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 5 Sep 2012 12:31:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q852XKYE22151168
	for <linux-mm@kvack.org>; Wed, 5 Sep 2012 12:33:21 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q852XJJx032741
	for <linux-mm@kvack.org>; Wed, 5 Sep 2012 12:33:20 +1000
Message-ID: <5046B9EE.7000804@linux.vnet.ibm.com>
Date: Wed, 05 Sep 2012 10:33:18 +0800
From: Michael Wang <wangyun@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] slab: fix the DEADLOCK issue on l3 alien lock
References: <5044692D.7080608@linux.vnet.ibm.com>
In-Reply-To: <5044692D.7080608@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

DEADLOCK will be report while running a kernel with NUMA and LOCKDEP enabled,
the process of this fake report is:

	   kmem_cache_free()	//free obj in cachep
	-> cache_free_alien()	//acquire cachep's l3 alien lock
	-> __drain_alien_cache()
	-> free_block()
	-> slab_destroy()
	-> kmem_cache_free()	//free slab in cachep->slabp_cache
	-> cache_free_alien()	//acquire cachep->slabp_cache's l3 alien lock

Since the cachep and cachep->slabp_cache's l3 alien are in the same lock class,
fake report generated.

This should not happen since we already have init_lock_keys() which will
reassign the lock class for both l3 list and l3 alien.

However, init_lock_keys() was invoked at a wrong position which is before we
invoke enable_cpucache() on each cache.

Since until set slab_state to be FULL, we won't invoke enable_cpucache()
on caches to build their l3 alien while creating them, so although we invoked
init_lock_keys(), the l3 alien lock class won't change since we don't have
them until invoked enable_cpucache() later.

This patch will invoke init_lock_keys() after we done enable_cpucache()
instead of before to avoid the fake DEADLOCK report.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 mm/slab.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d4715e5..cc679ef 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1780,9 +1780,6 @@ void __init kmem_cache_init_late(void)
 
 	slab_state = UP;
 
-	/* Annotate slab for lockdep -- annotate the malloc caches */
-	init_lock_keys();
-
 	/* 6) resize the head arrays to their final sizes */
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(cachep, &slab_caches, list)
@@ -1790,6 +1787,9 @@ void __init kmem_cache_init_late(void)
 			BUG();
 	mutex_unlock(&slab_mutex);
 
+	/* Annotate slab for lockdep -- annotate the malloc caches */
+	init_lock_keys();
+
 	/* Done! */
 	slab_state = FULL;
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
