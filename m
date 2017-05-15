Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4C316B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:00:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b74so65750506pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:20 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id s67si10008125pgs.403.2017.05.15.02.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:00:19 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id w69so15049877pfk.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/14] mm, memory_hotplug: consider offline memblocks removable
Date: Mon, 15 May 2017 10:58:19 +0200
Message-Id: <20170515085827.16474-7-mhocko@kernel.org>
In-Reply-To: <20170515085827.16474-1-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
index f8fd562c3f18..1e884d82af6f 100644
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
