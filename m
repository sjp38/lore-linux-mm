Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D21726B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 01:53:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DCC7A3EE0BC
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:53:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C35BE45DE53
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:53:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB36645DE4D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:53:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 969BB1DB8040
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:53:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D7D11DB8038
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:53:03 +0900 (JST)
Message-ID: <4F9A33CB.8040304@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 14:51:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/7 v2] memcg: fix error code in hugetlb_force_memcg_empty()
References: <4F9A327A.6050409@jp.fujitsu.com>
In-Reply-To: <4F9A327A.6050409@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

EBUSY should be returned.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/hugetlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 17ae2e4..4dd6b39 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1922,8 +1922,11 @@ int hugetlb_force_memcg_empty(struct cgroup *cgroup)
 	int ret = 0, idx = 0;
 
 	do {
-		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
+		if (cgroup_task_count(cgroup)
+			|| !list_empty(&cgroup->children)) {
+			ret = -EBUSY;
 			goto out;
+		}
 		/*
 		 * If the task doing the cgroup_rmdir got a signal
 		 * we don't really need to loop till the hugetlb resource
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
