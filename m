Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 55ED66B007E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 02:04:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E80303EE0C7
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:04:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE18C45DE56
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:04:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B133C45DE54
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:04:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FEFB1DB804E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:04:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 371F51DB804F
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:04:22 +0900 (JST)
Message-ID: <4F9A366E.9020307@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 15:02:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 7/9 v2] cgroup: avoid attaching task to a cgroup under
 rmdir()
References: <4F9A327A.6050409@jp.fujitsu.com>
In-Reply-To: <4F9A327A.6050409@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

attach_task() is done under cgroup_mutex() but ->pre_destroy() callback
in rmdir() isn't called under cgroup_mutex().

It's better to avoid attaching a task to a cgroup which
is under pre_destroy(). Considering memcg, the attached task may
increase resource usage after memcg's pre_destroy() confirms that
memcg is empty. This is not good.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/cgroup.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ad8eae5..7a3076b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1953,6 +1953,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	if (cgrp == oldcgrp)
 		return 0;
 
+	if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
+		return -EBUSY;
+
 	tset.single.task = tsk;
 	tset.single.cgrp = oldcgrp;
 
@@ -4181,7 +4184,6 @@ again:
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
-	mutex_unlock(&cgroup_mutex);
 
 	/*
 	 * In general, subsystem has no css->refcnt after pre_destroy(). But
@@ -4193,6 +4195,7 @@ again:
 	 * and css_tryget() and cgroup_wakeup_rmdir_waiter() implementation.
 	 */
 	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+	mutex_unlock(&cgroup_mutex);
 
 	/*
 	 * Call pre_destroy handlers of subsys. Notify subsystems
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
