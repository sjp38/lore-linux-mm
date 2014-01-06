Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8121D6B0038
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:33 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id y1so9394822lam.25
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x7si35724831lag.141.2014.01.06.00.45.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:32 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 10/11] memcg: remove KMEM_ACCOUNTED_ACTIVATED flag
Date: Mon, 6 Jan 2014 12:45:01 +0400
Message-ID: <04b54e94c0ab3932e7a94d728387f43d5ab54ecc.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Currently we have two state bits in mem_cgroup::kmem_account_flags
regarding kmem accounting activation, ACTIVATED and ACTIVE. We start
kmem accounting only if both flags are set (memcg_can_account_kmem()),
plus throughout the code there are several places where we check only
the ACTIVE flag, but we never check the ACTIVATED flag alone. These
flags are both set from memcg_update_kmem_limit() under the
set_limit_mutex, the ACTIVE flag always being set after ACTIVATED, and
they never get cleared. That said checking if both flags are set is
equivalent to checking only for the ACTIVE flag, and since there is no
ACTIVATED flag checks, we can safely remove the ACTIVATED flag, and
nothing will change.

Let's try to understand what was the reason for introducing these flags.
The purpose of the ACTIVE flag is clear - it states that kmem should be
accounting to the cgroup. The only requirement for it is that it should
be set after we have fully initialized kmem accounting bits for the
cgroup and patched all static branches relating to kmem accounting.
Since we always check if static branch is enabled before actually
considering if we should account (otherwise we wouldn't benefit from
static branching), this guarantees us that we won't skip a commit or
uncharge after a charge due to an unpatched static branch.

Now let's move on to the ACTIVATED bit. As I proved in the beginning of
this message, it is absolutely useless, and removing it will change
nothing. So what was the reason introducing it?

The ACTIVATED flag was introduced by commit a8964b9b ("memcg: use static
branches when code not in use") in order to guarantee that
static_key_slow_inc(&memcg_kmem_enabled_key) would be called only once
for each memory cgroup when its kmem accounting was activated. The point
was that at that time the memcg_update_kmem_limit() function's work-flow
looked like this:

        bool must_inc_static_branch = false;

        cgroup_lock();
        mutex_lock(&set_limit_mutex);
        if (!memcg->kmem_account_flags && val != RESOURCE_MAX) {
                /* The kmem limit is set for the first time */
                ret = res_counter_set_limit(&memcg->kmem, val);

                memcg_kmem_set_activated(memcg);
                must_inc_static_branch = true;
        } else
                ret = res_counter_set_limit(&memcg->kmem, val);
        mutex_unlock(&set_limit_mutex);
        cgroup_unlock();

        if (must_inc_static_branch) {
                /* We can't do this under cgroup_lock */
                static_key_slow_inc(&memcg_kmem_enabled_key);
                memcg_kmem_set_active(memcg);
        }

So that without the ACTIVATED flag we could race with other threads
trying to set the limit and increment the static branching ref-counter
more than once. Today we call the whole memcg_update_kmem_limit()
function under the set_limit_mutex and this race is impossible.

As now we understand why the ACTIVATED bit was introduced and why we
don't need it now, and know that removing it will change nothing anyway,
let's get rid of it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   28 ++--------------------------
 1 file changed, 2 insertions(+), 26 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a7521c3..a5a1ae1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -343,15 +343,10 @@ static size_t memcg_size(void)
 
 /* internal only representation about the status of kmem accounting. */
 enum {
-	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
-	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
+	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
 	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
 };
 
-/* We account when limit is on, but only after call sites are patched */
-#define KMEM_ACCOUNTED_MASK \
-		((1 << KMEM_ACCOUNTED_ACTIVE) | (1 << KMEM_ACCOUNTED_ACTIVATED))
-
 #ifdef CONFIG_MEMCG_KMEM
 static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
 {
@@ -363,16 +358,6 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static void memcg_kmem_set_activated(struct mem_cgroup *memcg)
-{
-	set_bit(KMEM_ACCOUNTED_ACTIVATED, &memcg->kmem_account_flags);
-}
-
-static void memcg_kmem_clear_activated(struct mem_cgroup *memcg)
-{
-	clear_bit(KMEM_ACCOUNTED_ACTIVATED, &memcg->kmem_account_flags);
-}
-
 static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
 {
 	/*
@@ -2959,7 +2944,7 @@ static DEFINE_MUTEX(set_limit_mutex);
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
 	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
-		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK);
+		memcg_kmem_is_active(memcg);
 }
 
 /*
@@ -3084,19 +3069,10 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 				0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
 	if (num < 0)
 		return num;
-	/*
-	 * After this point, kmem_accounted (that we test atomically in
-	 * the beginning of this conditional), is no longer 0. This
-	 * guarantees only one process will set the following boolean
-	 * to true. We don't need test_and_set because we're protected
-	 * by the set_limit_mutex anyway.
-	 */
-	memcg_kmem_set_activated(memcg);
 
 	ret = memcg_update_all_caches(num+1);
 	if (ret) {
 		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
 		return ret;
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
