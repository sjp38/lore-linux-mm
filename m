Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 83F0C6B02E1
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 12:45:38 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 24 Jun 2012 22:15:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5OGjGGd65339602
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 22:15:16 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5OMF3fQ004386
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 08:15:03 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] hugetlb/cgroup: Remove unnecessary NULL checks
Date: Sun, 24 Jun 2012 22:15:13 +0530
Message-Id: <1340556313-12789-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

cgroup_subsys_state can never be NULL, so don't check
for that in hugetlb_cgroup_from_css. Also current task will
always be part of some cgroup. So hugetlb_cgrop_from_task
cannot return NULL.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb_cgroup.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index db40669..b834e8d 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -36,9 +36,7 @@ static struct hugetlb_cgroup *root_h_cgroup __read_mostly;
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
 {
-	if (s)
-		return container_of(s, struct hugetlb_cgroup, css);
-	return NULL;
+	return container_of(s, struct hugetlb_cgroup, css);
 }
 
 static inline
@@ -202,9 +200,6 @@ int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
 again:
 	rcu_read_lock();
 	h_cg = hugetlb_cgroup_from_task(current);
-	if (!h_cg)
-		h_cg = root_h_cgroup;
-
 	if (!css_tryget(&h_cg->css)) {
 		rcu_read_unlock();
 		goto again;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
