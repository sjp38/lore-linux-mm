Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0726B0075
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:25:05 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id b16so7040752igk.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:25:05 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id n9si5161457icv.96.2015.02.12.14.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 14:25:04 -0800 (PST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so11304123igb.0
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:25:04 -0800 (PST)
Date: Thu, 12 Feb 2015 14:25:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hotplug: fix concurrent memory hot-add deadlock
Message-ID: <alpine.DEB.2.10.1502121423210.31048@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There's a deadlock when concurrently hot-adding memory through the probe
interface and switching a memory block from offline to online.

When hot-adding memory via the probe interface, add_memory() first takes
mem_hotplug_begin() and then device_lock() is later taken when
registering the newly initialized memory block.  This creates a lock
dependency of (1) mem_hotplug.lock (2) dev->mutex.

When switching a memory block from offline to online, dev->mutex is first
grabbed in device_online() when the write(2) transitions an existing
memory block from offline to online, and then online_pages() will take
mem_hotplug_begin().

This creates a lock inversion between mem_hotplug.lock and dev->mutex.
Vitaly reports that this deadlock can happen when kworker handling a
probe event races with systemd-udevd switching a memory block's state.

This patch requires the state transition to take mem_hotplug_begin()
before dev->mutex.  Hot-adding memory via the probe interface creates a
memory block while holding mem_hotplug_begin(), there is no way to take
dev->mutex first in this case.

online_pages() and offline_pages() are only called when transitioning
memory block state.  We now require that mem_hotplug_begin() is taken
before calling them -- this requires exporting the mem_hotplug_begin()
and mem_hotplug_done() to generic code.  In all hot-add and hot-remove
cases, mem_hotplug_begin() is done prior to device_online().  This is
all that is needed to avoid the deadlock.

Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/base/memory.c          | 19 ++++++++++++-------
 include/linux/memory_hotplug.h |  6 ++++++
 mm/memory_hotplug.c            | 33 ++++++++++++---------------------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -219,6 +219,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
 /*
  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
  * OK to have direct references to sparsemem variables in here.
+ * Must already be protected by mem_hotplug_begin().
  */
 static int
 memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
@@ -286,6 +287,7 @@ static int memory_subsys_online(struct device *dev)
 	if (mem->online_type < 0)
 		mem->online_type = MMOP_ONLINE_KEEP;
 
+	/* Already under protection of mem_hotplug_begin() */
 	ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
 
 	/* clear online_type */
@@ -328,17 +330,19 @@ store_mem_state(struct device *dev,
 		goto err;
 	}
 
+	/*
+	 * Memory hotplug needs to hold mem_hotplug_begin() for probe to find
+	 * the correct memory block to online before doing device_online(dev),
+	 * which will take dev->mutex.  Take the lock early to prevent an
+	 * inversion, memory_subsys_online() callbacks will be implemented by
+	 * assuming it's already protected.
+	 */
+	mem_hotplug_begin();
+
 	switch (online_type) {
 	case MMOP_ONLINE_KERNEL:
 	case MMOP_ONLINE_MOVABLE:
 	case MMOP_ONLINE_KEEP:
-		/*
-		 * mem->online_type is not protected so there can be a
-		 * race here.  However, when racing online, the first
-		 * will succeed and the second will just return as the
-		 * block will already be online.  The online type
-		 * could be either one, but that is expected.
-		 */
 		mem->online_type = online_type;
 		ret = device_online(&mem->dev);
 		break;
@@ -349,6 +353,7 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}
 
+	mem_hotplug_done();
 err:
 	unlock_device_hotplug();
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -192,6 +192,9 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
 void get_online_mems(void);
 void put_online_mems(void);
 
+void mem_hotplug_begin(void);
+void mem_hotplug_done(void);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -231,6 +234,9 @@ static inline int try_online_node(int nid)
 static inline void get_online_mems(void) {}
 static inline void put_online_mems(void) {}
 
+static inline void mem_hotplug_begin(void) {}
+static inline void mem_hotplug_done(void) {}
+
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -104,7 +104,7 @@ void put_online_mems(void)
 
 }
 
-static void mem_hotplug_begin(void)
+void mem_hotplug_begin(void)
 {
 	mem_hotplug.active_writer = current;
 
@@ -119,7 +119,7 @@ static void mem_hotplug_begin(void)
 	}
 }
 
-static void mem_hotplug_done(void)
+void mem_hotplug_done(void)
 {
 	mem_hotplug.active_writer = NULL;
 	mutex_unlock(&mem_hotplug.lock);
@@ -959,6 +959,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 }
 
 
+/* Must be protected by mem_hotplug_begin() */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -969,7 +970,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
-	mem_hotplug_begin();
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -977,21 +977,20 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	zone = page_zone(pfn_to_page(pfn));
 
-	ret = -EINVAL;
 	if ((zone_idx(zone) > ZONE_NORMAL ||
 	    online_type == MMOP_ONLINE_MOVABLE) &&
 	    !can_online_high_movable(zone))
-		goto out;
+		return -EINVAL;
 
 	if (online_type == MMOP_ONLINE_KERNEL &&
 	    zone_idx(zone) == ZONE_MOVABLE) {
 		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages))
-			goto out;
+			return -EINVAL;
 	}
 	if (online_type == MMOP_ONLINE_MOVABLE &&
 	    zone_idx(zone) == ZONE_MOVABLE - 1) {
 		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages))
-			goto out;
+			return -EINVAL;
 	}
 
 	/* Previous code may changed the zone of the pfn range */
@@ -1007,7 +1006,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = notifier_to_errno(ret);
 	if (ret) {
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		goto out;
+		return ret;
 	}
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
@@ -1031,7 +1030,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		       (((unsigned long long) pfn + nr_pages)
 			    << PAGE_SHIFT) - 1);
 		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		goto out;
+		return ret;
 	}
 
 	zone->present_pages += onlined_pages;
@@ -1061,9 +1060,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
-out:
-	mem_hotplug_done();
-	return ret;
+	return 0;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
@@ -1684,21 +1681,18 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
 
-	mem_hotplug_begin();
-
 	zone = page_zone(pfn_to_page(start_pfn));
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
-	ret = -EINVAL;
 	if (zone_idx(zone) <= ZONE_NORMAL && !can_offline_normal(zone, nr_pages))
-		goto out;
+		return -EINVAL;
 
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
 				       MIGRATE_MOVABLE, true);
 	if (ret)
-		goto out;
+		return ret;
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
@@ -1791,7 +1785,6 @@ repeat:
 	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
-	mem_hotplug_done();
 	return 0;
 
 failed_removal:
@@ -1801,12 +1794,10 @@ failed_removal:
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
-
-out:
-	mem_hotplug_done();
 	return ret;
 }
 
+/* Must be protected by mem_hotplug_begin() */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
