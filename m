Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EC8576B007E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 02:06:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8264C3EE0C0
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:06:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C68745DEC2
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:06:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42F1B45DEA6
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:06:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B834E08002
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:06:16 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2357E08006
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:06:15 +0900 (JST)
Message-ID: <4F9A36DE.30301@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 15:04:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 8/9 v2] cgroup: avoid creating new cgroup under a cgroup
 being destroyed
References: <4F9A327A.6050409@jp.fujitsu.com>
In-Reply-To: <4F9A327A.6050409@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

When ->pre_destroy() is called, it should be guaranteed that
new child cgroup is not created under a cgroup, where pre_destroy()
is running. If not, ->pre_destroy() must check children and
return -EBUSY, which causes warning.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/cgroup.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7a3076b..003ceed 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3970,6 +3970,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	mutex_lock(&cgroup_mutex);
 
+	/*
+	 * prevent making child cgroup when ->pre_destroy() is running.
+	 */
+	if (test_bit(CGRP_WAIT_ON_RMDIR, &parent->flags)) {
+		mutex_unlock(&cgroup_mutex);
+		atomic_dec(&sb->s_active);
+		return -EBUSY;
+	}
+
 	init_cgroup_housekeeping(cgrp);
 
 	cgrp->parent = parent;
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
