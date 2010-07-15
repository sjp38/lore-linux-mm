Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 70282600921
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:40:46 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6FIOZkE005622
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:24:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6FIefp5081980
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:40:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6FIeftY017015
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:40:41 -0400
Message-ID: <4C3F5628.6030809@austin.ibm.com>
Date: Thu, 15 Jul 2010 13:40:40 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] v2 Update sysfs node routines for new sysfs memory directories
References: <4C3F53D1.3090001@austin.ibm.com>
In-Reply-To: <4C3F53D1.3090001@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Update the node sysfs directory routines that create
links to the memory sysfs directories under each node.
This update makes the node code aware that a memory sysfs
directory can cover multiple memory sections.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 drivers/base/node.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/base/node.c
===================================================================
--- linux-2.6.orig/drivers/base/node.c	2010-07-15 09:54:06.000000000 -0500
+++ linux-2.6/drivers/base/node.c	2010-07-15 09:56:16.000000000 -0500
@@ -346,8 +346,10 @@
 		return -EFAULT;
 	if (!node_online(nid))
 		return 0;
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
+	sect_end_pfn += PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int page_nid;
 
@@ -383,8 +385,10 @@
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
+	sect_end_pfn += PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
