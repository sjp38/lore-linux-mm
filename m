Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36BD86B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:06:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l21so133118607ioi.2
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:21 -0700 (PDT)
Received: from mail-io0-f195.google.com (mail-io0-f195.google.com. [209.85.223.195])
        by mx.google.com with ESMTPS id v8si2240144iti.101.2017.04.21.05.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:06:16 -0700 (PDT)
Received: by mail-io0-f195.google.com with SMTP id d203so29739928iof.2
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 03/13] mm: drop page_initialized check from get_nid_for_pfn
Date: Fri, 21 Apr 2017 14:05:06 +0200
Message-Id: <20170421120512.23960-4-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

c04fc586c1a4 ("mm: show node to memory section relationship with
symlinks in sysfs") has added means to export memblock<->node
association into the sysfs. It has also introduced get_nid_for_pfn
which is a rather confusing counterpart of pfn_to_nid which checks also
whether the pfn page is already initialized (page_initialized).  This
is done by checking page::lru != NULL which doesn't make any sense at
all. Nothing in this path really relies on the lru list being used or
initialized. Just remove it because this will become a problem with
later patches.

Thanks to Reza Arbab for testing which revealed this to be a problem
(http://lkml.kernel.org/r/20170403202337.GA12482@dhcp22.suse.cz)

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/node.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f9686016..06294d69779b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -368,21 +368,14 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
-#define page_initialized(page)  (page->lru.next)
-
 static int __ref get_nid_for_pfn(unsigned long pfn)
 {
-	struct page *page;
-
 	if (!pfn_valid_within(pfn))
 		return -1;
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	if (system_state == SYSTEM_BOOTING)
 		return early_pfn_to_nid(pfn);
 #endif
-	page = pfn_to_page(pfn);
-	if (!page_initialized(page))
-		return -1;
 	return pfn_to_nid(pfn);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
