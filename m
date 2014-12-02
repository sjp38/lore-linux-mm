Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D23716B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 14:37:19 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so14137002pad.13
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 11:37:19 -0800 (PST)
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net (p3plsmtps2ded04.prod.phx3.secureserver.net. [208.109.80.198])
        by mx.google.com with ESMTP id zq10si34772114pbc.218.2014.12.02.11.37.17
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 11:37:18 -0800 (PST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] mm: Fix a deadlock in the hotplug code
Date: Tue,  2 Dec 2014 12:46:58 -0800
Message-Id: <1417553218-12339-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

Andy Whitcroft <apw@canonical.com> initially saw this deadlock. We have
seen this as well. Here is the original description of the problem (and a
potential solution) from Andy:

https://lkml.org/lkml/2014/3/14/451

Here is an excerpt from that mail:

"We are seeing machines lockup with what appears to be an ABBA deadlock in
the memory hotplug system.  These are from the 3.13.6 based Ubuntu kernels.
The hv_balloon driver is adding memory using add_memory() which takes the
hotplug lock, and then emits a udev event, and then attempts to lock the
sysfs device.  In response to the udev event udev opens the sysfs device
and locks it, then attempts to grab the hotplug lock to online the memory.
This seems to be inverted nesting in the two cases, leading to the hangs below:

[  240.608612] INFO: task kworker/0:2:861 blocked for more than 120 seconds.
[  240.608705] INFO: task systemd-udevd:1906 blocked for more than 120 seconds.

I note that the device hotplug locking allows complete retries (via
ERESTARTSYS) and if we could detect this at the online stage it
could be used to get us out.  But before I go down this road I wanted
to make sure I am reading this right.  Or indeed if the hv_balloon driver
is just doing this wrong."

This patch is based on Andy's analysis and suggestion.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 mm/memory_hotplug.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9fab107..e195269 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -104,19 +104,27 @@ void put_online_mems(void)
 
 }
 
-static void mem_hotplug_begin(void)
+static int mem_hotplug_begin(bool trylock)
 {
 	mem_hotplug.active_writer = current;
 
 	memhp_lock_acquire();
 	for (;;) {
-		mutex_lock(&mem_hotplug.lock);
+		if (trylock) {
+			if (!mutex_trylock(&mem_hotplug.lock)) {
+				mem_hotplug.active_writer = NULL;
+				return -ERESTARTSYS;
+			}
+		} else {
+			mutex_lock(&mem_hotplug.lock);
+		}
 		if (likely(!mem_hotplug.refcount))
 			break;
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		mutex_unlock(&mem_hotplug.lock);
 		schedule();
 	}
+	return 0;
 }
 
 static void mem_hotplug_done(void)
@@ -969,7 +977,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
-	mem_hotplug_begin();
+	ret = mem_hotplug_begin(true);
+	if (ret)
+		return ret;
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -1146,7 +1156,7 @@ int try_online_node(int nid)
 	if (node_online(nid))
 		return 0;
 
-	mem_hotplug_begin();
+	mem_hotplug_begin(false);
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
@@ -1236,7 +1246,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		new_pgdat = !p;
 	}
 
-	mem_hotplug_begin();
+	mem_hotplug_begin(false);
 
 	new_node = !node_online(nid);
 	if (new_node) {
@@ -1684,7 +1694,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
 
-	mem_hotplug_begin();
+	mem_hotplug_begin(false);
 
 	zone = page_zone(pfn_to_page(start_pfn));
 	node = zone_to_nid(zone);
@@ -2002,7 +2012,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
-	mem_hotplug_begin();
+	mem_hotplug_begin(false);
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
