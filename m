Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05CA86B0028
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:33:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v187so5270080qka.5
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:33:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w16si4734295qta.329.2018.04.13.06.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:33:23 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 6/8] mm: offline_pages() is also limited by MAX_ORDER
Date: Fri, 13 Apr 2018 15:33:18 +0200
Message-Id: <20180413133320.3557-1-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>

Page blocks might contain references to the next page block. So
a page block cannot be offlined independently. E.g. on x86: page block
size is 2MB, MAX_ORDER -1 (10) allows 4MB allocations.
-> Right now, __offline_isolated_pages() will mark pages in the following
page block as reserved.

Let document offline_pages() while at it.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3a8d56476233..1d6054edc241 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1598,11 +1598,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	struct zone *zone;
 	struct memory_notify arg;
 
-	/* at least, alignment against pageblock is necessary */
 	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
 		return -EINVAL;
+	if (!IS_ALIGNED(start_pfn, (1 << (MAX_ORDER - 1))))
+		return -EINVAL;
 	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
 		return -EINVAL;
+	if (!IS_ALIGNED(end_pfn, (1 << (MAX_ORDER - 1))))
+		return -EINVAL;
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
@@ -1699,7 +1702,22 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	return ret;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
+/**
+ * offline_pages - offline pages in a given range (that are currently online)
+ * @start_pfn: start pfn of the memory range
+ * @nr_pages: the number of pages
+ *
+ * This function tries to offline the given pages. The alignment/size that
+ * can be used is max(pageblock_nr_pages, 1 << (MAX_ORDER - 1)).
+ *
+ * Returns 0 if sucessful, -EBUSY if the pages cannot be offlined and
+ * -EINVAL if start_pfn/nr_pages is not properly aligned or not in a zone.
+ * -EINTR is returned if interrupted by a signal.
+ *
+ * Bad things will happen if pages are already offline.
+ *
+ * Must be protected by mem_hotplug_begin() or a device_lock
+ */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages);
-- 
2.14.3
