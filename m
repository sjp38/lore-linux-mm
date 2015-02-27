Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1AF6B006C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:59:38 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wp4so21559532obc.0
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:59:38 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id qv1si1667547oec.96.2015.02.27.14.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:59:38 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 1/3] hugetlbfs: add reserved mount fields to subpool structure
Date: Fri, 27 Feb 2015 14:58:09 -0800
Message-Id: <1425077893-18366-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Add a boolean to the subpool structure to indicate that the pages for
subpool have been reserved.  The hstate pointer in the subpool is
convenient to have when it comes time to unreserve the pages.
subool_reserved() is a handy way to check if reserved and take into
account a NULL subpool.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 6 ++++++
 mm/hugetlb.c            | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 431b7fc..605c648 100644
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
 
+static inline bool subpool_reserved(struct hugepage_subpool *spool)
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
