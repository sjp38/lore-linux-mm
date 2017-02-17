Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2FE681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so58140949pgc.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y67si10038714pfa.97.2017.02.17.03.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:27 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBO0vL137325
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:27 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28nx4twf53-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:26 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:24 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E0E372CE8056
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:21 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBQDeV35782886
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:21 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPn4n025665
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:49 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 6/6] sysctl: Add global tunable mt_page_copy
Date: Fri, 17 Feb 2017 16:54:53 +0530
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170217112453.307-7-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

A new global sysctl tunable 'mt_page_copy' is added which will override
syscall specific requests and enable multi threaded page copy during
all migrations on the system. This tunable is disabled by default.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 kernel/sysctl.c | 10 ++++++++++
 mm/migrate.c    | 14 ++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1aea594..e5f7ca9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -98,6 +98,7 @@
 #if defined(CONFIG_SYSCTL)
 
 /* External variables not in a header file. */
+extern int mt_page_copy;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
 extern int core_uses_pid;
@@ -1346,6 +1347,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
 	},
 #endif
+	{
+		.procname	= "mt_page_copy",
+		.data		= &mt_page_copy,
+		.maxlen		= sizeof(mt_page_copy),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
diff --git a/mm/migrate.c b/mm/migrate.c
index 660c4b2..75b6d7a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -48,6 +48,8 @@
 
 #include "internal.h"
 
+int mt_page_copy;
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -611,6 +613,9 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
+	if (mt_page_copy)
+		mode |= MIGRATE_MT;
+
 	if (mode & MIGRATE_MT)
 		rc = copy_pages_mthread(dst, src, nr_pages);
 
@@ -629,6 +634,9 @@ void migrate_page_copy(struct page *newpage, struct page *page,
 {
 	int cpupid;
 
+	if (mt_page_copy)
+		mode |= MIGRATE_MT;
+
 	if (PageHuge(page) || PageTransHuge(page)) {
 		copy_huge_page(newpage, page, mode);
 	} else {
@@ -695,6 +703,12 @@ void migrate_page_copy(struct page *newpage, struct page *page,
 }
 EXPORT_SYMBOL(migrate_page_copy);
 
+static int __init mt_page_copy_init(void)
+{
+	mt_page_copy = 0;
+	return 0;
+}
+subsys_initcall(mt_page_copy_init);
 /************************************************************
  *                    Migration functions
  ***********************************************************/
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
