Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF61F6B02A0
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:56:43 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so6007777pgq.9
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:56:43 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k13si13373990pgb.343.2018.11.12.21.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:52:42 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.9 17/17] mm: don't warn about large allocations for slab
Date: Tue, 13 Nov 2018 00:52:23 -0500
Message-Id: <20181113055223.79060-17-sashal@kernel.org>
In-Reply-To: <20181113055223.79060-1-sashal@kernel.org>
References: <20181113055223.79060-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Dmitry Vyukov <dvyukov@google.com>

[ Upstream commit 61448479a9f2c954cde0cfe778cb6bec5d0a748d ]

Slub does not call kmalloc_slab() for sizes > KMALLOC_MAX_CACHE_SIZE,
instead it falls back to kmalloc_large().

For slab KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE and it calls
kmalloc_slab() for all allocations relying on NULL return value for
over-sized allocations.

This inconsistency leads to unwanted warnings from kmalloc_slab() for
over-sized allocations for slab.  Returning NULL for failed allocations is
the expected behavior.

Make slub and slab code consistent by checking size >
KMALLOC_MAX_CACHE_SIZE in slab before calling kmalloc_slab().

While we are here also fix the check in kmalloc_slab().  We should check
against KMALLOC_MAX_CACHE_SIZE rather than KMALLOC_MAX_SIZE.  It all kinda
worked because for slab the constants are the same, and slub always checks
the size against KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().  But if we
get there with size > KMALLOC_MAX_CACHE_SIZE anyhow bad things will
happen.  For example, in case of a newly introduced bug in slub code.

Also move the check in kmalloc_slab() from function entry to the size >
192 case.  This partially compensates for the additional check in slab
code and makes slub code a bit faster (at least theoretically).

Also drop __GFP_NOWARN in the warning check.  This warning means a bug in
slab code itself, user-passed flags have nothing to do with it.

Nothing of this affects slob.

Link: http://lkml.kernel.org/r/20180927171502.226522-1-dvyukov@gmail.com
Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Reported-by: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com
Reported-by: syzbot+ef4e8fc3a06e9019bb40@syzkaller.appspotmail.com
Reported-by: syzbot+6e438f4036df52cbb863@syzkaller.appspotmail.com
Reported-by: syzbot+8574471d8734457d98aa@syzkaller.appspotmail.com
Reported-by: syzbot+af1504df0807a083dbd9@syzkaller.appspotmail.com
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c        |  4 ++++
 mm/slab_common.c | 12 ++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c59844dbd034..263dcda6897b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3690,6 +3690,8 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 	struct kmem_cache *cachep;
 	void *ret;
 
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+		return NULL;
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
@@ -3725,6 +3727,8 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	struct kmem_cache *cachep;
 	void *ret;
 
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+		return NULL;
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 622f6b6ae844..13f1926f8fcd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -883,18 +883,18 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
 	int index;
 
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
 
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely((flags & GFP_DMA)))
-- 
2.17.1
