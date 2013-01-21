Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 520316B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:13:27 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 6/6] memcg: avoid dangling reference count in creation failure.
Date: Mon, 21 Jan 2013 15:13:33 +0400
Message-Id: <1358766813-15095-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1358766813-15095-1-git-send-email-glommer@parallels.com>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@parallels.com>

When use_hierarchy is enabled, we acquire an extra reference count
in our parent during cgroup creation. We don't release it, though,
if any failure exist in the creation process.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Michal Hocko <mhocko@suse>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5a247de..3949123 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6167,6 +6167,8 @@ mem_cgroup_css_online(struct cgroup *cont)
 		 * call __mem_cgroup_free, so return directly
 		 */
 		mem_cgroup_put(memcg);
+		if (parent->use_hierarchy)
+			mem_cgroup_put(parent);
 	}
 	return error;
 }
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
