Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B43D86B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 15:45:49 -0500 (EST)
From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/4] resource.c: find the end of a E820 memory region
Date: Sun, 18 Dec 2011 13:45:42 -0700
Message-Id: <1324241142-7596-1-git-send-email-philipp_subx@redfish-solutions.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>, Guy Ellis <guy@traverse.com.au>, David Woodhouse <dwmw2@infradead.org>, Patrick Georgi <patrick.georgi@secunet.com>, Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>, linux-mm@kvack.org

From: Philip Prindeville <philipp@redfish-solutions.com>

Add support for finding the end-boundary of an E820 region given an
address falling in one such region. This is precursory functionality
for Coreboot loader support.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
Reviewed-by: Ed Wildgoose <ed@wildgooses.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>
Cc: Guy Ellis <guy@traverse.com.au>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Patrick Georgi <patrick.georgi@secunet.com>
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Cc: linux-geode@lists.infradead.org
Cc: linux-mm@kvack.org
---
 include/linux/ioport.h |    1 +
 kernel/resource.c      |   29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 9d57a71..962d5a5 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -223,6 +223,7 @@ extern struct resource * __devm_request_region(struct device *dev,
 extern void __devm_release_region(struct device *dev, struct resource *parent,
 				  resource_size_t start, resource_size_t n);
 extern int iomem_map_sanity_check(resource_size_t addr, unsigned long size);
+extern resource_size_t iomem_map_find_boundary(resource_size_t addr, int *mapped);
 extern int iomem_is_exclusive(u64 addr);
 
 extern int
diff --git a/kernel/resource.c b/kernel/resource.c
index 7640b3a..58e4fce 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1057,6 +1057,35 @@ static int __init reserve_setup(char *str)
 __setup("reserve=", reserve_setup);
 
 /*
+ * Find the upper boundary for the region that this address falls in, and
+ * whether it's currently mapped or not.
+ */
+
+resource_size_t iomem_map_find_boundary(resource_size_t addr, int *mapped)
+{
+	struct resource *p = &iomem_resource;
+	resource_size_t upper = 0;
+	loff_t l;
+
+	read_lock(&resource_lock);
+	for (p = p->child; p ; p = r_next(NULL, p, &l)) {
+		if (p->start > addr)
+			continue;
+		if (p->end < addr)
+			continue;
+		upper = p->end;
+		*mapped = ((p->flags & IORESOURCE_BUSY) != 0);
+		break;
+	}
+	read_unlock(&resource_lock);
+
+	return upper;
+}
+
+EXPORT_SYMBOL(iomem_map_find_boundary);
+
+
+/*
  * Check if the requested addr and size spans more than any slot in the
  * iomem resource tree.
  */
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
