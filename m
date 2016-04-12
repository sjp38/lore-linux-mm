Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7F79A6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:28 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id zm5so6126304pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:28 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id d28si7649027pfb.176.2016.04.11.21.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:27 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id zm5so6126141pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:27 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 00/11] mm/slab: reduce lock contention in alloc path
Date: Tue, 12 Apr 2016 13:50:55 +0900
Message-Id: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Major changes from v1
o hold node lock instead of slab_mutex in kmem_cache_shrink()
o fix suspend-to-ram issue reported by Nishanth
o use synchronize_sched() instead of kick_all_cpus_sync()

While processing concurrent allocation, SLAB could be contended
a lot because it did a lots of work with holding a lock. This
patchset try to reduce the number of critical section to reduce
lock contention. Major changes are lockless decision to allocate
more slab and lockless cpu cache refill from the newly allocated slab.

Below is the result of concurrent allocation/free in slab allocation
benchmark made by Christoph a long time ago. I make the output simpler.
The number shows cycle count during alloc/free respectively so less
is better.

* Before
Kmalloc N*alloc N*free(32): Average=365/806
Kmalloc N*alloc N*free(64): Average=452/690
Kmalloc N*alloc N*free(128): Average=736/886
Kmalloc N*alloc N*free(256): Average=1167/985
Kmalloc N*alloc N*free(512): Average=2088/1125
Kmalloc N*alloc N*free(1024): Average=4115/1184
Kmalloc N*alloc N*free(2048): Average=8451/1748
Kmalloc N*alloc N*free(4096): Average=16024/2048

* After
Kmalloc N*alloc N*free(32): Average=344/792
Kmalloc N*alloc N*free(64): Average=347/882
Kmalloc N*alloc N*free(128): Average=390/959
Kmalloc N*alloc N*free(256): Average=393/1067
Kmalloc N*alloc N*free(512): Average=683/1229
Kmalloc N*alloc N*free(1024): Average=1295/1325
Kmalloc N*alloc N*free(2048): Average=2513/1664
Kmalloc N*alloc N*free(4096): Average=4742/2172

It shows that performance improves greatly (roughly more than 50%)
for the object class whose size is more than 128 bytes.

Joonsoo Kim (11):
  mm/slab: fix the theoretical race by holding proper lock
  mm/slab: remove BAD_ALIEN_MAGIC again
  mm/slab: drain the free slab as much as possible
  mm/slab: factor out kmem_cache_node initialization code
  mm/slab: clean-up kmem_cache_node setup
  mm/slab: don't keep free slabs if free_objects exceeds free_limit
  mm/slab: racy access/modify the slab color
  mm/slab: make cache_grow() handle the page allocated on arbitrary node
  mm/slab: separate cache_grow() to two parts
  mm/slab: refill cpu cache through a new slab without holding a node
    lock
  mm/slab: lockless decision to grow cache

 mm/slab.c | 562 +++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 295 insertions(+), 267 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
