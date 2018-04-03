Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFF3F6B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 14:16:59 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d3so4913560iod.22
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 11:16:59 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 128-v6si2828164itp.65.2018.04.03.11.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 11:16:58 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 4/6] mm/memory_hotplug: optimize probe routine
Date: Tue,  3 Apr 2018 14:16:41 -0400
Message-Id: <20180403181643.28127-5-pasha.tatashin@oracle.com>
In-Reply-To: <20180403181643.28127-1-pasha.tatashin@oracle.com>
References: <20180403181643.28127-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com, alexander.levin@microsoft.com

When memory is hotplugged pages_correctly_reserved() is called to verify
that the added memory is present, this routine traverses through every
struct page and verifies that PageReserved() is set. This is a slow
operation especially if a large amount of memory is added.

Instead of checking every page, it is enough to simply check that the
section is present, has mapping (struct page array is allocated), and the
mapping is online.

In addition, we should not excpect that probe routine sets flags in struct
page, as the struct pages have not yet been initialized. The initialization
should be done in __init_single_page(), the same as during boot.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index fe4b24f05f6a..deb3f029b451 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -187,13 +187,14 @@ int memory_isolate_notify(unsigned long val, void *v)
 }
 
 /*
- * The probe routines leave the pages reserved, just as the bootmem code does.
- * Make sure they're still that way.
+ * The probe routines leave the pages uninitialized, just as the bootmem code
+ * does. Make sure we do not access them, but instead use only information from
+ * within sections.
  */
-static bool pages_correctly_reserved(unsigned long start_pfn)
+static bool pages_correctly_probed(unsigned long start_pfn)
 {
-	int i, j;
-	struct page *page;
+	unsigned long section_nr = pfn_to_section_nr(start_pfn);
+	unsigned long section_nr_end = section_nr + sections_per_block;
 	unsigned long pfn = start_pfn;
 
 	/*
@@ -201,21 +202,24 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
 	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
 	 * and assume memmap is contiguous within each section
 	 */
-	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
+	for (; section_nr < section_nr_end; section_nr++) {
 		if (WARN_ON_ONCE(!pfn_valid(pfn)))
 			return false;
-		page = pfn_to_page(pfn);
-
-		for (j = 0; j < PAGES_PER_SECTION; j++) {
-			if (PageReserved(page + j))
-				continue;
-
-			printk(KERN_WARNING "section number %ld page number %d "
-				"not reserved, was it already online?\n",
-				pfn_to_section_nr(pfn), j);
 
+		if (!present_section_nr(section_nr)) {
+			pr_warn("section %ld pfn[%lx, %lx) not present",
+				section_nr, pfn, pfn + PAGES_PER_SECTION);
+			return false;
+		} else if (!valid_section_nr(section_nr)) {
+			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
+				section_nr, pfn, pfn + PAGES_PER_SECTION);
+			return false;
+		} else if (online_section_nr(section_nr)) {
+			pr_warn("section %ld pfn[%lx, %lx) is already online",
+				section_nr, pfn, pfn + PAGES_PER_SECTION);
 			return false;
 		}
+		pfn += PAGES_PER_SECTION;
 	}
 
 	return true;
@@ -237,7 +241,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 
 	switch (action) {
 	case MEM_ONLINE:
-		if (!pages_correctly_reserved(start_pfn))
+		if (!pages_correctly_probed(start_pfn))
 			return -EBUSY;
 
 		ret = online_pages(start_pfn, nr_pages, online_type);
-- 
2.16.3
