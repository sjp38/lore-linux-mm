Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF996B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:38:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j4so2068912wrg.11
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:38:41 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id u62si1027759wma.135.2018.03.14.07.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 07:38:40 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 09/16] mm: remove blackfin MPU support
Date: Wed, 14 Mar 2018 15:37:38 +0100
Message-Id: <20180314143755.1508262-2-arnd@arndb.de>
In-Reply-To: <20180314143755.1508262-1-arnd@arndb.de>
References: <20180314143755.1508262-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Jessica Yu <jeyu@kernel.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Jeremy Linton <jeremy.linton@arm.com>, linux-mm@kvack.org

The CONFIG_MPU option was only defined on blackfin, and that architecture
is now being removed, so the respective code can be simplified.

A lot of other microcontrollers have an MPU, but I suspect that if we
want to bring that support back, we'd do it differently anyway.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 kernel/module.c |  4 ----
 mm/nommu.c      | 20 --------------------
 2 files changed, 24 deletions(-)

diff --git a/kernel/module.c b/kernel/module.c
index ad2d420024f6..2c1df850029b 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2181,10 +2181,6 @@ static void free_module(struct module *mod)
 	/* Finally, free the core (containing the module structure) */
 	disable_ro_nx(&mod->core_layout);
 	module_memfree(mod->core_layout.base);
-
-#ifdef CONFIG_MPU
-	update_protections(current->mm);
-#endif
 }
 
 void *__symbol_get(const char *symbol)
diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e618dade..838a8fdec5c2 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -663,22 +663,6 @@ static void put_nommu_region(struct vm_region *region)
 }
 
 /*
- * update protection on a vma
- */
-static void protect_vma(struct vm_area_struct *vma, unsigned long flags)
-{
-#ifdef CONFIG_MPU
-	struct mm_struct *mm = vma->vm_mm;
-	long start = vma->vm_start & PAGE_MASK;
-	while (start < vma->vm_end) {
-		protect_page(mm, start, flags);
-		start += PAGE_SIZE;
-	}
-	update_protections(mm);
-#endif
-}
-
-/*
  * add a VMA into a process's mm_struct in the appropriate place in the list
  * and tree and add to the address space's page tree also if not an anonymous
  * page
@@ -695,8 +679,6 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	mm->map_count++;
 	vma->vm_mm = mm;
 
-	protect_vma(vma, vma->vm_flags);
-
 	/* add the VMA to the mapping */
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
@@ -757,8 +739,6 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	struct mm_struct *mm = vma->vm_mm;
 	struct task_struct *curr = current;
 
-	protect_vma(vma, 0);
-
 	mm->map_count--;
 	for (i = 0; i < VMACACHE_SIZE; i++) {
 		/* if the vma is cached, invalidate the entire cache */
-- 
2.9.0
