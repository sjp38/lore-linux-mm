Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8906B03B8
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:04:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l44so4845271wrc.11
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:19 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w35si10152866wrc.60.2017.04.10.04.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 04:04:18 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d79so9002436wmi.2
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:18 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/9] mm: drop page_initialized check from get_nid_for_pfn
Date: Mon, 10 Apr 2017 13:03:45 +0200
Message-Id: <20170410110351.12215-4-mhocko@kernel.org>
In-Reply-To: <20170410110351.12215-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
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
