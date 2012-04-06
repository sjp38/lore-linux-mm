Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 83DC56B00EF
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:53 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpnaN4419602
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:49 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370MI5b008085
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:22:18 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 13/14] hugetlb: migrate memcg info from oldpage to new page during migration
Date: Sat,  7 Apr 2012 00:20:59 +0530
Message-Id: <1333738260-1329-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With HugeTLB pages, memcg is uncharged in compound page destructor.
Since we are holding a hugepage reference, we can be sure that old
page won't get uncharged till the last put_page(). On successful
migrate, we can move the memcg information to new page's page_cgroup
and mark the old page's page_cgroup unused.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/memcontrol.h |    8 ++++++++
 mm/memcontrol.c            |   28 ++++++++++++++++++++++++++++
 mm/migrate.c               |    4 ++++
 3 files changed, 40 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 70317e5..6f2d392 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -464,6 +464,8 @@ extern int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
 					  struct page *page);
 extern bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup);
 
+extern void  mem_cgroup_hugetlb_migrate(struct page *oldhpage,
+					struct page *newhpage);
 #else
 static inline int
 mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
@@ -510,6 +512,12 @@ static inline bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
 {
 	return 0;
 }
+
+static inline  void  mem_cgroup_hugetlb_migrate(struct page *oldhpage,
+						struct page *newhpage)
+{
+	return;
+}
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7b6e79a..7b373a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3382,6 +3382,34 @@ err_out:
 out:
 	return ret;
 }
+
+void  mem_cgroup_hugetlb_migrate(struct page *oldhpage, struct page *newhpage)
+{
+	struct mem_cgroup *memcg;
+	struct page_cgroup *pc;
+
+	VM_BUG_ON(!PageHuge(oldhpage));
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(oldhpage);
+	lock_page_cgroup(pc);
+	memcg = pc->mem_cgroup;
+	pc->mem_cgroup = root_mem_cgroup;
+	ClearPageCgroupUsed(pc);
+	cgroup_exclude_rmdir(&memcg->css);
+	unlock_page_cgroup(pc);
+
+	/* move the mem_cg details to new cgroup */
+	pc = lookup_page_cgroup(newhpage);
+	lock_page_cgroup(pc);
+	pc->mem_cgroup = memcg;
+	SetPageCgroupUsed(pc);
+	unlock_page_cgroup(pc);
+	cgroup_release_and_wakeup_rmdir(&memcg->css);
+	return;
+}
 #endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index d7eb82d..2b931e5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -928,6 +928,10 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	if (anon_vma)
 		put_anon_vma(anon_vma);
+
+	if (!rc)
+		mem_cgroup_hugetlb_migrate(hpage, new_hpage);
+
 	unlock_page(hpage);
 out:
 	put_page(new_hpage);
-- 
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
