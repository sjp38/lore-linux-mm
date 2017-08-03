Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46DAA6B0659
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 02:38:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l2so5572941pgu.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:38:28 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id t11si20706901plm.644.2017.08.02.23.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 23:38:27 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 123so652475pga.5
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:38:27 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/vmalloc: reduce half comparison during pcpu_get_vm_areas()
Date: Thu,  3 Aug 2017 14:38:22 +0800
Message-Id: <20170803063822.48702-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

In pcpu_get_vm_areas(), it checks each range is not overlapped. To make
sure it is, only (N^2)/2 comparison is necessary, while current code does
N^2 times. By starting from the next range, it achieves the goal and the
continue could be removed.

At the mean time, other two work in this patch:
*  the overlap check of two ranges could be done with one clause
*  one typo in comment is fixed.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/vmalloc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8087451cb332..f33c8350fd83 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2457,7 +2457,7 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
  * matching slot.  While scanning, if any of the areas overlaps with
  * existing vmap_area, the base address is pulled down to fit the
  * area.  Scanning is repeated till all the areas fit and then all
- * necessary data structres are inserted and the result is returned.
+ * necessary data structures are inserted and the result is returned.
  */
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
@@ -2485,15 +2485,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		if (start > offsets[last_area])
 			last_area = area;
 
-		for (area2 = 0; area2 < nr_vms; area2++) {
+		for (area2 = area + 1; area2 < nr_vms; area2++) {
 			unsigned long start2 = offsets[area2];
 			unsigned long end2 = start2 + sizes[area2];
 
-			if (area2 == area)
-				continue;
-
-			BUG_ON(start2 >= start && start2 < end);
-			BUG_ON(end2 <= end && end2 > start);
+			BUG_ON(start2 < end && start < end2);
 		}
 	}
 	last_end = offsets[last_area] + sizes[last_area];
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
