Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A2A6F6B0078
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:32:01 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91ILIvx020989
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:21:18 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o91IVuI6239700
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:31:56 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91IZgDH016084
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:35:42 -0600
Message-ID: <4CA62917.80008@austin.ibm.com>
Date: Fri, 01 Oct 2010 13:31:51 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/9] v3 Allow memory blocks to span multiple memory sections
References: <4CA62700.7010809@austin.ibm.com>
In-Reply-To: <4CA62700.7010809@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Update the memory sysfs code such that each sysfs memory directory is now
considered a memory block that can span multiple memory sections per
memory block.  The default size of each memory block is SECTION_SIZE_BITS
to maintain the current behavior of having a single memory section per
memory block (i.e. one sysfs directory per memory section).

For architectures that want to have memory blocks span multiple
memory sections they need only define their own memory_block_size_bytes()
routine.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c |  155 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 108 insertions(+), 47 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-30 14:13:50.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-30 14:46:00.000000000 -0500
@@ -30,6 +30,14 @@
 static DEFINE_MUTEX(mem_sysfs_mutex);
 
 #define MEMORY_CLASS_NAME	"memory"
+#define MIN_MEMORY_BLOCK_SIZE	(1 << SECTION_SIZE_BITS)
+
+static int sections_per_block;
+
+static inline int base_memory_block_id(int section_nr)
+{
+	return section_nr / sections_per_block;
+}
 
 static struct sysdev_class memory_sysdev_class = {
 	.name = MEMORY_CLASS_NAME,
@@ -84,28 +92,47 @@
  * register_memory - Setup a sysfs device for a memory block
  */
 static
-int register_memory(struct memory_block *memory, struct mem_section *section)
+int register_memory(struct memory_block *memory)
 {
 	int error;
 
 	memory->sysdev.cls = &memory_sysdev_class;
-	memory->sysdev.id = __section_nr(section);
+	memory->sysdev.id = memory->phys_index / sections_per_block;
 
 	error = sysdev_register(&memory->sysdev);
 	return error;
 }
 
 static void
-unregister_memory(struct memory_block *memory, struct mem_section *section)
+unregister_memory(struct memory_block *memory)
 {
 	BUG_ON(memory->sysdev.cls != &memory_sysdev_class);
-	BUG_ON(memory->sysdev.id != __section_nr(section));
 
 	/* drop the ref. we got in remove_memory_block() */
 	kobject_put(&memory->sysdev.kobj);
 	sysdev_unregister(&memory->sysdev);
 }
 
+unsigned long __weak memory_block_size_bytes(void)
+{
+	return MIN_MEMORY_BLOCK_SIZE;
+}
+
+static unsigned long get_memory_block_size(void)
+{
+	u32 block_sz;
+
+	block_sz = memory_block_size_bytes();
+
+	/* Validate blk_sz is a power of 2 and not less than section size */
+	if ((block_sz & (block_sz - 1)) || (block_sz < MIN_MEMORY_BLOCK_SIZE)) {
+		WARN_ON(1);
+		block_sz = MIN_MEMORY_BLOCK_SIZE;
+	}
+
+	return block_sz;
+}
+
 /*
  * use this as the physical section index that this memsection
  * uses.
@@ -116,7 +143,7 @@
 {
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
-	return sprintf(buf, "%08lx\n", mem->phys_index);
+	return sprintf(buf, "%08lx\n", mem->phys_index / sections_per_block);
 }
 
 /*
@@ -125,13 +152,16 @@
 static ssize_t show_mem_removable(struct sys_device *dev,
 			struct sysdev_attribute *attr, char *buf)
 {
-	unsigned long start_pfn;
-	int ret;
+	unsigned long i, pfn;
+	int ret = 1;
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
 
-	start_pfn = section_nr_to_pfn(mem->phys_index);
-	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
+	for (i = 0; i < sections_per_block; i++) {
+		pfn = section_nr_to_pfn(mem->phys_index + i);
+		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
+	}
+
 	return sprintf(buf, "%d\n", ret);
 }
 
@@ -184,17 +214,14 @@
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(struct memory_block *mem, unsigned long action)
+memory_section_action(unsigned long phys_index, unsigned long action)
 {
 	int i;
-	unsigned long psection;
 	unsigned long start_pfn, start_paddr;
 	struct page *first_page;
 	int ret;
-	int old_state = mem->state;
 
-	psection = mem->phys_index;
-	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
+	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
 
 	/*
 	 * The probe routines leave the pages reserved, just
@@ -207,8 +234,8 @@
 				continue;
 
 			printk(KERN_WARNING "section number %ld page number %d "
-				"not reserved, was it already online? \n",
-				psection, i);
+				"not reserved, was it already online?\n",
+				phys_index, i);
 			return -EBUSY;
 		}
 	}
@@ -219,18 +246,13 @@
 			ret = online_pages(start_pfn, PAGES_PER_SECTION);
 			break;
 		case MEM_OFFLINE:
-			mem->state = MEM_GOING_OFFLINE;
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
 			ret = remove_memory(start_paddr,
 					    PAGES_PER_SECTION << PAGE_SHIFT);
-			if (ret) {
-				mem->state = old_state;
-				break;
-			}
 			break;
 		default:
-			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
-					__func__, mem, action, action);
+			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
+			     "%ld\n", __func__, phys_index, action, action);
 			ret = -EINVAL;
 	}
 
@@ -240,7 +262,8 @@
 static int memory_block_change_state(struct memory_block *mem,
 		unsigned long to_state, unsigned long from_state_req)
 {
-	int ret = 0;
+	int i, ret = 0;
+
 	mutex_lock(&mem->state_mutex);
 
 	if (mem->state != from_state_req) {
@@ -248,8 +271,22 @@
 		goto out;
 	}
 
-	ret = memory_block_action(mem, to_state);
-	if (!ret)
+	if (to_state == MEM_OFFLINE)
+		mem->state = MEM_GOING_OFFLINE;
+
+	for (i = 0; i < sections_per_block; i++) {
+		ret = memory_section_action(mem->phys_index + i, to_state);
+		if (ret)
+			break;
+	}
+
+	if (ret) {
+		for (i = 0; i < sections_per_block; i++)
+			memory_section_action(mem->phys_index + i,
+					      from_state_req);
+
+		mem->state = from_state_req;
+	} else
 		mem->state = to_state;
 
 out:
@@ -262,20 +299,15 @@
 		struct sysdev_attribute *attr, const char *buf, size_t count)
 {
 	struct memory_block *mem;
-	unsigned int phys_section_nr;
 	int ret = -EINVAL;
 
 	mem = container_of(dev, struct memory_block, sysdev);
-	phys_section_nr = mem->phys_index;
-
-	if (!present_section_nr(phys_section_nr))
-		goto out;
 
 	if (!strncmp(buf, "online", min((int)count, 6)))
 		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
 	else if(!strncmp(buf, "offline", min((int)count, 7)))
 		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
-out:
+
 	if (ret)
 		return ret;
 	return count;
@@ -315,7 +347,7 @@
 print_block_size(struct sysdev_class *class, struct sysdev_class_attribute *attr,
 		 char *buf)
 {
-	return sprintf(buf, "%lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
+	return sprintf(buf, "%lx\n", get_memory_block_size());
 }
 
 static SYSDEV_CLASS_ATTR(block_size_bytes, 0444, print_block_size, NULL);
@@ -451,12 +483,13 @@
 	struct sys_device *sysdev;
 	struct memory_block *mem;
 	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
+	int block_id = base_memory_block_id(__section_nr(section));
 
 	/*
 	 * This only works because we know that section == sysdev->id
 	 * slightly redundant with sysdev_register()
 	 */
-	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
+	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, block_id);
 
 	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
 	if (!kobj)
