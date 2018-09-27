Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF018E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:15:14 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id s19-v6so5842883wmh.3
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:15:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16-v6sor1936233wrp.38.2018.09.27.10.15.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 10:15:12 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@gmail.com>
Subject: [PATCH v2] mm: don't warn about large allocations for slab
Date: Thu, 27 Sep 2018 19:15:02 +0200
Message-Id: <20180927171502.226522-1-dvyukov@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>

Slub does not call kmalloc_slab() for sizes > KMALLOC_MAX_CACHE_SIZE,
instead it falls back to kmalloc_large().
For slab KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE and it calls
kmalloc_slab() for all allocations relying on NULL return value
for over-sized allocations.
This inconsistency leads to unwanted warnings from kmalloc_slab()
for over-sized allocations for slab. Returning NULL for failed
allocations is the expected behavior.

Make slub and slab code consistent by checking size >
KMALLOC_MAX_CACHE_SIZE in slab before calling kmalloc_slab().

While we are here also fix the check in kmalloc_slab().
We should check against KMALLOC_MAX_CACHE_SIZE rather than
KMALLOC_MAX_SIZE. It all kinda worked because for slab the
constants are the same, and slub always checks the size against
KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().
But if we get there with size > KMALLOC_MAX_CACHE_SIZE anyhow
bad things will happen. For example, in case of a newly introduced
bug in slub code.

Also move the check in kmalloc_slab() from function entry
to the size > 192 case. This partially compensates for the additional
check in slab code and makes slub code a bit faster
(at least theoretically).

Also drop __GFP_NOWARN in the warning check.
This warning means a bug in slab code itself,
user-passed flags have nothing to do with it.

Nothing of this affects slob.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Reported-by: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com
Reported-by: syzbot+ef4e8fc3a06e9019bb40@syzkaller.appspotmail.com
Reported-by: syzbot+6e438f4036df52cbb863@syzkaller.appspotmail.com
Reported-by: syzbot+8574471d8734457d98aa@syzkaller.appspotmail.com
Reported-by: syzbot+af1504df0807a083dbd9@syzkaller.appspotmail.com

---

Changes since v1:
 - everything has changed, re-review
---
 mm/slab.c        |  4 ++++
 mm/slab_common.c | 12 ++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9515798f37b2d..2a5654bb3b3ff 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3675,6 +3675,8 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 	struct kmem_cache *cachep;
 	void *ret;
 
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+		return NULL;
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
@@ -3710,6 +3712,8 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	struct kmem_cache *cachep;
 	void *ret;
 
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+		return NULL;
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1f903589980f9..7eb8dc136c1cb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1023,18 +1023,18 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
 	unsigned int index;
 
-	if (unlikely(size > KMALLOC_MAX_SIZE)) {
-		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
-		return NULL;
-	}
-
 	if (size <= 192) {
 		if (!size)
 			return ZERO_SIZE_PTR;
 
 		index = size_index[size_index_elem(size)];
-	} else
+	} else {
+		if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
+			WARN_ON(1);
+			return NULL;
+		}
 		index = fls(size - 1);
+	}
 
 	return kmalloc_caches[kmalloc_type(flags)][index];
 }
-- 
2.19.0.605.g01d371f741-goog
