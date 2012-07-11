Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id E3ADB6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 23:52:24 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1581603pbb.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 20:52:24 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/hugetlb_cgroup: Add list_del to remove unused page from hugepage_activelist when hugepage migration
Date: Wed, 11 Jul 2012 11:51:58 +0800
Message-Id: <1341978718-6423-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

hugepage_activelist is used to track currently used HugeTLB pages.
We can find the in-use HugeTLB pages to support HugeTLB cgroup
removal. Don't keep unused page in hugetlb_activelist too long.
Otherwise, on cgroup removal we should update the unused page's 
charge to parent count. To reduce this overhead, remove unused page 
from hugepage_activelist immediately.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/hugetlb_cgroup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index b834e8d..d819d66 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -398,6 +398,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 	spin_lock(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(oldhpage);
 	set_hugetlb_cgroup(oldhpage, NULL);
+	list_del(&oldhpage->lru);
 
 	/* move the h_cg details to new cgroup */
 	set_hugetlb_cgroup(newhpage, h_cg);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
