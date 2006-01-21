Date: Fri, 20 Jan 2006 17:12:46 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: [PATCH] use 32 bit division in slab_put_obj()
Message-ID: <20060121011245.GA24301@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The patch below improves the performance of slab_put_obj().  Without the 
cast, gcc considers ptrdiff_t a 64 bit signed integer and ends up emitting 
code to use a full signed 128 bit divide on EM64T, which is substantially 
slower than a 32 bit unsigned divide.  I noticed this when looking at the 
profile of a case where the slab balance is just on edge and thrashes back 
and forth freeing a block.

Signed-off-by: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
diff -X work-2.6.16-rc1-mm2/Documentation/dontdiff -urP /home/bcrl/kernels/v2.6/linux-2.6.16-rc1-mm2/mm/slab.c work-2.6.16-rc1-mm2/mm/slab.c
--- /home/bcrl/kernels/v2.6/linux-2.6.16-rc1-mm2/mm/slab.c	2006-01-20 15:20:16.000000000 -0500
+++ work-2.6.16-rc1-mm2/mm/slab.c	2006-01-20 16:41:59.000000000 -0500
@@ -2267,8 +2267,12 @@
 static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp, void *objp,
 			  int nodeid)
 {
-	unsigned int objnr = (objp - slabp->s_mem) / cachep->buffer_size;
+	/* Slabs are always <4GB in size, so use a less expensive division. */
+	unsigned objnr = (unsigned)(objp - slabp->s_mem) / cachep->buffer_size;
 
+#if DEBUG
+	WARN_ON((unsigned long)(objp - slabp->s_mem) > ~0U);
+#endif
 #if 0
 	/* Verify that the slab belongs to the intended node */
 	WARN_ON(slabp->nodeid != nodeid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
