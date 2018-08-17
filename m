Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46AF06B0724
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 03:59:19 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b7-v6so5670724qtp.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 00:59:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 77-v6si1379537qkd.397.2018.08.17.00.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 00:59:17 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 2/2] mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock
Date: Fri, 17 Aug 2018 09:59:01 +0200
Message-Id: <20180817075901.4608-3-david@redhat.com>
In-Reply-To: <20180817075901.4608-1-david@redhat.com>
References: <20180817075901.4608-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Hildenbrand <david@redhat.com>, "K . Y . Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Rientjes <rientjes@google.com>

There seem to be some problems as result of 30467e0b3be ("mm, hotplug:
fix concurrent memory hot-add deadlock"), which tried to fix a possible
lock inversion reported and discussed in [1] due to the two locks
	a) device_lock()
	b) mem_hotplug_lock

While add_memory() first takes b), followed by a) during
bus_probe_device(), onlining of memory from user space first took b),
followed by a), exposing a possible deadlock.

In [1], and it was decided to not make use of device_hotplug_lock, but
rather to enforce a locking order. Looking at 1., this order is not always
satisfied when calling device_online() - essentially we simply don't take
one of both locks anymore - and fixing this would require us to
take the mem_hotplug_lock in core driver code (online_store()), which
sounds wrong.

The problems I spotted related to this:

1. Memory block device attributes: While .state first calls
   mem_hotplug_begin() and the calls device_online() - which takes
   device_lock() - .online does no longer call mem_hotplug_begin(), so
   effectively calls online_pages() without mem_hotplug_lock. onlining/
   offlining of pages is no longer serialised across different devices.

2. device_online() should be called under device_hotplug_lock, however
   onlining memory during add_memory() does not take care of that. (I
   didn't follow how strictly this is needed, but there seems to be a
   reason because it is documented at device_online() and
   device_offline()).

In addition, I think there is also something wrong about the locking in

3. arch/powerpc/platforms/powernv/memtrace.c calls offline_pages()
   (and device_online()) without locks. This was introduced after
   30467e0b3be. And skimming over the code, I assume it could need some
   more care in regards to locking.

ACPI code already holds the device_hotplug_lock, and as we are
effectively hotplugging memory block devices, requiring to hold that
lock does not sound too wrong, although not chosen in [1], as
	"I don't think resolving a locking dependency is appropriate by
	 just serializing them with another lock."
I think this is the cleanest solution.

Requiring add_memory()/add_memory_resource() to be called under
device_hotplug_lock fixes 2., taking the mem_hotplug_lock in
online_pages/offline_pages() fixes 1. and 3.

Fixup all callers of add_memory/add_memory_resource to hold the lock if
not already done.

So this is essentially a revert of 30467e0b3be, implementation of what
was suggested in [1] by Vitaly, applied to the current tree.

[1] http://driverdev.linuxdriverproject.org/pipermail/ driverdev-devel/
    2015-February/065324.html

This patch is partly based on a patch by Vitaly Kuznetsov.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/powerpc/platforms/powernv/memtrace.c |  3 ++
 drivers/acpi/acpi_memhotplug.c            |  1 +
 drivers/base/memory.c                     | 18 +++++-----
 drivers/hv/hv_balloon.c                   |  4 +++
 drivers/s390/char/sclp_cmd.c              |  3 ++
 drivers/xen/balloon.c                     |  3 ++
 mm/memory_hotplug.c                       | 42 ++++++++++++++++++-----
 7 files changed, 55 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index 51dc398ae3f7..4c2737a33020 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -206,6 +206,8 @@ static int memtrace_online(void)
 	int i, ret = 0;
 	struct memtrace_entry *ent;
 
+	/* add_memory() requires device_hotplug_lock */
+	lock_device_hotplug();
 	for (i = memtrace_array_nr - 1; i >= 0; i--) {
 		ent = &memtrace_array[i];
 
@@ -244,6 +246,7 @@ static int memtrace_online(void)
 		pr_info("Added trace memory back to node %d\n", ent->nid);
 		ent->size = ent->start = ent->nid = -1;
 	}
+	unlock_device_hotplug();
 	if (ret)
 		return ret;
 
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 6b0d3ef7309c..e7a4c7900967 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -228,6 +228,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
+		/* we already hold the device_hotplug lock at this point */
 		result = add_memory(node, info->start_addr, info->length);
 
 		/*
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c8a1cb0b6136..f60507f994df 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -341,19 +341,11 @@ store_mem_state(struct device *dev,
 		goto err;
 	}
 
-	/*
-	 * Memory hotplug needs to hold mem_hotplug_begin() for probe to find
-	 * the correct memory block to online before doing device_online(dev),
-	 * which will take dev->mutex.  Take the lock early to prevent an
-	 * inversion, memory_subsys_online() callbacks will be implemented by
-	 * assuming it's already protected.
-	 */
-	mem_hotplug_begin();
-
 	switch (online_type) {
 	case MMOP_ONLINE_KERNEL:
 	case MMOP_ONLINE_MOVABLE:
 	case MMOP_ONLINE_KEEP:
+		/* mem->online_type is protected by device_hotplug_lock */
 		mem->online_type = online_type;
 		ret = device_online(&mem->dev);
 		break;
@@ -364,7 +356,6 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}
 
