Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 69ED26B0034
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:33:01 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 14 Aug 2013 20:32:59 +0100
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8BB446E8048
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:32:51 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7EJVnnY11272288
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:31:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7EJVmrK009487
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:31:49 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [RFC][PATCH] drivers: base: dynamic memory block creation
Date: Wed, 14 Aug 2013 14:31:45 -0500
Message-Id: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Large memory systems (~1TB or more) experience boot delays on the order
of minutes due to the initializing the memory configuration part of
sysfs at /sys/devices/system/memory/.

ppc64 has a normal memory block size of 256M (however sometimes as low
as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
entries per block that's around 80k items that need be created at boot
time in sysfs.  Some systems go up to 16TB where the issue is even more
severe.

This patch provides a means by which users can prevent the creation of
the memory block attributes at boot time, yet still dynamically create
them if they are needed.

This patch creates a new boot parameter, "largememory" that will prevent
memory_dev_init() from creating all of the memory block sysfs attributes
at boot time.  Instead, a new root attribute "show" will allow
the dynamic creation of the memory block devices.
Another new root attribute "present" shows the memory blocks present in
the system; the valid inputs for the "show" attribute.

There was a significant amount of refactoring to allow for this but
IMHO, the code is much easier to understand now.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---

Reviewer/Maintainer Notes:

This is a replacement for my previous RFC and extends the existing memory
sysfs API rather than introducing an alternate layout.

 drivers/base/memory.c  | 248 +++++++++++++++++++++++++++++++++++++------------
 include/linux/memory.h |   1 -
 2 files changed, 188 insertions(+), 61 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 2b7813e..392ccd3 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -30,7 +30,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 #define MEMORY_CLASS_NAME	"memory"
 
-static int sections_per_block;
+static int sections_per_block __read_mostly;
 
 static inline int base_memory_block_id(int section_nr)
 {
@@ -47,6 +47,9 @@ static struct bus_type memory_subsys = {
 	.offline = memory_subsys_offline,
 };
 
+static unsigned long *memblock_present;
+static bool largememory_enable __read_mostly;
+
 static BLOCKING_NOTIFIER_HEAD(memory_chain);
 
 int register_memory_notifier(struct notifier_block *nb)
@@ -565,16 +568,13 @@ static const struct attribute_group *memory_memblk_attr_groups[] = {
 static
 int register_memory(struct memory_block *memory)
 {
-	int error;
-
 	memory->dev.bus = &memory_subsys;
 	memory->dev.id = memory->start_section_nr / sections_per_block;
 	memory->dev.release = memory_block_release;
 	memory->dev.groups = memory_memblk_attr_groups;
 	memory->dev.offline = memory->state == MEM_OFFLINE;
 
-	error = device_register(&memory->dev);
-	return error;
+	return device_register(&memory->dev);
 }
 
 static int init_memory_block(struct memory_block **memory,
@@ -582,67 +582,72 @@ static int init_memory_block(struct memory_block **memory,
 {
 	struct memory_block *mem;
 	unsigned long start_pfn;
-	int scn_nr;
-	int ret = 0;
+	int scn_nr, ret, memblock_id;
 
+	*memory = NULL;
 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
 	scn_nr = __section_nr(section);
+	memblock_id = base_memory_block_id(scn_nr);
 	mem->start_section_nr =
 			base_memory_block_id(scn_nr) * sections_per_block;
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
-	mem->section_count++;
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
 	ret = register_memory(mem);
+	if (ret) {
+		kfree(mem);
+		return ret;
+	}
 
 	*memory = mem;
-	return ret;
+	return 0;
 }
 
-static int add_memory_section(int nid, struct mem_section *section,
-			struct memory_block **mem_p,
-			unsigned long state, enum mem_add_context context)
+static int add_memory_block(int base_section_nr)
 {
-	struct memory_block *mem = NULL;
-	int scn_nr = __section_nr(section);
-	int ret = 0;
+	struct mem_section *section = __nr_to_section(base_section_nr);
+	struct memory_block *mem;
+	int i, ret = 0, present_sections = 0, memblock_id;
 
 	mutex_lock(&mem_sysfs_mutex);
 
-	if (context == BOOT) {
-		/* same memory block ? */
-		if (mem_p && *mem_p)
-			if (scn_nr >= (*mem_p)->start_section_nr &&
-			    scn_nr <= (*mem_p)->end_section_nr) {
-				mem = *mem_p;
-				kobject_get(&mem->dev.kobj);
-			}
-	} else
-		mem = find_memory_block(section);
+	memblock_id = base_memory_block_id(base_section_nr);
+	if (WARN_ON_ONCE(!test_bit(memblock_id, memblock_present))) {
+		/* tried to add a non-present memory block, shouldn't happen */
+		ret = -EINVAL;
+		goto out;
+	}
 
-	if (mem) {
-		mem->section_count++;
-		kobject_put(&mem->dev.kobj);
-	} else {
-		ret = init_memory_block(&mem, section, state);
-		/* store memory_block pointer for next loop */
-		if (!ret && context == BOOT)
-			if (mem_p)
-				*mem_p = mem;
+	/* count present sections */
+	for (i = base_section_nr;
+	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
+	     i++) {
+		if (present_section_nr(i))
+			present_sections++;
 	}
 
-	if (!ret) {
-		if (context == HOTPLUG &&
-		    mem->section_count == sections_per_block)
-			ret = register_mem_sect_under_node(mem, nid);
+	if (WARN_ON_ONCE(present_sections == 0)) {
+		/*
+		 * No present sections in memory block marked as present,
+		 * shouldn't happen. If it does, correct the present bitfield
+		 * and return error.
+		 */
+		clear_bit(memblock_id, memblock_present);
+		ret = -EINVAL;
+		goto out;
 	}
 
+	ret = init_memory_block(&mem, section, MEM_ONLINE);
+	if (ret)
+		goto out;
+	mem->section_count = present_sections;
+out:
 	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
@@ -653,7 +658,40 @@ static int add_memory_section(int nid, struct mem_section *section,
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	return add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
+	int ret = 0, memblock_id;
+	struct memory_block *mem;
+
+	mutex_lock(&mem_sysfs_mutex);
+
+	memblock_id = base_memory_block_id(__section_nr(section));
+
+	/*
+	 * Set present bit for the block if adding the first present
+	 * section in the block.
+	 */
+	if (!test_bit(memblock_id, memblock_present))
+		set_bit(memblock_id, memblock_present);
+
+	/* refs the memory_block dev if found */
+	mem = find_memory_block(section);
+
+	if (!mem) {
+		/* create offline memory block */
+		ret = init_memory_block(&mem, section, MEM_OFFLINE);
+		if (ret)
+			goto out;
+		kobject_get(&mem->dev.kobj);
+	}
+	mem->section_count++;
+	kobject_put(&mem->dev.kobj);
+
+	/* only register blocks with all sections present? */
+	if (mem->section_count == sections_per_block)
+		ret = register_mem_sect_under_node(mem, nid);
+
+out:
+	mutex_lock(&mem_sysfs_mutex);
+	return ret;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -671,15 +709,18 @@ static int remove_memory_block(unsigned long node_id,
 			       struct mem_section *section, int phys_device)
 {
 	struct memory_block *mem;
+	int memblock_id;
 
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
 	unregister_mem_sect_under_nodes(mem, __section_nr(section));
 
 	mem->section_count--;
-	if (mem->section_count == 0)
+	if (mem->section_count == 0) {
 		unregister_memory(mem);
-	else
+		memblock_id = base_memory_block_id(__section_nr(section));
+		clear_bit(memblock_id, memblock_present);
+	} else
 		kobject_put(&mem->dev.kobj);
 
 	mutex_unlock(&mem_sysfs_mutex);
@@ -701,6 +742,60 @@ bool is_memblock_offlined(struct memory_block *mem)
 	return mem->state == MEM_OFFLINE;
 }
 
+static ssize_t memory_show_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	unsigned long memblock_id;
+	int ret;
+
+	if (!largememory_enable)
+		/*
+		 * If !largememory_enable then the memblock is sure to
+		 * exist already because it was created at boot time by
+		 * memory_dev_init()
+		 */
+		return 0;
+
+	if (kstrtoul(buf, 10, &memblock_id))
+		return -EINVAL;
+
+	if (memblock_id > base_memory_block_id(NR_MEM_SECTIONS))
+		return -EINVAL;
+
+	if (!test_bit(memblock_id, memblock_present))
+		return -EINVAL;
+
+	dev = subsys_find_device_by_id(&memory_subsys, memblock_id, NULL);
+	if (dev)
+		return 0;
+
+	ret = add_memory_block(memblock_id * sections_per_block);
+	if (ret)
+		return ret;
+
+	return count;
+}
+
+static DEVICE_ATTR(show, S_IWUSR, NULL, memory_show_store);
+
+static ssize_t memory_present_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	int n_bits, ret;
+
+	n_bits = NR_MEM_SECTIONS / sections_per_block;
+	ret = bitmap_scnlistprintf(buf, PAGE_SIZE - 2,
+				memblock_present, n_bits);
+	buf[ret++] = '\n';
+	buf[ret] = '\0';
+
+	return ret;
+}
+
+static DEVICE_ATTR(present, S_IRUSR | S_IRGRP |  S_IROTH,
+			memory_present_show, NULL);
+
 static struct attribute *memory_root_attrs[] = {
 #ifdef CONFIG_ARCH_MEMORY_PROBE
 	&dev_attr_probe.attr,
@@ -712,6 +807,8 @@ static struct attribute *memory_root_attrs[] = {
 #endif
 
 	&dev_attr_block_size_bytes.attr,
+	&dev_attr_show.attr,
+	&dev_attr_present.attr,
 	NULL
 };
 
@@ -724,16 +821,48 @@ static const struct attribute_group *memory_root_attr_groups[] = {
 	NULL,
 };
 
+static int __init largememory_select(char *notused)
+{
+	largememory_enable = 1;
+	return 1;
+}
+__setup("largememory", largememory_select);
+
+static int __init init_memblock_present(int bitfield_size)
+{
+	int i, j;
+
+	/* allocate bitfield for monitoring present memory blocks */
+	memblock_present = kzalloc(bitfield_size, GFP_KERNEL);
+	if (!memblock_present)
+		return -ENOMEM;
+
+	/* for each block */
+	for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block) {
+		/* for each section in the block */
+		for (j = i; j < i + sections_per_block; j++) {
+			/*
+			 * If last least one section is present in a block,
+			 * then the block is considered present.
+			 */
+			if (present_section_nr(i)) {
+				set_bit(base_memory_block_id(i),
+					memblock_present);
+				break;
+			}
+		}
+	}
+
+	return 0;
+}
+
 /*
  * Initialize the sysfs support for memory devices...
  */
 int __init memory_dev_init(void)
 {
-	unsigned int i;
-	int ret;
-	int err;
+	int ret, nr_memblks, bitfield_size, memblock_id;
 	unsigned long block_sz;
-	struct memory_block *mem = NULL;
 
 	ret = subsys_system_register(&memory_subsys, memory_root_attr_groups);
 	if (ret)
@@ -742,22 +871,21 @@ int __init memory_dev_init(void)
 	block_sz = get_memory_block_size();
 	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
 
-	/*
-	 * Create entries for memory sections that were found
-	 * during boot and have been initialized
-	 */
-	for (i = 0; i < NR_MEM_SECTIONS; i++) {
-		if (!present_section_nr(i))
-			continue;
-		/* don't need to reuse memory_block if only one per block */
-		err = add_memory_section(0, __nr_to_section(i),
-				 (sections_per_block == 1) ? NULL : &mem,
-					 MEM_ONLINE,
-					 BOOT);
-		if (!ret)
-			ret = err;
-	}
+	nr_memblks = NR_MEM_SECTIONS / sections_per_block;
+	bitfield_size = BITS_TO_LONGS(nr_memblks) * sizeof(unsigned long);
 
+	ret = init_memblock_present(bitfield_size);
+	if (ret)
+		goto out;
+
+	if (!largememory_enable) {
+		/*
+		 * Create entries for memory sections that were found
+		 * during boot and have been initialized
+		 */
+		for_each_set_bit(memblock_id, memblock_present, bitfield_size)
+			add_memory_block(memblock_id * sections_per_block);
+	}
 out:
 	if (ret)
 		printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 85c31a8..4c89fb0 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -125,7 +125,6 @@ extern struct memory_block *find_memory_block_hinted(struct mem_section *,
 							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
-enum mem_add_context { BOOT, HOTPLUG };
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
