Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DEEB66B0068
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 06:31:13 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 04/25] Wipe out CFLGS_OFF_SLAB from flags during initial slab creation
Date: Mon, 18 Jun 2012 14:27:57 +0400
Message-Id: <1340015298-14133-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-1-git-send-email-glommer@parallels.com>
References: <1340015298-14133-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

CFLGS_OFF_SLAB is not a valid flag to be passed to cache creation.
If we are duplicating a cache - support added in a future patch -
we will rely on the flags it has stored in itself. That may include
CFLGS_OFF_SLAB.

So it is better to clean this flag at cache creation.

CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 2d5fe28..c30a61c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2201,6 +2201,12 @@ int __kmem_cache_create(struct kmem_cache *cachep)
 		BUG_ON(flags & SLAB_POISON);
 #endif
 	/*
+	 * Passing this flag at creation time is invalid, but if we're
+	 * duplicating a slab, it may happen.
+	 */
+	flags &= ~CFLGS_OFF_SLAB;
+
+	/*
 	 * Always checks flags, a caller might be expecting debug support which
 	 * isn't available.
 	 */
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
