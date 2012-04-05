Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 811B96B007E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 14:07:54 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1981033bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 11:07:53 -0700 (PDT)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [PATCH 2/2] mm: consistently register / release memory resource
Date: Thu,  5 Apr 2012 20:07:02 +0200
Message-Id: <1333649222-24285-3-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1333649222-24285-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1333649222-24285-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

add_memory() registers hotplugged memory resources by calling
register_memory_resource() for the whole memory range requested.
However, __remove_pages() releases memory resources by calling
release_memory_region on a per section basis. This discrepancy
can break memory hotplug operations when using memory devices
that span multiple sections. Specifically hot-readd
(hot-add/hot-remove/hot-add sequence) will not work. Fix by releasing
the memory resource as a whole (another option would be to register
and release always on a per section basis).

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 mm/memory_hotplug.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6629faf..8ab6b63 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -362,12 +362,12 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		release_mem_region(pfn << PAGE_SHIFT,
-				   PAGES_PER_SECTION << PAGE_SHIFT);
 		ret = __remove_section(zone, __pfn_to_section(pfn));
 		if (ret)
 			break;
 	}
+	release_mem_region(phys_start_pfn << PAGE_SHIFT,
+			nr_pages << PAGE_SHIFT);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
