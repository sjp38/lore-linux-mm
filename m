Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFEB06B0026
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:33:13 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s7-v6so5148000ybo.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:33:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y18si366412qtj.150.2018.04.13.06.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:33:13 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 5/8] mm: only mark section offline when all pages are offline
Date: Fri, 13 Apr 2018 15:33:06 +0200
Message-Id: <20180413133309.3501-1-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, open list <linux-kernel@vger.kernel.org>

If any page is still online, the section should stay online.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/page_alloc.c |  2 +-
 mm/sparse.c     | 25 ++++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e5dcfdb0908..ae9023da2ca2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8013,7 +8013,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			break;
 	if (pfn == end_pfn)
 		return;
-	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
@@ -8051,6 +8050,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+	offline_mem_sections(start_pfn, end_pfn);
 }
 #endif
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 58cab483e81b..44978cb18fed 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -623,7 +623,27 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/* Mark all memory sections within the pfn range as online */
+static bool all_pages_in_section_offline(unsigned long section_nr)
+{
+	unsigned long pfn = section_nr_to_pfn(section_nr);
+	struct page *page;
+	int i;
+
+	for (i = 0; i < PAGES_PER_SECTION; i++, pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (!PageOffline(page))
+			return false;
+	}
+	return true;
+}
+
+/*
+ * Mark all memory sections within the pfn range as offline (if all pages
+ * of a memory section are already offline)
+ */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
@@ -639,6 +659,9 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 		if (WARN_ON(!valid_section_nr(section_nr)))
 			continue;
 
+		if (!all_pages_in_section_offline(section_nr))
+			continue;
+
 		ms = __nr_to_section(section_nr);
 		ms->section_mem_map &= ~SECTION_IS_ONLINE;
 	}
-- 
2.14.3
