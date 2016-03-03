Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 20857828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:26:28 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id m184so45040601iof.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:26:28 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0026.hostedemail.com. [216.40.44.26])
        by mx.google.com with ESMTPS id i12si635709igt.72.2016.03.03.15.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 15:26:27 -0800 (PST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] mm: percpu: Use pr_fmt to prefix output
Date: Thu,  3 Mar 2016 15:25:34 -0800
Message-Id: <ddb59cbebc26211964c1e45d3d4251d76ae851ab.1457047399.git.joe@perches.com>
In-Reply-To: <cover.1457047399.git.joe@perches.com>
References: <cover.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use the normal mechanism to make the logging output consistently
"percpu: " instead of a mix of "PERCPU: " and "percpu: "

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/percpu-km.c |  4 ++--
 mm/percpu.c    | 20 +++++++++++---------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 0db94b7..d66911f 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -95,7 +95,7 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai)
 
 	/* all units must be in a single group */
 	if (ai->nr_groups != 1) {
-		pr_crit("percpu: can't handle more than one groups\n");
+		pr_crit("can't handle more than one group\n");
 		return -EINVAL;
 	}
 
@@ -103,7 +103,7 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai)
 	alloc_pages = roundup_pow_of_two(nr_pages);
 
 	if (alloc_pages > nr_pages)
-		pr_warn("percpu: wasting %zu pages per chunk\n",
+		pr_warn("wasting %zu pages per chunk\n",
 			alloc_pages - nr_pages);
 
 	return 0;
diff --git a/mm/percpu.c b/mm/percpu.c
index c987fd4..0c59684 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -53,6 +53,8 @@
  *   setup the first chunk containing the kernel static percpu area
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/bitmap.h>
 #include <linux/bootmem.h>
 #include <linux/err.h>
@@ -1033,11 +1035,11 @@ fail_unlock:
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 fail:
 	if (!is_atomic && warn_limit) {
-		pr_warn("PERCPU: allocation failed, size=%zu align=%zu atomic=%d, %s\n",
+		pr_warn("allocation failed, size=%zu align=%zu atomic=%d, %s\n",
 			size, align, is_atomic, err);
 		dump_stack();
 		if (!--warn_limit)
-			pr_info("PERCPU: limit reached, disable warning\n");
+			pr_info("limit reached, disable warning\n");
 	}
 	if (is_atomic) {
 		/* see the flag handling in pcpu_blance_workfn() */
@@ -1538,8 +1540,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
-		pr_emerg("PERCPU: failed to initialize, %s", #cond);	\
-		pr_emerg("PERCPU: cpu_possible_mask=%*pb\n",		\
+		pr_emerg("failed to initialize, %s\n", #cond);		\
+		pr_emerg("cpu_possible_mask=%*pb\n",			\
 			 cpumask_pr_args(cpu_possible_mask));		\
 		pcpu_dump_alloc_info(KERN_EMERG, ai);			\
 		BUG();							\
@@ -1723,7 +1725,7 @@ static int __init percpu_alloc_setup(char *str)
 		pcpu_chosen_fc = PCPU_FC_PAGE;
 #endif
 	else
-		pr_warn("PERCPU: unknown allocator %s specified\n", str);
+		pr_warn("unknown allocator %s specified\n", str);
 
 	return 0;
 }
@@ -2016,7 +2018,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 
 	/* warn if maximum distance is further than 75% of vmalloc space */
 	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
-		pr_warn("PERCPU: max_distance=0x%zx too large for vmalloc space 0x%lx\n",
+		pr_warn("max_distance=0x%zx too large for vmalloc space 0x%lx\n",
 			max_distance, VMALLOC_TOTAL);
 #ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
 		/* and fail if we have fallback */
@@ -2025,7 +2027,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 #endif
 	}
 
-	pr_info("PERCPU: Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
+	pr_info("Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
 		PFN_DOWN(size_sum), base, ai->static_size, ai->reserved_size,
 		ai->dyn_size, ai->unit_size);
 
@@ -2099,7 +2101,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 
 			ptr = alloc_fn(cpu, PAGE_SIZE, PAGE_SIZE);
 			if (!ptr) {
-				pr_warn("PERCPU: failed to allocate %s page for cpu%u\n",
+				pr_warn("failed to allocate %s page for cpu%u\n",
 					psize_str, cpu);
 				goto enomem;
 			}
@@ -2139,7 +2141,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	}
 
 	/* we're ready, commit */
-	pr_info("PERCPU: %d %s pages/cpu @%p s%zu r%zu d%zu\n",
+	pr_info("%d %s pages/cpu @%p s%zu r%zu d%zu\n",
 		unit_pages, psize_str, vm.addr, ai->static_size,
 		ai->reserved_size, ai->dyn_size);
 
-- 
2.6.3.368.gf34be46

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
