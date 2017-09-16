Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 381866B0275
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 22:52:23 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f24so4474053qte.7
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 19:52:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 84sor1011358qkx.153.2017.09.15.19.52.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 19:52:22 -0700 (PDT)
Subject: [PATCH 1/2] mm/memory_hotplug: Change
 pfn_to_section_nr/section_nr_to_pfn macro to inline function
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
Date: Fri, 15 Sep 2017 22:52:20 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, vbabka@suse.czarbab@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

pfn_to_section_nr() and section_nr_to_pfn() are defined as macro.
pfn_to_section_nr() has no issue even if it is defined as macro.
But section_nr_to_pfn() has overflow issue if sec is defined as int.

section_nr_to_pfn() just shifts sec by PFN_SECTION_SHIFT. If sec
is defined as unsigned long, section_nr_to_pfn() returns pfn as 64
bit value. But if sec is defined as int, section_nr_to_pfn() returns
pfn as 32 bit value.

__remove_section() calculates start_pfn using section_nr_to_pfn() and
scn_nr defined as int. So if hot-removed memory address is over 16TB,
overflow issue occurs and section_nr_to_pfn() does not calculate
correct pfn.

To make callers use proper arg, the patch changes the macros to
inline functions.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 include/linux/mmzone.h | 10 ++++++++--
 mm/memory_hotplug.c    |  2 +-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef6a13b..6ae12b2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1073,8 +1073,14 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif

-#define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
-#define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
+static inline unsigned long pfn_to_section_nr(unsigned long pfn)
+{
+	return pfn >> PFN_SECTION_SHIFT;
+}
+static inline unsigned long section_nr_to_pfn(unsigned long sec)
+{
+	return sec << PFN_SECTION_SHIFT;
+}

 #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b63d7d1..38c3c37 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -798,7 +798,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
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
