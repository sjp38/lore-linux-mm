Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7A40C6B00F5
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:35:19 -0400 (EDT)
Message-Id: <20120523203517.587788826@linux.com>
Date: Wed, 23 May 2012 15:34:55 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 22/22] Common object size alignment
References: <20120523203433.340661918@linux.com>
Content-Disposition: inline; filename=align_size
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

All allocators align the objects to a word boundary. Put that into
common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |   10 ----------
 mm/slab_common.c |    3 ++-
 mm/slub.c        |    7 -------
 3 files changed, 2 insertions(+), 18 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-23 09:13:05.938664721 -0500
+++ linux-2.6/mm/slab.c	2012-05-23 09:13:30.758664204 -0500
@@ -2240,16 +2240,6 @@ int __kmem_cache_create(struct kmem_cach
 	BUG_ON(flags & ~CREATE_MASK);
 
 	/*
-	 * Check that size is in terms of words.  This is needed to avoid
-	 * unaligned accesses for some archs when redzoning is used, and makes
-	 * sure any on-slab bufctl's are also correctly aligned.
-	 */
-	if (size & (BYTES_PER_WORD - 1)) {
-		size += (BYTES_PER_WORD - 1);
-		size &= ~(BYTES_PER_WORD - 1);
-	}
-
-	/*
 	 * Redzoning and user store require word alignment or possibly larger.
 	 * Note this will be overridden by architecture or caller mandated
 	 * alignment if either is greater than BYTES_PER_WORD.
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-23 09:13:05.974664718 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-23 09:14:49.634662589 -0500
@@ -127,6 +127,7 @@ struct kmem_cache *kmem_cache_create(con
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif
 
+	/* Align size to a word boundary */
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
 		goto oops;
@@ -144,7 +145,7 @@ struct kmem_cache *kmem_cache_create(con
 
 	s->name = n;
 	s->ctor = ctor;
-	s->size = size;
+	s->size = ALIGN(s->size, sizeof(void *));
 	s->align = calculate_alignment(flags, align, size);
 	s->flags = flags;
 	r = __kmem_cache_create(s);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-23 09:13:05.954664718 -0500
+++ linux-2.6/mm/slub.c	2012-05-23 09:13:30.762664204 -0500
@@ -2860,13 +2860,6 @@ static int calculate_sizes(struct kmem_c
 	unsigned long align = s->align;
 	int order;
 
-	/*
-	 * Round up object size to the next word boundary. We can only
-	 * place the free pointer at word boundaries and this determines
-	 * the possible location of the free pointer.
-	 */
-	size = ALIGN(size, sizeof(void *));
-
 #ifdef CONFIG_SLUB_DEBUG
 	/*
 	 * Determine if we can poison the object itself. If the user of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
