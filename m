Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 074016B00D5
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:59:42 -0400 (EDT)
Message-ID: <516F456E.9060003@infradead.org>
Date: Wed, 17 Apr 2013 17:59:26 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix memory_hotplug.c printk format warning
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

PFN_PHYS() is a phys_addr_t, which can be u32 or u64.
Fix the build warning when phys_addr_t is u32.

mm/memory_hotplug.c: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 2 has type 'unsigned int' [-Wformat]:  => 1685:3
mm/memory_hotplug.c: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 3 has type 'unsigned int' [-Wformat]:  => 1685:3

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/memory_hotplug.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

I guess this modern "%pa" is preferred over casting to (u64),
but just casting seems a simpler fix to me.  I.e.:

 	if (unlikely(ret))
 		pr_warn("removing memory fails, because memory "
 			"[%#010llx-%#010llx] is onlined\n",
-			PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
-			PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1);
+			(u64)PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
+			(u64)PFN_PHYS(section_nr_to_pfn(
+					mem->end_section_nr + 1))-1);
 
 	return ret;
 }

--- lnx-39-rc7.orig/mm/memory_hotplug.c
+++ lnx-39-rc7/mm/memory_hotplug.c
@@ -1681,11 +1681,15 @@ static int is_memblock_offlined_cb(struc
 {
 	int ret = !is_memblock_offlined(mem);
 
-	if (unlikely(ret))
+	if (unlikely(ret)) {
+		phys_addr_t beginpa, endpa;
+
+		beginpa = PFN_PHYS(section_nr_to_pfn(mem->start_section_nr));
+		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
 		pr_warn("removing memory fails, because memory "
-			"[%#010llx-%#010llx] is onlined\n",
-			PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
-			PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1);
+			"[%pa-%pa] is onlined\n",
+			&beginpa, &endpa);
+	}
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
