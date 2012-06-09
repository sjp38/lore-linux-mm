Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 688146B0078
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 05:00:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 14:30:49 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5990ZnR67043368
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 14:30:35 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59ETpMX030123
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 00:29:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V8 10/16] hugetlb/cgroup: Add the cgroup pointer to page lru
Date: Sat,  9 Jun 2012 14:29:55 +0530
Message-Id: <1339232401-14392-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Add the hugetlb cgroup pointer to 3rd page lru.next. This limit
the usage to hugetlb cgroup to only hugepages with 3 or more
normal pages. I guess that is an acceptable limitation.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb_cgroup.h |   31 +++++++++++++++++++++++++++++++
 mm/hugetlb.c                   |    4 ++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 5794be4..ceff1d5 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -26,6 +26,26 @@ struct hugetlb_cgroup {
 };
 
 #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
+static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
+{
+	if (!PageHuge(page))
+		return NULL;
+	if (compound_order(page) < 3)
+		return NULL;
+	return (struct hugetlb_cgroup *)page[2].lru.next;
+}
+
+static inline
+int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
+{
+	if (!PageHuge(page))
+		return -1;
+	if (compound_order(page) < 3)
+		return -1;
+	page[2].lru.next = (void *)h_cg;
+	return 0;
+}
+
 static inline bool hugetlb_cgroup_disabled(void)
 {
 	if (hugetlb_subsys.disabled)
@@ -43,6 +63,17 @@ extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 					   struct hugetlb_cgroup *h_cg);
 #else
+static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
+{
+	return NULL;
+}
+
+static inline
+int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
+{
+	return 0;
+}
+
 static inline bool hugetlb_cgroup_disabled(void)
 {
 	return true;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e899a2d..1ca2d8f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -28,6 +28,7 @@
 
 #include <linux/io.h>
 #include <linux/hugetlb.h>
+#include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
 #include "internal.h"
 
@@ -591,6 +592,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 				1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1 << PG_writeback);
 	}
+	BUG_ON(hugetlb_cgroup_from_page(page));
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
 	arch_release_hugepage(page);
@@ -643,6 +645,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 	INIT_LIST_HEAD(&page->lru);
 	set_compound_page_dtor(page, free_huge_page);
 	spin_lock(&hugetlb_lock);
+	set_hugetlb_cgroup(page, NULL);
 	h->nr_huge_pages++;
 	h->nr_huge_pages_node[nid]++;
 	spin_unlock(&hugetlb_lock);
@@ -892,6 +895,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 		INIT_LIST_HEAD(&page->lru);
 		r_nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
+		set_hugetlb_cgroup(page, NULL);
 		/*
 		 * We incremented the global counters already
 		 */
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
