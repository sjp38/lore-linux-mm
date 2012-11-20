Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6805A6B007D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:32:43 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/6] cgroup: implement CFTYPE_NO_PREFIX
Date: Tue, 20 Nov 2012 12:32:00 +0400
Message-Id: <1353400324-10897-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1353400324-10897-1-git-send-email-glommer@parallels.com>
References: <1353400324-10897-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Glauber Costa <glommer@parallels.com>

From: Tejun Heo <tj@kernel.org>

When cgroup files are created, cgroup core automatically prepends the
name of the subsystem as prefix.  This patch adds CFTYPE_NO_PREFIX
which disables the automatic prefix.

This will be used to deprecate cpuacct which will make cpu create and
serve the cpuacct files.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Glauber Costa <glommer@parallels.com>
---
 include/linux/cgroup.h | 1 +
 kernel/cgroup.c        | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a178a91..018468b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -272,6 +272,7 @@ struct cgroup_map_cb {
 /* cftype->flags */
 #define CFTYPE_ONLY_ON_ROOT	(1U << 0)	/* only create on root cg */
 #define CFTYPE_NOT_ON_ROOT	(1U << 1)	/* don't create onp root cg */
+#define CFTYPE_NO_PREFIX	(1U << 2)	/* skip subsys prefix */
 
 #define MAX_CFTYPE_NAME		64
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3d68aad..4081fee 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2629,7 +2629,8 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 	if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
 		return 0;
 
-	if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
+	if (subsys && !(cft->flags & CFTYPE_NO_PREFIX) &&
+	    !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
 		strcpy(name, subsys->name);
 		strcat(name, ".");
 	}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
