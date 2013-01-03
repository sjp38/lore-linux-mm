Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 128666B0070
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:54:50 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 6/7] memcg: further simplify mem_cgroup_iter
Date: Thu,  3 Jan 2013 18:54:20 +0100
Message-Id: <1357235661-29564-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

mem_cgroup_iter basically does two things currently. It takes care of
the house keeping (reference counting, raclaim cookie) and it iterates
through a hierarchy tree (by using cgroup generic tree walk).
The code would be much more easier to follow if we move the iteration
outside of the function (to __mem_cgrou_iter_next) so the distinction
is more clear.
This patch doesn't introduce any functional changes.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   79 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d8c6e5e..d80fcff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1110,6 +1110,51 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+/*
+ * Returns a next (in a pre-order walk) alive memcg (with elevated css
+ * ref. count) or NULL if the whole root's subtree has been visited.
+ *
+ * helper function to be used by mem_cgroup_iter
+ */
+static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
+		struct mem_cgroup *last_visited)
+{
+	struct cgroup *prev_cgroup, *next_cgroup;
+
+	/*
+	 * Root is not visited by cgroup iterators so it needs an
+	 * explicit visit.
+	 */
+	if (!last_visited)
+		return root;
+
+	prev_cgroup = (last_visited == root) ? NULL
+		: last_visited->css.cgroup;
+skip_node:
+	next_cgroup = cgroup_next_descendant_pre(
+			prev_cgroup, root->css.cgroup);
+
+	/*
+	 * Even if we found a group we have to make sure it is
+	 * alive. css && !memcg means that the groups should be
+	 * skipped and we should continue the tree walk.
+	 * last_visited css is safe to use because it is
+	 * protected by css_get and the tree walk is rcu safe.
+	 */
+	if (next_cgroup) {
+		struct mem_cgroup *mem = mem_cgroup_from_cont(
+				next_cgroup);
+		if (css_tryget(&mem->css))
+			return mem;
+		else {
+			prev_cgroup = next_cgroup;
+			goto skip_node;
+		}
+	}
+
+	return NULL;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -1172,39 +1217,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			}
 		}
 
-		/*
-		 * Root is not visited by cgroup iterators so it needs an
-		 * explicit visit.
-		 */
-		if (!last_visited) {
-			memcg = root;
-		} else {
-			struct cgroup *prev_cgroup, *next_cgroup;
-
-			prev_cgroup = (last_visited == root) ? NULL
-				: last_visited->css.cgroup;
-skip_node:
-			next_cgroup = cgroup_next_descendant_pre(
-					prev_cgroup, root->css.cgroup);
-
-			/*
-			 * Even if we found a group we have to make sure it is
-			 * alive. css && !memcg means that the groups should be
-			 * skipped and we should continue the tree walk.
-			 * last_visited css is safe to use because it is
-			 * protected by css_get and the tree walk is rcu safe.
-			 */
-			if (next_cgroup) {
-				struct mem_cgroup *mem = mem_cgroup_from_cont(
-						next_cgroup);
-				if (css_tryget(&mem->css))
-					memcg = mem;
-				else {
-					prev_cgroup = next_cgroup;
-					goto skip_node;
-				}
-			}
-		}
+		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
 			if (last_visited)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
