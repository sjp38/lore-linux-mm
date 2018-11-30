Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66A216B597C
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:00:34 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so5927768qkb.23
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 10:00:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n27si337732qtl.90.2018.11.30.10.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 10:00:32 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 3/4] mm/memory_hotplug: Introduce and use more memory types
Date: Fri, 30 Nov 2018 18:59:21 +0100
Message-Id: <20181130175922.10425-4-david@redhat.com>
In-Reply-To: <20181130175922.10425-1-david@redhat.com>
References: <20181130175922.10425-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Balbir Singh <bsingharora@gmail.com>, Michael Neuling <mikey@neuling.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, YueHaibing <yuehaibing@huawei.com>, Vasily Gorbik <gor@linux.ibm.com>, Ingo Molnar <mingo@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@suse.com>, Arun KS <arunks@codeaurora.org>, Andrew Banman <andrew.banman@hpe.com>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?Michal=20Such=C3=A1nek?= <msuchanek@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>

Let's introduce new types for different kinds of memory blocks and use
them in existing code. As I don't see an easy way to split this up,
do it in one hunk for now.

acpi:
 Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kernel.
 Properly change the type when trying to add memory that was already
 detected and used during boot (so this memory will correctly end up as
 "acpi" in user space).

pseries:
 Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kernel.
 As far as I see, handling like in the acpi case for existing blocks is
 not required.

probed memory from user space:
 Use DIMM_UNREMOVABLE as there is no interface to get rid of this code
 again.

hv_balloon,xen/balloon:
 Use BALLOON. As simple as that :)

s390x/sclp:
 Use a dedicated type S390X_STANDBY as this type of memory and it's
 semantics are very s390x specific.

powernv/memtrace:
 Only allow to use BOOT memory for memtrace. I consider this code in
 general dangerous, but we have to keep it working ... most probably just
 a debug feature.

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
Cc: Stefano Stabellini <sstabellini@kernel.org>
Cc: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Neuling <mikey@neuling.org>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: YueHaibing <yuehaibing@huawei.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Suchánek <msuchanek@suse.de>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>

---

At first I tried to abstract the types quite a lot, but I think there
are subtle differences that are worth differentiating. More details about
the types can be found in the excessive documentation.

It is wort noting that BALLOON_MOVABLE has no user yet, but I have
something in mind that might want to make use of that (virtio-mem).
Just included it to discuss the general approach. I can drop it from
this patch.
---
 arch/powerpc/platforms/powernv/memtrace.c     |  9 ++--
 .../platforms/pseries/hotplug-memory.c        |  7 ++-
 drivers/acpi/acpi_memhotplug.c                | 16 ++++++-
 drivers/base/memory.c                         | 18 ++++++-
 drivers/hv/hv_balloon.c                       |  3 +-
 drivers/s390/char/sclp_cmd.c                  |  3 +-
 drivers/xen/balloon.c                         |  2 +-
 include/linux/memory.h                        | 47 ++++++++++++++++++-
 include/linux/memory_hotplug.h                |  6 +--
 mm/memory_hotplug.c                           | 15 +++---
 10 files changed, 104 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index 248a38ad25c7..5d08db87091e 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -54,9 +54,9 @@ static const struct file_operations memtrace_fops = {
 	.open	= simple_open,
 };
 
-static int check_memblock_online(struct memory_block *mem, void *arg)
+static int check_memblock_boot_and_online(struct memory_block *mem, void *arg)
 {
-	if (mem->state != MEM_ONLINE)
+	if (mem->type != MEM_BLOCK_BOOT || mem->state != MEM_ONLINE)
 		return -1;
 
 	return 0;
@@ -77,7 +77,7 @@ static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
 	u64 end_pfn = start_pfn + nr_pages - 1;
 
 	if (walk_memory_range(start_pfn, end_pfn, NULL,
-	    check_memblock_online))
+	    check_memblock_boot_and_online))
 		return false;
 
 	walk_memory_range(start_pfn, end_pfn, (void *)MEM_GOING_OFFLINE,
@@ -233,7 +233,8 @@ static int memtrace_online(void)
 			ent->mem = 0;
 		}
 
