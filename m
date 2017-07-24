Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 366336B039F
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so92600113pgy.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z5si7218791pfd.320.2017.07.24.16.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:49 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 12/23] percpu: increase minimum percpu allocation size and align first regions
Date: Mon, 24 Jul 2017 19:02:09 -0400
Message-ID: <20170724230220.21774-13-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch increases the minimum allocation size of percpu memory to
4-bytes. This change will help minimize the metadata overhead
associated with the bitmap allocator. The assumption is that most
allocations will be of objects or structs greater than 2 bytes with
integers or longs being used rather than shorts.

The first chunk regions are now aligned with the minimum allocation
size. The reserved region is expected to be set as a multiple of the
minimum allocation size. The static region is aligned up and the delta
is removed from the dynamic size. This works because the dynamic size is
increased to be page aligned. If the static size is not minimum
allocation size aligned, then there must be a gap that is added to the
dynamic size. The dynamic size will never be smaller than the set value.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |  4 ++++
 mm/percpu.c            | 27 ++++++++++++++++++++-------
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 491b3f5..90e0cb0 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -21,6 +21,10 @@
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
 
+/* minimum allocation size and shift in bytes */
+#define PCPU_MIN_ALLOC_SHIFT		2
+#define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
+
 /*
  * Percpu allocator can serve percpu allocations before slab is
  * initialized which allows slab to depend on the percpu allocator.
diff --git a/mm/percpu.c b/mm/percpu.c
index 657ab08..dc755721 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -956,10 +956,10 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	 * We want the lowest bit of offset available for in-use/free
 	 * indicator, so force >= 16bit alignment and make size even.
 	 */
-	if (unlikely(align < 2))
-		align = 2;
+	if (unlikely(align < PCPU_MIN_ALLOC_SIZE))
+		align = PCPU_MIN_ALLOC_SIZE;
 
-	size = ALIGN(size, 2);
+	size = ALIGN(size, PCPU_MIN_ALLOC_SIZE);
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
 		     !is_power_of_2(align))) {
@@ -1653,6 +1653,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
+	size_t static_size, dyn_size;
 	struct pcpu_chunk *chunk;
 	unsigned long *group_offsets;
 	size_t *group_sizes;
@@ -1686,6 +1687,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
 	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
 	PCPU_SETUP_BUG_ON(!ai->dyn_size);
+	PCPU_SETUP_BUG_ON(!IS_ALIGNED(ai->reserved_size, PCPU_MIN_ALLOC_SIZE));
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
@@ -1764,6 +1766,17 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
 	/*
+	 * The end of the static region needs to be aligned with the
+	 * minimum allocation size as this offsets the reserved and
+	 * dynamic region.  The first chunk ends page aligned by
+	 * expanding the dynamic region, therefore the dynamic region
+	 * can be shrunk to compensate while still staying above the
+	 * configured sizes.
+	 */
+	static_size = ALIGN(ai->static_size, PCPU_MIN_ALLOC_SIZE);
+	dyn_size = ai->dyn_size - (static_size - ai->static_size);
+
+	/*
 	 * Initialize first chunk.
 	 * If the reserved_size is non-zero, this initializes the reserved
 	 * chunk.  If the reserved_size is zero, the reserved chunk is NULL
@@ -1771,8 +1784,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * pcpu_first_chunk, will always point to the chunk that serves
 	 * the dynamic region.
 	 */
-	tmp_addr = (unsigned long)base_addr + ai->static_size;
-	map_size = ai->reserved_size ?: ai->dyn_size;
+	tmp_addr = (unsigned long)base_addr + static_size;
+	map_size = ai->reserved_size ?: dyn_size;
 	chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, smap,
 				       ARRAY_SIZE(smap));
 
@@ -1780,9 +1793,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	if (ai->reserved_size) {
 		pcpu_reserved_chunk = chunk;
 
-		tmp_addr = (unsigned long)base_addr + ai->static_size +
+		tmp_addr = (unsigned long)base_addr + static_size +
 			   ai->reserved_size;
-		map_size = ai->dyn_size;
+		map_size = dyn_size;
 		chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, dmap,
 					       ARRAY_SIZE(dmap));
 	}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
