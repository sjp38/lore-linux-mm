Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBF06B026C
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t11-v6so558844edq.1
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5-v6si7350927eda.356.2018.06.30.07.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:32 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErVko035217
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:29 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx562u9t0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:29 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:27 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 05/11] docs/mm: bootmem: add overview documentation
Date: Sat, 30 Jun 2018 17:55:00 +0300
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530370506-21751-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/bootmem.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 76fc17e..97db0e8 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -21,6 +21,53 @@
 
 #include "internal.h"
 
+/**
+ * DOC: bootmem overview
+ *
+ * Bootmem is a boot-time physical memory allocator and configurator.
+ *
+ * It is used early in the boot process before the page allocator is
+ * set up.
+ *
+ * Bootmem is based on the most basic of allocators, a First Fit
+ * allocator which uses a bitmap to represent memory. If a bit is 1,
+ * the page is allocated and 0 if unallocated. To satisfy allocations
+ * of sizes smaller than a page, the allocator records the Page Frame
+ * Number (PFN) of the last allocation and the offset the allocation
+ * ended at. Subsequent small allocations are merged together and
+ * stored on the same page.
+ *
+ * The information used by the bootmem allocator is represented by
+ * :c:type:`struct bootmem_data`. An array to hold up to %MAX_NUMNODES
+ * such structures is statically allocated and then it is discarded
+ * when the system initialization completes. Each entry in this array
+ * corresponds to a node with memory. For UMA systems only entry 0 is
+ * used.
+ *
+ * The bootmem allocator is initialized during early architecture
+ * specific setup. Each architecture is required to supply a
+ * :c:func:`setup_arch` function which, among other tasks, is
+ * responsible for acquiring the necessary parameters to initialise
+ * the boot memory allocator. These parameters define limits of usable
+ * physical memory:
+ *
+ * * @min_low_pfn - the lowest PFN that is available in the system
+ * * @max_low_pfn - the highest PFN that may be addressed by low
+ *   memory (%ZONE_NORMAL)
+ * * @max_pfn - the last PFN available to the system.
+ *
+ * After those limits are determined, the :c:func:`init_bootmem` or
+ * :c:func:`init_bootmem_node` function should be called to initialize
+ * the bootmem allocator. The UMA case should use the `init_bootmem`
+ * function. It will initialize ``contig_page_data`` structure that
+ * represents the only memory node in the system. In the NUMA case the
+ * `init_bootmem_node` function should be called to initialize the
+ * bootmem allocator for each node.
+ *
+ * Once the allocator is set up, it is possible to use either single
+ * node or NUMA variant of the allocation APIs.
+ */
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 struct pglist_data __refdata contig_page_data = {
 	.bdata = &bootmem_node_data[0]
-- 
2.7.4
