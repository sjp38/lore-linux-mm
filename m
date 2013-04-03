Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7C6176B00BB
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:13:05 -0400 (EDT)
Message-ID: <515BF249.50607@huawei.com>
Date: Wed, 3 Apr 2013 17:11:37 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 1/7] memcg: use css_get in sock_update_memcg()
References: <515BF233.6070308@huawei.com>
In-Reply-To: <515BF233.6070308@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Use css_get/css_put instead of mem_cgroup_get/put.

Note, if at the same time someone is moving @current to a different
cgroup and removing the old cgroup, css_tryget() may return false,
and sock->sk_cgrp won't be initialized.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23d0f6e..43ca91d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -536,15 +536,15 @@ void sock_update_memcg(struct sock *sk)
 		 */
 		if (sk->sk_cgrp) {
 			BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
-			mem_cgroup_get(sk->sk_cgrp->memcg);
+			css_get(&sk->sk_cgrp->memcg->css);
 			return;
 		}
 
 		rcu_read_lock();
 		memcg = mem_cgroup_from_task(current);
 		cg_proto = sk->sk_prot->proto_cgroup(memcg);
-		if (!mem_cgroup_is_root(memcg) && memcg_proto_active(cg_proto)) {
-			mem_cgroup_get(memcg);
+		if (!mem_cgroup_is_root(memcg) &&
+		    memcg_proto_active(cg_proto) && css_tryget(&memcg->css)) {
 			sk->sk_cgrp = cg_proto;
 		}
 		rcu_read_unlock();
@@ -558,7 +558,7 @@ void sock_release_memcg(struct sock *sk)
 		struct mem_cgroup *memcg;
 		WARN_ON(!sk->sk_cgrp->memcg);
 		memcg = sk->sk_cgrp->memcg;
-		mem_cgroup_put(memcg);
+		css_put(&sk->sk_cgrp->memcg->css);
 	}
 }
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
