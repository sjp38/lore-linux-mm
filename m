Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 935DE8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 11:04:20 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u195-v6so6295333qka.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 08:04:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w10-v6si317442qtk.68.2018.09.28.08.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 08:04:18 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Date: Fri, 28 Sep 2018 17:03:57 +0200
Message-Id: <20180928150357.12942-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, David Hildenbrand <david@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

How to/when to online hotplugged memory is hard to manage for
distributions because different memory types are to be treated differently.
Right now, we need complicated udev rules that e.g. check if we are
running on s390x, on a physical system or on a virtualized system. But
there is also sometimes the demand to really online memory immediately
while adding in the kernel and not to wait for user space to make a
decision. And on virtualized systems there might be different
requirements, depending on "how" the memory was added (and if it will
eventually get unplugged again - DIMM vs. paravirtualized mechanisms).

On the one hand, we have physical systems where we sometimes
want to be able to unplug memory again - e.g. a DIMM - so we have to online
it to the MOVABLE zone optionally. That decision is usually made in user
space.

On the other hand, we have memory that should never be onlined
automatically, only when asked for by an administrator. Such memory only
applies to virtualized environments like s390x, where the concept of
"standby" memory exists. Memory is detected and added during boot, so it
can be onlined when requested by the admininistrator or some tooling.
Only when onlining, memory will be allocated in the hypervisor.

But then, we also have paravirtualized devices (namely xen and hyper-v
balloons), that hotplug memory that will never ever be removed from a
system right now using offline_pages/remove_memory. If at all, this memory
is logically unplugged and handed back to the hypervisor via ballooning.

For paravirtualized devices it is relevant that memory is onlined as
quickly as possible after adding - and that it is added to the NORMAL
zone. Otherwise, it could happen that too much memory in a row is added
(but not onlined), resulting in out-of-memory conditions due to the
additional memory for "struct pages" and friends. MOVABLE zone as well
as delays might be very problematic and lead to crashes (e.g. zone
imbalance).

Therefore, introduce memory block types and online memory depending on
it when adding the memory. Expose the memory type to user space, so user
space handlers can start to process only "normal" memory. Other memory
block types can be ignored. One thing less to worry about in user space.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: "Jonathan NeuschA?fer" <j.neuschaefer@gmx.net>
Cc: Joe Perches <joe@perches.com>
Cc: Michael Neuling <mikey@neuling.org>
Cc: Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Rob Herring <robh@kernel.org>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

This patch is based on the current mm-tree, where some related
patches from me are currently residing that touched the add_memory()
functions.

 arch/ia64/mm/init.c                       |  4 +-
 arch/powerpc/mm/mem.c                     |  4 +-
 arch/powerpc/platforms/powernv/memtrace.c |  3 +-
 arch/s390/mm/init.c                       |  4 +-
 arch/sh/mm/init.c                         |  4 +-
 arch/x86/mm/init_32.c                     |  4 +-
 arch/x86/mm/init_64.c                     |  8 +--
 drivers/acpi/acpi_memhotplug.c            |  3 +-
 drivers/base/memory.c                     | 63 ++++++++++++++++++++---
 drivers/hv/hv_balloon.c                   | 33 ++----------
 drivers/s390/char/sclp_cmd.c              |  3 +-
 drivers/xen/balloon.c                     |  2 +-
 include/linux/memory.h                    | 28 +++++++++-
 include/linux/memory_hotplug.h            | 17 +++---
 mm/hmm.c                                  |  6 ++-
 mm/memory_hotplug.c                       | 31 ++++++-----
 16 files changed, 139 insertions(+), 78 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d5e12ff1d73c..813d1d86bf95 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -646,13 +646,13 @@ mem_init (void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		    int memory_block_type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5551f5870dcc..dd32fcc9099c 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -118,7 +118,7 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 }
 
 int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+			      int memory_block_type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -135,7 +135,7 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
 	}
 	flush_inval_dcache_range(start, start + size);
 
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index 84d038ed3882..57d6b3d46382 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -232,7 +232,8 @@ static int memtrace_online(void)
 			ent->mem = 0;
 		}
 
