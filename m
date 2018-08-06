Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4EA96B000A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:31:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id h4-v6so8282758pll.4
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:31:29 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10102.outbound.protection.outlook.com. [40.107.1.102])
        by mx.google.com with ESMTPS id m64-v6si5642954pfc.17.2018.08.06.04.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Aug 2018 04:31:27 -0700 (PDT)
Subject: [PATCH v2] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 06 Aug 2018 14:31:16 +0300
Message-ID: <153355467546.11522.4518015068123480218.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

v2: Improved comments to SHRINKER_REGISTERING and written
    long description about all the things to the patch.

The patch introduces a special value SHRINKER_REGISTERING
to use instead of list_empty() to differ a registering
shrinker from unregistered shrinker. Why we need that at all?

Shrinker registration is split in two parts. The first one
is prealloc_shrinker(), which allocates shrinker memory and
reserves ID in shrinker_idr. This function can fail.
The second is register_shrinker_prepared(), and it finalizes
the registration. This function actually makes shrinker
available to be used from shrink_slab(), and it can't fail.

One shrinker may be based on more then one LRU lists. So,
we never clear the bit in memcg shrinker maps, when (one of)
corresponding LRU list becomes empty, since other LRU lists
may be not empty. See superblock shrinker for example:
it is based on two LRU lists: s_inode_lru and s_dentry_lru.
We do not want to clear shrinker bit, when there are no inodes
in s_inode_lru, as s_dentry_lru may contain dentries.

Instead of that, we use special algorithm to detect shrinkers
having no elements at all its LRU lists, and this is made
in shrink_slab_memcg(). See the comment in this function
for the details.

Also, in shrink_slab_memcg() we clear shrinker bit in the map,
when we meet unregistered shrinker (bit is set, while there is
no a shrinker in IDR). Otherwise, we would have done that
at the moment of shrinker unregistration for all memcgs (and this
looks worse, since iteration over all memcg may take much time).
Also this would have imposed restrictions on shrinker unregistration
order for its users: they would have had to guarantee, there are
no new elements after unregister_shrinker() (otherwise, a new
added element would have set a bit).

So, if we meet a set bit in map and no shrinker in IDR
when we're iterating over the map in shrink_slab_memcg(),
this means the corresponding shrinker is unregistered, and we
must clear the bit.

Another case is shrinker registration. We want two things there:

1)do_shrink_slab() can be called only for completely registered
  shrinkers;
2)shrinker internal lists may be populated in any order with
  register_shrinker_prepared() (let's talk on the example with sb).
  Both of:

  a)list_lru_add(&inode->i_sb->s_inode_lru, &inode->i_lru); [cpu0]
    memcg_set_shrinker_bit();                               [cpu0]
    ...
    register_shrinker_prepared();                           [cpu1]

  and

  b)register_shrinker_prepared();                           [cpu0]
    ...
    list_lru_add(&inode->i_sb->s_inode_lru, &inode->i_lru); [cpu1]
    memcg_set_shrinker_bit();                               [cpu1]

   are legitimate. We don't want to impose restriction here and
   to force people to use only (b) variant. We don't want to force
   people to care, there is no elements in LRU lists before
   the shrinker is completely registered. Internal users of LRU lists
   and shrinker code are two different subsystems, and they have
   to be closed in themselves each other.

In (a) case we have the bit set before shrinker is completely
registered. We don't want do_shrink_slab() is called at this moment,
so we have to detect such the registering shrinkers.

Before this patch list_empty() (shrinker is not linked to the list)
check was used for that. So, in (a) there could be a bit set, but
we don't call do_shrink_slab() unless shrinker is linked to the list.
It's just an indicator, I just overloaded linking to the list.

This was not the best solution, since it's better not to touch
the shrinker memory from shrink_slab_memcg() before it's completely
registered (this also will be useful in the future to make shrink_slab()
completely lockless).

So, this patch introduces better way to detect registering shrinker,
which allows not to dereference shrinker memory. It's just a ~0UL
value, which we insert into the IDR during ID allocation. After
shrinker is ready to be used, we insert actual shrinker pointer
in the IDR, and it becomes available to shrink_slab_memcg().

