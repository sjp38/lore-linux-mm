Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC7B82F66
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so53255735lfb.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:50 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id yj8si4235657wjb.27.2016.08.31.23.56.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:34 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 14/16] of/numa: remove the constraint on the distances of node pairs
Date: Thu, 1 Sep 2016 14:55:05 +0800
Message-ID: <1472712907-12700-15-git-send-email-thunder.leizhen@huawei.com>
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

At present, the distances must equal in both direction for each node
pairs. For example: the distance of node B->A must the same to A->B.
But we really don't have to do this.

End up fill default distances as below:
1. If both direction specified, keep no change.
2. If only one direction specified, assign it to the other direction.
3. If none of the two direction specified, both are assigned to
   REMOTE_DISTANCE.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 drivers/of/of_numa.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/of/of_numa.c b/drivers/of/of_numa.c
index f63d4b0d..1840045 100644
--- a/drivers/of/of_numa.c
+++ b/drivers/of/of_numa.c
@@ -127,15 +127,25 @@ static int __init of_numa_parse_distance_map_v1(struct device_node *map)
 		numa_set_distance(nodea, nodeb, distance);
 		pr_debug("distance[node%d -> node%d] = %d\n",
 			 nodea, nodeb, distance);
-
-		/* Set default distance of node B->A same as A->B */
-		if (nodeb > nodea)
-			numa_set_distance(nodeb, nodea, distance);
 	}

 	return 0;
 }

+static void __init fill_default_distances(void)
+{
+	int i, j;
+
+	for (i = 0; i < nr_node_ids; i++)
+		for (j = 0; j < nr_node_ids; j++)
+			if (i == j)
+				numa_set_distance(i, j, LOCAL_DISTANCE);
+			else if (!node_distance(i, j))
+				numa_set_distance(i, j,
+				    node_distance(j, i) ? : REMOTE_DISTANCE);
+
+}
+
 static int __init of_numa_parse_distance_map(void)
 {
 	int ret = 0;
@@ -145,8 +155,10 @@ static int __init of_numa_parse_distance_map(void)
 				     "numa-distance-map-v1");
 	if (np)
 		ret = of_numa_parse_distance_map_v1(np);
-
 	of_node_put(np);
+
+	fill_default_distances();
+
 	return ret;
 }

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
