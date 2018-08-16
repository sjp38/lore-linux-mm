Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01C6E6B000A
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:06:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q3-v6so3857572qki.4
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:06:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y2-v6si776193qkl.233.2018.08.16.03.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:06:40 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 1/5] mm/memory_hotplug: drop intermediate __offline_pages
Date: Thu, 16 Aug 2018 12:06:24 +0200
Message-Id: <20180816100628.26428-2-david@redhat.com>
In-Reply-To: <20180816100628.26428-1-david@redhat.com>
References: <20180816100628.26428-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Let's avoid this indirection and just call the function offline_pages().

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6a2726920ed2..090cf474de87 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1589,10 +1589,10 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 		node_clear_state(node, N_MEMORY);
 }
 
-static int __ref __offline_pages(unsigned long start_pfn,
-		  unsigned long end_pfn)
+/* Must be protected by mem_hotplug_begin() or a device_lock */
+int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
-	unsigned long pfn, nr_pages;
+	unsigned long pfn, end_pfn = start_pfn + nr_pages;
 	long offlined_pages;
 	int ret, node;
 	unsigned long flags;
@@ -1612,7 +1612,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	zone = page_zone(pfn_to_page(valid_start));
 	node = zone_to_nid(zone);
-	nr_pages = end_pfn - start_pfn;
 
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
@@ -1700,12 +1699,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	return ret;
 }
-
-/* Must be protected by mem_hotplug_begin() or a device_lock */
-int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
-{
-	return __offline_pages(start_pfn, start_pfn + nr_pages);
-}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /**
-- 
2.17.1
