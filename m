Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC10E6B006C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:53:42 -0400 (EDT)
Received: by oibu204 with SMTP id u204so52018849oib.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:53:42 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e8si3913709oib.130.2015.03.16.16.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 16:53:42 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V2 1/4] hugetlbfs: add minimum size tracking fields to subpool structure
Date: Mon, 16 Mar 2015 16:53:26 -0700
Message-Id: <1ef964ec5febb254dbee28604481c6768e018268.1426549010.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

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
 include/linux/hugetlb.h | 2 ++
 mm/hugetlb.c            | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 431b7fc..cfe13fd 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -23,6 +23,8 @@ struct hugepage_subpool {
 	spinlock_t lock;
 	long count;
 	long max_hpages, used_hpages;
+	struct hstate *hstate;
+	long min_hpages, rsv_hpages;
 };
 
 struct resv_map {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 85032de..07b7226 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -85,6 +85,9 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
 	spool->count = 1;
 	spool->max_hpages = nr_blocks;
 	spool->used_hpages = 0;
+	spool->hstate = NULL;
+	spool->min_hpages = 0;
+	spool->rsv_hpages = 0;
 
 	return spool;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
