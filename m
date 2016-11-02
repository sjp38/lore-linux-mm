Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1409B6B02AC
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 02:30:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so3517900pag.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 23:30:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id fe10si917973pac.222.2016.11.01.23.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 23:30:42 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v4 3/7] mm: add a function to get the max pfn
Date: Wed,  2 Nov 2016 14:17:23 +0800
Message-Id: <1478067447-24654-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, dave.hansen@intel.com
Cc: pbonzini@redhat.com, amit.shah@redhat.com, quintela@redhat.com, dgilbert@redhat.com, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, mgorman@techsingularity.net, cornelia.huck@de.ibm.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>

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
index a92c8d7..f47862a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1772,6 +1772,7 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern unsigned long get_max_pfn(void);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fd42aa..12cc8ed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4428,6 +4428,16 @@ void show_free_areas(unsigned int filter)
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
