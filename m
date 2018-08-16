Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3E926B0269
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:06:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so3799283qkb.16
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:06:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r4-v6si2863534qkc.173.2018.08.16.03.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:06:49 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 4/5] mm/memory_hotplug: onlining pages can only fail due to notifiers
Date: Thu, 16 Aug 2018 12:06:27 +0200
Message-Id: <20180816100628.26428-5-david@redhat.com>
In-Reply-To: <20180816100628.26428-1-david@redhat.com>
References: <20180816100628.26428-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Onlining pages can only fail if a notifier reported a problem (e.g. -ENOMEM).
online_pages_range() can never fail.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3dc6d2a309c2..bbbd16f9d877 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -933,13 +933,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		setup_zone_pageset(zone);
 	}
 
-	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
-		online_pages_range);
-	if (ret) {
-		if (need_zonelists_rebuild)
-			zone_pcp_reset(zone);
-		goto failed_addition;
-	}
+	walk_system_ram_range(pfn, nr_pages, &onlined_pages,
+			      online_pages_range);
 
 	zone->present_pages += onlined_pages;
 
-- 
2.17.1
