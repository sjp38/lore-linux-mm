Date: Wed, 31 Oct 2007 19:24:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory cgroup enhancements take 4 [1/8] fix zone handling
 in try_to_free_mem_cgroup_page
Message-Id: <20071031192439.202da479.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Because NODE_DATA(node)->node_zonelists[] is guaranteed to contain
all necessary zones, it is not necessary to use for_each_online_node.

And this for_each_online_node() makes reclaim routine start always
from node 0. This is not good. This patch makes reclaim start from
caller's node and just use usual (default) zonelist order.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/vmscan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: devel-2.6.23-mm1/mm/vmscan.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/vmscan.c
+++ devel-2.6.23-mm1/mm/vmscan.c
@@ -1375,15 +1375,13 @@ unsigned long try_to_free_mem_cgroup_pag
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
-	int node;
+	int node = numa_node_id();
 	struct zone **zones;
 	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
-	for_each_online_node(node) {
-		zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
-		if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
-			return 1;
-	}
+	zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
+	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
+		return 1;
 	return 0;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
