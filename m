Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id DDC906B0273
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:21 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:20 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DCEC238C804A
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:18 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301JLK300546
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Gf1012600
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:01:18 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 07/31] mm: Add Dynamic NUMA Kconfig.
Date: Thu,  2 May 2013 17:00:39 -0700
Message-Id: <1367539263-19999-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

We need to add some functionality for use by Dynamic NUMA to pieces of
mm/, so provide the Kconfig prior to adding actual Dynamic NUMA
functionality. For details on Dynamic NUMA, see te later patch (which
adds baseline functionality):

 "mm: add memlayout & dnuma to track pfn->nid & transplant pages between nodes"
---
 mm/Kconfig | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index e742d06..bfbe300 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -169,6 +169,30 @@ config MOVABLE_NODE
 config HAVE_BOOTMEM_INFO_NODE
 	def_bool n
 
+config DYNAMIC_NUMA
+	bool "Dynamic Numa: Allow NUMA layout to change after boot time"
+	depends on NUMA
+	depends on !DISCONTIGMEM
+	depends on MEMORY_HOTPLUG # locking + mem_online_node().
+	help
+	 Dynamic Numa (DNUMA) allows the movement of pages between NUMA nodes at
+	 run time.
+
+	 Typically, this is used on systems running under a hypervisor which
+	 may move the running VM based on the hypervisors needs. On such a
+	 system, this config option enables Linux to update it's knowledge of
+	 the memory layout.
+
+	 If the feature is not used but is enabled, there is a very small
+	 amount of overhead (an additional pageflag check) is added to all page frees.
+
+	 This is only useful if you enable some of the additional options to
+	 allow modifications of the numa memory layout (either through hypervisor events
+	 or a userspace interface).
+
+	 Choose Y if you have are running linux under a hypervisor that uses
+	 this feature, otherwise choose N if unsure.
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
