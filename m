Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id EF0446B006C
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:05:19 -0400 (EDT)
Received: by oifl3 with SMTP id l3so35417302oif.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:05:19 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ci11si3106696pdb.144.2015.03.19.07.05.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 07:05:19 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so76714578pac.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:05:19 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [RFC v2 2/3] mm/vmalloc: occupy newly allocated vmap block just after allocation
Date: Thu, 19 Mar 2015 23:04:40 +0900
Message-Id: <1426773881-5757-3-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Previous implementation allocates new vmap block and repeats search of a free
block from the very beginning, iterating over the CPU free list.

Why it can be better??

1. Allocation can happen on one CPU, but search can be done on another CPU.
   In worst case we preallocate amount of vmap blocks which is equal to
   CPU number on the system.

2. In previous patch I added newly allocated block to the tail of free list
   to avoid soon exhaustion of virtual space and give a chance to occupy
   blocks which were allocated long time ago.  Thus to find newly allocated
   block all the search sequence should be repeated, seems it is not efficient.

In this patch newly allocated block is occupied right away, address of virtual
space is returned to the caller, so there is no any need to repeat the search
sequence, allocation job is done.

Signed-off-by: Roman Pen <r.peniaev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: WANG Chao <chaowang@redhat.com>
Cc: Fabian Frederick <fabf@skynet.be>
Cc: Christoph Lameter <cl@linux.com>
Cc: Gioh Kim <gioh.kim@lge.com>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 58 +++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 37 insertions(+), 21 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index db6bffb..9bd102c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -791,13 +791,31 @@ static unsigned long addr_to_vb_idx(unsigned long addr)
 	return addr;
 }
 
-static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
+static void *vmap_block_vaddr(unsigned long va_start, unsigned long pages_off)
+{
+	unsigned long addr;
+
+	addr = va_start + (pages_off << PAGE_SHIFT);
+	BUG_ON(addr_to_vb_idx(addr) != addr_to_vb_idx(va_start));
+	return (void *)addr;
+}
+
+/**
+ * new_vmap_block - allocates new vmap_block and occupies 2^order pages in this
+ *                  block. Of course pages number can't exceed VMAP_BBMAP_BITS
+ * @order:    how many 2^order pages should be occupied in newly allocated block
+ * @gfp_mask: flags for the page level allocator
+ *
+ * Returns: virtual address in a newly allocated block or ERR_PTR(-errno)
+ */
+static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 {
 	struct vmap_block_queue *vbq;
 	struct vmap_block *vb;
 	struct vmap_area *va;
 	unsigned long vb_idx;
 	int node, err;
+	void *vaddr;
 
 	node = numa_node_id();
 
@@ -821,9 +839,12 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 		return ERR_PTR(err);
 	}
 
+	vaddr = vmap_block_vaddr(va->va_start, 0);
 	spin_lock_init(&vb->lock);
 	vb->va = va;
-	vb->free = VMAP_BBMAP_BITS;
+	/* At least something should be left free */
+	BUG_ON(VMAP_BBMAP_BITS <= (1UL << order));
+	vb->free = VMAP_BBMAP_BITS - (1UL << order);
 	vb->dirty = 0;
 	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
 	INIT_LIST_HEAD(&vb->free_list);
@@ -841,7 +862,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_block_queue);
 
-	return vb;
+	return vaddr;
 }
 
 static void free_vmap_block(struct vmap_block *vb)
@@ -905,7 +926,7 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 {
 	struct vmap_block_queue *vbq;
 	struct vmap_block *vb;
-	unsigned long addr = 0;
+	void *vaddr = NULL;
 	unsigned int order;
 
 	BUG_ON(size & ~PAGE_MASK);
@@ -920,43 +941,38 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 	}
 	order = get_order(size);
 
-again:
 	rcu_read_lock();
 	vbq = &get_cpu_var(vmap_block_queue);
 	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
-		int i;
+		unsigned long pages_off;
 
 		spin_lock(&vb->lock);
-		if (vb->free < 1UL << order)
-			goto next;
+		if (vb->free < (1UL << order)) {
+			spin_unlock(&vb->lock);
+			continue;
+		}
 
-		i = VMAP_BBMAP_BITS - vb->free;
-		addr = vb->va->va_start + (i << PAGE_SHIFT);
-		BUG_ON(addr_to_vb_idx(addr) !=
-				addr_to_vb_idx(vb->va->va_start));
+		pages_off = VMAP_BBMAP_BITS - vb->free;
+		vaddr = vmap_block_vaddr(vb->va->va_start, pages_off);
 		vb->free -= 1UL << order;
 		if (vb->free == 0) {
 			spin_lock(&vbq->lock);
 			list_del_rcu(&vb->free_list);
 			spin_unlock(&vbq->lock);
 		}
+
 		spin_unlock(&vb->lock);
 		break;
-next:
-		spin_unlock(&vb->lock);
 	}
 
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
 
-	if (!addr) {
-		vb = new_vmap_block(gfp_mask);
-		if (IS_ERR(vb))
-			return vb;
-		goto again;
-	}
+	/* Allocate new block if nothing was found */
+	if (!vaddr)
+		vaddr = new_vmap_block(order, gfp_mask);
 
-	return (void *)addr;
+	return vaddr;
 }
 
 static void vb_free(const void *addr, unsigned long size)
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
