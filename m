Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m49669fh224464
	for <linux-mm@kvack.org>; Fri, 9 May 2008 06:06:09 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m49669wh2474194
	for <linux-mm@kvack.org>; Fri, 9 May 2008 08:06:09 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m49669en011639
	for <linux-mm@kvack.org>; Fri, 9 May 2008 08:06:09 +0200
Date: Fri, 9 May 2008 08:06:09 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] memory_hotplug: always initialize pageblock bitmap.
Message-ID: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Trying to online a new memory section that was added via memory hotplug
sometimes results in crashes when the new pages are added via
__free_page. Reason for that is that the pageblock bitmap isn't
initialized and hence contains random stuff.
That means that get_pageblock_migratetype() returns also random stuff
and therefore

	list_add(&page->lru,
		 &zone->free_area[order].free_list[migratetype]);

in __free_one_page() tries to do a list_add to something that isn't
even necessarily a list.
This is only an issue for memory sections that get added after boot
time since all previously present memory sections allocate their
pageblock bitmaps via the bootmem allocator which in turn initializes
just everything it returns.

Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/sparse.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c
+++ linux-2.6/mm/sparse.c
@@ -244,7 +244,7 @@ unsigned long usemap_size(void)
 #ifdef CONFIG_MEMORY_HOTPLUG
 static unsigned long *__kmalloc_section_usemap(void)
 {
-	return kmalloc(usemap_size(), GFP_KERNEL);
+	return kzalloc(usemap_size(), GFP_KERNEL);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
