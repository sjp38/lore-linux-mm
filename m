Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id AF03D6B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 03:48:57 -0400 (EDT)
Date: Mon, 10 Jun 2013 09:48:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130610074854.GA5138@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370254735-13012-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

Just for the record. I squash the following doc update to the patch in
the next version.
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 811967a..9ca85ff 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -42,11 +42,19 @@ struct mem_cgroup_reclaim_cookie {
 };
 
 enum mem_cgroup_filter_t {
-	VISIT,
-	SKIP,
-	SKIP_TREE,
+	VISIT,		/* visit current node */
+	SKIP,		/* skip the current node and continue traversal */
+	SKIP_TREE,	/* skip the whole subtree and continue traversal */
 };
 
+/*
+ * mem_cgroup_filter_t predicate might instruct mem_cgroup_iter_cond how to
+ * iterate through the hierarchy tree. Each tree element is checked by the
+ * predicate before it is returned by the iterator. If a filter returns
+ * SKIP or SKIP_TREE then the iterator code continues traversal (with the
+ * next node down the hierarchy or the next node that doesn't belong under the
+ * memcg's subtree).
+ */
 typedef enum mem_cgroup_filter_t
 (*mem_cgroup_iter_filter)(struct mem_cgroup *memcg, struct mem_cgroup *root);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91740f7..43e955a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1073,6 +1073,14 @@ skip_node:
 			prev_cgroup = next_cgroup;
 			goto skip_node;
 		case SKIP_TREE:
+			/*
+			 * cgroup_rightmost_descendant is not an optimal way to
+			 * skip through a subtree (especially for imbalanced
+			 * trees leaning to right) but that's what we have right
+			 * now. More effective solution would be traversing
+			 * right-up for first non-NULL without calling
+			 * cgroup_next_descendant_pre afterwards.
+			 */
 			prev_cgroup = cgroup_rightmost_descendant(next_cgroup);
 			goto skip_node;
 		case VISIT:
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
