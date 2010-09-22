Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE4366B004A
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:28:45 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8ME9oT5031106
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:09:51 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MESeH7448892
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:28:40 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MEWJsZ005433
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 08:32:20 -0600
Message-ID: <4C9A1293.4060803@austin.ibm.com>
Date: Wed, 22 Sep 2010 09:28:35 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/8] Move find_memory_block() routine
References: <4C9A0F8F.2030409@austin.ibm.com>
In-Reply-To: <4C9A0F8F.2030409@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Move the find_memory_block() routine up to avoid needing a forward
declaration in subsequent patches.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c |   62 +++++++++++++++++++++++++-------------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-21 11:59:24.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-21 12:32:45.000000000 -0500
@@ -435,6 +435,37 @@ int __weak arch_get_memory_phys_device(u
 	return 0;
 }
 
+/*
+ * For now, we have a linear search to go find the appropriate
+ * memory_block corresponding to a particular phys_index. If
+ * this gets to be a real problem, we can always use a radix
+ * tree or something here.
+ *
+ * This could be made generic for all sysdev classes.
+ */
+struct memory_block *find_memory_block(struct mem_section *section)
+{
+	struct kobject *kobj;
+	struct sys_device *sysdev;
+	struct memory_block *mem;
+	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
+
+	/*
+	 * This only works because we know that section == sysdev->id
+	 * slightly redundant with sysdev_register()
+	 */
+	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
+
+	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
+	if (!kobj)
+		return NULL;
+
+	sysdev = container_of(kobj, struct sys_device, kobj);
+	mem = container_of(sysdev, struct memory_block, sysdev);
+
+	return mem;
+}
+
 static int add_memory_block(int nid, struct mem_section *section,
 			unsigned long state, enum mem_add_context context)
 {
@@ -468,37 +499,6 @@ static int add_memory_block(int nid, str
 	return ret;
 }
 
-/*
- * For now, we have a linear search to go find the appropriate
- * memory_block corresponding to a particular phys_index. If
- * this gets to be a real problem, we can always use a radix
- * tree or something here.
- *
- * This could be made generic for all sysdev classes.
- */
-struct memory_block *find_memory_block(struct mem_section *section)
-{
-	struct kobject *kobj;
-	struct sys_device *sysdev;
-	struct memory_block *mem;
-	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
-
-	/*
-	 * This only works because we know that section == sysdev->id
-	 * slightly redundant with sysdev_register()
-	 */
-	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
-
-	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
-	if (!kobj)
-		return NULL;
-
-	sysdev = container_of(kobj, struct sys_device, kobj);
-	mem = container_of(sysdev, struct memory_block, sysdev);
-
-	return mem;
-}
-
 int remove_memory_block(unsigned long node_id, struct mem_section *section,
 		int phys_device)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
