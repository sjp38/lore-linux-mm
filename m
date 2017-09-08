Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3981C6B04B9
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 16:43:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i50so4725263qtf.0
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 13:43:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor1501183qti.23.2017.09.08.13.43.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Sep 2017 13:43:06 -0700 (PDT)
Subject: [PATCH] mm/memory_hotplug: fix wrong casting for __remove_section()
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
Date: Fri, 8 Sep 2017 16:43:04 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>Reza Arbab <arbab@linux.vnet.ibm.com>

__remove_section() calls __remove_zone() to shrink zone and pgdat.
But due to wrong castings, __remvoe_zone() cannot shrink zone
and pgdat correctly if pfn is over 0xffffffff.

So the patch fixes the following 3 wrong castings.

  1. find_smallest_section_pfn() returns 0 or start_pfn which defined
     as unsigned long. But the function always returns 32bit value
     since the function is defined as int.

  2. find_biggest_section_pfn() returns 0 or pfn which defined as
     unsigned long. the function always returns 32bit value
     since the function is defined as int.

  3. __remove_section() calculates start_pfn using section_nr_to_pfn()
     and scn_nr. section_nr_to_pfn() just shifts scn_nr by
     PFN_SECTION_SHIFT bit. But since scn_nr is defined as int,
     section_nr_to_pfn() always return 32 bit value.

The patch fixes the wrong castings.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 73bf17d..3514ef2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -331,7 +331,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,

 #ifdef CONFIG_MEMORY_HOTREMOVE
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
-static int find_smallest_section_pfn(int nid, struct zone *zone,
+static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
@@ -356,7 +356,7 @@ static int find_smallest_section_pfn(int nid, struct zone *zone,
 }

 /* find the biggest valid pfn in the range [start_pfn, end_pfn). */
-static int find_biggest_section_pfn(int nid, struct zone *zone,
+static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
@@ -544,7 +544,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 		return ret;

 	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn(scn_nr);
+	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);

 	sparse_remove_one_section(zone, ms, map_offset);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
