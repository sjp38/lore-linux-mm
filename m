Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 582206B0260
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 02:43:18 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so207986485pab.0
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 23:43:18 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q3si29597848pae.284.2016.08.07.23.43.17
        for <linux-mm@kvack.org>;
        Sun, 07 Aug 2016 23:43:17 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v3 kernel 3/7] mm: add a function to get the max pfn
Date: Mon,  8 Aug 2016 14:35:30 +0800
Message-Id: <1470638134-24149-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Expose the function to get the max pfn, so it can be used in the
virtio-balloon device driver. Simply include the 'linux/bootmem.h'
is not enough, if the device driver is built to a module, directly
refer the max_pfn lead to build failed.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mm.h |  1 +
 mm/page_alloc.c    | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53e..5873057 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1788,6 +1788,7 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern unsigned long get_max_pfn(void);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fb975ce..3373704 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4391,6 +4391,16 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+/*
+ * The max_pfn can change because of memory hot plug, so it's only good
+ * as a hint. e.g. for sizing data structures.
+ */
+unsigned long get_max_pfn(void)
+{
+	return max_pfn;
+}
+EXPORT_SYMBOL(get_max_pfn);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
