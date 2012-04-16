Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 55AD66B007E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:45:11 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 16:15:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GAj43Q3686466
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:15:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GGFeVD001035
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 02:15:41 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V6 02/14] hugetlbfs: don't use ERR_PTR with VM_FAULT* values
Date: Mon, 16 Apr 2012 16:14:39 +0530
Message-Id: <1334573091-18602-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Using VM_FAULT_* codes with ERR_PTR will require us to make sure
VM_FAULT_* values will not exceed MAX_ERRNO value.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 766eb90..5a472a5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1123,10 +1123,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	 */
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
-		return ERR_PTR(-VM_FAULT_OOM);
+		return ERR_PTR(-ENOMEM);
 	if (chg)
 		if (hugepage_subpool_get_pages(spool, chg))
-			return ERR_PTR(-VM_FAULT_SIGBUS);
+			return ERR_PTR(-ENOSPC);
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
@@ -1136,7 +1136,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugepage_subpool_put_pages(spool, chg);
-			return ERR_PTR(-VM_FAULT_SIGBUS);
+			return ERR_PTR(-ENOSPC);
 		}
 	}
 
@@ -2486,6 +2486,7 @@ retry_avoidcopy:
 	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
+		int err = PTR_ERR(new_page);
 		page_cache_release(old_page);
 
 		/*
@@ -2515,7 +2516,10 @@ retry_avoidcopy:
 
 		/* Caller expects lock to be held */
 		spin_lock(&mm->page_table_lock);
-		return -PTR_ERR(new_page);
+		if (err == -ENOMEM)
+			return VM_FAULT_OOM;
+		else
+			return VM_FAULT_SIGBUS;
 	}
 
 	/*
@@ -2633,7 +2637,11 @@ retry:
 			goto out;
 		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
-			ret = -PTR_ERR(page);
+			ret = PTR_ERR(page);
+			if (ret == -ENOMEM)
+				ret = VM_FAULT_OOM;
+			else
+				ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
