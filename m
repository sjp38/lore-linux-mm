Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7CE6B006C
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:03:20 -0400 (EDT)
Received: by oica37 with SMTP id a37so56464649oic.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 16:03:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x6si6488093oig.122.2015.04.16.16.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 16:03:20 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/4] hugetlbfs: truncate_hugepages() takes a range of pages
Date: Thu, 16 Apr 2015 16:02:55 -0700
Message-Id: <1429225378-22965-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
References: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

Modify truncate_hugepages() to take a range of pages (start, end)
instead of simply start.  If the value of end is -1, this indicates
the end of the range is the end of the file.  This functionality
will be used for fallocate hole punching.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c274aca..d5b67fd 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -324,11 +324,12 @@ static void truncate_huge_page(struct page *page)
 	delete_from_page_cache(page);
 }
 
-static void truncate_hugepages(struct inode *inode, loff_t lstart)
+static void truncate_hugepages(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	struct hstate *h = hstate_inode(inode);
 	struct address_space *mapping = &inode->i_data;
 	const pgoff_t start = lstart >> huge_page_shift(h);
+	const pgoff_t end = lend >> huge_page_shift(h);
 	struct pagevec pvec;
 	pgoff_t next;
 	int i, freed = 0;
@@ -336,7 +337,19 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 	pagevec_init(&pvec, 0);
 	next = start;
 	while (1) {
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		long lookup_nr = PAGEVEC_SIZE;
+
+		/*
+		 * Make sure to never grab more pages that we
+		 * might possibly need.
+		 */
+		if (end - start < lookup_nr)
+			lookup_nr = end - start;
+		/*
+		 * This pagevec_lookup() may return pages past 'end',
+		 * so we must check for page->index > end.
+		 */
+		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
 			if (next == start)
 				break;
 			next = start;
@@ -347,6 +360,10 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 			struct page *page = pvec.pages[i];
 
 			lock_page(page);
+			if (page->index >= end) {
+				unlock_page(page);
+				break;
+			}
 			if (page->index > next)
 				next = page->index;
 			++next;
@@ -364,7 +381,7 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
 
-	truncate_hugepages(inode, 0);
+	truncate_hugepages(inode, 0, -1);
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */
 	if (resv_map)
@@ -410,7 +427,7 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
 	i_mmap_unlock_write(mapping);
-	truncate_hugepages(inode, offset);
+	truncate_hugepages(inode, offset, -1);
 	return 0;
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
