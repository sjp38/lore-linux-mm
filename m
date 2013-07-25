Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BFB936B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 21:54:10 -0400 (EDT)
Message-ID: <51F08505.6050402@huawei.com>
Date: Thu, 25 Jul 2013 09:53:09 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: remove redundant code in mem_cgroup_force_empty_write()
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>

vfs guarantees the cgroup won't be destroyed, so it's redundant
to get a css reference.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 03c8bf7..aa3e478 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5015,15 +5015,10 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	int ret;
 
 	if (mem_cgroup_is_root(memcg))
 		return -EINVAL;
-	css_get(&memcg->css);
-	ret = mem_cgroup_force_empty(memcg);
-	css_put(&memcg->css);
-
-	return ret;
+	return mem_cgroup_force_empty(memcg);
 }
 
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
