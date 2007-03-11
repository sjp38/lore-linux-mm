From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070311021021.19963.90870.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
References: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 2/3] Enable poisoning for RCU and constructors
Date: Sat, 10 Mar 2007 18:10:21 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

Enable poisoning / redzoning for slabs with constructors or SLAB_DEWSTROY_BY_RCU

We cannot poison the object itself but we can poison padding spaces and do
the redzoning. For that we introduce another flag controlling object
poisoning.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/mm/slub.c
===================================================================
--- linux-2.6.21-rc3.orig/mm/slub.c	2007-03-09 21:13:02.000000000 -0800
+++ linux-2.6.21-rc3/mm/slub.c	2007-03-09 21:13:44.000000000 -0800
@@ -80,6 +80,9 @@
 #define ARCH_SLAB_MINALIGN sizeof(void *)
 #endif
 
+/* Internal SLUB flags */
+#define __OBJECT_POISON 0x80000000	/* Poison object */
+
 static int kmem_size = sizeof(struct kmem_cache);
 
 #ifdef CONFIG_SMP
@@ -247,8 +250,8 @@
 	if (s->objects == 1)
 		return;
 
-	if (s->flags & SLAB_POISON) {
-		memset(p, POISON_FREE, s->objsize -1);
+	if (s->flags & __OBJECT_POISON) {
+		memset(p, POISON_FREE, s->objsize - 1);
 		p[s->objsize -1] = POISON_END;
 	}
 
@@ -388,7 +391,8 @@
 			object_err(s, page, p, "Alignment padding check fails");
 
 	if (s->flags & SLAB_POISON) {
-		if (!active && (!check_bytes(p, POISON_FREE, s->objsize - 1) ||
+		if (!active && (s->flags & __OBJECT_POISON)
+				&& (!check_bytes(p, POISON_FREE, s->objsize - 1) ||
 				p[s->objsize -1] != POISON_END)) {
 			object_err(s, page, p, "Poison");
 			return 0;
@@ -1371,14 +1375,9 @@
 		strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)) == 0))
 			flags |= slub_debug;
 
-	if ((flags & SLAB_POISON) &&((flags & SLAB_DESTROY_BY_RCU) ||
-			ctor || dtor)) {
-		if (!(slub_debug & SLAB_POISON))
-			printk(KERN_WARNING "SLUB %s: Clearing SLAB_POISON "
-				"because de/constructor exists.\n",
-				s->name);
-		flags &= ~SLAB_POISON;
-	}
+	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
+			!ctor && !dtor)
+		flags |= __OBJECT_POISON;
 
 	tentative_size = ALIGN(size, calculate_alignment(align, flags));
 
@@ -1389,7 +1388,7 @@
 	 */
 	if (size == PAGE_SIZE)
 		flags &= ~(SLAB_RED_ZONE| SLAB_DEBUG_FREE | \
-			SLAB_STORE_USER | SLAB_POISON);
+			SLAB_STORE_USER | SLAB_POISON | __OBJECT_POISON);
 
 	s->name = name;
 	s->ctor = ctor;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
