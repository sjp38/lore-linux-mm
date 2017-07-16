Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E30406B0597
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e199so128952142pfh.7
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d10si719739pgn.405.2017.07.15.19.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:38 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 04/10] percpu: update the header comment and pcpu_build_alloc_info comments
Date: Sat, 15 Jul 2017 22:23:09 -0400
Message-ID: <20170716022315.19892-5-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The header comment for percpu memory is a little hard to parse and is
not super clear about how the first chunk is managed. This adds a
little more clarity to the situation.

There is also quite a bit of tricky logic in the pcpu_build_alloc_info.
This adds a restructure of a comment to add a little more information.
Unfortunately, you will still have to piece together a handful of other
comments too, but should help direct you to the meaningful comments.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 58 ++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 32 insertions(+), 26 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 9ec5fd4..5bb90d8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -4,36 +4,35 @@
  * Copyright (C) 2009		SUSE Linux Products GmbH
  * Copyright (C) 2009		Tejun Heo <tj@kernel.org>
  *
- * This file is released under the GPLv2.
+ * This file is released under the GPLv2 license.
  *
- * This is percpu allocator which can handle both static and dynamic
- * areas.  Percpu areas are allocated in chunks.  Each chunk is
- * consisted of boot-time determined number of units and the first
- * chunk is used for static percpu variables in the kernel image
- * (special boot time alloc/init handling necessary as these areas
- * need to be brought up before allocation services are running).
- * Unit grows as necessary and all units grow or shrink in unison.
- * When a chunk is filled up, another chunk is allocated.
+ * The percpu allocator handles both static and dynamic areas.  Percpu
+ * areas are allocated in chunks which are divided into units.  There is
+ * a 1-to-1 mapping for units to possible cpus.  These units are grouped
+ * based on NUMA properties of the machine.
  *
  *  c0                           c1                         c2
  *  -------------------          -------------------        ------------
  * | u0 | u1 | u2 | u3 |        | u0 | u1 | u2 | u3 |      | u0 | u1 | u
  *  -------------------  ......  -------------------  ....  ------------
+
+ * Allocation is done by offsets into a unit's address space.  Ie., an
+ * area of 512 bytes at 6k in c1 occupies 512 bytes at 6k in c1:u0,
+ * c1:u1, c1:u2, etc.  On NUMA machines, the mapping may be non-linear
+ * and even sparse.  Access is handled by configuring percpu base
+ * registers according to the cpu to unit mappings and offsetting the
+ * base address using pcpu_unit_size.
+ *
+ * There is special consideration for the first chunk which must handle
+ * the static percpu variables in the kernel image as allocation services
+ * are not online yet.  In short, the first chunk is structure like so:
  *
- * Allocation is done in offset-size areas of single unit space.  Ie,
- * an area of 512 bytes at 6k in c1 occupies 512 bytes at 6k of c1:u0,
- * c1:u1, c1:u2 and c1:u3.  On UMA, units corresponds directly to
- * cpus.  On NUMA, the mapping can be non-linear and even sparse.
- * Percpu access can be done by configuring percpu base registers
- * according to cpu to unit mapping and pcpu_unit_size.
- *
- * There are usually many small percpu allocations many of them being
- * as small as 4 bytes.  The allocator organizes chunks into lists
- * according to free size and tries to allocate from the fullest one.
- * Each chunk keeps the maximum contiguous area size hint which is
- * guaranteed to be equal to or larger than the maximum contiguous
- * area in the chunk.  This helps the allocator not to iterate the
- * chunk maps unnecessarily.
+ *                  <Static | [Reserved] | Dynamic>
+ *
+ * The static data is copied from the original section managed by the
+ * linker.  The reserved section, if non-zero, primarily manages static
+ * percpu variables from kernel modules.  Finally, the dynamic section
+ * takes care of normal allocations.
  *
  * Allocation state in each chunk is kept using an array of integers
  * on chunk->map.  A positive value in the map represents a free
@@ -43,6 +42,12 @@
  * Chunks can be determined from the address using the index field
  * in the page struct. The index field contains a pointer to the chunk.
  *
+ * These chunks are organized into lists according to free_size and
+ * tries to allocate from the fullest chunk first. Each chunk maintains
+ * a maximum contiguous area size hint which is guaranteed to be equal
+ * to or larger than the maximum contiguous area in the chunk. This
+ * helps prevent the allocator from iterating over chunks unnecessarily.
+ *
  * To use this allocator, arch code should do the following:
  *
  * - define __addr_to_pcpu_ptr() and __pcpu_ptr_to_addr() to translate
@@ -1842,6 +1847,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	 */
 	min_unit_size = max_t(size_t, size_sum, PCPU_MIN_UNIT_SIZE);
 
+	/* determine the maximum # of units that can fit in an allocation */
 	alloc_size = roundup(min_unit_size, atom_size);
 	upa = alloc_size / min_unit_size;
 	while (alloc_size % upa || (offset_in_page(alloc_size / upa)))
@@ -1868,9 +1874,9 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	}
 
 	/*
-	 * Expand unit size until address space usage goes over 75%
-	 * and then as much as possible without using more address
-	 * space.
+	 * Wasted space is caused by a ratio imbalance of upa to group_cnt.
+	 * Expand the unit_size until we use >= 75% of the units allocated.
+	 * Related to atom_size, which could be much larger than the unit_size.
 	 */
 	last_allocs = INT_MAX;
 	for (upa = max_upa; upa; upa--) {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
