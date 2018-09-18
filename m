Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E113F8E0006
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:48:57 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x204-v6so1081441qka.6
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 04:48:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x3-v6si11362741qti.136.2018.09.18.04.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 04:48:56 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 3/6] mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock
Date: Tue, 18 Sep 2018 13:48:19 +0200
Message-Id: <20180918114822.21926-4-david@redhat.com>
In-Reply-To: <20180918114822.21926-1-david@redhat.com>
References: <20180918114822.21926-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

There seem to be some problems as result of 30467e0b3be ("mm, hotplug:
fix concurrent memory hot-add deadlock"), which tried to fix a possible
lock inversion reported and discussed in [1] due to the two locks
	a) device_lock()
	b) mem_hotplug_lock

While add_memory() first takes b), followed by a) during
bus_probe_device(), onlining of memory from user space first took a),
followed by b), exposing a possible deadlock.

In [1], and it was decided to not make use of device_hotplug_lock, but
rather to enforce a locking order.

The problems I spotted related to this:

1. Memory block device attributes: While .state first calls
   mem_hotplug_begin() and the calls device_online() - which takes
   device_lock() - .online does no longer call mem_hotplug_begin(), so
   effectively calls online_pages() without mem_hotplug_lock.

2. device_online() should be called under device_hotplug_lock, however
   onlining memory during add_memory() does not take care of that.

In addition, I think there is also something wrong about the locking in

3. arch/powerpc/platforms/powernv/memtrace.c calls offline_pages()
   without locks. This was introduced after 30467e0b3be. And skimming over
   the code, I assume it could need some more care in regards to locking
   (e.g. device_online() called without device_hotplug_lock. This will
   be addressed in the following patches.

Now that we hold the device_hotplug_lock when
- adding memory (e.g. via add_memory()/add_memory_resource())
- removing memory (e.g. via remove_memory())
- device_online()/device_offline()

We can move mem_hotplug_lock usage back into
online_pages()/offline_pages().

Why is mem_hotplug_lock still needed? Essentially to make
get_online_mems()/put_online_mems() be very fast (relying on
device_hotplug_lock would be very slow), and to serialize against
addition of memory that does not create memory block devices (hmm).

[1] http://driverdev.linuxdriverproject.org/pipermail/ driverdev-devel/
    2015-February/065324.html

This patch is partly based on a patch by Vitaly Kuznetsov.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Michael Neuling <mikey@neuling.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c | 13 +------------
 mm/memory_hotplug.c   | 28 ++++++++++++++++++++--------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 40cac122ec73..0e5985682642 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -228,7 +228,6 @@ static bool pages_correctly_probed(unsigned long start_pfn)
 /*
  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
  * OK to have direct references to sparsemem variables in here.
- * Must already be protected by mem_hotplug_begin().
  */
 static int
 memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
@@ -294,7 +293,6 @@ static int memory_subsys_online(struct device *dev)
 	if (mem->online_type < 0)
 		mem->online_type = MMOP_ONLINE_KEEP;
 
-	/* Already under protection of mem_hotplug_begin() */
 	ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
 
 	/* clear online_type */
@@ -341,19 +339,11 @@ store_mem_state(struct device *dev,
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
@@ -364,7 +354,6 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}
 
-	mem_hotplug_done();
 err:
 	unlock_device_hotplug();
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ef5444145c88..497e9315ca6f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -881,7 +881,6 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	return zone;
 }
 
-/* Must be protected by mem_hotplug_begin() or a device_lock */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -893,6 +892,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	struct memory_notify arg;
 	struct memory_block *mem;
 
+	mem_hotplug_begin();
+
 	/*
 	 * We can't use pfn_to_nid() because nid might be stored in struct page
 	 * which is not yet initialized. Instead, we find nid from memory block.
@@ -957,6 +958,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
+	mem_hotplug_done();
 	return 0;
 
 failed_addition:
@@ -964,6 +966,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		 (unsigned long long) pfn << PAGE_SHIFT,
 		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_ONLINE, &arg);
+	mem_hotplug_done();
 	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
@@ -1168,20 +1171,20 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
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
@@ -1622,10 +1625,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
@@ -1634,8 +1643,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
@@ -1706,6 +1717,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
+	mem_hotplug_done();
 	return 0;
 
 failed_removal:
@@ -1715,10 +1727,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
