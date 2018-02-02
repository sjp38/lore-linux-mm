Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3326B0006
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 04:15:26 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id a17so18938149qta.10
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 01:15:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a11si1676122qtj.353.2018.02.02.01.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 01:15:25 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w129AVYI111109
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 04:15:25 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fvmqn98gr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 04:15:24 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 2 Feb 2018 09:15:23 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/migrate: Change migration reason MR_CMA as MR_CONTIG_RANGE
Date: Fri,  2 Feb 2018 14:45:18 +0530
In-Reply-To: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
Message-Id: <20180202091518.18798-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

alloc_contig_range() initiates compaction and eventual migration for
the purpose of either CMA or HugeTLB allocation. At present, reason
code remains the same MR_CMA for either of these cases. Lets make it
MR_CONTIG_RANGE which will appropriately reflect reason code in both
these cases.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/mmu_context_iommu.c | 2 +-
 include/linux/migrate.h             | 2 +-
 include/trace/events/migrate.h      | 2 +-
 mm/page_alloc.c                     | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 91ee2231c527..4c615fcb0cf0 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -111,7 +111,7 @@ static int mm_iommu_move_page_from_cma(struct page *page)
 	put_page(page); /* Drop the gup reference */
 
 	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
-				NULL, 0, MIGRATE_SYNC, MR_CMA);
+				NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE);
 	if (ret) {
 		if (!list_empty(&cma_migrate_pages))
 			putback_movable_pages(&cma_migrate_pages);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a732598fcf83..7e7e2606bb4c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -25,7 +25,7 @@ enum migrate_reason {
 	MR_SYSCALL,		/* also applies to cpusets */
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
-	MR_CMA,
+	MR_CONTIG_RANGE,
 	MR_TYPES
 };
 
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index bcf4daccd6be..711372845945 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -20,7 +20,7 @@
 	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
-	EMe(MR_CMA,		"cma")
+	EMe(MR_CONTIG_RANGE,	"contig_range")
 
 /*
  * First define the enums in the above macros to be exported to userspace
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 242565855d05..b9a22e16b4cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7622,7 +7622,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		cc->nr_migratepages -= nr_reclaimed;
 
 		ret = migrate_pages(&cc->migratepages, new_page_alloc_contig,
-				    NULL, 0, cc->mode, MR_CMA);
+				    NULL, 0, cc->mode, MR_CONTIG_RANGE);
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
