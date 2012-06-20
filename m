Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id A589D6B005D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 17:02:59 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/4] Wipe out CFLGS_OFF_SLAB from flags during initial slab creation
Date: Thu, 21 Jun 2012 00:59:17 +0400
Message-Id: <1340225959-1966-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1340225959-1966-1-git-send-email-glommer@parallels.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

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
index bb79652..0d1bd09 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2317,6 +2317,12 @@ kmem_cache_create (const char *name, size_t size, size_t align,
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
