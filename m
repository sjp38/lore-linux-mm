Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B96056B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 22:07:22 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u133so5949690qka.12
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:07:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e9si1820485qth.244.2018.01.29.19.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 19:07:21 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0U34AgW021908
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 22:07:21 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ftdhp5rr5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 22:07:20 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 03:07:19 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
Date: Tue, 30 Jan 2018 08:37:14 +0530
Message-Id: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

alloc_contig_range() initiates compaction and eventual migration for
the purpose of either CMA or HugeTLB allocation. At present, reason
code remains the same MR_CMA for either of those cases. Lets add a
new reason code which will differentiate the purpose of migration
as HugeTLB allocation instead.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/migrate.h        |  1 +
 include/trace/events/migrate.h |  3 ++-
 mm/page_alloc.c                | 14 ++++++++++----
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a732598fcf83..44381c33a2bd 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -26,6 +26,7 @@ enum migrate_reason {
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
 	MR_CMA,
+	MR_HUGETLB,
 	MR_TYPES
 };
 
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index bcf4daccd6be..61474c93f8f3 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -20,7 +20,8 @@
 	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
-	EMe(MR_CMA,		"cma")
+	EM( MR_CMA,		"cma")				\
+	EMe(MR_HUGETLB,		"hugetlb")
 
 /*
  * First define the enums in the above macros to be exported to userspace
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 242565855d05..ce8a2f2d4994 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7588,13 +7588,14 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
 
 /* [start, end) must belong to a single zone. */
 static int __alloc_contig_migrate_range(struct compact_control *cc,
-					unsigned long start, unsigned long end)
+					unsigned long start, unsigned long end,
+					unsigned migratetype)
 {
 	/* This function is based on compact_zone() from compaction.c. */
 	unsigned long nr_reclaimed;
 	unsigned long pfn = start;
 	unsigned int tries = 0;
-	int ret = 0;
+	int ret = 0, migrate_reason = 0;
 
 	migrate_prep();
 
@@ -7621,8 +7622,13 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 							&cc->migratepages);
 		cc->nr_migratepages -= nr_reclaimed;
 
+		if (migratetype == MIGRATE_CMA)
+			migrate_reason = MR_CMA;
+		else
+			migrate_reason = MR_HUGETLB;
+
 		ret = migrate_pages(&cc->migratepages, new_page_alloc_contig,
-				    NULL, 0, cc->mode, MR_CMA);
+				    NULL, 0, cc->mode, migrate_reason);
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);
@@ -7710,7 +7716,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 * allocated.  So, if we fall through be sure to clear ret so that
 	 * -EBUSY is not accidentally used or returned to caller.
 	 */
-	ret = __alloc_contig_migrate_range(&cc, start, end);
+	ret = __alloc_contig_migrate_range(&cc, start, end, migratetype);
 	if (ret && ret != -EBUSY)
 		goto done;
 	ret =0;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
