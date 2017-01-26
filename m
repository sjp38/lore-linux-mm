Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F33BC6B0038
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 15:48:54 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j18so50569554ioe.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:48:54 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id w71si168165ith.106.2017.01.26.12.48.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 12:48:54 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 1/2] mm/memory_hotplug.c: check start_pfn in test_pages_in_a_zone()
Date: Thu, 26 Jan 2017 14:44:14 -0700
Message-Id: <20170126214415.4509-2-toshi.kani@hpe.com>
In-Reply-To: <20170126214415.4509-1-toshi.kani@hpe.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

test_pages_in_a_zone() does not check 'start_pfn' when it is
aligned by section since 'sec_end_pfn' is set equal to 'pfn'.
Since this function is called for testing the range of a sysfs
memory file, 'start_pfn' is always aligned by section.

Fix it by properly setting 'sec_end_pfn' to the next section pfn.

Also make sure that this function returns 1 only when the range
belongs to a zone.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Banman <abanman@sgi.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e43142c1..7836606 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1477,7 +1477,7 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 }
 
 /*
- * Confirm all pages in a range [start, end) is belongs to the same zone.
+ * Confirm all pages in a range [start, end) belong to the same zone.
  */
 int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1485,9 +1485,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 	struct zone *zone = NULL;
 	struct page *page;
 	int i;
-	for (pfn = start_pfn, sec_end_pfn = SECTION_ALIGN_UP(start_pfn);
+	for (pfn = start_pfn, sec_end_pfn = SECTION_ALIGN_UP(start_pfn + 1);
 	     pfn < end_pfn;
-	     pfn = sec_end_pfn + 1, sec_end_pfn += PAGES_PER_SECTION) {
+	     pfn = sec_end_pfn, sec_end_pfn += PAGES_PER_SECTION) {
 		/* Make sure the memory section is present first */
 		if (!present_section_nr(pfn_to_section_nr(pfn)))
 			continue;
@@ -1506,7 +1506,11 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 			zone = page_zone(page);
 		}
 	}
-	return 1;
+
+	if (zone)
+		return 1;
+	else
+		return 0;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
