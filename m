Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 056936B0081
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 07:38:07 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 6/6] hugetlb: do not fail in hugetlb_cgroup_pre_destroy
Date: Fri, 26 Oct 2012 13:37:33 +0200
Message-Id: <1351251453-6140-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@parallels.com>

Now that pre_destroy callbacks are called from the context where neither
any task can attach the group nor any children group can be added there
is no other way to fail from hugetlb_pre_destroy.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 mm/hugetlb_cgroup.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index a3f358f..dc595c6 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -159,14 +159,9 @@ static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
 {
 	struct hstate *h;
 	struct page *page;
-	int ret = 0, idx = 0;
+	int idx = 0;
 
 	do {
-		if (cgroup_task_count(cgroup) ||
-		    !list_empty(&cgroup->children)) {
-			ret = -EBUSY;
-			goto out;
-		}
 		for_each_hstate(h) {
 			spin_lock(&hugetlb_lock);
 			list_for_each_entry(page, &h->hugepage_activelist, lru)
@@ -177,8 +172,8 @@ static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
 		}
 		cond_resched();
 	} while (hugetlb_cgroup_have_usage(cgroup));
-out:
-	return ret;
+
+	return 0;
 }
 
 int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
