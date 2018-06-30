Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D16D16B0276
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z5-v6so5607119wro.15
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r6-v6si229950wro.401.2018.06.30.07.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:41 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErVIF038674
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:40 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx5rjtn7u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:38 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 10/11] docs/mm: memblock: add overview documentation
Date: Sat, 30 Jun 2018 17:55:05 +0300
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530370506-21751-11-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/memblock.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 3e6be01..084f5f5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -27,6 +27,61 @@
 
 #include "internal.h"
 
+/**
+ * DOC: memblock overview
+ *
+ * Memblock is a method of managing memory regions during the early
+ * boot period when the usual kernel memory allocators are not up and
+ * running.
+ *
+ * Memblock views the system memory as collections of contiguous
+ * regions. There are several types of these collections:
+ *
+ * * ``memory`` - describes the physical memory available to the
+ *   kernel; this may differ from the actual physical memory installed
+ *   in the system, for instance when the memory is restricted with
+ *   ``mem=`` command line parameter
+ * * ``reserved`` - describes the regions that were allocated
+ * * ``physmap`` - describes the actual physical memory regardless of
+ *   the possible restrictions; the ``physmap`` type is only available
+ *   on some architectures.
+ *
+ * Each region is represented by :c:type:`struct memblock_region` that
+ * defines the region extents, its attributes and NUMA node id on NUMA
+ * systems. Every memory type is described by the :c:type:`struct
+ * memblock_type` which contains an array of memory regions along with
+ * the allocator metadata. The memory types are nicely wrapped with
+ * :c:type:`struct memblock`. This structure is statically initialzed
+ * at build time. The region arrays for the "memory" and "reserved"
+ * types are initially sized to %INIT_MEMBLOCK_REGIONS and for the
+ * "physmap" type to %INIT_PHYSMEM_REGIONS.
+ * The :c:func:`memblock_allow_resize` enables automatic resizing of
+ * the region arrays during addition of new regions. This feature
+ * should be used with care so that memory allocated for the region
+ * array will not overlap with areas that should be reserved, for
+ * example initrd.
+ *
+ * The early architecture setup should tell memblock what the physical
+ * memory layout is by using :c:func:`memblock_add` or
+ * :c:func:`memblock_add_node` functions. The first function does not
+ * assign the region to a NUMA node and it is appropriate for UMA
+ * systems. Yet, it is possible to use it on NUMA systems as well and
+ * assign the region to a NUMA node later in the setup process using
+ * :c:func:`memblock_set_node`. The :c:func:`memblock_add_node`
+ * performs such an assignment directly.
+ *
+ * Once memblock is setup the memory can be allocated using either
+ * memblock or bootmem APIs.
+ *
+ * As the system boot progresses, the architecture specific
+ * :c:func:`mem_init` function frees all the memory to the buddy page
+ * allocator.
+ *
+ * If an architecure enables %CONFIG_ARCH_DISCARD_MEMBLOCK, the
+ * memblock data structures will be discarded after the system
+ * initialization compltes.
+ */
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
-- 
2.7.4
