Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id A99A76B0072
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:42:11 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 2/2 V2] slub, hotplug: ignore unrelated node's hot-adding and hot-removing
Date: Wed, 24 Oct 2012 17:43:52 +0800
Message-Id: <1351071840-5060-3-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Mel Gorman <mgorman@suse.de>, 'FNST-Wen Congyang' <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

SLUB only fucus on the nodes which has normal memory, so ignore the other
node's hot-adding and hot-removing.

Aka: if some memroy of a node(which has no onlined memory) is online,
but this new memory onlined is not normal memory(HIGH memory example),
we should not allocate kmem_cache_node for SLUB.

And if the last normal memory is offlined, but the node still has memroy,
we should remove kmem_cache_node for that node.(current code delay it when
all of the memory is offlined)

so we only do something when marg->status_change_nid_normal > 0.
marg->status_change_nid is not suitable here.

The same problem doesn't exsit in SLAB, because SLAB allocates kmem_list3
for every node even the node don't have normal memory, SLAB tolerates
kmem_list3 on alien nodes. SLUB only fucus on the nodes which has normal
memory, it don't tolerates alien kmem_cache_node, the patch makes
SLUB become self-compatible and avoid WARN and BUG in a rare condition.

CC: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Rob Landley <rob@landley.net>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Jiang Liu <jiang.liu@huawei.com>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Greg Kroah-Hartman <gregkh@suse.de>
CC: Mel Gorman <mgorman@suse.de>
CC: 'FNST-Wen Congyang' <wency@cn.fujitsu.com>
CC: linux-doc@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/slub.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index a0d6984..487f0bd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3573,7 +3573,7 @@ static void slab_mem_offline_callback(void *arg)
 	struct memory_notify *marg = arg;
 	int offline_node;
 
-	offline_node = marg->status_change_nid;
+	offline_node = marg->status_change_nid_normal;
 
 	/*
 	 * If the node still has available memory. we need kmem_cache_node
@@ -3606,7 +3606,7 @@ static int slab_mem_going_online_callback(void *arg)
 	struct kmem_cache_node *n;
 	struct kmem_cache *s;
 	struct memory_notify *marg = arg;
-	int nid = marg->status_change_nid;
+	int nid = marg->status_change_nid_normal;
 	int ret = 0;
 
 	/*
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