@@ -468,26 +501,27 @@
 	return mem;
 }
 
-static int add_memory_block(int nid, struct mem_section *section,
-			unsigned long state, enum mem_add_context context)
+static int init_memory_block(struct memory_block **memory,
+			     struct mem_section *section, unsigned long state)
 {
-	struct memory_block *mem = kzalloc(sizeof(*mem), GFP_KERNEL);
+	struct memory_block *mem;
 	unsigned long start_pfn;
+	int scn_nr;
 	int ret = 0;
 
+	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
-	mutex_lock(&mem_sysfs_mutex);
-
-	mem->phys_index = __section_nr(section);
+	scn_nr = __section_nr(section);
+	mem->phys_index = base_memory_block_id(scn_nr) * sections_per_block;
 	mem->state = state;
 	mem->section_count++;
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
-	ret = register_memory(mem, section);
+	ret = register_memory(mem);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_index);
 	if (!ret)
@@ -496,8 +530,29 @@
 		ret = mem_create_simple_file(mem, phys_device);
 	if (!ret)
 		ret = mem_create_simple_file(mem, removable);
+
+	*memory = mem;
+	return ret;
+}
+
+static int add_memory_section(int nid, struct mem_section *section,
+			unsigned long state, enum mem_add_context context)
+{
+	struct memory_block *mem;
+	int ret = 0;
+
+	mutex_lock(&mem_sysfs_mutex);
+
+	mem = find_memory_block(section);
+	if (mem) {
+		mem->section_count++;
+		kobject_put(&mem->sysdev.kobj);
+	} else
+		ret = init_memory_block(&mem, section, state);
+
 	if (!ret) {
-		if (context == HOTPLUG)
+		if (context == HOTPLUG &&
+		    mem->section_count == sections_per_block)
 			ret = register_mem_sect_under_node(mem, nid);
 	}
 
@@ -520,8 +575,10 @@
 		mem_remove_simple_file(mem, state);
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
-		unregister_memory(mem, section);
-	}
+		unregister_memory(mem);
+		kfree(mem);
+	} else
+		kobject_put(&mem->sysdev.kobj);
 
 	mutex_unlock(&mem_sysfs_mutex);
 	return 0;
@@ -533,7 +590,7 @@
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	return add_memory_block(nid, section, MEM_OFFLINE, HOTPLUG);
+	return add_memory_section(nid, section, MEM_OFFLINE, HOTPLUG);
 }
 
 int unregister_memory_section(struct mem_section *section)
@@ -552,12 +609,16 @@
 	unsigned int i;
 	int ret;
 	int err;
+	unsigned long block_sz;
 
 	memory_sysdev_class.kset.uevent_ops = &memory_uevent_ops;
 	ret = sysdev_class_register(&memory_sysdev_class);
 	if (ret)
 		goto out;
 
+	block_sz = get_memory_block_size();
+	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
+
 	/*
 	 * Create entries for memory sections that were found
 	 * during boot and have been initialized
@@ -565,8 +626,8 @@
 	for (i = 0; i < NR_MEM_SECTIONS; i++) {
 		if (!present_section_nr(i))
 			continue;
-		err = add_memory_block(0, __nr_to_section(i), MEM_ONLINE,
-				       BOOT);
+		err = add_memory_section(0, __nr_to_section(i), MEM_ONLINE,
+					 BOOT);
 		if (!ret)
 			ret = err;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
