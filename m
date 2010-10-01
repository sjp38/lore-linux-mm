Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24B696B0078
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:29:50 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91IE41Z011731
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 14:14:04 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o91ITkY0131688
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 14:29:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91ITicB023116
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 14:29:45 -0400
Message-ID: <4CA62896.2060307@austin.ibm.com>
Date: Fri, 01 Oct 2010 13:29:42 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/9] v3 Add mutex for adding/removing memory blocks
References: <4CA62700.7010809@austin.ibm.com>
In-Reply-To: <4CA62700.7010809@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Add a new mutex for use in adding and removing of memory blocks.  This
is needed to avoid any race conditions in which the same memory block could
be added and removed at the same time.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 drivers/base/memory.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2010-09-30 14:09:36.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-30 14:12:41.000000000 -0500
@@ -27,6 +27,8 @@
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 
+static DEFINE_MUTEX(mem_sysfs_mutex);
+
 #define MEMORY_CLASS_NAME	"memory"
 
 static struct sysdev_class memory_sysdev_class = {
@@ -476,6 +478,8 @@
 	if (!mem)
 		return -ENOMEM;
 
+	mutex_lock(&mem_sysfs_mutex);
+
 	mem->phys_index = __section_nr(section);
 	mem->state = state;
 	mutex_init(&mem->state_mutex);
@@ -496,6 +500,7 @@
 			ret = register_mem_sect_under_node(mem, nid);
 	}
 
+	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
 
@@ -504,6 +509,7 @@
 {
 	struct memory_block *mem;
 
+	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
 	unregister_mem_sect_under_nodes(mem);
 	mem_remove_simple_file(mem, phys_index);
@@ -512,6 +518,7 @@
 	mem_remove_simple_file(mem, removable);
 	unregister_memory(mem, section);
 
+	mutex_unlock(&mem_sysfs_mutex);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
