Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 226D76B0069
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:39:37 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 30 May 2012 20:09:33 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4UEdVXi6488452
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:09:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4UK8k1Q026077
	for <linux-mm@kvack.org>; Thu, 31 May 2012 06:08:47 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 03/14] hugetlbfs: add an inline helper for finding hstate index
Date: Wed, 30 May 2012 20:08:48 +0530
Message-Id: <1338388739-22919-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Add an inline helper and use it in the code.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/hugetlb.h |    6 ++++++
 mm/hugetlb.c            |   20 +++++++++++---------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d5d6bbe..217f528 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -302,6 +302,11 @@ static inline unsigned hstate_index_to_shift(unsigned index)
 	return hstates[index].order + PAGE_SHIFT;
 }
 
+static inline int hstate_index(struct hstate *h)
+{
+	return h - hstates;
+}
+
 #else
 struct hstate {};
 #define alloc_huge_page_node(h, nid) NULL
@@ -320,6 +325,7 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 	return 1;
 }
 #define hstate_index_to_shift(index) 0
+#define hstate_index(h) 0
 #endif
 
 #endif /* _LINUX_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8ded02d..9b97a5c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1646,7 +1646,7 @@ static int hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
 				    struct attribute_group *hstate_attr_group)
 {
 	int retval;
-	int hi = h - hstates;
+	int hi = hstate_index(h);
 
 	hstate_kobjs[hi] = kobject_create_and_add(h->name, parent);
 	if (!hstate_kobjs[hi])
@@ -1741,11 +1741,13 @@ void hugetlb_unregister_node(struct node *node)
 	if (!nhs->hugepages_kobj)
 		return;		/* no hstate attributes */
 
-	for_each_hstate(h)
-		if (nhs->hstate_kobjs[h - hstates]) {
-			kobject_put(nhs->hstate_kobjs[h - hstates]);
-			nhs->hstate_kobjs[h - hstates] = NULL;
+	for_each_hstate(h) {
+		int idx = hstate_index(h);
+		if (nhs->hstate_kobjs[idx]) {
+			kobject_put(nhs->hstate_kobjs[idx]);
+			nhs->hstate_kobjs[idx] = NULL;
 		}
+	}
 
 	kobject_put(nhs->hugepages_kobj);
 	nhs->hugepages_kobj = NULL;
@@ -1848,7 +1850,7 @@ static void __exit hugetlb_exit(void)
 	hugetlb_unregister_all_nodes();
 
 	for_each_hstate(h) {
-		kobject_put(hstate_kobjs[h - hstates]);
+		kobject_put(hstate_kobjs[hstate_index(h)]);
 	}
 
 	kobject_put(hugepages_kobj);
@@ -1869,7 +1871,7 @@ static int __init hugetlb_init(void)
 		if (!size_to_hstate(default_hstate_size))
 			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
 	}
-	default_hstate_idx = size_to_hstate(default_hstate_size) - hstates;
+	default_hstate_idx = hstate_index(size_to_hstate(default_hstate_size));
 	if (default_hstate_max_huge_pages)
 		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
 
@@ -2687,7 +2689,7 @@ retry:
 		 */
 		if (unlikely(PageHWPoison(page))) {
 			ret = VM_FAULT_HWPOISON |
-			      VM_FAULT_SET_HINDEX(h - hstates);
+				VM_FAULT_SET_HINDEX(hstate_index(h));
 			goto backout_unlocked;
 		}
 	}
@@ -2760,7 +2762,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
-			       VM_FAULT_SET_HINDEX(h - hstates);
+				VM_FAULT_SET_HINDEX(hstate_index(h));
 	}
 
 	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
