Date: Tue, 10 Apr 2007 15:49:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101547290.32218@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> What does that 65536 mean in kmem_cache_open? (Needs comment?)

SLUB: Explain the 64k limits.

Note that these limits could now be removed since we no longer use
page->private for compound pages. But I think this is fine for now.

Signed-off-by: Christoph Lameter <clameter@sgi.com>


Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 15:40:58.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 15:47:16.000000000 -0700
@@ -1594,6 +1594,12 @@ static int calculate_sizes(struct kmem_c
 		return 0;
 
 	s->objects = (PAGE_SIZE << s->order) / size;
+
+	/*
+	 * Verify that the number of objects is within permitted limits.
+	 * The page->inuse field is only 16 bit wide! So we cannot have
+	 * more than 64k objects per slab.
+	 */
 	if (!s->objects || s->objects > 65535)
 		return 0;
 	return 1;
@@ -1616,9 +1622,23 @@ static int kmem_cache_open(struct kmem_c
 
 	BUG_ON(flags & SLUB_UNIMPLEMENTED);
 
-	if (s->size >= 65535 * sizeof(void *))
+	/*
+	 * The page->offset field is only 16 bit wide. This is an offset
+	 * in units of words from the beginning of an object. If the slab
+	 * size is bigger then we cannot move the free pointer behind the
+	 * object anymore.
+	 *
+	 * On 32 bit platforms the limit is 256k. On 64bit platforms
+	 * the limit is 512k.
+	 *
+	 * Debugging or ctor/dtors may create a need to move the free
+	 * pointer. Fail if this happens.
+	 */
+	if (s->size >= 65535 * sizeof(void *)) {
 		BUG_ON(flags & (SLAB_RED_ZONE | SLAB_POISON |
 				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
+		BUG_ON(ctor || dtor);
+	}
 	else
 		/*
 		 * Enable debugging if selected on the kernel commandline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
