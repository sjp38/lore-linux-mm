Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D8EA06B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:33 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so9714672pde.12
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id cc2si26083191pbb.208.2014.07.01.01.22.31
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:32 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 0/9] clean-up and remove lockdep annotation in SLAB
Date: Tue,  1 Jul 2014 17:27:29 +0900
Message-Id: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset does some clean-up and tries to remove lockdep annotation.

Patches 1~2 are just for really really minor improvement.
Patches 3~9 are for clean-up and removing lockdep annotation.

There are two cases that lockdep annotation is needed in SLAB.
1) holding two node locks
2) holding two array cache(alien cache) locks

I looked at the code and found that we can avoid these cases without
any negative effect.

1) occurs if freeing object makes new free slab and we decide to
destroy it. Although we don't need to hold the lock during destroying
a slab, current code do that. Destroying a slab without holding the lock
would help the reduction of the lock contention. To do it, I change the
implementation that new free slab is destroyed after releasing the lock.

2) occurs on similar situation. When we free object from non-local node,
we put this object to alien cache with holding the alien cache lock.
If alien cache is full, we try to flush alien cache to proper node cache,
and, in this time, new free slab could be made. Destroying it would be
started and we will free metadata object which comes from another node.
In this case, we need another node's alien cache lock to free object.
This forces us to hold two array cache locks and then we need lockdep
annotation although they are always different locks and deadlock cannot
be possible. To prevent this situation, I use same way as 1).

In this way, we can avoid 1) and 2) cases, and then, can remove lockdep
annotation. As short stat noted, this makes SLAB code much simpler.

All patches of this series got Ack from Christoph Lamter on previous
iteration, and there is no big change from previous iteration. Just
one clean-up patch is dropped, because it seems not good clean-up.
Others are just rebased on current linux-next.

Thanks.

Joonsoo Kim (9):
  slab: add unlikely macro to help compiler
  slab: move up code to get kmem_cache_node in free_block()
  slab: defer slab_destroy in free_block()
  slab: factor out initialization of arracy cache
  slab: introduce alien_cache
  slab: use the lock on alien_cache, instead of the lock on array_cache
  slab: destroy a slab without holding any alien cache lock
  slab: remove a useless lockdep annotation
  slab: remove BAD_ALIEN_MAGIC

 mm/slab.c |  377 ++++++++++++++++++++++---------------------------------------
 mm/slab.h |    2 +-
 2 files changed, 137 insertions(+), 242 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
