Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07D026B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so54298559wmu.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:27 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 75si8143565wmy.134.2016.08.31.23.56.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:26 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 03/16] of/numa: add nid check for memory block
Date: Thu, 1 Sep 2016 14:54:54 +0800
Message-ID: <1472712907-12700-4-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

If the numa-id which was configured in memory@ devicetree node is greater
than MAX_NUMNODES, we should report a warning. We have done this for cpus
and distance-map dt nodes, this patch help them to be consistent.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 drivers/of/of_numa.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/of/of_numa.c b/drivers/of/of_numa.c
index 7b3fbdc..c1bd62c 100644
--- a/drivers/of/of_numa.c
+++ b/drivers/of/of_numa.c
@@ -75,6 +75,11 @@ static int __init of_numa_parse_memory_nodes(void)
 			 */
 			continue;

+		if (nid >= MAX_NUMNODES) {
+			pr_warn("NUMA: Node id %u exceeds maximum value\n", nid);
+			r = -EINVAL;
+		}
+
 		for (i = 0; !r && !of_address_to_resource(np, i, &rsrc); i++)
 			r = numa_add_memblk(nid, rsrc.start, rsrc.end + 1);

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
