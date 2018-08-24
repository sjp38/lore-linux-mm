Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4740B6B2875
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:33:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y135-v6so1166595oie.11
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 23:33:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t196-v6si4616706oif.57.2018.08.23.23.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 23:33:34 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7O6TXmQ079822
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:33:34 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m2bb833se-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:33:33 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 24 Aug 2018 00:33:33 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/hugetlb: filter out hugetlb pages if HUGEPAGE migration is not supported.
Date: Fri, 24 Aug 2018 12:03:14 +0530
Message-Id: <20180824063314.21981-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, mike.kravetz@oracle.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

When scanning for movable pages, filter out Hugetlb pages if hugepage migration
is not supported. Without this we hit infinte loop in __offline pages where we
do
	pfn = scan_movable_pages(start_pfn, end_pfn);
	if (pfn) { /* We have movable pages */
		ret = do_migrate_range(pfn, end_pfn);
		goto repeat;
	}

We do support hugetlb migration ony if the hugetlb pages are at pmd level. Here
we just check for Kernel config. The gigantic page size check is done in
page_huge_active.

Acked-by: Michal Hocko <mhocko@suse.com>
Reported-by: Haren Myneni <haren@linux.vnet.ibm.com>
CC: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 mm/memory_hotplug.c | 3 ++-
 mm/page_alloc.c     | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9eea6e809a4e..38d94b703e9d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1333,7 +1333,8 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 			if (__PageMovable(page))
 				return pfn;
 			if (PageHuge(page)) {
-				if (page_huge_active(page))
+				if (hugepage_migration_supported(page_hstate(page)) &&
+				    page_huge_active(page))
 					return pfn;
 				else
 					pfn = round_up(pfn + 1,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c677c1506d73..b8d91f59b836 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7709,6 +7709,10 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * handle each tail page individually in migration.
 		 */
 		if (PageHuge(page)) {
+
+			if (!hugepage_migration_supported(page_hstate(page)))
+				goto unmovable;
+
 			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
 			continue;
 		}
-- 
2.17.1
