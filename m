Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 311776B02F4
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 22:53:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u5so19688329pgq.14
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:21 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 97si7107048plc.447.2017.06.24.19.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 19:53:20 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id z6so4522452pfk.3
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:20 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH 2/4] mm/hotplug: walk_memroy_range on memory_block uit
Date: Sun, 25 Jun 2017 10:52:25 +0800
Message-Id: <20170625025227.45665-3-richard.weiyang@gmail.com>
In-Reply-To: <20170625025227.45665-1-richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, linux-mm@kvack.org
Cc: Wei Yang <richard.weiyang@gmail.com>

hotplug memory range is memory_block aligned and walk_memroy_range guarded
with check_hotplug_memory_range(). This is save to iterate on the
memory_block base.

This patch adjust the iteration unit and assume there is not hole in
hotplug memory range.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memory_hotplug.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f5d06afc8645..a79a83ec965f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1858,17 +1858,11 @@ int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn, section_nr;
 	int ret;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+	for (pfn = start_pfn; pfn < end_pfn;
+		pfn += PAGES_PER_SECTION * sections_per_block) {
 		section_nr = pfn_to_section_nr(pfn);
-		if (!present_section_nr(section_nr))
-			continue;
 
 		section = __nr_to_section(section_nr);
-		/* same memblock? */
-		if (mem)
-			if ((section_nr >= mem->start_section_nr) &&
-			    (section_nr <= mem->end_section_nr))
-				continue;
 
 		mem = find_memory_block_hinted(section, mem);
 		if (!mem)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
