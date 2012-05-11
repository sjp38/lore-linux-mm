Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8418D8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:47:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2536B3EE0BD
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:47:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0781E45DE7E
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:47:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E496545DE6A
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:47:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4B4DE08003
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:47:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8831A1DB8042
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:47:18 +0900 (JST)
Message-ID: <4FACDFAE.5050808@jp.fujitsu.com>
Date: Fri, 11 May 2012 18:45:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v3 1/6] memcg: fix error code in hugetlb_force_memcg_empty()
References: <4FACDED0.3020400@jp.fujitsu.com>
In-Reply-To: <4FACDED0.3020400@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

The conditions are handled as -EBUSY, _now_.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/hugetlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1d3c8ea9..824f07b 100644
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
