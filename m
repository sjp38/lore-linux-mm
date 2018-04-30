Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A939F6B0008
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:42:52 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c73so6541057qke.2
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:42:52 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f48-v6si5516543qta.78.2018.04.30.02.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 02:42:51 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RCFv2 3/7] mm/memory_hotplug: limit offline_pages() to sizes we can actually handle
Date: Mon, 30 Apr 2018 11:42:32 +0200
Message-Id: <20180430094236.29056-4-david@redhat.com>
In-Reply-To: <20180430094236.29056-1-david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

We have to take care of MAX_ORDER. Page blocks might contain references
to the next page block. So sometimes a page block cannot be offlined
independently. E.g. on x86: page block size is 2MB, MAX_ORDER -1 (10)
allows 4MB allocations.

E.g. a buddy page could either overlap at the beginning or the end of the
range to offline. While the end case could be handled easily (shrink the
buddy page), overlaps at the beginning are hard to handle (unknown page
order).

Let document offline_pages() while at it.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  6 ++++++
 mm/memory_hotplug.c            | 22 ++++++++++++++++++----
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e0e49b5b1ee1..d71829d54360 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -294,6 +294,12 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 #endif /* !(CONFIG_MEMORY_HOTPLUG || CONFIG_DEFERRED_STRUCT_PAGE_INIT) */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * Isolation and offlining code cannot deal with pages (e.g. buddy)
+ * overlapping with the range to be offlined yet.
+ */
+#define offline_nr_pages	max((unsigned long)pageblock_nr_pages, \
+				    (unsigned long)MAX_ORDER_NR_PAGES)
 
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7f7bd2acb55b..c971295a1100 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1599,10 +1599,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	struct zone *zone;
 	struct memory_notify arg;
 
-	/* at least, alignment against pageblock is necessary */
-	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
+	if (!IS_ALIGNED(start_pfn, offline_nr_pages))
 		return -EINVAL;
-	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
+	if (!IS_ALIGNED(end_pfn, offline_nr_pages))
 		return -EINVAL;
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
@@ -1700,7 +1699,22 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	return ret;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
+/**
+ * offline_pages - offline pages in a given range (that are currently online)
+ * @start_pfn: start pfn of the memory range
+ * @nr_pages: the number of pages
+ *
+ * This function tries to offline the given pages. The alignment/size that
+ * can be used is given by offline_nr_pages.
+ *
+ * Returns 0 if sucessful, -EBUSY if the pages cannot be offlined and
+ * -EINVAL if start_pfn/nr_pages is not properly aligned or not in a zone.
+ * -EINTR is returned if interrupted by a signal.
+ *
+ * Bad things will happen if pages in the range are already offline.
+ *
+ * Must be protected by mem_hotplug_begin() or a device_lock
+ */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages);
-- 
2.14.3
