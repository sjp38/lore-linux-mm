Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 748E56B03A3
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:06:51 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id v2so37292251ybd.22
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:51 -0700 (PDT)
Received: from mail-yb0-f195.google.com (mail-yb0-f195.google.com. [209.85.213.195])
        by mx.google.com with ESMTPS id 205si4115371yws.386.2017.04.21.05.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:06:50 -0700 (PDT)
Received: by mail-yb0-f195.google.com with SMTP id l192so5150148ybl.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:06:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/13] mm, memory_hotplug: consider offline memblocks removable
Date: Fri, 21 Apr 2017 14:05:09 +0200
Message-Id: <20170421120512.23960-7-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

is_pageblock_removable_nolock relies on having zone association to
examine all the page blocks to check whether they are movable or free.
This is just wasting of cycles when the memblock is offline. Later patch
in the series will also change the time when the page is associated with
a zone so we let's bail out early if the memblock is offline.

Reported-by: Igor Mammedov <imammedo@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index a6e11fa6406b..ea838f8114b4 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -128,6 +128,9 @@ static ssize_t show_mem_removable(struct device *dev,
 	int ret = 1;
 	struct memory_block *mem = to_memory_block(dev);
 
+	if (mem->state != MEM_ONLINE)
+		goto out;
+
 	for (i = 0; i < sections_per_block; i++) {
 		if (!present_section_nr(mem->start_section_nr + i))
 			continue;
@@ -135,6 +138,7 @@ static ssize_t show_mem_removable(struct device *dev,
 		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
 	}
 
+out:
 	return sprintf(buf, "%d\n", ret);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
