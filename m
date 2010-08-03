Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B45F620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:30:34 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o73DX8XB020560
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:33:08 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73Dcgnw1843354
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:38:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o73DcfRO002595
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:38:42 -0400
Message-ID: <4C581BDD.1040601@austin.ibm.com>
Date: Tue, 03 Aug 2010 08:38:37 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/9] v4  Add section count to memory_block
References: <4C581A6D.9030908@austin.ibm.com>
In-Reply-To: <4C581A6D.9030908@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Add a section count property to the memory_block struct to track the number
of memory sections that have been added/removed from a memory block. This
allows us to know when the last memory section of a memory block has been
removed so we can remove the memory block.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 drivers/base/memory.c  |   18 +++++++++++-------
 include/linux/memory.h |    2 ++
 2 files changed, 13 insertions(+), 7 deletions(-)

Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2010-08-02 13:33:27.000000000 -0500
+++ linux-2.6/drivers/base/memory.c	2010-08-02 13:35:00.000000000 -0500
@@ -487,6 +487,7 @@ static int add_memory_block(int nid, str
 
 	mem->start_phys_index = __section_nr(section);
 	mem->state = state;
+	atomic_inc(&mem->section_count);
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
@@ -516,13 +517,16 @@ int remove_memory_block(unsigned long no
 	struct memory_block *mem;
 
 	mem = find_memory_block(section);
-	unregister_mem_sect_under_nodes(mem);
-	mem_remove_simple_file(mem, phys_index);
-	mem_remove_simple_file(mem, end_phys_index);
-	mem_remove_simple_file(mem, state);
-	mem_remove_simple_file(mem, phys_device);
-	mem_remove_simple_file(mem, removable);
-	unregister_memory(mem, section);
+
+	if (atomic_dec_and_test(&mem->section_count)) {
+		unregister_mem_sect_under_nodes(mem);
+		mem_remove_simple_file(mem, phys_index);
+		mem_remove_simple_file(mem, end_phys_index);
+		mem_remove_simple_file(mem, state);
+		mem_remove_simple_file(mem, phys_device);
+		mem_remove_simple_file(mem, removable);
+		unregister_memory(mem, section);
+	}
 
 	return 0;
 }
Index: linux-2.6/include/linux/memory.h
===================================================================
--- linux-2.6.orig/include/linux/memory.h	2010-08-02 13:33:27.000000000 -0500
+++ linux-2.6/include/linux/memory.h	2010-08-02 13:35:00.000000000 -0500
@@ -19,11 +19,13 @@
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/mutex.h>
+#include <asm/atomic.h>
 
 struct memory_block {
 	unsigned long start_phys_index;
 	unsigned long end_phys_index;
 	unsigned long state;
+	atomic_t section_count;
 	/*
 	 * This serializes all state change requests.  It isn't
 	 * held during creation because the control files are

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
