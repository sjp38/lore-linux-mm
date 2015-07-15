Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1133A28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:15:21 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so30811209wgm.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:20 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id u3si7289432wje.160.2015.07.15.04.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:15:19 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so78208821wib.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/5] memcg, tcp_kmem: check for cg_proto in sock_update_memcg
Date: Wed, 15 Jul 2015 13:14:45 +0200
Message-Id: <1436958885-18754-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

sk_prot->proto_cgroup is allowed to return NULL but sock_update_memcg
doesn't check for NULL. The function relies on the mem_cgroup_is_root
check because we shouldn't get NULL otherwise because
mem_cgroup_from_task will always return !NULL.

All other callers are checking for NULL and we can safely replace
mem_cgroup_is_root() check by cg_proto != NULL which will be more
straightforward (proto_cgroup returns NULL for the root memcg already).

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5d4fba8cbdd0..cf9fb1f41831 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -315,8 +315,7 @@ void sock_update_memcg(struct sock *sk)
 		rcu_read_lock();
 		memcg = mem_cgroup_from_task(current);
 		cg_proto = sk->sk_prot->proto_cgroup(memcg);
-		if (!mem_cgroup_is_root(memcg) &&
-		    memcg_proto_active(cg_proto) &&
+		if (cg_proto && memcg_proto_active(cg_proto) &&
 		    css_tryget_online(&memcg->css)) {
 			sk->sk_cgrp = cg_proto;
 		}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