-		if (add_memory(ent->nid, ent->start, ent->size)) {
+		if (add_memory(ent->nid, ent->start, ent->size,
+			       MEMORY_BLOCK_NORMAL)) {
 			pr_err("Failed to add trace memory to node %d\n",
 				ent->nid);
 			ret += 1;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index e472cd763eb3..b5324527c7f6 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -222,7 +222,7 @@ device_initcall(s390_cma_mem_init);
 #endif /* CONFIG_CMA */
 
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		    int memory_block_type)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -232,7 +232,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, altmap, memory_block_type);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index c8c13c777162..6b876000731a 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -419,14 +419,14 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		    int memory_block_type)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index f2837e4c40b3..4f50cd4467a9 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -851,12 +851,12 @@ void __init mem_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		    int memory_block_type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5fab264948c2..fc3df573f0f3 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -783,11 +783,11 @@ static void update_end_of_memory_vars(u64 start, u64 size)
 }
 
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock)
+		struct vmem_altmap *altmap, int memory_block_type)
 {
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
@@ -798,14 +798,14 @@ int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 }
 
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+		    int memory_block_type)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
 	init_memory_mapping(start, start + size);
 
-	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 }
 
 #define PAGE_INUSE 0xFD
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 8fe0960ea572..c5f646b4e97e 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -228,7 +228,8 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length);
+		result = __add_memory(node, info->start_addr, info->length,
+				      MEMORY_BLOCK_NORMAL);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0e5985682642..2686101e41b5 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -381,6 +381,32 @@ static ssize_t show_phys_device(struct device *dev,
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
+static ssize_t type_show(struct device *dev, struct device_attribute *attr,
+			 char *buf)
+{
+	struct memory_block *mem = to_memory_block(dev);
+	ssize_t len = 0;
+
+	switch (mem->state) {
+	case MEMORY_BLOCK_NORMAL:
+		len = sprintf(buf, "normal\n");
+		break;
+	case MEMORY_BLOCK_STANDBY:
+		len = sprintf(buf, "standby\n");
+		break;
+	case MEMORY_BLOCK_PARAVIRT:
+		len = sprintf(buf, "paravirt\n");
+		break;
+	default:
+		len = sprintf(buf, "ERROR-UNKNOWN-%ld\n",
+				mem->state);
+		WARN_ON(1);
+		break;
+	}
+
+	return len;
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static void print_allowed_zone(char *buf, int nid, unsigned long start_pfn,
 		unsigned long nr_pages, int online_type,
@@ -442,6 +468,7 @@ static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
 static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
 static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
 static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
+static DEVICE_ATTR_RO(type);
 
 /*
  * Block size attribute stuff
@@ -514,7 +541,8 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+			   MIN_MEMORY_BLOCK_SIZE * sections_per_block,
+			   MEMORY_BLOCK_NORMAL);
 
 	if (ret)
 		goto out;
@@ -620,6 +648,7 @@ static struct attribute *memory_memblk_attrs[] = {
 	&dev_attr_state.attr,
 	&dev_attr_phys_device.attr,
 	&dev_attr_removable.attr,
+	&dev_attr_type.attr,
 #ifdef CONFIG_MEMORY_HOTREMOVE
 	&dev_attr_valid_zones.attr,
 #endif
@@ -657,13 +686,17 @@ int register_memory(struct memory_block *memory)
 }
 
 static int init_memory_block(struct memory_block **memory,
-			     struct mem_section *section, unsigned long state)
+			     struct mem_section *section, unsigned long state,
+			     int memory_block_type)
 {
 	struct memory_block *mem;
 	unsigned long start_pfn;
 	int scn_nr;
 	int ret = 0;
 
+	if (memory_block_type == MEMORY_BLOCK_NONE)
+		return -EINVAL;
+
 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
@@ -675,6 +708,7 @@ static int init_memory_block(struct memory_block **memory,
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
+	mem->type = memory_block_type;
 
 	ret = register_memory(mem);
 
@@ -699,7 +733,8 @@ static int add_memory_block(int base_section_nr)
 
 	if (section_count == 0)
 		return 0;
-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
+	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE,
+				MEMORY_BLOCK_NORMAL);
 	if (ret)
 		return ret;
 	mem->section_count = section_count;
@@ -710,19 +745,35 @@ static int add_memory_block(int base_section_nr)
  * need an interface for the VM to add new memory regions,
  * but without onlining it.
  */
-int hotplug_memory_register(int nid, struct mem_section *section)
+int hotplug_memory_register(int nid, struct mem_section *section,
+			    int memory_block_type)
 {
 	int ret = 0;
 	struct memory_block *mem;
 
 	mutex_lock(&mem_sysfs_mutex);
 
+	/* make sure there is no memblock if we don't want one */
+	if (memory_block_type == MEMORY_BLOCK_NONE) {
+		mem = find_memory_block(section);
+		if (mem) {
+			put_device(&mem->dev);
+			ret = -EINVAL;
+		}
+		goto out;
+	}
+
 	mem = find_memory_block(section);
 	if (mem) {
-		mem->section_count++;
+		/* make sure the type matches */
+		if (mem->type == memory_block_type)
+			mem->section_count++;
+		else
+			ret = -EINVAL;
 		put_device(&mem->dev);
 	} else {
-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
+		ret = init_memory_block(&mem, section, MEM_OFFLINE,
+					memory_block_type);
 		if (ret)
 			goto out;
 		mem->section_count++;
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b1b788082793..5a8d18c4d699 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -537,11 +537,6 @@ struct hv_dynmem_device {
 	 */
 	bool host_specified_ha_region;
 
-	/*
-	 * State to synchronize hot-add.
-	 */
-	struct completion  ol_waitevent;
-	bool ha_waiting;
 	/*
 	 * This thread handles hot-add
 	 * requests from the host as well as notifying
@@ -640,14 +635,6 @@ static int hv_memory_notifier(struct notifier_block *nb, unsigned long val,
 	unsigned long flags, pfn_count;
 
 	switch (val) {
-	case MEM_ONLINE:
-	case MEM_CANCEL_ONLINE:
-		if (dm_device.ha_waiting) {
-			dm_device.ha_waiting = false;
-			complete(&dm_device.ol_waitevent);
-		}
-		break;
-
 	case MEM_OFFLINE:
 		spin_lock_irqsave(&dm_device.ha_lock, flags);
 		pfn_count = hv_page_offline_check(mem->start_pfn,
@@ -665,9 +652,7 @@ static int hv_memory_notifier(struct notifier_block *nb, unsigned long val,
 		}
 		spin_unlock_irqrestore(&dm_device.ha_lock, flags);
 		break;
-	case MEM_GOING_ONLINE:
-	case MEM_GOING_OFFLINE:
-	case MEM_CANCEL_OFFLINE:
+	default:
 		break;
 	}
 	return NOTIFY_OK;
@@ -731,12 +716,10 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 		has->covered_end_pfn +=  processed_pfn;
 		spin_unlock_irqrestore(&dm_device.ha_lock, flags);
 
-		init_completion(&dm_device.ol_waitevent);
-		dm_device.ha_waiting = !memhp_auto_online;
-
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
-				(HA_CHUNK << PAGE_SHIFT));
+				 (HA_CHUNK << PAGE_SHIFT),
+				 MEMORY_BLOCK_PARAVIRT);
 
 		if (ret) {
 			pr_err("hot_add memory failed error is %d\n", ret);
@@ -757,16 +740,6 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 			break;
 		}
 
-		/*
-		 * Wait for the memory block to be onlined when memory onlining
-		 * is done outside of kernel (memhp_auto_online). Since the hot
-		 * add has succeeded, it is ok to proceed even if the pages in
-		 * the hot added region have not been "onlined" within the
-		 * allowed time.
-		 */
-		if (dm_device.ha_waiting)
-			wait_for_completion_timeout(&dm_device.ol_waitevent,
-						    5*HZ);
 		post_status(&dm_device);
 	}
 }
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index d7686a68c093..1928a2411456 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -406,7 +406,8 @@ static void __init add_memory_merged(u16 rn)
 	if (!size)
 		goto skip_add;
 	for (addr = start; addr < start + size; addr += block_size)
-		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size,
+			   MEMORY_BLOCK_STANDBY);
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index fdfc64f5acea..291a8aac6af3 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -397,7 +397,7 @@ static enum bp_state reserve_additional_memory(void)
 	mutex_unlock(&balloon_mutex);
 	/* add_memory_resource() requires the device_hotplug lock */
 	lock_device_hotplug();
-	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	rc = add_memory_resource(nid, resource, MEMORY_BLOCK_PARAVIRT);
 	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a6ddefc60517..3dc2a0b12653 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -23,6 +23,30 @@
 
 #define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
 
+/*
+ * NONE:     No memory block is to be created (e.g. device memory).
+ * NORMAL:   Memory block that represents normal (boot or hotplugged) memory
+ *           (e.g. ACPI DIMMs) that should be onlined either automatically
+ *           (memhp_auto_online) or manually by user space to select a
+ *           specific zone.
+ *           Applicable to memhp_auto_online.
+ * STANDBY:  Memory block that represents standby memory that should only
+ *           be onlined on demand by user space (e.g. standby memory on
+ *           s390x), but never automatically by the kernel.
+ *           Not applicable to memhp_auto_online.
+ * PARAVIRT: Memory block that represents memory added by
+ *           paravirtualized mechanisms (e.g. hyper-v, xen) that will
+ *           always automatically get onlined. Memory will be unplugged
+ *           using ballooning, not by relying on the MOVABLE ZONE.
+ *           Not applicable to memhp_auto_online.
+ */
+enum {
+	MEMORY_BLOCK_NONE,
+	MEMORY_BLOCK_NORMAL,
+	MEMORY_BLOCK_STANDBY,
+	MEMORY_BLOCK_PARAVIRT,
+};
+
 struct memory_block {
 	unsigned long start_section_nr;
 	unsigned long end_section_nr;
@@ -34,6 +58,7 @@ struct memory_block {
 	int (*phys_callback)(struct memory_block *);
 	struct device dev;
 	int nid;			/* NID for this memory block */
+	int type;			/* type of this memory block */
 };
 
 int arch_get_memory_phys_device(unsigned long start_pfn);
@@ -111,7 +136,8 @@ extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
-int hotplug_memory_register(int nid, struct mem_section *section);
+int hotplug_memory_register(int nid, struct mem_section *section,
+			    int memory_block_type);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int unregister_memory_section(struct mem_section *);
 #endif
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ffd9cd10fcf3..b560a9ee0e8c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -115,18 +115,18 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+		struct vmem_altmap *altmap, int memory_block_type);
 
 #ifndef CONFIG_ARCH_HAS_ADD_PAGES
 static inline int add_pages(int nid, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		int memory_block_type)
 {
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, altmap, memory_block_type);
 }
 #else /* ARCH_HAS_ADD_PAGES */
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+	      struct vmem_altmap *altmap, int memory_block_type);
 #endif /* ARCH_HAS_ADD_PAGES */
 
 #ifdef CONFIG_NUMA
@@ -324,11 +324,12 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
 extern void __ref free_area_init_core_hotplug(int nid);
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
-extern int __add_memory(int nid, u64 start, u64 size);
-extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource, bool online);
+extern int __add_memory(int nid, u64 start, u64 size, int memory_block_type);
+extern int add_memory(int nid, u64 start, u64 size, int memory_block_type);
+extern int add_memory_resource(int nid, struct resource *resource,
+			       int memory_block_type);
 extern int arch_add_memory(int nid, u64 start, u64 size,
-		struct vmem_altmap *altmap, bool want_memblock);
+			   struct vmem_altmap *altmap, int memory_block_type);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/mm/hmm.c b/mm/hmm.c
index c968e49f7a0c..2350f6f6ab42 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -32,6 +32,7 @@
 #include <linux/jump_label.h>
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
+#include <linux/memory.h>
 
 #define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
