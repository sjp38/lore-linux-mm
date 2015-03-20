Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 631666B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:48:01 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so119637778pac.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:48:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w4si11142121pdi.213.2015.03.20.13.47.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 13:47:59 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V3 1/4] hugetlbfs: add minimum size tracking fields to subpool structure
Date: Fri, 20 Mar 2015 13:47:07 -0700
Message-Id: <3b1775e06c1cb376570eab1084f482730ba8dd7d.1426880499.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426880499.git.mike.kravetz@oracle.com>
References: <cover.1426880499.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426880499.git.mike.kravetz@oracle.com>
References: <cover.1426880499.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <andi@firstfloor.org>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

Add a field to the subpool structure to indicate the minimimum
number of huge pages to always be used by this subpool.  This
minimum count includes allocated pages as well as reserved pages.
If the minimum number of pages for the subpool have not been
allocated, pages are reserved up to this minimum.  An additional
field (rsv_hpages) is used to track the number of pages reserved
to meet this minimum size.  The hstate pointer in the subpool
is convenient to have when reserving and unreserving the pages.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 8 +++++++-
 mm/hugetlb.c            | 3 +--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 431b7fc..2ec06a1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -22,7 +22,13 @@ struct mmu_gather;
 struct hugepage_subpool {
 	spinlock_t lock;
 	long count;
-	long max_hpages, used_hpages;
+	long max_hpages;	/* Maximum huge pages or -1 if no maximum. */
+	long used_hpages;	/* Used count against maximum, includes */
+				/* both alloced and reserved pages. */
+	struct hstate *hstate;
+	long min_hpages;	/* Minimum huge pages or -1 if no minimum. */
+	long rsv_hpages;	/* Pages reserved against global pool to */
+				/* sasitfy minimum size. */
 };
 
 struct resv_map {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 85032de..0b4a01c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -77,14 +77,13 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
 {
 	struct hugepage_subpool *spool;
 
-	spool = kmalloc(sizeof(*spool), GFP_KERNEL);
+	spool = kzalloc(sizeof(*spool), GFP_KERNEL);
 	if (!spool)
 		return NULL;
 
 	spin_lock_init(&spool->lock);
 	spool->count = 1;
 	spool->max_hpages = nr_blocks;
-	spool->used_hpages = 0;
 
 	return spool;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
