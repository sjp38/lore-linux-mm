Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id DFEF06B0072
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:48:12 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch v2 2/6] memcg: keep prev's css alive for the whole mem_cgroup_iter
Date: Mon, 26 Nov 2012 19:47:47 +0100
Message-Id: <1353955671-14385-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

css reference counting keeps the cgroup alive even though it has been
already removed. mem_cgroup_iter relies on this fact and takes a
reference to the returned group. The reference is then released on the
next iteration or mem_cgroup_iter_break.
mem_cgroup_iter currently releases the reference right after it gets the
last css_id.
This is correct because neither prev's memcg nor cgroup are accessed
after then. This will change in the next patch so we need to hold the
group alive a bit longer so let's move the css_put at the end of the
function.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0e52ec9..1f5528d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1077,12 +1077,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	if (prev && !reclaim)
 		id = css_id(&prev->css);
 
-	if (prev && prev != root)
-		css_put(&prev->css);
-
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
-			return NULL;
+			goto out_css_put;
 		return root;
 	}
 
@@ -1100,7 +1097,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			spin_lock(&iter->iter_lock);
 			if (prev && reclaim->generation != iter->generation) {
 				spin_unlock(&iter->iter_lock);
-				return NULL;
+				goto out_css_put;
 			}
 			id = iter->position;
 		}
@@ -1124,8 +1121,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		}
 
 		if (prev && !css)
-			return NULL;
+			goto out_css_put;
 	}
+out_css_put:
+	if (prev && prev != root)
+		css_put(&prev->css);
+
 	return memcg;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
