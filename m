Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A22716B454E
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 05:05:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so530000edm.13
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:05:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c10-v6si757606edk.121.2018.08.28.02.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 02:05:54 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7S94lig018564
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 05:05:52 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m503dg3je-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 05:05:52 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Tue, 28 Aug 2018 10:05:43 +0100
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH] memory_hotplug: fix kernel_panic on offline page processing
Date: Tue, 28 Aug 2018 11:05:39 +0200
Message-Id: <20180828090539.41491-1-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pasha.tatashin@oracle.com, mhocko@kernel.org, zaslonko@linux.ibm.com

Within show_valid_zones() the function test_pages_in_a_zone() should be
called for online memory blocks only. Otherwise it might lead to the
VM_BUG_ON due to uninitialized struct pages (when CONFIG_DEBUG_VM_PGFLAGS
kernel option is set):

 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 ------------[ cut here ]------------
 Call Trace:
 ([<000000000038f91e>] test_pages_in_a_zone+0xe6/0x168)
  [<0000000000923472>] show_valid_zones+0x5a/0x1a8
  [<0000000000900284>] dev_attr_show+0x3c/0x78
  [<000000000046f6f0>] sysfs_kf_seq_show+0xd0/0x150
  [<00000000003ef662>] seq_read+0x212/0x4b8
  [<00000000003bf202>] __vfs_read+0x3a/0x178
  [<00000000003bf3ca>] vfs_read+0x8a/0x148
  [<00000000003bfa3a>] ksys_read+0x62/0xb8
  [<0000000000bc2220>] system_call+0xdc/0x2d8

That VM_BUG_ON was triggered by the page poisoning introduced in
mm/sparse.c with the git commit d0dc12e86b31 ("mm/memory_hotplug: optimize
memory hotplug")
With the same commit the new 'nid' field has been added to the struct
memory_block in order to store and later on derive the node id for offline
pages (instead of accessing struct page which might be uninitialized). But
one reference to nid in show_valid_zones() function has been overlooked.
Fixed with current commit.
Also, nr_pages will not be used any more after test_pages_in_a_zone() call,
do not update it.

Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Cc: <stable@vger.kernel.org> # v4.17+
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
---
 drivers/base/memory.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index f5e560188a18..622ab8edc035 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -416,26 +416,24 @@ static ssize_t show_valid_zones(struct device *dev,
 	struct zone *default_zone;
 	int nid;
 
-	/*
-	 * The block contains more than one zone can not be offlined.
-	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
-	 */
-	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages, &valid_start_pfn, &valid_end_pfn))
-		return sprintf(buf, "none\n");
-
-	start_pfn = valid_start_pfn;
-	nr_pages = valid_end_pfn - start_pfn;
-
 	/*
 	 * Check the existing zone. Make sure that we do that only on the
 	 * online nodes otherwise the page_zone is not reliable
 	 */
 	if (mem->state == MEM_ONLINE) {
+		/*
+		 * The block contains more than one zone can not be offlined.
+		 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
+		 */
+		if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages,
+					  &valid_start_pfn, &valid_end_pfn))
+			return sprintf(buf, "none\n");
+		start_pfn = valid_start_pfn;
 		strcat(buf, page_zone(pfn_to_page(start_pfn))->name);
 		goto out;
 	}
 
-	nid = pfn_to_nid(start_pfn);
+	nid = mem->nid;
 	default_zone = zone_for_pfn_range(MMOP_ONLINE_KEEP, nid, start_pfn, nr_pages);
 	strcat(buf, default_zone->name);
 
-- 
2.16.4
