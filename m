Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40AA06B02A4
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:40:03 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6FId0fH014183
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:39:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6FIdw3k1802286
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:39:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6FIdvnb014293
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:39:57 -0400
Message-ID: <4C3F55FC.4050205@austin.ibm.com>
Date: Thu, 15 Jul 2010 13:39:56 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/5] v2 Change the mutex name in the memory_block struct
References: <4C3F53D1.3090001@austin.ibm.com>
In-Reply-To: <4C3F53D1.3090001@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Change the name of the memory_block mutex since it is now used for
more than just gating changes to the status of the memory sections
covered by the memory sysfs directory.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 drivers/base/memory.c  |   20 ++++++++++----------
 include/linux/memory.h |    9 +--------
 2 files changed, 11 insertions(+), 18 deletions(-)

Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2010-07-15 09:56:05.000000000 -0500
+++ linux-2.6/drivers/base/memory.c	2010-07-15 09:56:10.000000000 -0500
@@ -144,14 +144,14 @@
 	int ret = 1;
 
 	mem = container_of(dev, struct memory_block, sysdev);
-	mutex_lock(&mem->state_mutex);
+	mutex_lock(&mem->mutex);
 
 	list_for_each_entry(mbs, &mem->sections, next) {
 		start_pfn = section_nr_to_pfn(mbs->phys_index);
 		ret &= is_mem_section_removable(start_pfn, PAGES_PER_SECTION);
 	}
 
-	mutex_unlock(&mem->state_mutex);
+	mutex_unlock(&mem->mutex);
 	return sprintf(buf, "%d\n", ret);
 }
 
@@ -263,7 +263,7 @@
 	struct memory_block_section *mbs;
 	int ret = 0;
 
-	mutex_lock(&mem->state_mutex);
+	mutex_lock(&mem->mutex);
 
 	list_for_each_entry(mbs, &mem->sections, next) {
 		if (mbs->state != from_state_req)
@@ -288,7 +288,7 @@
 	if (!ret)
 		mem->state = to_state;
 
-	mutex_unlock(&mem->state_mutex);
+	mutex_unlock(&mem->mutex);
 	return ret;
 }
 
@@ -531,12 +531,12 @@
 			return -ENOMEM;
 
 		mem->state = state;
-		mutex_init(&mem->state_mutex);
+		mutex_init(&mem->mutex);
 		start_pfn = section_nr_to_pfn(__section_nr(section));
 		mem->phys_device = arch_get_memory_phys_device(start_pfn);
 		INIT_LIST_HEAD(&mem->sections);
 
-		mutex_lock(&mem->state_mutex);
+		mutex_lock(&mem->mutex);
 
 		ret = register_memory(mem, section);
 		if (!ret)
@@ -555,13 +555,13 @@
 		}
 	} else {
 		kobject_put(&mem->sysdev.kobj);
-		mutex_lock(&mem->state_mutex);
+		mutex_lock(&mem->mutex);
 	}
 
 	if (!ret)
 		ret = add_mem_block_section(mem, __section_nr(section), state);
 
-	mutex_unlock(&mem->state_mutex);
+	mutex_unlock(&mem->mutex);
 	return ret;
 }
 
@@ -573,7 +573,7 @@
 	int section_nr = __section_nr(section);
 
 	mem = find_memory_block(section);
-	mutex_lock(&mem->state_mutex);
+	mutex_lock(&mem->mutex);
 
 	/* remove the specified section */
 	list_for_each_entry_safe(mbs, tmp, &mem->sections, next) {
@@ -583,7 +583,7 @@
 		}
 	}
 
-	mutex_unlock(&mem->state_mutex);
+	mutex_unlock(&mem->mutex);
 
 	if (list_empty(&mem->sections)) {
 		unregister_mem_sect_under_nodes(mem);
Index: linux-2.6/include/linux/memory.h
===================================================================
--- linux-2.6.orig/include/linux/memory.h	2010-07-15 09:56:05.000000000 -0500
+++ linux-2.6/include/linux/memory.h	2010-07-15 09:56:10.000000000 -0500
@@ -31,14 +31,7 @@
 	unsigned long state;
 	unsigned long start_phys_index;
 	unsigned long end_phys_index;
-
-	/*
-	 * This serializes all state change requests.  It isn't
-	 * held during creation because the control files are
-	 * created long after the critical areas during
-	 * initialization.
-	 */
-	struct mutex state_mutex;
+	struct mutex mutex;
 	int phys_device;		/* to which fru does this belong? */
 	void *hw;			/* optional pointer to fw/hw data */
 	int (*phys_callback)(struct memory_block *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
