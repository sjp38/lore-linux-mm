Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9095F6B0266
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:50:01 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so60386800wjy.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:01 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g15si12716366wmc.25.2017.01.30.01.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:50:00 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u63so7765938wmu.2
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:00 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/9] net: use kvmalloc with __GFP_REPEAT rather than open coded variant
Date: Mon, 30 Jan 2017 10:49:37 +0100
Message-Id: <20170130094940.13546-7-mhocko@kernel.org>
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
References: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

fq_alloc_node, alloc_netdev_mqs and netif_alloc* open code kmalloc
with vmalloc fallback. Use the kvmalloc variant instead. Keep the
__GFP_REPEAT flag based on explanation from Eric:
"
At the time, tests on the hardware I had in my labs showed that
vmalloc() could deliver pages spread all over the memory and that was a
small penalty (once memory is fragmented enough, not at boot time)
"

The way how the code is constructed means, however, that we prefer to go
and hit the OOM killer before we fall back to the vmalloc for requests
<=32kB (with 4kB pages) in the current code. This is rather disruptive for
something that can be achived with the fallback. On the other hand
__GFP_REPEAT doesn't have any useful semantic for these requests. So the
effect of this patch is that requests smaller than 64kB will fallback to
vmalloc esier now.

Cc: Eric Dumazet <edumazet@google.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/core/dev.c     | 24 +++++++++---------------
 net/sched/sch_fq.c | 12 +-----------
 2 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index be11abac89b3..707e730821a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7081,12 +7081,10 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	BUG_ON(count < 1);
 
-	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-	if (!rx) {
-		rx = vzalloc(sz);
-		if (!rx)
-			return -ENOMEM;
-	}
+	rx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
+	if (!rx)
+		return -ENOMEM;
+
 	dev->_rx = rx;
 
 	for (i = 0; i < count; i++)
@@ -7123,12 +7121,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	if (count < 1 || count > 0xffff)
 		return -EINVAL;
 
-	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-	if (!tx) {
-		tx = vzalloc(sz);
-		if (!tx)
-			return -ENOMEM;
-	}
+	tx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
+	if (!tx)
+		return -ENOMEM;
+
 	dev->_tx = tx;
 
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
@@ -7661,9 +7657,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	/* ensure 32-byte alignment of whole construct */
 	alloc_size += NETDEV_ALIGN - 1;
 
-	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-	if (!p)
-		p = vzalloc(alloc_size);
+	p = kvzalloc(alloc_size, GFP_KERNEL | __GFP_REPEAT);
 	if (!p)
 		return NULL;
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a4f738ac7728..594f77d89f6c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -624,16 +624,6 @@ static void fq_rehash(struct fq_sched_data *q,
 	q->stat_gc_flows += fcnt;
 }
 
-static void *fq_alloc_node(size_t sz, int node)
-{
-	void *ptr;
-
-	ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN, node);
-	if (!ptr)
-		ptr = vmalloc_node(sz, node);
-	return ptr;
-}
-
 static void fq_free(void *addr)
 {
 	kvfree(addr);
@@ -650,7 +640,7 @@ static int fq_resize(struct Qdisc *sch, u32 log)
 		return 0;
 
 	/* If XPS was setup, we can allocate memory on right NUMA node */
-	array = fq_alloc_node(sizeof(struct rb_root) << log,
+	array = kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GFP_REPEAT,
 			      netdev_queue_numa_node_read(sch->dev_queue));
 	if (!array)
 		return -ENOMEM;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
