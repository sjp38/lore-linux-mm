Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7F8C66B004D
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:06:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 09:55:36 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FA6Etk46792906
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:06:14 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FA6DAZ029513
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:06:13 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 11/15] hugetlb/cgroup: Add charge/uncharge routines for hugetlb cgroup
In-Reply-To: <20120614092539.GI27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614092539.GI27397@tiehlicka.suse.cz>
Date: Fri, 15 Jun 2012 15:36:10 +0530
Message-ID: <87k3z8nb3h.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Wed 13-06-12 15:57:30, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patchset add the charge and uncharge routines for hugetlb cgroup.
>> We do cgroup charging in page alloc and uncharge in compound page
>> destructor. Assigning page's hugetlb cgroup is protected by hugetlb_lock.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> One minor comment
> [...]
>> +void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
>> +				  struct hugetlb_cgroup *h_cg,
>> +				  struct page *page)
>> +{
>> +	if (hugetlb_cgroup_disabled() || !h_cg)
>> +		return;
>> +
>> +	spin_lock(&hugetlb_lock);
>> +	set_hugetlb_cgroup(page, h_cg);
>> +	spin_unlock(&hugetlb_lock);
>> +	return;
>> +}
>
> I guess we can remove the lock here because nobody can see the page yet,
> right?
>

We need that to make sure when we remove cgroup we find correct page
hugetlb cgroup values. But i guess we have a bug here. How about the
below ?

NOTE: We also need another patch to update active list during soft
offline. I will send that in reply.

commit e4c3fd3cc0f0faa30ea283cb48ba478a5c0d3e74
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Fri Jun 15 14:42:27 2012 +0530

    hugetlb/cgroup: Assign the page hugetlb cgroup when we move the page to active list.
    
    page's hugetlb cgroup assign and moving to active list should happen with
    hugetlb_lock held. Otherwise when we remove the hugetlb cgroup we would
    iterate the active list and will find page with NULL hugetlb cgroup values.
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ee4da3b..b90dfb4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1146,9 +1146,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
-	spin_unlock(&hugetlb_lock);
-
-	if (!page) {
+	if (page) {
+		/* update page cgroup details */
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
+		spin_unlock(&hugetlb_lock);
+	} else {
+		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugetlb_cgroup_uncharge_cgroup(idx,
@@ -1159,14 +1162,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		}
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 		spin_unlock(&hugetlb_lock);
 	}
 
 	set_page_private(page, (unsigned long)spool);
 
 	vma_commit_reservation(h, vma, addr);
-	/* update page cgroup details */
-	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 	return page;
 }
 
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 8e7ca0a..d4f3f7b 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -218,6 +218,7 @@ done:
 	return ret;
 }
 
+/* Should be called with hugetlb_lock held */
 void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
 				  struct hugetlb_cgroup *h_cg,
 				  struct page *page)
@@ -225,9 +226,7 @@ void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
 
-	spin_lock(&hugetlb_lock);
 	set_hugetlb_cgroup(page, h_cg);
-	spin_unlock(&hugetlb_lock);
 	return;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
