Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 048686B02A7
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:32:41 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z1so14603251pfl.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:32:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s135si9986925pgs.399.2017.12.19.05.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 05:32:39 -0800 (PST)
Date: Tue, 19 Dec 2017 05:32:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] Provide useful debugging information for VM_BUG
Message-ID: <20171219133236.GE13680@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Tobin C. Harding" <me@tobin.cc>, kernel-hardening@lists.openwall.com


From: Matthew Wilcox <mawilcox@microsoft.com>

With the recent addition of hashed kernel pointers, places which need
to produce useful debug output have to specify %px, not %p.  This patch
fixes all the VM debug to use %px.  This is appropriate because it's
debug output that the user should never be able to trigger, and kernel
developers need to see the actual pointers.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/debug.c b/mm/debug.c
index d947f3e03b0d..56e2d9125ea5 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -50,7 +50,7 @@ void __dump_page(struct page *page, const char *reason)
 	 */
 	int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
 
-	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
+	pr_emerg("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
 		  page, page_ref_count(page), mapcount,
 		  page->mapping, page_to_pgoff(page));
 	if (PageCompound(page))
@@ -69,7 +69,7 @@ void __dump_page(struct page *page, const char *reason)
 
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
-		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
+		pr_alert("page->mem_cgroup:%px\n", page->mem_cgroup);
 #endif
 }
 
@@ -84,10 +84,10 @@ EXPORT_SYMBOL(dump_page);
 
 void dump_vma(const struct vm_area_struct *vma)
 {
-	pr_emerg("vma %p start %p end %p\n"
-		"next %p prev %p mm %p\n"
-		"prot %lx anon_vma %p vm_ops %p\n"
-		"pgoff %lx file %p private_data %p\n"
+	pr_emerg("vma %px start %px end %px\n"
+		"next %px prev %px mm %px\n"
+		"prot %lx anon_vma %px vm_ops %px\n"
+		"pgoff %lx file %px private_data %px\n"
 		"flags: %#lx(%pGv)\n",
 		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
 		vma->vm_prev, vma->vm_mm,
@@ -100,27 +100,27 @@ EXPORT_SYMBOL(dump_vma);
 
 void dump_mm(const struct mm_struct *mm)
 {
-	pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
+	pr_emerg("mm %px mmap %px seqnum %d task_size %lu\n"
 #ifdef CONFIG_MMU
-		"get_unmapped_area %p\n"
+		"get_unmapped_area %px\n"
 #endif
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
-		"pgd %p mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
+		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
 		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
-		"binfmt %p flags %lx core_state %p\n"
+		"binfmt %px flags %lx core_state %px\n"
 #ifdef CONFIG_AIO
-		"ioctx_table %p\n"
+		"ioctx_table %px\n"
 #endif
 #ifdef CONFIG_MEMCG
-		"owner %p "
+		"owner %px "
 #endif
-		"exe_file %p\n"
+		"exe_file %px\n"
 #ifdef CONFIG_MMU_NOTIFIER
-		"mmu_notifier_mm %p\n"
+		"mmu_notifier_mm %px\n"
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
