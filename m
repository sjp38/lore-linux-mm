Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 5B5896B0072
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:41:33 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 18:11:29 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FCfRsv54526166
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 18:11:28 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FIB1lh024898
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 23:41:02 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 4/4] hugetlb/cgroup: Remove exclude and wakeup rmdir calls from migrate
Date: Fri, 15 Jun 2012 18:11:22 +0530
Message-Id: <1339764082-1611-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We already hold the hugetlb_lock. That should prevent a parallel
cgroup rmdir from touching page's hugetlb cgroup. So remove
the exclude and wakeup calls.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb_cgroup.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 55e109a..a7a0a79 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -387,6 +387,10 @@ int __init hugetlb_cgroup_file_init(int idx)
 	return 0;
 }
 
+/*
+ * hugetlb_lock will make sure a parallel cgroup rmdir won't happen
+ * when we migrate hugepages
+ */
 void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 {
 	struct hugetlb_cgroup *h_cg;
@@ -399,13 +403,11 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 	spin_lock(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(oldhpage);
 	set_hugetlb_cgroup(oldhpage, NULL);
-	cgroup_exclude_rmdir(&h_cg->css);
 
 	/* move the h_cg details to new cgroup */
 	set_hugetlb_cgroup(newhpage, h_cg);
 	list_move(&newhpage->lru, &h->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
-	cgroup_release_and_wakeup_rmdir(&h_cg->css);
 	return;
 }
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
