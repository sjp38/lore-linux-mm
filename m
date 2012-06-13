Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 37A796B0078
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 06:28:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Jun 2012 15:58:24 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5DASLmo2294078
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 15:58:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5DFvqHH001771
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:27:56 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V9 08/15] hugetlb: Make some static variables global
Date: Wed, 13 Jun 2012 15:57:27 +0530
Message-Id: <1339583254-895-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use them later in hugetlb_cgroup.c

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |    5 +++++
 mm/hugetlb.c            |    7 ++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ed550d8..4aca057 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -21,6 +21,11 @@ struct hugepage_subpool {
 	long max_hpages, used_hpages;
 };
 
+extern spinlock_t hugetlb_lock;
+extern int hugetlb_max_hstate;
+#define for_each_hstate(h) \
+	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
+
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b5b6e15..e899a2d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -35,7 +35,7 @@ const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-static int hugetlb_max_hstate;
+int hugetlb_max_hstate;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
 
@@ -46,13 +46,10 @@ static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
 static unsigned long __initdata default_hstate_size;
 
-#define for_each_hstate(h) \
-	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
-
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
  */
-static DEFINE_SPINLOCK(hugetlb_lock);
+DEFINE_SPINLOCK(hugetlb_lock);
 
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
