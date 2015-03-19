Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7D96B006E
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 17:14:43 -0400 (EDT)
Received: by ykek76 with SMTP id k76so57047600yke.0
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 14:14:43 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id fv6si3081205pdb.149.2015.03.19.07.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 07:05:15 -0700 (PDT)
Received: by padcy3 with SMTP id cy3so76620591pad.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:05:14 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [RFC v2 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space caused by vm_map_ram allocator
Date: Thu, 19 Mar 2015 23:04:39 +0900
Message-Id: <1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

If suitable block can't be found, new block is allocated and put into a head
of a free list, so on next iteration this new block will be found first.

That's bad, because old blocks in a free list will not get a chance to be fully
used, thus fragmentation will grow.

Let's consider this simple example:

 #1 We have one block in a free list which is partially used, and where only
    one page is free:

    HEAD |xxxxxxxxx-| TAIL
                   ^
                   free space for 1 page, order 0

 #2 New allocation request of order 1 (2 pages) comes, new block is allocated
    since we do not have free space to complete this request. New block is put
    into a head of a free list:

    HEAD |----------|xxxxxxxxx-| TAIL

 #3 Two pages were occupied in a new found block:

    HEAD |xx--------|xxxxxxxxx-| TAIL
          ^
          two pages mapped here

 #4 New allocation request of order 0 (1 page) comes.  Block, which was created
    on #2 step, is located at the beginning of a free list, so it will be found
    first:

  HEAD |xxX-------|xxxxxxxxx-| TAIL
          ^                 ^
          page mapped here, but better to use this hole

It is obvious, that it is better to complete request of #4 step using the old
block, where free space is left, because in other case fragmentation will be
highly increased.

But fragmentation is not only the case.  The most worst thing is that I can
easily create scenario, when the whole vmalloc space is exhausted by blocks,
which are not used, but already dirty and have several free pages.

Let's consider this function which execution should be pinned to one CPU:

 ------------------------------------------------------------------------------
static void exhaust_virtual_space(struct page *pages[16], int iters)
{
	/* Firstly we have to map a big chunk, e.g. 16 pages.
	 * Then we have to occupy the remaining space with smaller
	 * chunks, i.e. 8 pages. At the end small hole should remain.
	 * So at the end of our allocation sequence block looks like
	 * this:
	 *                XX  big chunk
	 * |XXxxxxxxx-|    x  small chunk
	 *                 -  hole, which is enough for a small chunk,
	 *                    but is not enough for a big chunk
	 */
	while (iters--) {
		int i;
		void *vaddr;

		/* Map/unmap big chunk */
		vaddr = vm_map_ram(pages, 16, -1, PAGE_KERNEL);
		vm_unmap_ram(vaddr, 16);

		/* Map/unmap small chunks.
		 *
		 * -1 for hole, which should be left at the end of each block
		 * to keep it partially used, with some free space available */
		for (i = 0; i < (VMAP_BBMAP_BITS - 16) / 8 - 1; i++) {
			vaddr = vm_map_ram(pages, 8, -1, PAGE_KERNEL);
			vm_unmap_ram(vaddr, 8);
		}
	}
}
 ------------------------------------------------------------------------------

On every iteration new block (1MB of vm area in my case) will be allocated and
then will be occupied, without attempt to resolve small allocation request
using previously allocated blocks in a free list.

In case of random allocation (size should be randomly taken from the range
[1..64] in 64-bit case or [1..32] in 32-bit case) situation is the same:
new blocks continue to appear if maximum possible allocation size (32 or 64)
passed to the allocator, because all remaining blocks in a free list do not
have enough free space to complete this allocation request.

In summary if new blocks are put into the head of a free list eventually
virtual space will be exhausted.

In current patch I simply put newly allocated block to the tail of a free list,
thus reduce fragmentation, giving a chance to resolve allocation request using
older blocks with possible holes left.

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
Cc: stable@vger.kernel.org
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 39c3388..db6bffb 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -837,7 +837,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 
 	vbq = &get_cpu_var(vmap_block_queue);
 	spin_lock(&vbq->lock);
-	list_add_rcu(&vb->free_list, &vbq->free);
+	list_add_tail_rcu(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_block_queue);
 
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
