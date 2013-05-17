Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 08CAE6B0036
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:04:31 -0400 (EDT)
Message-ID: <5195D626.3010406@huawei.com>
Date: Fri, 17 May 2013 15:03:02 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/9] Revert "memcg: avoid dangling reference count in creation
 failure."
References: <5195D5F8.7000609@huawei.com>
In-Reply-To: <5195D5F8.7000609@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This reverts commit e4715f01be697a3730c78f8ffffb595591d6a88c

mem_cgroup_put is hierarchy aware so mem_cgroup_put(memcg) already drops
an additional reference from all parents so the additional
mem_cgrroup_put(parent) potentially causes use-after-free.

Cc: <stable@vger.kernel.org> # 3.9.x
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb1c9de..5918e90 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6297,8 +6297,6 @@ mem_cgroup_css_online(struct cgroup *cont)
 		 * call __mem_cgroup_free, so return directly
 		 */
 		mem_cgroup_put(memcg);
-		if (parent->use_hierarchy)
-			mem_cgroup_put(parent);
 	}
 	return error;
 }
-- 
1.8.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
