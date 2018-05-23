Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26E9D6B02AE
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:12:24 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d5-v6so21176986qtg.17
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:12:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q27-v6si1188362qkj.363.2018.05.23.08.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:23 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 06/10] mm/memory_hotplug: onlining pages can only fail due to notifiers
Date: Wed, 23 May 2018 17:11:47 +0200
Message-Id: <20180523151151.6730-7-david@redhat.com>
In-Reply-To: <20180523151151.6730-1-david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Thomas Gleixner <tglx@linutronix.de>

Onlining pages can only fail if a notifier reported a problem (e.g. -ENOMEM).
Remove and restructure error handling. While at it, document how
online_pages() can be used right now.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 47 +++++++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 17 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c971295a1100..8c0b7d85252b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -902,7 +902,26 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	return zone;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
+/**
+ * online_pages - online pages in a given range (that are currently offline)
+ * @start_pfn: start pfn of the memory range
+ * @nr_pages: the number of pages
+ * @online_type: how to online pages (esp. to which zone to add them)
+ *
+ * This function onlines the given pages. Usually, any alignemt / size
+ * can be used. However, all pages of memory to be removed later on in
+ * one piece via remove_memory() should be onlined the same way and at
+ * least the first page should be onlined if anything else is onlined.
+ * The zone of the first page is used to fixup zones when removing memory
+ * later on (see __remove_pages()).
+ *
+ * Returns 0 if sucessful, an error code if a memory notifier reported a
+ *         problem (e.g. -ENOMEM).
+ *
+ * Bad things will happen if pages in the range are already online.
+ *
+ * Must be protected by mem_hotplug_begin() or a device_lock
+ */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -923,8 +942,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
-	if (ret)
-		goto failed_addition;
+	if (ret) {
+		pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
+			 (unsigned long long) pfn << PAGE_SHIFT,
+			 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
+		memory_notify(MEM_CANCEL_ONLINE, &arg);
+		return ret;
+	}
 
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
@@ -936,13 +960,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		setup_zone_pageset(zone);
 	}
 
-	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
-		online_pages_range);
-	if (ret) {
-		if (need_zonelists_rebuild)
-			zone_pcp_reset(zone);
-		goto failed_addition;
-	}
+	/* onlining pages cannot fail */
+	walk_system_ram_range(pfn, nr_pages, &onlined_pages,
+			      online_pages_range);
 
 	zone->present_pages += onlined_pages;
 
@@ -972,13 +992,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
 	return 0;
-
-failed_addition:
-	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
-		 (unsigned long long) pfn << PAGE_SHIFT,
-		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
-	memory_notify(MEM_CANCEL_ONLINE, &arg);
-	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
-- 
2.17.0
