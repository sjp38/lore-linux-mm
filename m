Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2F216B03A3
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r71so9795625wrb.17
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:06 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id f3si3616129wme.93.2017.03.30.04.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:05 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id u18so11423314wrc.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] mm, memory_hotplug: use node instead of zone in can_online_high_movable
Date: Thu, 30 Mar 2017 13:54:52 +0200
Message-Id: <20170330115454.32154-5-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-1-mhocko@kernel.org>
References: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

the primary purpose of this helper is to query the node state so use
the node id directly. This is a preparatory patch for later changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 056dbbe6d20e..221f622bcc88 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -936,15 +936,15 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
  * When CONFIG_MOVABLE_NODE, we permit onlining of a node which doesn't have
  * normal memory.
  */
-static bool can_online_high_movable(struct zone *zone)
+static bool can_online_high_movable(int nid)
 {
 	return true;
 }
 #else /* CONFIG_MOVABLE_NODE */
 /* ensure every online node has NORMAL memory */
-static bool can_online_high_movable(struct zone *zone)
+static bool can_online_high_movable(int nid)
 {
-	return node_state(zone_to_nid(zone), N_NORMAL_MEMORY);
+	return node_state(nid, N_NORMAL_MEMORY);
 }
 #endif /* CONFIG_MOVABLE_NODE */
 
@@ -1078,7 +1078,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if ((zone_idx(zone) > ZONE_NORMAL ||
 	    online_type == MMOP_ONLINE_MOVABLE) &&
-	    !can_online_high_movable(zone))
+	    !can_online_high_movable(pfn_to_nid(pfn)))
 		return -EINVAL;
 
 	if (online_type == MMOP_ONLINE_KERNEL) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
