Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBC2D681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:22 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so7897184wjd.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n22si12951969wra.214.2017.02.17.03.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:21 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBNuHa055529
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:20 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28p02srk67-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:19 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:16 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9093A3578053
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:14 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBQ6we25559078
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:14 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPgg0025505
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:42 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 4/6] mm/migrate: Add new migrate mode MIGRATE_MT
Date: Fri, 17 Feb 2017 16:54:51 +0530
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170217112453.307-5-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This change adds a new migration mode called MIGRATE_MT to enable multi
threaded page copy implementation inside copy_huge_page() function by
selectively calling copy_pages_mthread() when requested. But it still
falls back using the regular page copy mechanism instead the previous
multi threaded attempt fails. It also attempts multi threaded copy for
regular pages.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/migrate_mode.h |  1 +
 mm/migrate.c                 | 25 ++++++++++++++++++-------
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 89c1700..d344ad6 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -12,6 +12,7 @@ enum migrate_mode {
 	MIGRATE_SYNC_LIGHT	= 1<<1,
 	MIGRATE_SYNC		= 1<<2,
 	MIGRATE_ST		= 1<<3,
+	MIGRATE_MT		= 1<<4,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index 63c3682..6ac3572 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -594,6 +594,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 {
 	int i;
 	int nr_pages;
+	int rc = -EFAULT;
 
 	if (PageHuge(src)) {
 		/* hugetlbfs page */
@@ -610,10 +611,14 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
-	for (i = 0; i < nr_pages; i++) {
-		cond_resched();
-		copy_highpage(dst + i, src + i);
-	}
+	if (mode & MIGRATE_MT)
+		rc = copy_pages_mthread(dst, src, nr_pages);
+
+	if (rc)
+		for (i = 0; i < nr_pages; i++) {
+			cond_resched();
+			copy_highpage(dst + i, src + i);
+		}
 }
 
 /*
@@ -624,10 +629,16 @@ void migrate_page_copy(struct page *newpage, struct page *page,
 {
 	int cpupid;
 
-	if (PageHuge(page) || PageTransHuge(page))
+	if (PageHuge(page) || PageTransHuge(page)) {
 		copy_huge_page(newpage, page, mode);
-	else
-		copy_highpage(newpage, page);
+	} else {
+		if (mode & MIGRATE_MT) {
+			if (copy_pages_mthread(newpage, page, 1))
+				copy_highpage(newpage, page);
+		} else {
+			copy_highpage(newpage, page);
+		}
+	}
 
 	if (PageError(page))
 		SetPageError(newpage);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
