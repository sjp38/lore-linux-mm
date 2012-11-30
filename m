Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 18E576B00A7
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 08:31:40 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/4] cgroup: warn about broken hierarchies only after css_online
Date: Fri, 30 Nov 2012 17:31:23 +0400
Message-Id: <1354282286-32278-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1354282286-32278-1-git-send-email-glommer@parallels.com>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

If everything goes right, it shouldn't really matter if we are spitting
this warning after css_alloc or css_online. If we fail between then,
there are some ill cases where we would previously see the message and
now we won't (like if the files fail to be created).

I believe it really shouldn't matter: this message is intended in spirit
to be shown when creation succeeds, but with insane settings.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 kernel/cgroup.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 56ed543..b35a10c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4151,15 +4151,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			if (err)
 				goto err_free_all;
 		}
-
-		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
-		    parent->parent) {
-			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
-				   current->comm, current->pid, ss->name);
-			if (!strcmp(ss->name, "memory"))
-				pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
-			ss->warned_broken_hierarchy = true;
-		}
 	}
 
 	/*
@@ -4188,6 +4179,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		err = online_css(ss, cgrp);
 		if (err)
 			goto err_destroy;
+
+		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
+		    parent->parent) {
+			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
+				   current->comm, current->pid, ss->name);
+			if (!strcmp(ss->name, "memory"))
+				pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
+			ss->warned_broken_hierarchy = true;
+		}
 	}
 
 	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