-	mem_hotplug_done();
 err:
 	unlock_device_hotplug();
 
@@ -522,6 +513,12 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 		return -EINVAL;
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
+
+	/* add_memory() requires the device_hotplug_lock */
+	ret = lock_device_hotplug_sysfs();
+	if (ret)
+		return ret;
+
 	ret = add_memory(nid, phys_addr,
 			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
 
@@ -530,6 +527,7 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 
 	ret = count;
 out:
+	unlock_device_hotplug();
 	return ret;
 }
 
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b1b788082793..c6d0b654f109 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -735,8 +735,12 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 		dm_device.ha_waiting = !memhp_auto_online;
 
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
+
+		/* add_memory() requires the device_hotplug lock */
+		lock_device_hotplug();
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
 				(HA_CHUNK << PAGE_SHIFT));
+		unlock_device_hotplug();
 
 		if (ret) {
 			pr_err("hot_add memory failed error is %d\n", ret);
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index d7686a68c093..cd0cdab8fcfb 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -405,8 +405,11 @@ static void __init add_memory_merged(u16 rn)
 	align_to_block_size(&start, &size, block_size);
 	if (!size)
 		goto skip_add;
+	/* add_memory() requires the device_hotplug lock */
+	lock_device_hotplug();
 	for (addr = start; addr < start + size; addr += block_size)
 		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+	unlock_device_hotplug();
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 559e77a20a4d..df1ced4c0692 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -395,8 +395,11 @@ static enum bp_state reserve_additional_memory(void)
 	 * callers drop the mutex before trying again.
 	 */
 	mutex_unlock(&balloon_mutex);
+	/* add_memory_resource() requires the device_hotplug lock */
+	lock_device_hotplug();
 	rc = add_memory_resource(nid, resource->start, resource_size(resource),
 				 memhp_auto_online);
+	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
 	if (rc) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6a2726920ed2..492e558f791b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -885,7 +885,6 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	return zone;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -897,6 +896,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	struct memory_notify arg;
 	struct memory_block *mem;
 
+	mem_hotplug_begin();
+
 	/*
 	 * We can't use pfn_to_nid() because nid might be stored in struct page
 	 * which is not yet initialized. Instead, we find nid from memory block.
@@ -961,6 +962,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
+	mem_hotplug_done();
 	return 0;
 
 failed_addition:
@@ -968,6 +970,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		 (unsigned long long) pfn << PAGE_SHIFT,
 		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_ONLINE, &arg);
+	mem_hotplug_done();
 	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
@@ -1115,7 +1118,18 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 	return device_online(&mem->dev);
 }
 
-/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+/*
+ * Requires device_hotplug_lock:
+ *
+ * add_memory_resource() will first take the mem_hotplug_lock and then
+ * device_lock() the created memory block device (via bus_probe_device()).
+ * However, device_online() calls device_lock() and then takes the
+ * mem_hotplug lock (via online_pages()). The device_hotplug_lock makes
+ * sure this lock inversion can never happen - and also device_online()
+ * needs it.
+ *
+ * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
+ */
 int __ref add_memory_resource(int nid, u64 start, u64 size, bool online)
 {
 	bool new_node = false;
@@ -1163,25 +1177,26 @@ int __ref add_memory_resource(int nid, u64 start, u64 size, bool online)
 	/* create new memmap entry */
 	firmware_map_add_hotplug(start, start + size, "System RAM");
 
+	/* device_online() will take the lock when calling online_pages() */
+	mem_hotplug_done();
+
 	/* online pages if requested */
 	if (online)
 		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
 				  NULL, online_memory_block);
 
-	goto out;
-
+	return ret;
 error:
 	/* rollback pgdat allocation and others */
 	if (new_node)
 		rollback_node_hotadd(nid);
 	memblock_remove(start, size);
-
-out:
 	mem_hotplug_done();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory_resource);
 
+/* requires device_hotplug_lock, see add_memory_resource() */
 int __ref add_memory(int nid, u64 start, u64 size)
 {
 	struct resource *res;
@@ -1605,10 +1620,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		return -EINVAL;
 	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
 		return -EINVAL;
+
+	mem_hotplug_begin();
+
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
-	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
+	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
+				  &valid_end)) {
+		mem_hotplug_done();
 		return -EINVAL;
+	}
 
 	zone = page_zone(pfn_to_page(valid_start));
 	node = zone_to_nid(zone);
@@ -1617,8 +1638,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
 				       MIGRATE_MOVABLE, true);
-	if (ret)
+	if (ret) {
+		mem_hotplug_done();
 		return ret;
+	}
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
@@ -1689,6 +1712,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
+	mem_hotplug_done();
 	return 0;
 
 failed_removal:
@@ -1698,10 +1722,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	mem_hotplug_done();
 	return ret;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages);
-- 
2.17.1
