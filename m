Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 378FE6B0069
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:26:27 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e137so84435601itc.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:26:27 -0800 (PST)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id k188si2476692ita.95.2017.01.27.13.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:26:26 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 1/2] mm/memory_hotplug.c: check start_pfn in test_pages_in_a_zone()
Date: Fri, 27 Jan 2017 15:21:48 -0700
Message-Id: <20170127222149.30893-2-toshi.kani@hpe.com>
In-Reply-To: <20170127222149.30893-1-toshi.kani@hpe.com>
References: <20170127222149.30893-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org, stable@vger.kernel.org, toshi.kani@hpe.com

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
Cc: <stable@vger.kernel.org> # v4.4+
---
 mm/memory_hotplug.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3e3db7a..c845c5f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1489,7 +1489,7 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 }
 
 /*
- * Confirm all pages in a range [start, end) is belongs to the same zone.
+ * Confirm all pages in a range [start, end) belong to the same zone.
  */
 int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1497,9 +1497,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -1518,7 +1518,11 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
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
