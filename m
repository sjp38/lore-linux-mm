Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 265B38E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:01 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so2961039qtb.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:01 -0800 (PST)
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id s188si603132qkh.260.2018.12.20.11.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:22:00 -0800 (PST)
Message-ID: <01000167cd1143e3-1533fccc-7036-4a4e-97ea-5be8b347bbf0-000000@email.amazonses.com>
Date: Thu, 20 Dec 2018 19:22:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 4/7] slub: Sort slab cache list and establish maximum objects for defrag slabs
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=sort_and_max
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Determine the maximum number of objects in defragmentable slabs. This allows
the sizing of the array holding refs to objects in a slab later.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -196,6 +196,9 @@ static inline bool kmem_cache_has_cpu_pa
 /* Use cmpxchg_double */
 #define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000U)
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects;
+
 /*
  * Tracking user of a slab.
  */
@@ -4310,22 +4313,45 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+/*
+ * Allocate a slab scratch space that is sufficient to keep at least
+ * max_defrag_slab_objects pointers to individual objects and also a bitmap
+ * for max_defrag_slab_objects.
+ */
+static inline void *alloc_scratch(void)
+{
+	return kmalloc(max_defrag_slab_objects * sizeof(void *) +
+		BITS_TO_LONGS(max_defrag_slab_objects) * sizeof(unsigned long),
+		GFP_KERNEL);
+}
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 	kmem_isolate_func isolate, kmem_migrate_func migrate)
 {
+	int max_objects = oo_objects(s->max);
+
 	/*
 	 * Defragmentable slabs must have a ctor otherwise objects may be
 	 * in an undetermined state after they are allocated.
 	 */
 	BUG_ON(!s->ctor);
+
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
+
 	/*
 	 * Sadly serialization requirements currently mean that we have
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
 
+	list_move(&s->list, &slab_caches);	/* Move to top */
+	if (max_objects > max_defrag_slab_objects)
+		max_defrag_slab_objects = max_objects;
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -393,7 +393,7 @@ static struct kmem_cache *create_cache(c
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)
