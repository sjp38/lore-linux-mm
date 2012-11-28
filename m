Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6965C6B0072
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:34 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so10587559pbc.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:34:33 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/13] cpuset: remove fast exit path from remove_tasks_in_empty_cpuset()
Date: Wed, 28 Nov 2012 13:34:09 -0800
Message-Id: <1354138460-19286-3-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

The function isn't that hot, the overhead of missing the fast exit is
low, the test itself depends heavily on cgroup internals, and it's
gonna be a hindrance when trying to decouple cpuset locking from
cgroup core.  Remove the fast exit path.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index a423774..54b2b73 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1968,14 +1968,6 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 	struct cpuset *parent;
 
 	/*
-	 * The cgroup's css_sets list is in use if there are tasks
-	 * in the cpuset; the list is empty if there are none;
-	 * the cs->css.refcnt seems always 0.
-	 */
-	if (list_empty(&cs->css.cgroup->css_sets))
-		return;
-
-	/*
 	 * Find its next-highest non-empty parent, (top cpuset
 	 * has online cpus, so can't be empty).
 	 */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
