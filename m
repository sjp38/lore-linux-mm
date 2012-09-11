Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7B6146B00BD
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 05:48:29 -0400 (EDT)
Date: Tue, 11 Sep 2012 17:48:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
Message-ID: <20120911094823.GA29568@localhost>
References: <20120910131426.GA12431@localhost>
 <504E1182.7080300@bfs.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <504E1182.7080300@bfs.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: walter harms <wharms@bfs.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Sep 10, 2012 at 06:12:50PM +0200, walter harms wrote:
> 
> 
> Am 10.09.2012 15:14, schrieb Fengguang Wu:
> > To avoid name conflicts:
> > 
> > drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> > 
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> > ---
> > 
> > Andrew: the conflict happens in Glauber's kmemcg-slab tree.  So it's
> > better to quickly push this pre-fix to upstream before Glauber's patches.
> > 
> > 
> >  include/linux/idr.h |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > --- linux.orig/include/linux/idr.h	2012-09-10 21:08:51.177452944 +0800
> > +++ linux/include/linux/idr.h	2012-09-10 21:08:57.729452732 +0800
> > @@ -43,10 +43,10 @@
> >  #define MAX_ID_MASK (MAX_ID_BIT - 1)
> >  
> >  /* Leave the possibility of an incomplete final layer */
> > -#define MAX_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
> > +#define MAX_ID_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
> >  
> >  /* Number of id_layer structs to leave in free list */
> > -#define IDR_FREE_MAX MAX_LEVEL + MAX_LEVEL
> > +#define IDR_FREE_MAX MAX_ID_LEVEL + MAX_ID_LEVEL
> >  
> 
> To be fair, i am a bit confused by the naming.
> There is MAX_id_LEVEL but idr_BITS are these different things ?

Perhaps not. One is derived from the other.

> If not i would argue to give both the same names either ID or IDR.

I had the same thought, however gave up at the time because it would
make the patch more intrusive. Anyway, here is the new patch for your
comments.

--
idr: Rename MAX_LEVEL to MAX_IDR_LEVEL

To avoid name conflicts:

drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined

While at it, also make the other names more consistent and
add parentheses.

Cc: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: walter harms <wharms@bfs.de>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/idr.h |   10 +++++-----
 lib/idr.c           |   18 +++++++++---------
 2 files changed, 14 insertions(+), 14 deletions(-)

--- linux.orig/include/linux/idr.h	2012-09-11 17:37:41.533777968 +0800
+++ linux/include/linux/idr.h	2012-09-11 17:38:03.841777248 +0800
@@ -38,15 +38,15 @@
 #define IDR_SIZE (1 << IDR_BITS)
 #define IDR_MASK ((1 << IDR_BITS)-1)
 
-#define MAX_ID_SHIFT (sizeof(int)*8 - 1)
-#define MAX_ID_BIT (1U << MAX_ID_SHIFT)
-#define MAX_ID_MASK (MAX_ID_BIT - 1)
+#define MAX_IDR_SHIFT (sizeof(int)*8 - 1)
+#define MAX_IDR_BIT (1U << MAX_IDR_SHIFT)
+#define MAX_IDR_MASK (MAX_IDR_BIT - 1)
 
 /* Leave the possibility of an incomplete final layer */
-#define MAX_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
+#define MAX_IDR_LEVEL ((MAX_IDR_SHIFT + IDR_BITS - 1) / IDR_BITS)
 
 /* Number of id_layer structs to leave in free list */
-#define IDR_FREE_MAX MAX_LEVEL + MAX_LEVEL
+#define MAX_IDR_FREE (MAX_IDR_LEVEL * 2)
 
 struct idr_layer {
 	unsigned long		 bitmap; /* A zero bit means "space here" */
--- linux.orig/lib/idr.c	2012-09-11 17:38:02.381777295 +0800
+++ linux/lib/idr.c	2012-09-11 17:38:09.085777079 +0800
@@ -20,7 +20,7 @@
  * that id to this code and it returns your pointer.
 
  * You can release ids at any time. When all ids are released, most of
- * the memory is returned (we keep IDR_FREE_MAX) in a local pool so we
+ * the memory is returned (we keep MAX_IDR_FREE) in a local pool so we
  * don't need to go to the memory "store" during an id allocate, just
  * so you don't need to be too concerned about locking and conflicts
  * with the slab allocator.
@@ -122,7 +122,7 @@ static void idr_mark_full(struct idr_lay
  */
 int idr_pre_get(struct idr *idp, gfp_t gfp_mask)
 {
-	while (idp->id_free_cnt < IDR_FREE_MAX) {
+	while (idp->id_free_cnt < MAX_IDR_FREE) {
 		struct idr_layer *new;
 		new = kmem_cache_zalloc(idr_layer_cache, gfp_mask);
 		if (new == NULL)
@@ -179,7 +179,7 @@ static int sub_alloc(struct idr *idp, in
 			sh = IDR_BITS*l;
 			id = ((id >> sh) ^ n ^ m) << sh;
 		}
-		if ((id >= MAX_ID_BIT) || (id < 0))
+		if ((id >= MAX_IDR_BIT) || (id < 0))
 			return IDR_NOMORE_SPACE;
 		if (l == 0)
 			break;
@@ -402,7 +402,7 @@ void idr_remove(struct idr *idp, int id)
 	struct idr_layer *to_free;
 
 	/* Mask off upper bits we don't use for the search. */
-	id &= MAX_ID_MASK;
+	id &= MAX_IDR_MASK;
 
 	sub_remove(idp, (idp->layers - 1) * IDR_BITS, id);
 	if (idp->top && idp->top->count == 1 && (idp->layers > 1) &&
@@ -420,7 +420,7 @@ void idr_remove(struct idr *idp, int id)
 		to_free->bitmap = to_free->count = 0;
 		free_layer(to_free);
 	}
-	while (idp->id_free_cnt >= IDR_FREE_MAX) {
+	while (idp->id_free_cnt >= MAX_IDR_FREE) {
 		p = get_from_free_list(idp);
 		/*
 		 * Note: we don't call the rcu callback here, since the only
@@ -517,7 +517,7 @@ void *idr_find(struct idr *idp, int id)
 	n = (p->layer+1) * IDR_BITS;
 
 	/* Mask off upper bits we don't use for the search. */
-	id &= MAX_ID_MASK;
+	id &= MAX_IDR_MASK;
 
 	if (id >= (1 << n))
 		return NULL;
@@ -659,7 +659,7 @@ void *idr_replace(struct idr *idp, void
 
 	n = (p->layer+1) * IDR_BITS;
 
-	id &= MAX_ID_MASK;
+	id &= MAX_IDR_MASK;
 
 	if (id >= (1 << n))
 		return ERR_PTR(-EINVAL);
@@ -793,7 +793,7 @@ int ida_get_new_above(struct ida *ida, i
 	if (t < 0)
 		return _idr_rc_to_errno(t);
 
-	if (t * IDA_BITMAP_BITS >= MAX_ID_BIT)
+	if (t * IDA_BITMAP_BITS >= MAX_IDR_BIT)
 		return -ENOSPC;
 
 	if (t != idr_id)
@@ -827,7 +827,7 @@ int ida_get_new_above(struct ida *ida, i
 	}
 
 	id = idr_id * IDA_BITMAP_BITS + t;
-	if (id >= MAX_ID_BIT)
+	if (id >= MAX_IDR_BIT)
 		return -ENOSPC;
 
 	__set_bit(t, bitmap->bitmap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
