Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2E96C6B0075
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 05:23:58 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC V3 PATCH 18/25] hotplug: update nodemasks management
Date: Mon, 6 Aug 2012 17:23:12 +0800
Message-Id: <1344244999-5081-19-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
 <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

update nodemasks management for N_MEMORY

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |    5 +++-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |   49 +++++++++++++++++++++++++++++++++----
 3 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 6e6cbc7..70bc1c7 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -378,6 +378,7 @@ struct memory_notify {
        unsigned long start_pfn;
        unsigned long nr_pages;
        int status_change_nid_normal;
+       int status_change_nid_high;
        int status_change_nid;
 }
 
@@ -385,7 +386,9 @@ start_pfn is start_pfn of online/offline memory.
 nr_pages is # of pages of online/offline memory.
 status_change_nid_normal is set node id when N_NORMAL_MEMORY of nodemask
 is (will be) set/clear, if this is -1, then nodemask status is not changed.
-status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+status_change_nid_high is set node id when N_HIGH_MEMORY of nodemask
+is (will be) set/clear, if this is -1, then nodemask status is not changed.
+status_change_nid is set node id when N_MEMORY of nodemask is (will be)
 set/clear. It means a new(memoryless) node gets new memory by online and a
 node loses all memory. If this is -1, then nodemask status is not changed.
 If status_changed_nid* >= 0, callback should create/discard structures for the
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 6b9202b..8089e49 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -54,6 +54,7 @@ struct memory_notify {
 	unsigned long start_pfn;
 	unsigned long nr_pages;
 	int status_change_nid_normal;
+	int status_change_nid_high;
 	int status_change_nid;
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3438c4a..c2c96a4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -462,7 +462,7 @@ static void check_nodemasks_changes_online(unsigned long nr_pages,
 	int nid = zone_to_nid(zone);
 	enum zone_type zone_last = ZONE_NORMAL;
 
-	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+	if (N_MEMORY == N_NORMAL_MEMORY)
 		zone_last = ZONE_MOVABLE;
 
 	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
@@ -470,7 +470,20 @@ static void check_nodemasks_changes_online(unsigned long nr_pages,
 	else
 		arg->status_change_nid_normal = -1;
 
-	if (!node_state(nid, N_HIGH_MEMORY))
+#ifdef CONFIG_HIGHMEM
+	zone_last = ZONE_HIGH;
+	if (N_MEMORY == N_HIGH_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	if (zone_idx(zone) <= zone_last && !node_state(nid, N_HIGH_MEMORY))
+		arg->status_change_nid_high = nid;
+	else
+		arg->status_change_nid_high = -1;
+#else
+	arg->status_change_nid_high = arg->status_change_nid_normal;
+#endif
+
+	if (!node_state(nid, N_MEMORY))
 		arg->status_change_nid = nid;
 	else
 		arg->status_change_nid = -1;
@@ -481,7 +494,10 @@ static void set_nodemasks(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_normal >= 0)
 		node_set_state(node, N_NORMAL_MEMORY);
 
-	node_set_state(node, N_HIGH_MEMORY);
+	if (arg->status_change_nid_high >= 0)
+		node_set_state(node, N_HIGH_MEMORY);
+
+	node_set_state(node, N_MEMORY);
 }
 
 
@@ -899,7 +915,7 @@ static void check_nodemasks_changes_offline(unsigned long nr_pages,
 	unsigned long present_pages = 0;
 	enum zone_type zt, zone_last = ZONE_NORMAL;
 
-	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+	if (N_MEMORY == N_NORMAL_MEMORY)
 		zone_last = ZONE_MOVABLE;
 
 	for (zt = 0; zt <= zone_last; zt++)
@@ -909,6 +925,21 @@ static void check_nodemasks_changes_offline(unsigned long nr_pages,
 	else
 		arg->status_change_nid_normal = -1;
 
+#ifdef CONIG_HIGHMEM
+	zone_last = ZONE_HIGH;
+	if (N_MEMORY == N_HIGH_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	for (; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+		arg->status_change_nid_high = zone_to_nid(zone);
+	else
+		arg->status_change_nid_high = -1;
+#else
+	arg->status_change_nid_high = arg->status_change_nid_normal;
+#endif
+
 	zone_last = ZONE_MOVABLE;
 	for (; zt <= zone_last; zt++)
 		present_pages += pgdat->node_zones[zt].present_pages;
@@ -923,11 +954,17 @@ static void clear_nodemasks(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_normal >= 0)
 		node_clear_state(node, N_NORMAL_MEMORY);
 
-	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+	if (N_MEMORY == N_NORMAL_MEMORY)
 		return;
 
-	if (arg->status_change_nid >= 0)
+	if (arg->status_change_nid_high >= 0)
 		node_clear_state(node, N_HIGH_MEMORY);
+
+	if (N_MEMORY == N_HIGH_MEMORY)
+		return;
+
+	if (arg->status_change_nid >= 0)
+		node_clear_state(node, N_MEMORY);
 }
 
 static int __ref offline_pages(unsigned long start_pfn,
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
