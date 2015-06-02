Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 34047900015
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 13:09:24 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so137053445pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 10:09:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id cf17si27247478pdb.113.2015.06.02.10.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 10:09:23 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 1/3] mm/hugetlb: document the reserve map/region tracking routines
Date: Tue,  2 Jun 2015 09:59:11 -0700
Message-Id: <1433264353-4050-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1433264353-4050-1-git-send-email-mike.kravetz@oracle.com>
References: <1433264353-4050-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This is a documentation only patch and does not modify any code.
Descriptions of the routines used for reserve map/region tracking
are added.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 50 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 10de25c..4a1d702 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -217,8 +217,20 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
  *
- * The region data structures are embedded into a resv_map and
- * protected by a resv_map's lock
+ * The region data structures are embedded into a resv_map and protected
+ * by a resv_map's lock.  The set of regions within the resv_map represent
+ * reservations for huge pages, or huge pages that have already been
+ * instantiated within the map.  The from and to elements are huge page
+ * indicies into the associated mapping.  from indicates the starting index
+ * of the region.  to represents the first index past the end of  the region.
+ *
+ * For example, a file region structure with from == 0 and to == 4 represents
+ * four huge pages in a mapping.  It is important to note that the to element
+ * represents the first element past the end of the region. This is used in
+ * arithmetic as 4(to) - 0(from) = 4 huge pages in the region.
+ *
+ * Interval notation of the form [from, to) will be used to indicate that
+ * the endpoint from is inclusive and to is exclusive.
  */
 struct file_region {
 	struct list_head link;
@@ -226,6 +238,14 @@ struct file_region {
 	long to;
 };
 
+/*
+ * Add the huge page range represented by [f, t) to the reserve
+ * map.  Existing regions will be expanded to accommodate the
+ * specified range.  We know only existing regions need to be
+ * expanded, because region_add is only called after region_chg
+ * with the same range.  If a new file_region structure must
+ * be allocated, it is done in region_chg.
+ */
 static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
@@ -265,6 +285,25 @@ static long region_add(struct resv_map *resv, long f, long t)
 	return 0;
 }
 
+/*
+ * Examine the existing reserve map and determine how many
+ * huge pages in the specified range [f, t) are NOT currently
+ * represented.  This routine is called before a subsequent
+ * call to region_add that will actually modify the reserve
+ * map to add the specified range [f, t).  region_chg does
+ * not change the number of huge pages represented by the
+ * map.  However, if the existing regions in the map can not
+ * be expanded to represent the new range, a new file_region
+ * structure is added to the map as a placeholder.  This is
+ * so that the subsequent region_add call will have all the
+ * regions it needs and will not fail.
+ *
+ * Returns the number of huge pages that need to be added
+ * to the existing reservation map for the range [f, t).
+ * This number is greater or equal to zero.  -ENOMEM is
+ * returned if a new file_region structure is needed and can
+ * not be allocated.
+ */
 static long region_chg(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
@@ -331,6 +370,11 @@ out_nrg:
 	return chg;
 }
 
+/*
+ * Truncate the reserve map at index 'end'.  Modify/truncate any
+ * region which contains end.  Delete any regions past end.
+ * Return the number of huge pages removed from the map.
+ */
 static long region_truncate(struct resv_map *resv, long end)
 {
 	struct list_head *head = &resv->regions;
@@ -366,6 +410,10 @@ out:
 	return chg;
 }
 
+/*
+ * Count and return the number of huge pages in the reserve map
+ * that intersect with the range [f, t).
+ */
 static long region_count(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
