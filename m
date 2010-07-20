Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 82C8860080B
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:55:22 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6K3sH29032102
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:54:17 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6K3tBf7134698
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:55:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6K3tAeO006976
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:55:11 -0400
Message-ID: <4C451E1C.8070907@austin.ibm.com>
Date: Mon, 19 Jul 2010 22:55:08 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/8] v3 Allow memory_block to span multiple memory sections
References: <4C451BF5.50304@austin.ibm.com>
In-Reply-To: <4C451BF5.50304@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

Update the memory sysfs code that each sysfs memory directory is now
considered a memory block that can contain multiple memory sections per
memory block.  The default size of each memory block is SECTION_SIZE_BITS
to maintain the current behavior of having a single memory section per
memory block (i.e. one sysfs directory per memory section).

For architectures that want to have memory blocks span multiple
memory sections they need only define their own memory_block_size_bytes()
routine.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 drivers/base/memory.c |  141 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 98 insertions(+), 43 deletions(-)

Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2010-07-19 20:44:01.000000000 -0500
+++ linux-2.6/drivers/base/memory.c	2010-07-19 21:12:22.000000000 -0500
@@ -28,6 +28,14 @@
 #include <asm/uaccess.h>
 
 #define MEMORY_CLASS_NAME	"memory"
+#define MIN_MEMORY_BLOCK_SIZE	(1 << SECTION_SIZE_BITS)
+
+static int sections_per_block;
+
+static inline int base_memory_block_id(int section_nr)
+{
+	return (section_nr / sections_per_block) * sections_per_block;
+}
 
 static struct sysdev_class memory_sysdev_class = {
 	.name = MEMORY_CLASS_NAME,
@@ -82,22 +90,21 @@ EXPORT_SYMBOL(unregister_memory_isolate_
  * register_memory - Setup a sysfs device for a memory block
  */
 static
-int register_memory(struct memory_block *memory, struct mem_section *section)
+int register_memory(struct memory_block *memory)
 {
 	int error;
 
 	memory->sysdev.cls = &memory_sysdev_class;
-	memory->sysdev.id = __section_nr(section);
+	memory->sysdev.id = memory->start_phys_index;
 
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
@@ -131,13 +138,16 @@ static ssize_t show_mem_end_phys_index(s
 static ssize_t show_mem_removable(struct sys_device *dev,
 			struct sysdev_attribute *attr, char *buf)
 {
-	unsigned long start_pfn;
-	int ret;
+	unsigned long i, pfn;
+	int ret = 1;
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, sysdev);
 
-	start_pfn = section_nr_to_pfn(mem->start_phys_index);
-	ret = is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
+	for (i = mem->start_phys_index; i <= mem->end_phys_index; i++) {
+		pfn = section_nr_to_pfn(i);
+		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
+	}
+
 	return sprintf(buf, "%d\n", ret);
 }
 
@@ -190,17 +200,14 @@ int memory_isolate_notify(unsigned long
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
 
-	psection = mem->start_phys_index;
-	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
+	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
 
 	/*
 	 * The probe routines leave the pages reserved, just
@@ -213,8 +220,8 @@ memory_block_action(struct memory_block
 				continue;
 
 			printk(KERN_WARNING "section number %ld page number %d "
-				"not reserved, was it already online? \n",
-				psection, i);
+				"not reserved, was it already online?\n",
+				phys_index, i);
 			return -EBUSY;
 		}
 	}
@@ -225,18 +232,13 @@ memory_block_action(struct memory_block
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
 
@@ -246,7 +248,7 @@ memory_block_action(struct memory_block
 static int memory_block_change_state(struct memory_block *mem,
 		unsigned long to_state, unsigned long from_state_req)
 {
-	int ret = 0;
+	int i, ret = 0;
 	mutex_lock(&mem->state_mutex);
 
 	if (mem->state != from_state_req) {
@@ -254,8 +256,21 @@ static int memory_block_change_state(str
 		goto out;
 	}
 
-	ret = memory_block_action(mem, to_state);
-	if (!ret)
+	if (to_state == MEM_OFFLINE)
+		mem->state = MEM_GOING_OFFLINE;
+
+	for (i = mem->start_phys_index; i <= mem->end_phys_index; i++) {
+		ret = memory_section_action(i, to_state);
+		if (ret)
+			break;
+	}
+
+	if (ret) {
+		for (i = mem->start_phys_index; i <= mem->end_phys_index; i++)
+			memory_section_action(i, from_state_req);
+
+		mem->state = from_state_req;
+	} else
 		mem->state = to_state;
 
 out:
@@ -268,20 +283,15 @@ store_mem_state(struct sys_device *dev,
 		struct sysdev_attribute *attr, const char *buf, size_t count)
 {
 	struct memory_block *mem;
-	unsigned int phys_section_nr;
 	int ret = -EINVAL;
 
 	mem = container_of(dev, struct memory_block, sysdev);
-	phys_section_nr = mem->start_phys_index;
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
@@ -458,12 +468,13 @@ struct memory_block *find_memory_block(s
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
@@ -475,24 +486,26 @@ struct memory_block *find_memory_block(s
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
 	int ret = 0;
 
+	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
-	mem->start_phys_index = __section_nr(section);
+	mem->start_phys_index = base_memory_block_id(__section_nr(section));
+	mem->end_phys_index = mem->start_phys_index + sections_per_block - 1;
 	mem->state = state;
 	atomic_inc(&mem->section_count);
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
-	ret = register_memory(mem, section);
+	ret = register_memory(mem);
 	if (!ret)
 		ret = mem_create_simple_file(mem, start_phys_index);
 	if (!ret)
@@ -503,8 +516,27 @@ static int add_memory_block(int nid, str
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
+	mem = find_memory_block(section);
+	if (mem) {
+		atomic_inc(&mem->section_count);
+		kobject_put(&mem->sysdev.kobj);
+	} else
+		ret = init_memory_block(&mem, section, state);
+
 	if (!ret) {
-		if (context == HOTPLUG)
+		if (context == HOTPLUG &&
+		    atomic_read(&mem->section_count) == sections_per_block)
 			ret = register_mem_sect_under_node(mem, nid);
 	}
 
@@ -526,8 +558,9 @@ int remove_memory_block(unsigned long no
 		mem_remove_simple_file(mem, state);
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
-		unregister_memory(mem, section);
-	}
+		unregister_memory(mem);
+	} else
+		kobject_put(&mem->sysdev.kobj);
 
 	return 0;
 }
@@ -538,7 +571,7 @@ int remove_memory_block(unsigned long no
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	return add_memory_block(nid, section, MEM_OFFLINE, HOTPLUG);
+	return add_memory_section(nid, section, MEM_OFFLINE, HOTPLUG);
 }
 
 int unregister_memory_section(struct mem_section *section)
@@ -549,6 +582,24 @@ int unregister_memory_section(struct mem
 	return remove_memory_block(0, section, 0);
 }
 
+u32 __weak memory_block_size_bytes(void)
+{
+	return MIN_MEMORY_BLOCK_SIZE;
+}
+
+static u32 get_memory_block_size(void)
+{
+	u32 block_sz;
+
+	block_sz = memory_block_size_bytes();
+
+	/* Validate blk_sz is a power of 2 and not less than section size */
+	if ((block_sz & (block_sz - 1)) || (block_sz < MIN_MEMORY_BLOCK_SIZE))
+		block_sz = MIN_MEMORY_BLOCK_SIZE;
+
+	return block_sz;
+}
+
 /*
  * Initialize the sysfs support for memory devices...
  */
@@ -557,12 +608,16 @@ int __init memory_dev_init(void)
 	unsigned int i;
 	int ret;
 	int err;
+	int block_sz;
 
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
@@ -570,8 +625,8 @@ int __init memory_dev_init(void)
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
