Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2042F6B003D
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:17:00 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so1055593pdi.29
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:16:59 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id yg2si1698975pab.48.2014.08.29.12.16.56
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 12:16:56 -0700 (PDT)
Message-Id: <20140829191647.582288686@asylum.americas.sgi.com>
References: <20140829191647.364032240@asylum.americas.sgi.com>
Date: Fri, 29 Aug 2014 14:16:48 -0500
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/2] x86: Optimize resource lookups for ioremap
Content-Disposition: inline; filename=add-get-resource-type
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com
Cc: akpm@linux-foundation.org, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>

Since the ioremap operation is verifying that the specified address range
is NOT RAM, it will search the entire ioresource list if the condition
is true.  To make matters worse, it does this one 4k page at a time.
For a 128M BAR region this is 32 passes to determine the entire region
does not contain any RAM addresses.

This patch provides another resource lookup function, region_is_ram,
that searches for the entire region specified, verifying that it is
completely contained within the resource region.  If it is found, then
it is checked to be RAM or not, within a single pass.

The return result reflects if it was found or not (-1), and whether it is
RAM (1) or not (0).  This allows the caller to fallback to the previous
page by page search if it was not found.

Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Alex Thorlton <athorlton@sgi.com>
Reviewed-by: Cliff Wickman <cpw@sgi.com>
---
v2: remove 'weak' and EXPORT_SYMBOL_GPL from region_is_ram()
---
 include/linux/mm.h |    1 +
 kernel/resource.c  |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -346,6 +346,7 @@ static inline int put_page_unless_one(st
 }
 
 extern int page_is_ram(unsigned long pfn);
+extern int region_is_ram(resource_size_t phys_addr, unsigned long size);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
--- linux.orig/kernel/resource.c
+++ linux/kernel/resource.c
@@ -494,6 +494,42 @@ int __weak page_is_ram(unsigned long pfn
 }
 EXPORT_SYMBOL_GPL(page_is_ram);
 
+/*
+ * Search for a resouce entry that fully contains the specified region.
+ * If found, return 1 if it is RAM, 0 if not.
+ * If not found, or region is not fully contained, return -1
+ *
+ * Used by the ioremap functions to insure user not remapping RAM and is as
+ * vast speed up over walking through the resource table page by page.
+ */
+int region_is_ram(resource_size_t start, unsigned long size)
+{
+	struct resource *p;
+	resource_size_t end = start + size - 1;
+	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	const char *name = "System RAM";
+	int ret = -1;
+
+	read_lock(&resource_lock);
+	for (p = iomem_resource.child; p ; p = p->sibling) {
+		if (end < p->start)
+			continue;
+
+		if (p->start <= start && end <= p->end) {
+			/* resource fully contains region */
+			if ((p->flags != flags) || strcmp(p->name, name))
+				ret = 0;
+			else
+				ret = 1;
+			break;
+		}
+		if (p->end < start)
+			break;	/* not found */
+	}
+	read_unlock(&resource_lock);
+	return ret;
+}
+
 void __weak arch_remove_reservations(struct resource *avail)
 {
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
