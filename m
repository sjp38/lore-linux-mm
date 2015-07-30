Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id B3BF36B0256
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:19 -0400 (EDT)
Received: by ykay190 with SMTP id y190so39039466yka.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:19 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id t123si1305303ywe.6.2015.07.30.10.04.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:18 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 04/10] xen/balloon: find non-conflicting regions to place hotplugged memory
Date: Thu, 30 Jul 2015 18:03:06 +0100
Message-ID: <1438275792-5726-5-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

Instead of placing hotplugged memory at the end of RAM (which may
conflict with PCI devices or reserved regions) use allocate_resource()
to get a new, suitably aligned resource that does not conflict.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
---
v3:
- Remove stale comment.
---
 drivers/xen/balloon.c | 73 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 53 insertions(+), 20 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index fd93369..7ecbbc5 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -54,6 +54,7 @@
 #include <linux/memory.h>
 #include <linux/memory_hotplug.h>
 #include <linux/percpu-defs.h>
+#include <linux/slab.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -208,26 +209,56 @@ static bool balloon_is_inflated(void)
 		return false;
 }
 
-/*
- * reserve_additional_memory() adds memory region of size >= credit above
- * max_pfn. New region is section aligned and size is modified to be multiple
- * of section size. Those features allow optimal use of address space and
- * establish proper alignment when this function is called first time after
- * boot (last section not fully populated at boot time contains unused memory
- * pages with PG_reserved bit not set; online_pages_range() does not allow page
- * onlining in whole range if first onlined page does not have PG_reserved
- * bit set). Real size of added memory is established at page onlining stage.
- */
+static struct resource *additional_memory_resource(phys_addr_t size)
+{
+	struct resource *res;
+	int ret;
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res)
+		return NULL;
+
+	res->name = "System RAM";
+	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+
+	ret = allocate_resource(&iomem_resource, res,
+				size, 0, -1,
+				PAGES_PER_SECTION * PAGE_SIZE, NULL, NULL);
+	if (ret < 0) {
+		pr_err("Cannot allocate new System RAM resource\n");
+		kfree(res);
+		return NULL;
+	}
+
+	return res;
+}
+
+static void release_memory_resource(struct resource *resource)
+{
+	if (!resource)
+		return;
+
+	/*
+	 * No need to reset region to identity mapped since we now
+	 * know that no I/O can be in this region
+	 */
+	release_resource(resource);
+	kfree(resource);
+}
 
 static enum bp_state reserve_additional_memory(long credit)
 {
+	struct resource *resource;
 	int nid, rc;
-	u64 hotplug_start_paddr;
-	unsigned long balloon_hotplug = credit;
+	unsigned long balloon_hotplug;
+
+	balloon_hotplug = round_up(credit, PAGES_PER_SECTION);
+
+	resource = additional_memory_resource(balloon_hotplug * PAGE_SIZE);
+	if (!resource)
+		goto err;
 
-	hotplug_start_paddr = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
-	balloon_hotplug = round_up(balloon_hotplug, PAGES_PER_SECTION);
-	nid = memory_add_physaddr_to_nid(hotplug_start_paddr);
+	nid = memory_add_physaddr_to_nid(resource->start);
 
 #ifdef CONFIG_XEN_HAVE_PVMMU
         /*
@@ -242,21 +273,20 @@ static enum bp_state reserve_additional_memory(long credit)
 	if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 		unsigned long pfn, i;
 
-		pfn = PFN_DOWN(hotplug_start_paddr);
+		pfn = PFN_DOWN(resource->start);
 		for (i = 0; i < balloon_hotplug; i++) {
 			if (!set_phys_to_machine(pfn + i, INVALID_P2M_ENTRY)) {
 				pr_warn("set_phys_to_machine() failed, no memory added\n");
-				return BP_ECANCELED;
+				goto err;
 			}
                 }
 	}
 #endif
 
-	rc = add_memory(nid, hotplug_start_paddr, balloon_hotplug << PAGE_SHIFT);
-
+	rc = add_memory_resource(nid, resource);
 	if (rc) {
 		pr_warn("Cannot add additional memory (%i)\n", rc);
-		return BP_ECANCELED;
+		goto err;
 	}
 
 	balloon_hotplug -= credit;
@@ -265,6 +295,9 @@ static enum bp_state reserve_additional_memory(long credit)
 	balloon_stats.balloon_hotplug = balloon_hotplug;
 
 	return BP_DONE;
+  err:
+	release_memory_resource(resource);
+	return BP_ECANCELED;
 }
 
 static void xen_online_page(struct page *page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
