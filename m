Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85FAD6B002A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:33:39 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j80so5404658ywg.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:33:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h23si586842qta.114.2018.04.13.06.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:33:38 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 7/8] mm: allow to control onlining/offlining of memory by a driver
Date: Fri, 13 Apr 2018 15:33:28 +0200
Message-Id: <20180413133334.3612-1-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>, "moderated list:XEN HYPERVISOR INTERFACE" <xen-devel@lists.xenproject.org>

Some devices (esp. paravirtualized) might want to control
- when to online/offline a memory block
- how to online memory (MOVABLE/NORMAL)
- in which granularity to online/offline memory

So let's add a new flag "driver_managed" and disallow to change the
state by user space. Device onlining/offlining will still work, however
the memory will not be actually onlined/offlined. That has to be handled
by the device driver that owns the memory.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c          | 22 ++++++++++++++--------
 drivers/xen/balloon.c          |  2 +-
 include/linux/memory.h         |  1 +
 include/linux/memory_hotplug.h |  4 +++-
 mm/memory_hotplug.c            | 34 ++++++++++++++++++++++++++++++++--
 5 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index bffe8616bd55..3b8616551561 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -231,27 +231,28 @@ static bool pages_correctly_probed(unsigned long start_pfn)
  * Must already be protected by mem_hotplug_begin().
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
+memory_block_action(struct memory_block *mem, unsigned long action)
 {
-	unsigned long start_pfn;
+	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
-	int ret;
+	int ret = 0;
 
-	start_pfn = section_nr_to_pfn(phys_index);
+	if (mem->driver_managed)
+		return 0;
 
 	switch (action) {
 	case MEM_ONLINE:
 		if (!pages_correctly_probed(start_pfn))
 			return -EBUSY;
 
-		ret = online_pages(start_pfn, nr_pages, online_type);
+		ret = online_pages(start_pfn, nr_pages, mem->online_type);
 		break;
 	case MEM_OFFLINE:
 		ret = offline_pages(start_pfn, nr_pages);
 		break;
 	default:
 		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
-		     "%ld\n", __func__, phys_index, action, action);
+		     "%ld\n", __func__, mem->start_section_nr, action, action);
 		ret = -EINVAL;
 	}
 
@@ -269,8 +270,7 @@ static int memory_block_change_state(struct memory_block *mem,
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
-	ret = memory_block_action(mem->start_section_nr, to_state,
-				mem->online_type);
+	ret = memory_block_action(mem, to_state);
 
 	mem->state = ret ? from_state_req : to_state;
 
@@ -350,6 +350,11 @@ store_mem_state(struct device *dev,
 	 */
 	mem_hotplug_begin();
 
+	if (mem->driver_managed) {
+		ret = -EINVAL;
+		goto out;
+	}
+
 	switch (online_type) {
 	case MMOP_ONLINE_KERNEL:
 	case MMOP_ONLINE_MOVABLE:
@@ -364,6 +369,7 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}
 
+out:
 	mem_hotplug_done();
 err:
 	unlock_device_hotplug();
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 065f0b607373..89981d573c06 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -401,7 +401,7 @@ static enum bp_state reserve_additional_memory(void)
 	 * callers drop the mutex before trying again.
 	 */
 	mutex_unlock(&balloon_mutex);
-	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	rc = add_memory_resource(nid, resource, memhp_auto_online, false);
 	mutex_lock(&balloon_mutex);
 
 	if (rc) {
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 9f8cd856ca1e..018c5e5ecde1 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -29,6 +29,7 @@ struct memory_block {
 	unsigned long state;		/* serialized by the dev->lock */
 	int section_count;		/* serialized by mem_sysfs_mutex */
 	int online_type;		/* for passing data to online routine */
+	bool driver_managed;		/* driver handles online/offline */
 	int phys_device;		/* to which fru does this belong? */
 	void *hw;			/* optional pointer to fw/hw data */
 	int (*phys_callback)(struct memory_block *);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e0e49b5b1ee1..46c6ceb1110d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -320,7 +320,9 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource, bool online);
+extern int add_memory_driver_managed(int nid, u64 start, u64 size);
+extern int add_memory_resource(int nid, struct resource *resource, bool online,
+			       bool driver_managed);
 extern int arch_add_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap, bool want_memblock);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1d6054edc241..ac14ea772792 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1108,8 +1108,15 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 	return device_online(&mem->dev);
 }
 
+static int mark_memory_block_driver_managed(struct memory_block *mem, void *arg)
+{
+	mem->driver_managed = true;
+	return 0;
+}
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory_resource(int nid, struct resource *res, bool online)
+int __ref add_memory_resource(int nid, struct resource *res, bool online,
+			      bool driver_managed)
 {
 	u64 start, size;
 	pg_data_t *pgdat = NULL;
@@ -1117,6 +1124,9 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	bool new_node;
 	int ret;
 
+	if (online && driver_managed)
+		return -EINVAL;
+
 	start = res->start;
 	size = resource_size(res);
 
@@ -1188,6 +1198,9 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	if (online)
 		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
 				  NULL, online_memory_block);
+	else if (driver_managed)
+		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
+				  NULL, mark_memory_block_driver_managed);
 
 	goto out;
 
@@ -1212,13 +1225,30 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res, memhp_auto_online);
+	ret = add_memory_resource(nid, res, memhp_auto_online, false);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
+int __ref add_memory_driver_managed(int nid, u64 start, u64 size)
+{
+	struct resource *res;
+	int ret;
+
+	res = register_memory_resource(start, size);
+	if (IS_ERR(res))
+		return PTR_ERR(res);
+
+	ret = add_memory_resource(nid, res, false, true);
+	if (ret < 0)
+		release_memory_resource(res);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_memory_driver_managed);
+
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
-- 
2.14.3
