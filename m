Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C45DE6B0546
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 41so14947532iop.2
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:49 -0700 (PDT)
Received: from mail-it0-f66.google.com (mail-it0-f66.google.com. [209.85.214.66])
        by mx.google.com with ESMTPS id e190si1559583itg.50.2017.08.01.05.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:49 -0700 (PDT)
Received: by mail-it0-f66.google.com with SMTP id h199so1511654ith.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:49 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/6] mm, sparse: complain about implicit altmap usage in vmemmap_populate
Date: Tue,  1 Aug 2017 14:41:10 +0200
Message-Id: <20170801124111.28881-6-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

All current users of the altmap are in the memory hotplug code and
they use __vmemmap_populate explicitly (via __sparse_mem_map_populate).
Complain if somebody uses vmemmap_populate with altmap registered
because that could be an unexpected usage. Also call __vmemmap_populate
with NULL from that code path.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3ce673570fb8..ae1fa053d09e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2456,8 +2456,12 @@ int __vmemmap_populate(unsigned long start, unsigned long end, int node,
 static inline int vmemmap_populate(unsigned long start, unsigned long end,
 		int node)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(start);
-	return __vmemmap_populate(start, end, node, altmap);
+	/*
+	 * All users of the altmap have to be explicit and use
+	 * __vmemmap_populate directly
+	 */
+	WARN_ON(to_vmem_altmap(start));
+	return __vmemmap_populate(start, end, node, NULL);
 }
 
 void vmemmap_populate_print_last(void);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
