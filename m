Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 935D48E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:28:40 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u1-v6so6144162wrt.3
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:28:40 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80130.outbound.protection.outlook.com. [40.107.8.130])
        by mx.google.com with ESMTPS id s6-v6si4477969wrg.240.2018.09.28.04.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Sep 2018 04:28:39 -0700 (PDT)
Subject: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 28 Sep 2018 14:28:32 +0300
Message-ID: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gorcunov@openvz.org, ktkhai@virtuozzo.com, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

do_shrink_slab() returns unsigned long value, and
the placing into int variable cuts high bytes off.
Then we compare ret and 0xfffffffe (since SHRINK_EMPTY
is converted to ret type).

Thus, big number of objects returned by do_shrink_slab()
may be interpreted as SHRINK_EMPTY, if low bytes of
their value are equal to 0xfffffffe. Fix that
by declaration ret as unsigned long in these functions.

Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0b63d9a2dc17..8ea87586925e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -581,8 +581,8 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
 	struct memcg_shrinker_map *map;
-	unsigned long freed = 0;
-	int ret, i;
+	unsigned long ret, freed = 0;
+	int i;
 
 	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
 		return 0;
@@ -678,9 +678,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
 				 int priority)
 {
+	unsigned long ret, freed = 0;
 	struct shrinker *shrinker;
-	unsigned long freed = 0;
-	int ret;
 
 	if (!mem_cgroup_is_root(memcg))
 		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
