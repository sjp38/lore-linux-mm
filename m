Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1CE386B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 23:04:04 -0400 (EDT)
Received: by yhjj63 with SMTP id j63so809249yhj.9
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 20:04:03 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/hugetlb_cgroup: Add huge_page_order check to avoid incorrectly uncharge
Date: Wed, 11 Jul 2012 11:03:16 +0800
Message-Id: <1341975796-5730-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Against linux-next:

Function alloc_huge_page will call hugetlb_cgroup_charge_cgroup
to charge pages, the compound page have less than 3 pages will not
charge to hugetlb cgroup. When alloc_huge_page fails it will call
hugetlb_cgroup_uncharge_cgroup to uncharge pages, however,
hugetlb_cgroup_uncharge_cgroup doesn't have huge_page_order check.
That means it will uncharge pages even if the compound page have less
than 3 pages. Add huge_page_order check to avoid this incorrectly
uncharge.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/hugetlb_cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index b834e8d..2b9e214 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -252,6 +252,9 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
+
+	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
+		return;
 
 	res_counter_uncharge(&h_cg->hugepage[idx], csize);
 	return;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
