Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 198176B0261
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 05:29:16 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t15so3219814wmh.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 02:29:16 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id q1si3747886wrd.403.2017.12.07.02.29.14
        for <linux-mm@kvack.org>;
        Thu, 07 Dec 2017 02:29:14 -0800 (PST)
Date: Thu, 7 Dec 2017 11:29:14 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm: memory_hotplug: remove second __nr_to_section in
 register_page_bootmem_info_section()
Message-ID: <20171207102914.GA12396@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz

In register_page_bootmem_info_section() we call __nr_to_section() in order to
get the mem_section struct at the beginning of the function.
Since we already got it, there is no need for a second call to __nr_to_section().

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7452a53b027f..262bfd26baf9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -184,7 +184,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, SECTION_INFO);
 
-	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	usemap = ms->pageblock_flags;
 	page = virt_to_page(usemap);
 
 	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
@@ -207,7 +207,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 
 	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
 
-	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	usemap = ms->pageblock_flags;
 	page = virt_to_page(usemap);
 
 	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