@@ -1096,10 +1097,11 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	 */
 	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
 		ret = arch_add_memory(nid, align_start, align_size, NULL,
-				false);
+				      MEMORY_BLOCK_NONE);
 	else
 		ret = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
+				align_size >> PAGE_SHIFT, NULL,
+				MEMORY_BLOCK_NONE);
 	if (ret) {
 		mem_hotplug_done();
 		goto error_add_memory;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d4c7e42e46f3..bce6c41d721c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -246,7 +246,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		struct vmem_altmap *altmap, bool want_memblock)
+		struct vmem_altmap *altmap, int memory_block_type)
 {
 	int ret;
 
@@ -257,10 +257,11 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (ret < 0)
 		return ret;
 
-	if (!want_memblock)
+	if (memory_block_type == MEMBLOCK_NONE)
 		return 0;
 
-	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
+	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn),
+				       memory_block_type);
 }
 
 /*
@@ -271,7 +272,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  */
 int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		int memory_block_type)
 {
 	unsigned long i;
 	int err = 0;
@@ -296,7 +297,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				want_memblock);
+				    memory_block_type);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1099,7 +1100,8 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  *
  * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
  */
-int __ref add_memory_resource(int nid, struct resource *res, bool online)
+int __ref add_memory_resource(int nid, struct resource *res,
+			      int memory_block_type)
 {
 	u64 start, size;
 	bool new_node = false;
@@ -1108,6 +1110,9 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	start = res->start;
 	size = resource_size(res);
 
+	if (memory_block_type == MEMORY_BLOCK_NONE)
+		return -EINVAL;
+
 	ret = check_hotplug_memory_range(start, size);
 	if (ret)
 		return ret;
@@ -1128,7 +1133,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	new_node = ret;
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, NULL, true);
+	ret = arch_add_memory(nid, start, size, NULL, memory_block_type);
 	if (ret < 0)
 		goto error;
 
@@ -1153,8 +1158,8 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	/* device_online() will take the lock when calling online_pages() */
 	mem_hotplug_done();
 
-	/* online pages if requested */
-	if (online)
+	if (memory_block_type == MEMORY_BLOCK_PARAVIRT ||
+	    (memory_block_type == MEMORY_BLOCK_NORMAL && memhp_auto_online))
 		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
 				  NULL, online_memory_block);
 
@@ -1169,7 +1174,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 }
 
 /* requires device_hotplug_lock, see add_memory_resource() */
-int __ref __add_memory(int nid, u64 start, u64 size)
+int __ref __add_memory(int nid, u64 start, u64 size, int memory_block_type)
 {
 	struct resource *res;
 	int ret;
@@ -1178,18 +1183,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res, memhp_auto_online);
+	ret = add_memory_resource(nid, res, memory_block_type);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
 }
 
-int add_memory(int nid, u64 start, u64 size)
+int add_memory(int nid, u64 start, u64 size, int memory_block_type)
 {
 	int rc;
 
 	lock_device_hotplug();
-	rc = __add_memory(nid, start, size);
+	rc = __add_memory(nid, start, size, memory_block_type);
 	unlock_device_hotplug();
 
 	return rc;
-- 
2.17.1
