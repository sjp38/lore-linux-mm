Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A65126B003D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:23:05 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 3/3] mm: Change __remove_pages() to call release_mem_region_adjustable()
Date: Mon,  8 Apr 2013 11:09:56 -0600
Message-Id: <1365440996-30981-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1365440996-30981-1-git-send-email-toshi.kani@hp.com>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com, Toshi Kani <toshi.kani@hp.com>

Changed __remove_pages() to call release_mem_region_adjustable().
This allows a requested memory range to be released from
the iomem_resource table even if it does not match exactly to
an resource entry but still fits into.  The resource entries
initialized at bootup usually cover the whole contiguous
memory ranges and may not necessarily match with the size of
memory hot-delete requests.

If release_mem_region_adjustable() failed, __remove_pages() logs
an error message and continues to proceed as it was the case
with release_mem_region().  release_mem_region(), which is defined
to __release_region(), logs an error message and returns no error
since a void function.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 57decb2..c916582 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -705,8 +705,10 @@ EXPORT_SYMBOL_GPL(__add_pages);
 int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		 unsigned long nr_pages)
 {
-	unsigned long i, ret = 0;
+	unsigned long i;
 	int sections_to_remove;
+	resource_size_t start, size;
+	int ret = 0;
 
 	/*
 	 * We can only remove entire sections
@@ -714,7 +716,12 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
 	BUG_ON(nr_pages % PAGES_PER_SECTION);
 
-	release_mem_region(phys_start_pfn << PAGE_SHIFT, nr_pages * PAGE_SIZE);
+	start = phys_start_pfn << PAGE_SHIFT;
+	size = nr_pages * PAGE_SIZE;
+	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+	if (ret)
+		pr_warn("Unable to release resource <%016llx-%016llx> (%d)\n",
+				start, start + size - 1, ret);
 
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
