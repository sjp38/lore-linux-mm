Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BHKNdx001570
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 12:20:23 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BHKLVI110080
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 10:20:22 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BHKKC3011951
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 10:20:20 -0700
Subject: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Mon, 11 Feb 2008 09:23:18 -0800
Message-Id: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Greg KH <greg@kroah.com>, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

While testing hotplug memory remove against -mm, I noticed
that unregister_memory() is not cleaning up /sysfs entries
correctly. It also de-references structures after destroying
them (luckily in the code which never gets used). So, I cleaned
up the code and fixed the extra reference issue.

Could you please include it in -mm ?

Thanks,
Badari

register_memory()/unregister_memory() never gets called with
"root". unregister_memory() is accessing kobject_name of
the object just freed up. Since no one uses the code,
lets take the code out. And also, make register_memory() static.  

Another bug fix - before calling unregister_memory()
remove_memory_block() gets a ref on kobject. unregister_memory()
need to drop that ref before calling sysdev_unregister().

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 drivers/base/memory.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

Index: linux-2.6.24/drivers/base/memory.c
===================================================================
--- linux-2.6.24.orig/drivers/base/memory.c	2008-02-07 16:59:52.000000000 -0800
+++ linux-2.6.24/drivers/base/memory.c	2008-02-08 15:54:45.000000000 -0800
@@ -62,8 +62,8 @@ void unregister_memory_notifier(struct n
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
-int register_memory(struct memory_block *memory, struct mem_section *section,
-		struct node *root)
+static
+int register_memory(struct memory_block *memory, struct mem_section *section)
 {
 	int error;
 
@@ -71,26 +71,18 @@ int register_memory(struct memory_block 
 	memory->sysdev.id = __section_nr(section);
 
 	error = sysdev_register(&memory->sysdev);
-
-	if (root && !error)
-		error = sysfs_create_link(&root->sysdev.kobj,
-					  &memory->sysdev.kobj,
-					  kobject_name(&memory->sysdev.kobj));
-
 	return error;
 }
 
 static void
-unregister_memory(struct memory_block *memory, struct mem_section *section,
-		struct node *root)
+unregister_memory(struct memory_block *memory, struct mem_section *section)
 {
 	BUG_ON(memory->sysdev.cls != &memory_sysdev_class);
 	BUG_ON(memory->sysdev.id != __section_nr(section));
 
+	/* drop the ref. we got in remove_memory_block() */
+	kobject_put(&memory->sysdev.kobj);
 	sysdev_unregister(&memory->sysdev);
-	if (root)
-		sysfs_remove_link(&root->sysdev.kobj,
-				  kobject_name(&memory->sysdev.kobj));
 }
 
 /*
@@ -361,7 +353,7 @@ static int add_memory_block(unsigned lon
 	mutex_init(&mem->state_mutex);
 	mem->phys_device = phys_device;
 
-	ret = register_memory(mem, section, NULL);
+	ret = register_memory(mem, section);
 	if (!ret)
 		ret = mem_create_simple_file(mem, phys_index);
 	if (!ret)
@@ -415,7 +407,7 @@ int remove_memory_block(unsigned long no
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
 	mem_remove_simple_file(mem, removable);
-	unregister_memory(mem, section, NULL);
+	unregister_memory(mem, section);
 
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
