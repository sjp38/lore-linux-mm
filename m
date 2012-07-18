Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1D70A6B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 03:24:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 12:54:15 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6I7OE6G14877068
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:54:14 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6ICsn70011259
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 22:54:49 +1000
Date: Wed, 18 Jul 2012 15:24:12 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
Message-ID: <20120718072412.GA10734@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Jul 18, 2012 at 11:04:09AM +0530, Aneesh Kumar K.V wrote:
>From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
>Since we cannot fail in hugetlb_cgroup_move_parent, we don't really
>need to check whether cgroup have any change left after that. Also skip
>those hstates for which we don't have any charge in this cgroup.
>
>Based on an earlier patch from  Wanpeng Li <liwanp@linux.vnet.ibm.com>
>Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/hugetlb_cgroup.c |   49 +++++++++++++++++++++----------------------------
> 1 file changed, 21 insertions(+), 28 deletions(-)
>
>diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
>index b834e8d..b355fb4 100644
>--- a/mm/hugetlb_cgroup.c
>+++ b/mm/hugetlb_cgroup.c
>@@ -65,18 +65,6 @@ static inline struct hugetlb_cgroup *parent_hugetlb_cgroup(struct cgroup *cg)
> 	return hugetlb_cgroup_from_cgroup(cg->parent);
> }
>
>-static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
>-{
>-	int idx;
>-	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
>-
>-	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
>-		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
>-			return true;
>-	}
>-	return false;
>-}
>-
> static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
> {
> 	int idx;
>@@ -159,24 +147,29 @@ static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
> {
> 	struct hstate *h;
> 	struct page *page;
>-	int ret = 0, idx = 0;
>+	int ret = 0, idx;
>+	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
>
>-	do {
>-		if (cgroup_task_count(cgroup) ||
>-		    !list_empty(&cgroup->children)) {
>-			ret = -EBUSY;
>-			goto out;
>-		}
>-		for_each_hstate(h) {
>-			spin_lock(&hugetlb_lock);
>-			list_for_each_entry(page, &h->hugepage_activelist, lru)
>-				hugetlb_cgroup_move_parent(idx, cgroup, page);
>
>-			spin_unlock(&hugetlb_lock);
>-			idx++;
>-		}
>-		cond_resched();
>-	} while (hugetlb_cgroup_have_usage(cgroup));
>+	if (cgroup_task_count(cgroup) ||
>+	    !list_empty(&cgroup->children)) {
>+		ret = -EBUSY;
>+		goto out;
>+	}
>+
>+	for_each_hstate(h) {
>+		/*
>+		 * if we don't have any charge, skip this hstate
>+		 */
>+		idx = hstate_index(h);
>+		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
>+			continue;
>+		spin_lock(&hugetlb_lock);
>+		list_for_each_entry(page, &h->hugepage_activelist, lru)
>+			hugetlb_cgroup_move_parent(idx, cgroup, page);
>+		spin_unlock(&hugetlb_lock);
>+		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
>+	}
> out:
> 	return ret;
> }
>-- 
>1.7.10
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
