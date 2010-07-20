Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C09960080B
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 23:54:02 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6K3nPhG019534
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 21:49:25 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6K3s0VF142430
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 21:54:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6K3rx3I024402
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 21:54:00 -0600
Message-ID: <4C451DD6.3080005@austin.ibm.com>
Date: Mon, 19 Jul 2010 22:53:58 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/8] v3 Add section count to memory_block
References: <4C451BF5.50304@austin.ibm.com>
In-Reply-To: <4C451BF5.50304@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

Add a section count property to the memory_block struct to track the number
of memory sections that have been added/removed from a emory block.

Signed-off-by: Nathan Fontenot <nfont@asutin.ibm.com>
---
 drivers/base/memory.c  |   19 ++++++++++++-------
 include/linux/memory.h |    2 ++
 2 files changed, 14 insertions(+), 7 deletions(-)

Index: linux-2.6/drivers/base/memory.c
===================================================================
--- linux-2.6.orig/drivers/base/memory.c	2010-07-19 20:43:49.000000000 -0500
+++ linux-2.6/drivers/base/memory.c	2010-07-19 20:44:01.000000000 -0500
@@ -487,6 +487,7 @@ static int add_memory_block(int nid, str
 
 	mem->start_phys_index = __section_nr(section);
 	mem->state = state;
+	atomic_inc(&mem->section_count);
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_phys_index);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
@@ -516,13 +517,17 @@ int remove_memory_block(unsigned long no
 	struct memory_block *mem;
 
 	mem = find_memory_block(section);
-	unregister_mem_sect_under_nodes(mem);
-	mem_remove_simple_file(mem, start_phys_index);
-	mem_remove_simple_file(mem, end_phys_index);
-	mem_remove_simple_file(mem, state);
-	mem_remove_simple_file(mem, phys_device);
-	mem_remove_simple_file(mem, removable);
-	unregister_memory(mem, section);
+	atomic_dec(&mem->section_count);
+
+	if (atomic_read(&mem->section_count) == 0) {
+		unregister_mem_sect_under_nodes(mem);
+		mem_remove_simple_file(mem, start_phys_index);
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
--- linux-2.6.orig/include/linux/memory.h	2010-07-19 20:43:49.000000000 -0500
+++ linux-2.6/include/linux/memory.h	2010-07-19 20:44:01.000000000 -0500
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
