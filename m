Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 77CEC6B0257
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 08:28:17 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so11066162wgx.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 05:28:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey5si3678578wjd.74.2015.07.08.05.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 05:28:03 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/8] memcg, tcp_kmem: check for cg_proto in sock_update_memcg
Date: Wed,  8 Jul 2015 14:27:50 +0200
Message-Id: <1436358472-29137-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

sk_prot->proto_cgroup is allowed to return NULL but sock_update_memcg
doesn't check for NULL. The function relies on the mem_cgroup_is_root
check because we shouldn't get NULL otherwise because
mem_cgroup_from_task will always return !NULL.

All other callers are checking for NULL and we can safely replace
mem_cgroup_is_root() check by cg_proto != NULL which will be more
straightforward (proto_cgroup returns NULL for the root memcg already).

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 559e3b2926e8..19ffae804076 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -322,8 +322,7 @@ void sock_update_memcg(struct sock *sk)
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
