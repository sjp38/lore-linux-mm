Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 431AF6B003C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:36:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 06:02:36 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9ED681258051
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 06:08:12 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3H0abSc1638780
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 06:06:38 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3H0aeEt027895
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:36:41 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/6] mm/hugetlb: introduce new sysctl knob which control gigantic page pools shrinking
Date: Wed, 17 Apr 2013 08:36:29 +0800
Message-Id: <1366158995-3116-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

This patch introduces new sysctl knob to support gigantic hugetlb page
pools shrinking. The default value is 0 since gigantic page pools
aren't permitted shrinked by default, administrator can echo 1 to knob
to enable gigantic page pools shrinking after they confirm they won't
use them any more.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 Documentation/sysctl/vm.txt |   13 +++++++++++++
 include/linux/hugetlb.h     |    3 +++
 kernel/sysctl.c             |    7 +++++++
 mm/hugetlb.c                |    9 +++++++++
 4 files changed, 32 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 21ad181..3baf332 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -30,6 +30,7 @@ Currently, these files are in /proc/sys/vm:
 - extfrag_threshold
 - hugepages_treat_as_movable
 - hugetlb_shm_group
+- hugetlb_shrink_gigantic_pool
 - laptop_mode
 - legacy_va_layout
 - lowmem_reserve_ratio
@@ -211,6 +212,18 @@ shared memory segment using hugetlb page.
 
 ==============================================================
 
+hugetlb_shrink_gigantic_pool
+
+order >= MAX_ORDER pages are only allocated at boot stage using the bootmem
+allocator with the "hugepages=xxx" option. These pages are never free'd
+by default since it would be a one-way street(>= MAX_ORDER pages cannot
+be allocated later), but if administrator confirm not to use these gigantic
+pages any more, these pinned pages will waste memory since other users
+can't grab free pages from gigantic hugetlb pool even OOM. Administrator
+can enable this parameter to permit to shrink gigantic hugetlb pool
+
+==============================================================
+
 laptop_mode
 
 laptop_mode is a knob that controls "laptop mode". All the things that are
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 3a62df3..b7e4106 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -36,6 +36,8 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_shrink_gigantic_pool_handler(struct ctl_table *,
+				int, void __user *, size_t *, loff_t *);
 
 #ifdef CONFIG_NUMA
 int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
@@ -73,6 +75,7 @@ extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
+extern int hugetlb_shrink_gigantic_pool;
 
 /* arch callbacks */
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3dadde5..25eb85f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1187,6 +1187,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&hugetlb_zero,
 		.extra2		= (void *)&hugetlb_infinity,
 	},
+	{
+		.procname       = "hugetlb_shrink_gigantic_pool",
+		.data           = &hugetlb_shrink_gigantic_pool,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = hugetlb_shrink_gigantic_pool_handler,
+	},
 #ifdef CONFIG_NUMA
 	{
 		.procname       = "nr_hugepages_mempolicy",
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bacdf38..4a0c270 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -35,6 +35,7 @@
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
+int hugetlb_shrink_gigantic_pool;
 
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
@@ -671,6 +672,14 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 	}
 }
 
+int hugetlb_shrink_gigantic_pool_handler(struct ctl_table *table, int write,
+			void __user *buffer,
+			size_t *length, loff_t *ppos)
+{
+	proc_dointvec(table, write, buffer, length, ppos);
+	return 0;
+}
+
 /*
  * PageHuge() only returns true for hugetlbfs pages, but not for normal or
  * transparent huge pages.  See the PageTransHuge() documentation for more
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
