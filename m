Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59CB4280250
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so45143739pfi.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g16si1244377pfj.150.2016.10.20.23.37.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:37:11 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 3/7] mm: add a function to get the max pfn
Date: Fri, 21 Oct 2016 14:24:36 +0800
Message-Id: <1477031080-12616-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

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
---
 include/linux/mm.h |  1 +
 mm/page_alloc.c    | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffbd729..2a89da0e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1776,6 +1776,7 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern unsigned long get_max_pfn(void);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b3bf67..e5f63a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4426,6 +4426,16 @@ void show_free_areas(unsigned int filter)
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
