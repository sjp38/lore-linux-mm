Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC746B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:52:55 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id kx10so8809383pab.16
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:52:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id mi6si26800976pab.17.2014.09.24.07.52.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 07:52:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap memcg_can_account_kmem
Date: Wed, 24 Sep 2014 18:52:41 +0400
Message-ID: <1411570361-29361-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

memcg_can_account_kmem() returns true iff

    !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
                                   memcg_kmem_is_active(memcg);

To begin with the !mem_cgroup_is_root(memcg) check is useless, because
one can't enable kmem accounting for the root cgroup (mem_cgroup_write()
returns EINVAL on an attempt to set the limit on the root cgroup).

Furthermore, the !mem_cgroup_disabled() check also seems to be
redundant. The point is memcg_can_account_kmem() is called from three
places: mem_cgroup_salbinfo_read(), __memcg_kmem_get_cache(), and
__memcg_kmem_newpage_charge(). The latter two functions are only invoked
if memcg_kmem_enabled() returns true, which implies that the memory
cgroup subsystem is enabled. And mem_cgroup_slabinfo_read() shows the
output of memory.kmem.slabinfo, which won't exist if the memory cgroup
is completely disabled.

So let's substitute all the calls to memcg_can_account_kmem() with plain
memcg_kmem_is_active(), and kill the former.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1ec22bf380d0..63d58d79470d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2786,12 +2786,6 @@ static DEFINE_MUTEX(memcg_slab_mutex);
 
 static DEFINE_MUTEX(activate_kmem_mutex);
 
-static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
-{
-	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
-		memcg_kmem_is_active(memcg);
-}
-
 /*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
@@ -2811,7 +2805,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	struct memcg_cache_params *params;
 
-	if (!memcg_can_account_kmem(memcg))
+	if (!memcg_kmem_is_active(memcg))
 		return -EIO;
 
 	print_slabinfo_header(m);
@@ -3188,7 +3182,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
 
-	if (!memcg_can_account_kmem(memcg))
+	if (!memcg_kmem_is_active(memcg))
 		goto out;
 
 	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
@@ -3273,7 +3267,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
 
-	if (!memcg_can_account_kmem(memcg)) {
+	if (!memcg_kmem_is_active(memcg)) {
 		css_put(&memcg->css);
 		return true;
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
