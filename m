Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 632C66B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 18:29:22 -0400 (EDT)
Message-ID: <51901797.9070303@infradead.org>
Date: Sun, 12 May 2013 15:28:39 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix memory_hotplug.c printk format warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix printk format warnings in mm/memory_hotplug.c by using "%pa":

mm/memory_hotplug.c: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 2 has type 'resource_size_t' [-Wformat]
mm/memory_hotplug.c: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 3 has type 'resource_size_t' [-Wformat]

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/memory_hotplug.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- lnx-310-rc1.orig/mm/memory_hotplug.c
+++ lnx-310-rc1/mm/memory_hotplug.c
@@ -720,9 +720,12 @@ int __remove_pages(struct zone *zone, un
 	start = phys_start_pfn << PAGE_SHIFT;
 	size = nr_pages * PAGE_SIZE;
 	ret = release_mem_region_adjustable(&iomem_resource, start, size);
-	if (ret)
-		pr_warn("Unable to release resource <%016llx-%016llx> (%d)\n",
-				start, start + size - 1, ret);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+				&start, &endres, ret);
+	}
 
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