-		if (add_memory(ent->nid, ent->start, ent->size)) {
+		if (add_memory(ent->nid, ent->start, ent->size,
+			       MEMORY_BLOCK_BOOT)) {
 			pr_err("Failed to add trace memory to node %d\n",
 				ent->nid);
 			ret += 1;
diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index 2a983b5a52e1..5f91359c7993 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -651,7 +651,7 @@ static int dlpar_memory_remove_by_ic(u32 lmbs_to_remove, u32 drc_index)
 static int dlpar_add_lmb(struct drmem_lmb *lmb)
 {
 	unsigned long block_sz;
-	int nid, rc;
+	int nid, rc, type = MEMORY_BLOCK_DIMM;
 
 	if (lmb->flags & DRCONF_MEM_ASSIGNED)
 		return -EINVAL;
@@ -667,8 +667,11 @@ static int dlpar_add_lmb(struct drmem_lmb *lmb)
 	/* Find the node id for this address */
 	nid = memory_add_physaddr_to_nid(lmb->base_addr);
 
+	if (!IS_ENABLED(CONFIG_MEMORY_HOTREMOVE))
+		type = MEMORY_BLOCK_DIMM_UNREMOVABLE;
+
 	/* Add the memory */
-	rc = __add_memory(nid, lmb->base_addr, block_sz);
+	rc = __add_memory(nid, lmb->base_addr, block_sz, type);
 	if (rc) {
 		invalidate_lmb_associativity_index(lmb);
 		return rc;
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 8fe0960ea572..f841113b450d 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -177,6 +177,13 @@ static unsigned long acpi_meminfo_end_pfn(struct acpi_memory_info *info)
 
 static int acpi_bind_memblk(struct memory_block *mem, void *arg)
 {
+	/* switch the type of memory block if this memory was already present */
+	if (mem->type == MEMORY_BLOCK_BOOT) {
+		if (IS_ENABLED(CONFIG_MEMORY_HOTREMOVE))
+			mem->type = MEMORY_BLOCK_DIMM;
+		else
+			mem->type = MEMORY_BLOCK_DIMM_UNREMOVABLE;
+	}
 	return acpi_bind_one(&mem->dev, arg);
 }
 
@@ -191,6 +198,7 @@ static int acpi_bind_memory_blocks(struct acpi_memory_info *info,
 static int acpi_unbind_memblk(struct memory_block *mem, void *arg)
 {
 	acpi_unbind_one(&mem->dev);
+	mem->type = MEMORY_BLOCK_BOOT;
 	return 0;
 }
 
@@ -203,10 +211,13 @@ static void acpi_unbind_memory_blocks(struct acpi_memory_info *info)
 static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 {
 	acpi_handle handle = mem_device->device->handle;
-	int result, num_enabled = 0;
+	int result, num_enabled = 0, type = MEMORY_BLOCK_DIMM;
 	struct acpi_memory_info *info;
 	int node;
 
+	if (!IS_ENABLED(CONFIG_MEMORY_HOTREMOVE))
+		type = MEMORY_BLOCK_DIMM_UNREMOVABLE;
+
 	node = acpi_get_node(handle);
 	/*
 	 * Tell the VM there is more memory here...
@@ -228,7 +239,8 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length);
+		result = __add_memory(node, info->start_addr, info->length,
+				      type);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c42300082c88..c5fdca7a3009 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -394,6 +394,21 @@ static ssize_t type_show(struct device *dev, struct device_attribute *attr,
 	case MEMORY_BLOCK_BOOT:
 		len = sprintf(buf, "boot\n");
 		break;
+	case MEMORY_BLOCK_DIMM:
+		len = sprintf(buf, "dimm\n");
+		break;
+	case MEMORY_BLOCK_DIMM_UNREMOVABLE:
+		len = sprintf(buf, "dimm-unremovable\n");
+		break;
+	case MEMORY_BLOCK_BALLOON:
+		len = sprintf(buf, "balloon\n");
+		break;
+	case MEMORY_BLOCK_BALLOON_MOVABLE:
+		len = sprintf(buf, "balloon-movable\n");
+		break;
+	case MEMORY_BLOCK_S390X_STANDBY:
+		len = sprintf(buf, "s390x-standby\n");
+		break;
 	default:
 		len = sprintf(buf, "ERROR-UNKNOWN-%ld\n",
 				mem->state);
@@ -538,7 +553,8 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+			   MIN_MEMORY_BLOCK_SIZE * sections_per_block,
+			   MEMORY_BLOCK_DIMM_UNREMOVABLE);
 
 	if (ret)
 		goto out;
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 47719862e57f..f502ea6cd255 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -741,7 +741,8 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
-				(HA_CHUNK << PAGE_SHIFT));
+				 (HA_CHUNK << PAGE_SHIFT),
+				 MEMORY_BLOCK_BALLOON);
 
 		if (ret) {
 			pr_err("hot_add memory failed error is %d\n", ret);
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index 37d42de06079..0ca6f77e7e1d 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -406,7 +406,8 @@ static void __init add_memory_merged(u16 rn)
 	if (!size)
 		goto skip_add;
 	for (addr = start; addr < start + size; addr += block_size)
-		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size,
+			   MEMORY_BLOCK_S390X_STANDBY);
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 5d2d7a917b4e..953ff86d609b 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -352,7 +352,7 @@ static enum bp_state reserve_additional_memory(void)
 	mutex_unlock(&balloon_mutex);
 	/* add_memory_resource() requires the device_hotplug lock */
 	lock_device_hotplug();
-	rc = add_memory_resource(nid, resource);
+	rc = add_memory_resource(nid, resource, MEMORY_BLOCK_BALLOON);
 	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 9f39ef41e6d2..a3a1e9764805 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -59,12 +59,57 @@ int set_memory_block_size_order(unsigned int order);
  *  specific device driver takes care of this memory block. This memory
  *  block type is onlined automatically by the kernel during boot and might
  *  later be managed by a different device driver, in which case the type
- *  might change.
+ *  might change (e.g. to MEMORY_BLOCK_DIMM).
+ *
+ * MEMORY_BLOCK_DIMM:
+ *  This memory block is managed by a device driver taking care of DIMMs
+ *  (or similar). Once all memory blocks belonging to the DIMM have been
+ *  offlined, the DIMM along with the memory blocks can be removed to
+ *  effectively unplug it. This memory block type is usually onlined to the
+ *  MOVABLE zone, to make offlining and unplug possible. Examples include
+ *  ACPI DIMMs and PPC LMBs if the kernel supports removal of memory.
+ *
+ * MEMORY_BLOCK_DIMM_UNREMOVABLE:
+ *  This memory block is managed by a device driver taking care of DIMMs
+ *  (or similar). There is either no HW interface to remove the DIMM or
+ *  the kernel does not support offlining/removal of memory, so this memory
+ *  block can never be removed. Examples include ACPI DIMMs and PPC LMBs
+ *  when removal of memory is not supported by the kernel, as well as
+ *  memory probed manually from user space.
+ *  This memory block type is usually onlined to the NORMAL zone.
+ *
+ * MEMORY_BLOCK_BALLOON:
+ *  This memory block was added by a balloon device driver (or similar)
+ *  that does not require a specific zone for optimal operation
+ *  (e.g. unplug memory using balloon inflation on this memory block on
+ *  page granularity). Examples include memory added by the XEN and Hyper-V
+ *  balloon driver.
+ *  This memory block type is usually onlined to the NORMAL zone.
+ *
+ * MEMORY_BLOCK_BALLOON_MOVABLE:
+ *  This memory block was added by a balloon device driver (or similar)
+ *  that suggests to online this memory block to the MOVABLE zone for
+ *  optimal operation (a.g. unplug using balloon inflation on this memory
+ *  block in bigger chunks than pages). There are no examples yet.
+ *  This memory block type is usually onlined to the MOVABLE zone.
+ *
+ * MEMORY_BLOCK_S390X_STANDBY:
+ *  The memory block is special standby memory on s390x. As long as
+ *  offline, no memory will be allocated to the system for this memory
+ *  block. Onlining memory will result in memory getting allocated to the
+ *  system and memory can usually not be offlined again. The memory block
+ *  will never be removed. This memory type is usually not onlined
+ *  automatically but explicitly by the administrator.
  */
 enum {
 	MEMORY_BLOCK_NONE = 0,
 	MEMORY_BLOCK_UNSPECIFIED,
 	MEMORY_BLOCK_BOOT,
+	MEMORY_BLOCK_DIMM,
+	MEMORY_BLOCK_DIMM_UNREMOVABLE,
+	MEMORY_BLOCK_BALLOON,
+	MEMORY_BLOCK_BALLOON_MOVABLE,
+	MEMORY_BLOCK_S390X_STANDBY,
 };
 
 /* These states are exposed to userspace as text strings in sysfs */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 667a37aa9a3c..7c8895299e8c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -326,9 +326,9 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
 extern void __ref free_area_init_core_hotplug(int nid);
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
-extern int __add_memory(int nid, u64 start, u64 size);
-extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource);
+extern int __add_memory(int nid, u64 start, u64 size, int type);
+extern int add_memory(int nid, u64 start, u64 size, int type);
+extern int add_memory_resource(int nid, struct resource *resource, int type);
 extern int arch_add_memory(int nid, u64 start, u64 size,
 			   struct vmem_altmap *altmap, int type);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7246faa44488..f109002d6e6e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1071,7 +1071,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  *
  * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
  */
-int __ref add_memory_resource(int nid, struct resource *res)
+int __ref add_memory_resource(int nid, struct resource *res, int type)
 {
 	u64 start, size;
 	bool new_node = false;
@@ -1080,6 +1080,9 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	start = res->start;
 	size = resource_size(res);
 
+	if (type == MEMORY_BLOCK_NONE)
+		return -EINVAL;
+
 	ret = check_hotplug_memory_range(start, size);
 	if (ret)
 		return ret;
@@ -1100,7 +1103,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	new_node = ret;
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, NULL, MEMORY_TYPE_UNSPECIFIED);
+	ret = arch_add_memory(nid, start, size, NULL, type);
 	if (ret < 0)
 		goto error;
 
@@ -1141,7 +1144,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 }
 
 /* requires device_hotplug_lock, see add_memory_resource() */
-int __ref __add_memory(int nid, u64 start, u64 size)
+int __ref __add_memory(int nid, u64 start, u64 size, int type)
 {
 	struct resource *res;
 	int ret;
@@ -1150,18 +1153,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res);
+	ret = add_memory_resource(nid, res, type);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
 }
 
-int add_memory(int nid, u64 start, u64 size)
+int add_memory(int nid, u64 start, u64 size, int type)
 {
 	int rc;
 
 	lock_device_hotplug();
-	rc = __add_memory(nid, start, size);
+	rc = __add_memory(nid, start, size, type);
 	unlock_device_hotplug();
 
 	return rc;
-- 
2.17.2
