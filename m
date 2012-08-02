From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 15/23 V2] memory_hotplug: fix missing nodemask management
Date: Thu, 2 Aug 2012 10:53:03 +0800
Message-ID: <1343875991-7533-16-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1343875991-7533-1-git-send-email-laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Dan Magenheimer <dan.magenheimer-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Gavin Shan <shangw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Petr Holasek <pholasek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Wanlong Gao <gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra@ch>
List-Id: linux-mm.kvack.org

Currently memory_hotplug only manages the node_states[N_HIGH_MEMORY],
it forgot to manage node_states[N_NORMAL_MEMORY]. fix it.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/memory-hotplug.txt |    2 +-
 mm/memory_hotplug.c              |   23 +++++++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 6d0c251..89f21b2 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -382,7 +382,7 @@ struct memory_notify {
 
 start_pfn is start_pfn of online/offline memory.
 nr_pages is # of pages of online/offline memory.
-status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+status_change_nid is set node id when N_MEMORY of nodemask is (will be)
 set/clear. It means a new(memoryless) node gets new memory by online and a
 node loses all memory. If this is -1, then nodemask status is not changed.
 If status_changed_nid >= 0, callback should create/discard structures for the
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 427bb29..c44b39e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -522,8 +522,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
+		enum zone_type zoneid = zone_idx(zone);
+
 		kswapd_run(zone_to_nid(zone));
-		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
+
+		node_set_state(nid, N_MEMORY);
+		if (zoneid <= ZONE_NORMAL && N_NORMAL_MEMORY != N_MEMORY)
+			node_set_state(nid, N_NORMAL_MEMORY);
+#ifdef CONFIG_HIGMEM
+		if (zoneid <= ZONE_HIGHMEM && N_HIGH_MEMORY != N_MEMORY)
+			node_set_state(nid, N_HIGH_MEMORY);
+#endif
+
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
@@ -966,7 +976,16 @@ repeat:
 	init_per_zone_wmark_min();
 
 	if (!node_present_pages(node)) {
-		node_clear_state(node, N_HIGH_MEMORY);
+		enum zone_type zoneid = zone_idx(zone);
+
+		node_clear_state(node, N_MEMORY);
+		if (zoneid <= ZONE_NORMAL && N_NORMAL_MEMORY != N_MEMORY)
+			node_clear_state(node, N_NORMAL_MEMORY);
+#ifdef CONFIG_HIGMEM
+		if (zoneid <= ZONE_HIGHMEM && N_HIGH_MEMORY != N_MEMORY)
+			node_clear_state(node, N_HIGH_MEMORY);
+#endif
+
 		kswapd_stop(node);
 	}
 
-- 
1.7.1
