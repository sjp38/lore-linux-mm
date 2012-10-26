Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 84F1B6B0074
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 07:38:05 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 2/6] memcg: root_cgroup cannot reach mem_cgroup_move_parent
Date: Fri, 26 Oct 2012 13:37:29 +0200
Message-Id: <1351251453-6140-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@parallels.com>

The root cgroup cannot be destroyed so we never hit it down the
mem_cgroup_pre_destroy path and mem_cgroup_force_empty_write shouldn't
even try to do anything if called for the root.

This means that mem_cgroup_move_parent doesn't have to bother with the
root cgroup and it can assume it can always move charges upwards.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 07d92b8..916132a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2715,9 +2715,7 @@ static int mem_cgroup_move_parent(struct page *page,
 	unsigned long uninitialized_var(flags);
 	int ret;
 
-	/* Is ROOT ? */
-	if (mem_cgroup_is_root(child))
-		return -EINVAL;
+	VM_BUG_ON(mem_cgroup_is_root(child));
 
 	ret = -EBUSY;
 	if (!get_page_unless_zero(page))
@@ -3823,6 +3821,8 @@ static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	int ret;
 
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
 	css_get(&memcg->css);
 	ret = mem_cgroup_force_empty(memcg);
 	css_put(&memcg->css);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
