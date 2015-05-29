Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB906B008C
	for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:56 -0400 (EDT)
Received: by wizo1 with SMTP id o1so20656620wiz.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 04:57:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu4si9203417wjb.112.2015.05.29.04.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 04:57:38 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC -v2 5/7] memcg, tcp_kmem: check for cg_proto in sock_update_memcg
Date: Fri, 29 May 2015 13:57:23 +0200
Message-Id: <1432900645-8856-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
References: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

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
index 5f0adf6e2332..1f10f90da4ef 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -320,8 +320,7 @@ void sock_update_memcg(struct sock *sk)
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
