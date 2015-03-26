Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AEB266B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:53:52 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so15654858pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:53:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id d2si8919700pbu.67.2015.03.26.08.53.39
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 08:53:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: handle errors in hugepage_init() properly
Date: Thu, 26 Mar 2015 17:52:40 +0200
Message-Id: <1427385160-74036-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

We miss error-handling in few cases hugepage_init(). Let's fix that.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3f1504322187..a1594b18bc1b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -67,6 +67,7 @@ static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
+static void khugepaged_slab_exit(void);
 
 #define MM_SLOTS_HASH_BITS 10
 static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
@@ -634,13 +635,15 @@ static int __init hugepage_init(void)
 
 	err = hugepage_init_sysfs(&hugepage_kobj);
 	if (err)
-		return err;
+		goto err_sysfs;
 
 	err = khugepaged_slab_init();
 	if (err)
-		goto out;
+		goto err_slab;
 
-	register_shrinker(&huge_zero_page_shrinker);
+	err = register_shrinker(&huge_zero_page_shrinker);
+	if (err)
+		goto err_hzp_shrinker;
 
 	/*
 	 * By default disable transparent hugepages on smaller systems,
@@ -650,11 +653,18 @@ static int __init hugepage_init(void)
 	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
 		transparent_hugepage_flags = 0;
 
-	start_khugepaged();
+	err = start_khugepaged();
+	if (err)
+		goto err_khugepaged;
 
 	return 0;
-out:
+err_khugepaged:
+	unregister_shrinker(&huge_zero_page_shrinker);
+err_hzp_shrinker:
+	khugepaged_slab_exit();
+err_slab:
 	hugepage_exit_sysfs(hugepage_kobj);
+err_sysfs:
 	return err;
 }
 subsys_initcall(hugepage_init);
@@ -2009,6 +2019,11 @@ static int __init khugepaged_slab_init(void)
 	return 0;
 }
 
+static void __init khugepaged_slab_exit(void)
+{
+	kmem_cache_destroy(mm_slot_cache);
+}
+
 static inline struct mm_slot *alloc_mm_slot(void)
 {
 	if (!mm_slot_cache)	/* initialization failed */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
