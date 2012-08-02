Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 48C206B0070
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 02:01:13 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 14/23 V2] slub, hotplug: ignore unrelated node's hot-adding and hot-removing
Date: Thu, 2 Aug 2012 14:01:19 +0800
Message-Id: <1343887288-8866-15-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

SLUB only fucus on the nodes which has normal memory, so ignore the other
node's hot-adding and hot-removing.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/slub.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8c691fa..4c5bdc0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3577,6 +3577,9 @@ static void slab_mem_offline_callback(void *arg)
 	if (offline_node < 0)
 		return;
 
+	if (page_zonenum(pfn_to_page(marg->start_pfn)) > ZONE_NORMAL)
+		return;
+
 	down_read(&slub_lock);
 	list_for_each_entry(s, &slab_caches, list) {
 		n = get_node(s, offline_node);
@@ -3611,6 +3614,9 @@ static int slab_mem_going_online_callback(void *arg)
 	if (nid < 0)
 		return 0;
 
+	if (page_zonenum(pfn_to_page(marg->start_pfn)) > ZONE_NORMAL)
+		return 0;
+
 	/*
 	 * We are bringing a node online. No memory is available yet. We must
 	 * allocate a kmem_cache_node structure in order to bring the node
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
