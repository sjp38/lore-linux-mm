Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 014F46B0078
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 10:32:06 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MEOMeP004028
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 08:24:22 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MEW1OY127266
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 08:32:02 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MEW1ob014174
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 08:32:01 -0600
Message-ID: <4C9A1360.6030800@austin.ibm.com>
Date: Wed, 22 Sep 2010 09:32:00 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/8] Add mutex for adding/removing memory blocks
References: <4C9A0F8F.2030409@austin.ibm.com>
In-Reply-To: <4C9A0F8F.2030409@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
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
--- linux-next.orig/drivers/base/memory.c	2010-09-21 12:36:45.000000000 -0500
+++ linux-next/drivers/base/memory.c	2010-09-21 12:37:03.000000000 -0500
@@ -27,6 +27,8 @@
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 
+static DEFINE_MUTEX(mem_sysfs_mutex);
+
 #define MEMORY_CLASS_NAME	"memory"
 
 static struct sysdev_class memory_sysdev_class = {
@@ -485,6 +487,8 @@ static int add_memory_block(int nid, str
 	if (!mem)
 		return -ENOMEM;
 
+	mutex_lock(&mem_sysfs_mutex);
+
 	mem->start_phys_index = __section_nr(section);
 	mem->state = state;
 	atomic_inc(&mem->section_count);
@@ -508,6 +512,7 @@ static int add_memory_block(int nid, str
 			ret = register_mem_sect_under_node(mem, nid);
 	}
 
+	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
 
@@ -516,6 +521,7 @@ int remove_memory_block(unsigned long no
 {
 	struct memory_block *mem;
 
+	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
 
 	if (atomic_dec_and_test(&mem->section_count)) {
@@ -528,6 +534,7 @@ int remove_memory_block(unsigned long no
 		unregister_memory(mem, section);
 	}
 
+	mutex_unlock(&mem_sysfs_mutex);
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
