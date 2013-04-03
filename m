Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 107EC6B00C0
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:54:02 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2] Revert "memcg: avoid dangling reference count in creation failure."
Date: Wed,  3 Apr 2013 10:53:53 +0200
Message-Id: <1364979234-16427-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20130403085056.GD14384@dhcp22.suse.cz>
References: <20130403085056.GD14384@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Li Zefan <lizefan@huawei.com>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

This reverts commit e4715f01be697a3730c78f8ffffb595591d6a88c

mem_cgroup_put is hierarchy aware so mem_cgroup_put(memcg) already drops
an additional reference from all parents so the additional
mem_cgrroup_put(parent) potentially causes use-after-free.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f608546..6de6d70 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6424,8 +6424,6 @@ mem_cgroup_css_online(struct cgroup *cont)
 		 * call __mem_cgroup_free, so return directly
 		 */
 		mem_cgroup_put(memcg);
-		if (parent->use_hierarchy)
-			mem_cgroup_put(parent);
 	}
 	return error;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
