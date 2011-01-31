Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EBBD08D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 11:55:32 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0VGVbOW027226
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 11:31:39 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 064FC728063
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 11:55:25 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VGtO4f392818
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 11:55:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VGtOZn025469
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 11:55:24 -0500
Message-ID: <4D46E97B.4060604@austin.ibm.com>
Date: Mon, 31 Jan 2011 10:55:23 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] sysfs probe routine should add all memory sections
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg KH <greg@kroah.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

As a follow-on to the recent patches I submitted that allowed for a sysfs
memory block to span multiple memory sections, we should also update the
probe routine to online all of the memory sections in a memory block.  Without
this patch the current code will only add a single memory section.  I think
the probe routine should add all of the memory sections in the specified memory
block so that its behavior is in line with memory hotplug actions through
the sysfs interfaces.

This patch applies on top of the previous sysfs memory updates to allow
a sysfs directory o span multiple memory sections.

https://lkml.org/lkml/2011/1/20/245

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 drivers/base/memory.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

Index: linux-next/drivers/base/memory.c
===================================================================
--- linux-next.orig/drivers/base/memory.c	2011-01-28 14:14:20.000000000 -0600
+++ linux-next/drivers/base/memory.c	2011-01-31 09:10:11.000000000 -0600
@@ -387,12 +387,19 @@ memory_probe_store(struct class *class,
 {
 	u64 phys_addr;
 	int nid;
-	int ret;
+	int i, ret;
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
-	nid = memory_add_physaddr_to_nid(phys_addr);
-	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	for (i = 0; i < sections_per_block; i++) {
+		nid = memory_add_physaddr_to_nid(phys_addr);
+		ret = add_memory(nid, phys_addr,
+				 PAGES_PER_SECTION << PAGE_SHIFT);
+		if (ret)
+			break;
+
+		phys_addr += MIN_MEMORY_BLOCK_SIZE;
+	}
 
 	if (ret)
 		count = ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
