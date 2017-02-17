Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55DD14405F5
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id p22so38559376qka.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id b3si7649783qke.164.2017.02.17.07.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:08 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 04/14] mm/migrate: Add new migrate mode MIGRATE_MT
Date: Fri, 17 Feb 2017 10:05:41 -0500
Message-Id: <20170217150551.117028-5-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

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
index 89c170060e5b..d344ad60f499 100644
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
index 87253cb9b50a..21307219428d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -601,6 +601,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 {
 	int i;
 	int nr_pages;
+	int rc = -EFAULT;
 
 	if (PageHuge(src)) {
 		/* hugetlbfs page */
@@ -617,10 +618,14 @@ static void copy_huge_page(struct page *dst, struct page *src,
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
@@ -631,10 +636,16 @@ void migrate_page_copy(struct page *newpage, struct page *page,
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
