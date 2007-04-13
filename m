From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070413013640.17093.37934.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
References: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 2/5] Add after object padding
Date: Thu, 12 Apr 2007 18:36:40 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Without padding there is the danger that we do not notice writing
before the allocated object. So increase the slab size by another
word in the debug case. That will force the creation of some fill
space which SLUB will continue to check.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 16:44:13.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 16:45:18.000000000 -0700
@@ -484,7 +484,7 @@ static int check_object(struct kmem_cach
 	if (s->flags & SLAB_POISON) {
 		if (!active && (s->flags & __OBJECT_POISON) &&
 			(!check_bytes(p, POISON_FREE, s->objsize - 1) ||
-				p[s->objsize -1] != POISON_END)) {
+				p[s->objsize - 1] != POISON_END)) {
 			object_err(s, page, p, "Poison check failed");
 			return 0;
 		}
@@ -1623,6 +1623,15 @@ static int calculate_sizes(struct kmem_c
 		 */
 		size += 2 * sizeof(struct track);
 
+	if (flags & DEBUG_DEFAULT_FLAGS)
+		/*
+		 * Add some empty padding so that we can catch
+		 * overwrites from earlier objects rather than let
+		 * tracking information or the free pointer be
+		 * corrupted if an user writes before the start
+		 * of the object.
+		 */
+		size += sizeof(void *);
 	/*
 	 * Determine the alignment based on various parameters that the
 	 * user specified (this is unecessarily complex due to the attempt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
