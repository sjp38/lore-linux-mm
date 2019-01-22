Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] mm: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:13 +0100
Message-Id: <20190122152151.16139-14-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/cma_debug.c     |  2 --
 mm/failslab.c      | 14 ++++----------
 mm/gup_benchmark.c |  8 ++------
 mm/huge_memory.c   |  8 ++------
 mm/memblock.c      |  3 +--
 mm/memory.c        |  8 ++------
 mm/page_alloc.c    | 22 ++++++----------------
 mm/page_owner.c    |  8 +++-----
 mm/vmstat.c        | 15 ++++-----------
 9 files changed, 24 insertions(+), 64 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index ad6723e9d110..b55f28fbe831 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -191,8 +191,6 @@ static int __init cma_debugfs_init(void)
 	int i;
 
 	cma_debugfs_root = debugfs_create_dir("cma", NULL);
-	if (!cma_debugfs_root)
-		return -ENOMEM;
 
 	for (i = 0; i < cma_area_count; i++)
 		cma_debugfs_add_one(&cma_areas[i], i);
diff --git a/mm/failslab.c b/mm/failslab.c
index b135ebb88b6f..ec5aad211c5b 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -48,18 +48,12 @@ static int __init failslab_debugfs_init(void)
 	if (IS_ERR(dir))
 		return PTR_ERR(dir);
 
-	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				&failslab.ignore_gfp_reclaim))
-		goto fail;
-	if (!debugfs_create_bool("cache-filter", mode, dir,
-				&failslab.cache_filter))
-		goto fail;
+	debugfs_create_bool("ignore-gfp-wait", mode, dir,
+			    &failslab.ignore_gfp_reclaim);
+	debugfs_create_bool("cache-filter", mode, dir,
+			    &failslab.cache_filter);
 
 	return 0;
-fail:
-	debugfs_remove_recursive(dir);
-
-	return -ENOMEM;
 }
 
 late_initcall(failslab_debugfs_init);
diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 5b42d3d4b60a..6c0279e70cc4 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -122,12 +122,8 @@ static const struct file_operations gup_benchmark_fops = {
 
 static int gup_benchmark_init(void)
 {
-	void *ret;
-
-	ret = debugfs_create_file_unsafe("gup_benchmark", 0600, NULL, NULL,
-			&gup_benchmark_fops);
-	if (!ret)
-		pr_warn("Failed to create gup_benchmark in debugfs");
+	debugfs_create_file_unsafe("gup_benchmark", 0600, NULL, NULL,
+				   &gup_benchmark_fops);
 
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf357eaf0ce..94f05e3fff71 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2886,12 +2886,8 @@ DEFINE_SIMPLE_ATTRIBUTE(split_huge_pages_fops, NULL, split_huge_pages_set,
 
 static int __init split_huge_pages_debugfs(void)
 {
-	void *ret;
-
-	ret = debugfs_create_file("split_huge_pages", 0200, NULL, NULL,
-			&split_huge_pages_fops);
-	if (!ret)
-		pr_warn("Failed to create split_huge_pages in debugfs");
+	debugfs_create_file("split_huge_pages", 0200, NULL, NULL,
+			    &split_huge_pages_fops);
 	return 0;
 }
 late_initcall(split_huge_pages_debugfs);
diff --git a/mm/memblock.c b/mm/memblock.c
index 022d4cbb3618..18ee657fb918 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1998,8 +1998,7 @@ DEFINE_SHOW_ATTRIBUTE(memblock_debug);
 static int __init memblock_init_debugfs(void)
 {
 	struct dentry *root = debugfs_create_dir("memblock", NULL);
-	if (!root)
-		return -ENXIO;
+
 	debugfs_create_file("memory", 0444, root,
 			    &memblock.memory, &memblock_debug_fops);
 	debugfs_create_file("reserved", 0444, root,
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..5009ad9e1d09 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3321,12 +3321,8 @@ DEFINE_DEBUGFS_ATTRIBUTE(fault_around_bytes_fops,
 
 static int __init fault_around_debugfs(void)
 {
-	void *ret;
-
-	ret = debugfs_create_file_unsafe("fault_around_bytes", 0644, NULL, NULL,
-			&fault_around_bytes_fops);
-	if (!ret)
-		pr_warn("Failed to create fault_around_bytes in debugfs");
+	debugfs_create_file_unsafe("fault_around_bytes", 0644, NULL, NULL,
+				   &fault_around_bytes_fops);
 	return 0;
 }
 late_initcall(fault_around_debugfs);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..df33311eb1a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3161,24 +3161,14 @@ static int __init fail_page_alloc_debugfs(void)
 
 	dir = fault_create_debugfs_attr("fail_page_alloc", NULL,
 					&fail_page_alloc.attr);
-	if (IS_ERR(dir))
-		return PTR_ERR(dir);
-
-	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				&fail_page_alloc.ignore_gfp_reclaim))
-		goto fail;
-	if (!debugfs_create_bool("ignore-gfp-highmem", mode, dir,
-				&fail_page_alloc.ignore_gfp_highmem))
-		goto fail;
-	if (!debugfs_create_u32("min-order", mode, dir,
-				&fail_page_alloc.min_order))
-		goto fail;
 
-	return 0;
-fail:
-	debugfs_remove_recursive(dir);
+	debugfs_create_bool("ignore-gfp-wait", mode, dir,
+			    &fail_page_alloc.ignore_gfp_reclaim);
+	debugfs_create_bool("ignore-gfp-highmem", mode, dir,
+			    &fail_page_alloc.ignore_gfp_highmem);
+	debugfs_create_u32("min-order", mode, dir, &fail_page_alloc.min_order);
 
-	return -ENOMEM;
+	return 0;
 }
 
 late_initcall(fail_page_alloc_debugfs);
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 28b06524939f..925b6f44a444 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -625,16 +625,14 @@ static const struct file_operations proc_page_owner_operations = {
 
 static int __init pageowner_init(void)
 {
-	struct dentry *dentry;
-
 	if (!static_branch_unlikely(&page_owner_inited)) {
 		pr_info("page_owner is disabled\n");
 		return 0;
 	}
 
-	dentry = debugfs_create_file("page_owner", 0400, NULL,
-				     NULL, &proc_page_owner_operations);
+	debugfs_create_file("page_owner", 0400, NULL, NULL,
+			    &proc_page_owner_operations);
 
-	return PTR_ERR_OR_ZERO(dentry);
+	return 0;
 }
 late_initcall(pageowner_init)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 83b30edc2f7f..36b56f858f0f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -2121,21 +2121,14 @@ static int __init extfrag_debug_init(void)
 	struct dentry *extfrag_debug_root;
 
 	extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
-	if (!extfrag_debug_root)
-		return -ENOMEM;
 
-	if (!debugfs_create_file("unusable_index", 0444,
-			extfrag_debug_root, NULL, &unusable_file_ops))
-		goto fail;
+	debugfs_create_file("unusable_index", 0444, extfrag_debug_root, NULL,
+			    &unusable_file_ops);
 
-	if (!debugfs_create_file("extfrag_index", 0444,
-			extfrag_debug_root, NULL, &extfrag_file_ops))
-		goto fail;
+	debugfs_create_file("extfrag_index", 0444, extfrag_debug_root, NULL,
+			    &extfrag_file_ops);
 
 	return 0;
-fail:
-	debugfs_remove_recursive(extfrag_debug_root);
-	return -ENOMEM;
 }
 
 module_init(extfrag_debug_init);
-- 
2.20.1
