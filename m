Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF1F6B0070
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:22:12 -0500 (EST)
Received: by pabli10 with SMTP id li10so28827586pab.13
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:22:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id uq1si2894347pac.192.2015.03.03.17.22.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 17:22:11 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/4] hugetlbfs: add reserved mount fields to subpool structure
Date: Tue,  3 Mar 2015 17:21:43 -0800
Message-Id: <1425432106-17214-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Add a boolean to the subpool structure to indicate that the pages for
subpool have been reserved.  The hstate pointer in the subpool is
convenient to have when reserving and unreserving the pages.
hugepage_subool_reserved() is a handy way to check if reserved and
take into account a NULL subpool.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 6 ++++++
 mm/hugetlb.c            | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 431b7fc..12fbd5d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -23,6 +23,8 @@ struct hugepage_subpool {
 	spinlock_t lock;
 	long count;
 	long max_hpages, used_hpages;
+	struct hstate *hstate;
+	bool reserved;
 };
 
 struct resv_map {
@@ -38,6 +40,10 @@ extern int hugetlb_max_hstate __read_mostly;
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
 
+static inline bool hugepage_subpool_reserved(struct hugepage_subpool *spool)
+{
+	return spool && spool->reserved;
+}
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 85032de..c6adf65 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -85,6 +85,8 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
 	spool->count = 1;
 	spool->max_hpages = nr_blocks;
 	spool->used_hpages = 0;
+	spool->hstate = NULL;
+	spool->reserved = false;
 
 	return spool;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