We can't use NULL instead of this new value for this purpose as:
shrink_slab_memcg() already uses NULL to detect unregistered
shrinkers, and we don't want the function sees NULL and
clears the bit, otherwise (a) won't work.

This is the only thing the patch makes: the better way to detect
registering shrinker. Nothing else this patch makes.

Also this gives a better assembler, but it's minor side of the patch:

Before:
callq  <idr_find>
mov    %rax,%r15
test   %rax,%rax
je     <shrink_slab_memcg+0x1d5>
mov    0x20(%rax),%rax
lea    0x20(%r15),%rdx
cmp    %rax,%rdx
je     <shrink_slab_memcg+0xbd>
mov    0x8(%rsp),%edx
mov    %r15,%rsi
lea    0x10(%rsp),%rdi
callq  <do_shrink_slab>

After:
callq  <idr_find>
mov    %rax,%r15
lea    -0x1(%rax),%rax
cmp    $0xfffffffffffffffd,%rax
ja     <shrink_slab_memcg+0x1cd>
mov    0x8(%rsp),%edx
mov    %r15,%rsi
lea    0x10(%rsp),%rdi
callq  ffffffff810cefd0 <do_shrink_slab>

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0d980e801b8a..da135e1acd94 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -170,6 +170,20 @@ static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
 #ifdef CONFIG_MEMCG_KMEM
+
+/*
+ * We allow subsystems to populate their shrinker-related
+ * LRU lists before register_shrinker_prepared() is called
+ * for the shrinker, since we don't want to impose
+ * restrictions on their internal registration order.
+ * In this case shrink_slab_memcg() may find corresponding
+ * bit is set in the shrinkers map.
+ *
+ * This value is used by the function to detect registering
+ * shrinkers and to skip do_shrink_slab() calls for them.
+ */
+#define SHRINKER_REGISTERING ((struct shrinker *)~0UL)
+
 static DEFINE_IDR(shrinker_idr);
 static int shrinker_nr_max;
 
@@ -179,7 +193,7 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 
 	down_write(&shrinker_rwsem);
 	/* This may call shrinker, so it must use down_read_trylock() */
-	id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
+	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
 	if (id < 0)
 		goto unlock;
 
@@ -364,21 +378,6 @@ int prealloc_shrinker(struct shrinker *shrinker)
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
 
-	/*
-	 * There is a window between prealloc_shrinker()
-	 * and register_shrinker_prepared(). We don't want
-	 * to clear bit of a shrinker in such the state
-	 * in shrink_slab_memcg(), since this will impose
-	 * restrictions on a code registering a shrinker
-	 * (they would have to guarantee, their LRU lists
-	 * are empty till shrinker is completely registered).
-	 * So, we differ the situation, when 1)a shrinker
-	 * is semi-registered (id is assigned, but it has
-	 * not yet linked to shrinker_list) and 2)shrinker
-	 * is not registered (id is not assigned).
-	 */
-	INIT_LIST_HEAD(&shrinker->list);
-
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
 		if (prealloc_memcg_shrinker(shrinker))
 			goto free_deferred;
@@ -408,6 +407,7 @@ void register_shrinker_prepared(struct shrinker *shrinker)
 {
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
+	idr_replace(&shrinker_idr, shrinker, shrinker->id);
 	up_write(&shrinker_rwsem);
 }
 
@@ -589,15 +589,12 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 		struct shrinker *shrinker;
 
 		shrinker = idr_find(&shrinker_idr, i);
-		if (unlikely(!shrinker)) {
-			clear_bit(i, map->map);
+		if (unlikely(!shrinker || shrinker == SHRINKER_REGISTERING)) {
+			if (!shrinker)
+				clear_bit(i, map->map);
 			continue;
 		}
 
-		/* See comment in prealloc_shrinker() */
-		if (unlikely(list_empty(&shrinker->list)))
-			continue;
-
 		ret = do_shrink_slab(&sc, shrinker, priority);
 		if (ret == SHRINK_EMPTY) {
 			clear_bit(i, map->map);
