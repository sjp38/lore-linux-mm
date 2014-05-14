Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4F13C6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 03:09:34 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so1321647pab.40
        for <linux-mm@kvack.org>; Wed, 14 May 2014 00:09:34 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id ew3si985106pac.229.2014.05.14.00.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 00:09:33 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so1323417pbc.23
        for <linux-mm@kvack.org>; Wed, 14 May 2014 00:09:32 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm, hugetlb: use list_for_each_entry in region_xxx
Date: Wed, 14 May 2014 15:09:19 +0800
Message-Id: <1400051359-19942-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, mhocko@suse.cz, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Commit 7b24d8616be3 ("mm, hugetlb: fix race in region tracking") has
changed to use a per resv_map spinlock to serialize against any
concurrent write operations to the resv_map, thus we don't need
list_for_each_entry_safe to interate over file_region's any more.
Use list_for_each_entry is enough.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/hugetlb.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c82290b..26b1464 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -156,7 +156,7 @@ struct file_region {
 static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
-	struct file_region *rg, *nrg, *trg;
+	struct file_region *rg, *nrg;
 
 	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
@@ -170,7 +170,7 @@ static long region_add(struct resv_map *resv, long f, long t)
 
 	/* Check for and consume any regions we now overlap with. */
 	nrg = rg;
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+	list_for_each_entry(rg, rg->link.prev, link) {
 		if (&rg->link == head)
 			break;
 		if (rg->from > t)
@@ -261,7 +261,7 @@ out_nrg:
 static long region_truncate(struct resv_map *resv, long end)
 {
 	struct list_head *head = &resv->regions;
-	struct file_region *rg, *trg;
+	struct file_region *rg;
 	long chg = 0;
 
 	spin_lock(&resv->lock);
@@ -280,7 +280,7 @@ static long region_truncate(struct resv_map *resv, long end)
 	}
 
 	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+	list_for_each_entry(rg, rg->link.prev, link) {
 		if (&rg->link == head)
 			break;
 		chg += rg->to - rg->from;
-- 
2.0.0-rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
