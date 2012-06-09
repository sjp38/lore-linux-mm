Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EDC476B0080
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 05:00:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 14:30:50 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5990lsx64684210
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 14:30:47 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59EU21w031287
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 00:30:03 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V8 15/16] hugetlb/cgroup: migrate hugetlb cgroup info from oldpage to new page during migration
Date: Sat,  9 Jun 2012 14:30:00 +0530
Message-Id: <1339232401-14392-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With HugeTLB pages, hugetlb cgroup is uncharged in compound page destructor.  Since
we are holding a hugepage reference, we can be sure that old page won't
get uncharged till the last put_page().

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb_cgroup.h |    8 ++++++++
 mm/hugetlb_cgroup.c            |   21 +++++++++++++++++++++
 mm/migrate.c                   |    5 +++++
 3 files changed, 34 insertions(+)

diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index ba4836f..b64d067 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -63,6 +63,8 @@ extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 					   struct hugetlb_cgroup *h_cg);
 extern int hugetlb_cgroup_file_init(int idx) __init;
+extern void hugetlb_cgroup_migrate(struct page *oldhpage,
+				   struct page *newhpage);
 #else
 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
@@ -112,5 +114,11 @@ static inline int __init hugetlb_cgroup_file_init(int idx)
 {
 	return 0;
 }
+
+static inline void hugetlb_cgroup_migrate(struct page *oldhpage,
+					  struct page *newhpage)
+{
+	return;
+}
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index c2b7b8e..2d384fe 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -394,6 +394,27 @@ int __init hugetlb_cgroup_file_init(int idx)
 	return 0;
 }
 
+void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
+{
+	struct hugetlb_cgroup *h_cg;
+
+	VM_BUG_ON(!PageHuge(oldhpage));
+
+	if (hugetlb_cgroup_disabled())
+		return;
+
+	spin_lock(&hugetlb_lock);
+	h_cg = hugetlb_cgroup_from_page(oldhpage);
+	set_hugetlb_cgroup(oldhpage, NULL);
+	cgroup_exclude_rmdir(&h_cg->css);
+
+	/* move the h_cg details to new cgroup */
+	set_hugetlb_cgroup(newhpage, h_cg);
+	spin_unlock(&hugetlb_lock);
+	cgroup_release_and_wakeup_rmdir(&h_cg->css);
+	return;
+}
+
 struct cgroup_subsys hugetlb_subsys = {
 	.name = "hugetlb",
 	.create     = hugetlb_cgroup_create,
diff --git a/mm/migrate.c b/mm/migrate.c
index fdce3a2..6c37c51 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -33,6 +33,7 @@
 #include <linux/memcontrol.h>
 #include <linux/syscalls.h>
 #include <linux/hugetlb.h>
+#include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 
 #include <asm/tlbflush.h>
@@ -931,6 +932,10 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	if (anon_vma)
 		put_anon_vma(anon_vma);
+
+	if (!rc)
+		hugetlb_cgroup_migrate(hpage, new_hpage);
+
 	unlock_page(hpage);
 out:
 	put_page(new_hpage);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
