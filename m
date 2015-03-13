Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B249A8299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:13:33 -0400 (EDT)
Received: by pabli10 with SMTP id li10so29035086pab.13
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:13:33 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id tk2si3699451pab.87.2015.03.13.05.13.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 05:13:32 -0700 (PDT)
Received: by pablj1 with SMTP id lj1so29065520pab.8
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:13:32 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [PATCH 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space caused by vm_map_ram allocator
Date: Fri, 13 Mar 2015 21:12:55 +0900
Message-Id: <1426248777-19768-2-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

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
/* Here we consider that our block is equal to 1MB, thus 256 pages */
static void exhaust_virtual_space(struct page *pages[256], int iters)
{
	/* Firstly we have to map a big chunk, e.g. 16 pages.
	 * Then we have to occupy the remaining space with smaller
	 * chunks, i.e. 8 pages. At the end small hole should remain.
	 * So at the end of our allocation sequence block looks like
	 * this:
	 *                XX  big chunk
	 * |XXxxxxxxx-|    x  small chunk
	 *                 -  hole, which is enough for a small chunk,
	 *                    but not for a big chunk
	 */
	unsigned big_allocs   = 1;
	/* -1 for hole, which should be left at the end of each block
	 * to keep it partially used, with some free space available */
	unsigned small_allocs = (256 - 16) / 8 - 1;
	void    *vaddrs[big_allocs + small_allocs];

	while (iters--) {
		int i = 0, j;

		/* Map big chunk */
		vaddrs[i++] = vm_map_ram(pages, 16, -1, PAGE_KERNEL);

		/* Map small chunks */
		for (j = 0; j < small_allocs; j++)
			vaddrs[i++] = vm_map_ram(pages + 16 + j * 8, 8, -1,
						 PAGE_KERNEL);

		/* Unmap everything */
		while (i--)
			vm_unmap_ram(vaddrs[i], (i ? 8 : 16));
	}
}
 ------------------------------------------------------------------------------

On every iteration new block (1MB of vm area in my case) will be allocated and
then will be occupied, without attempt to resolve small allocation request
using previously allocated blocks in a free list.

In current patch I simply put newly allocated block to the tail of a free list,
thus reduce fragmentation, giving a chance to resolve allocation request using
older blocks with possible holes left.

Signed-off-by: Roman Pen <r.peniaev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
