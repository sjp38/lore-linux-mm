Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 114ED6B0598
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z1so135202026pgs.10
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e127si9898132pgc.44.2017.07.15.19.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:39 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 05/10] percpu: change reserved_size to end page aligned
Date: Sat, 15 Jul 2017 22:23:10 -0400
Message-ID: <20170716022315.19892-6-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Preparatory patch to modify the first chunk's static_size +
reserved_size to end page aligned. The first chunk has a unique
allocation scheme overlaying the static, reserved, and dynamic regions.
The other regions of each chunk are reserved or hidden. The bitmap
allocator would have to allocate in the bitmap the static region to
replicate this. By having the reserved region to end page aligned, the
metadata overhead can be saved. The consequence is that up to an
additional page of memory will be allocated to the reserved region that
primarily serves static percpu variables.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 arch/ia64/mm/contig.c    |  3 ++-
 arch/ia64/mm/discontig.c |  3 ++-
 include/linux/percpu.h   | 29 +++++++++++++++++++++++++++++
 mm/percpu.c              |  6 ++++++
 4 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 52715a7..20ee2b2 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -164,7 +164,8 @@ setup_per_cpu_areas(void)
 
 	/* set parameters */
 	static_size = __per_cpu_end - __per_cpu_start;
-	reserved_size = PERCPU_MODULE_RESERVE;
+	reserved_size = pcpu_align_reserved_region(static_size,
+						   PERCPU_MODULE_RESERVE);
 	dyn_size = PERCPU_PAGE_SIZE - static_size - reserved_size;
 	if (dyn_size < 0)
 		panic("percpu area overflow static=%zd reserved=%zd\n",
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 8786268..f898b24 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -214,7 +214,8 @@ void __init setup_per_cpu_areas(void)
 
 	/* set basic parameters */
 	static_size = __per_cpu_end - __per_cpu_start;
-	reserved_size = PERCPU_MODULE_RESERVE;
+	reserved_size = pcpu_align_reserved_region(static_size,
+						   PERCPU_MODULE_RSERVE);
 	dyn_size = PERCPU_PAGE_SIZE - static_size - reserved_size;
 	if (dyn_size < 0)
 		panic("percpu area overflow static=%zd reserved=%zd\n",
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 491b3f5..98a371c 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -130,4 +130,33 @@ extern phys_addr_t per_cpu_ptr_to_phys(void *addr);
 	(typeof(type) __percpu *)__alloc_percpu(sizeof(type),		\
 						__alignof__(type))
 
+/*
+ * pcpu_align_reserved_region - page align the end of the reserved region
+ * @static_size: the static region size
+ * @reserved_size: the minimum reserved region size
+ *
+ * This function calculates the size of the reserved region required to
+ * make the reserved region end page aligned.
+ *
+ * Percpu memory offers a maximum alignment of PAGE_SIZE.  Aligning this
+ * minimizes the metadata overhead of overlapping the static, reserved,
+ * and dynamic regions by allowing the metadata for the static region to
+ * not be allocated.  This lets the base_addr be moved up to a page
+ * aligned address and disregard the static region as offsets are allocated.
+ * The beginning of the reserved region will overlap with the static
+ * region if the end of the static region is not page aligned.
+ *
+ * RETURNS:
+ * Size of reserved region required to make static_size + reserved_size
+ * page aligned.
+ */
+static inline ssize_t pcpu_align_reserved_region(ssize_t static_size,
+						 ssize_t reserved_size)
+{
+	if (!reserved_size)
+		return 0;
+
+	return PFN_ALIGN(static_size + reserved_size) - static_size;
+}
+
 #endif /* __LINUX_PERCPU_H */
diff --git a/mm/percpu.c b/mm/percpu.c
index 5bb90d8..7704db9 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1597,6 +1597,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(ai->unit_size < size_sum);
 	PCPU_SETUP_BUG_ON(offset_in_page(ai->unit_size));
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
+	PCPU_SETUP_BUG_ON(ai->reserved_size &&
+			  !PAGE_ALIGNED(ai->static_size + ai->reserved_size));
 	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
@@ -1800,6 +1802,9 @@ early_param("percpu_alloc", percpu_alloc_setup);
  * @atom_size: allocation atom size
  * @cpu_distance_fn: callback to determine distance between cpus, optional
  *
+ * If there is a @reserved_size, it is expanded to ensure the end of the
+ * reserved region is page aligned.
+ *
  * This function determines grouping of units, their mappings to cpus
  * and other parameters considering needed percpu size, allocation
  * atom size and distances between CPUs.
@@ -1835,6 +1840,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	memset(group_cnt, 0, sizeof(group_cnt));
 
 	/* calculate size_sum and ensure dyn_size is enough for early alloc */
+	reserved_size = pcpu_align_reserved_region(static_size, reserved_size);
 	size_sum = PFN_ALIGN(static_size + reserved_size +
 			    max_t(size_t, dyn_size, PERCPU_DYNAMIC_EARLY_SIZE));
 	dyn_size = size_sum - static_size - reserved_size;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
