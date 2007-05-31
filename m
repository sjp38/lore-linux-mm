Message-Id: <20070531003012.989601160@sgi.com>
References: <20070531002047.702473071@sgi.com>
Date: Wed, 30 May 2007 17:20:51 -0700
From: clameter@sgi.com
Subject: [RFC 4/4] CONFIG_STABLE: SLUB: Prefer object corruption over failure
Content-Disposition: inline; filename=stable_slub_robust
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

I am not sure if this is the right thing to do .... I suspect there may be
people on both side of the issue.

SLUB places its free pointer in the first word of an object. There it is very
vulnerable since write after frees usually occur to the first word. If
objects are tighly packed then the writes after the object boundary will
also immediately hit free pointer. A corrupted free pointer typically
leads to a deferencing of a pointer to nowhere and the system will
stop with a bad pointer dereference.

While this is good for development (we catch lots of cases that would
otherwise corrupt slab objects) it is desirable for stable releases that
SLUB behaves more like SLAB: Tolerate object corruption in order to let
the system continue its work.

This patch produces that type of SLAB behavior in SLUB for CONFIG_STABLE by
moving the free pointer to the second word of the object. The first word
can then be overwritten and the SLUB will continue without noticing (unless
we boot with slub_debug).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-30 16:40:40.000000000 -0700
+++ slub/mm/slub.c	2007-05-30 16:41:57.000000000 -0700
@@ -374,7 +374,7 @@ static struct track *get_track(struct km
 {
 	struct track *p;
 
-	if (s->offset)
+	if (s->offset > s->objsize)
 		p = object + s->offset + sizeof(void *);
 	else
 		p = object + s->inuse;
@@ -387,7 +387,7 @@ static void set_track(struct kmem_cache 
 {
 	struct track *p;
 
-	if (s->offset)
+	if (s->offset > s->objsize)
 		p = object + s->offset + sizeof(void *);
 	else
 		p = object + s->inuse;
@@ -484,7 +484,7 @@ static void print_trailer(struct kmem_ca
 		print_section("Redzone", p + s->objsize,
 			s->inuse - s->objsize);
 
-	if (s->offset)
+	if (s->offset > s->objsize)
 		off = s->offset + sizeof(void *);
 	else
 		off = s->inuse;
@@ -618,7 +618,7 @@ static int check_pad_bytes(struct kmem_c
 {
 	unsigned long off = s->inuse;	/* The end of info */
 
-	if (s->offset)
+	if (s->offset > s->objsize)
 		/* Freepointer is placed after the object. */
 		off += sizeof(void *);
 
@@ -696,7 +696,7 @@ static int check_object(struct kmem_cach
 		check_pad_bytes(s, page, p);
 	}
 
-	if (!s->offset && active)
+	if (s->offset < s->objsize && active)
 		/*
 		 * Object and freepointer overlap. Cannot check
 		 * freepointer while object is allocated.
@@ -1947,6 +1947,25 @@ static int calculate_sizes(struct kmem_c
 	 */
 	size = ALIGN(size, sizeof(void *));
 
+
+#ifdef CONFIG_STABLE
+	if (size >= 2*sizeof(void *)) {
+		/*
+		 * For SLUB robustness we use the second word. The first word
+		 * is likely to be corrupted by write after the object end or
+		 * write after free. This means we do not fail because of
+		 * a corrupted free pointer. We continue with the corrupted
+		 * object like SLAB.
+		 */
+		s->offset = sizeof(void *);
+	} else
+#endif
+	/*
+	 * Object is too small to push back the free pointer a word. Or this is
+	 * not a release kernel. We prefer failures over object corruption.
+	 */
+	s->offset = 0;
+
 #ifdef CONFIG_SLUB_DEBUG
 	/*
 	 * If we are Redzoning then check if there is some space between the

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
