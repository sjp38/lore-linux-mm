Subject: [PATCH] Inconsistent mmap()/mremap() flags
From: Thayne Harbaugh <thayne@c2.net>
Reply-To: thayne@c2.net
Content-Type: text/plain
Date: Thu, 27 Sep 2007 23:46:33 -0600
Message-Id: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: ak@suse.de, linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

The x86_64 mmap() accepts the MAP_32BIT flag to request 32-bit clean
addresses.  It seems to me that for consistency x86_64 mremap() should
also accept this (or an equivalent) flag.

Here is a trivial and untested patch for basis of discussion:

--- linux-source-2.6.22/mm/mremap.c.orig	2007-09-27 23:02:13.000000000 -0600
+++ linux-source-2.6.22/mm/mremap.c	2007-09-27 23:07:29.000000000 -0600
@@ -23,6 +23,11 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>

+/* MAP_32BIT possibly defined in asm/mman.h */
+#ifndef MAP_32BIT
+#define MAP_32BIT 0
+#endif
+
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
@@ -255,7 +259,7 @@
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MAP_32BIT))
 		goto out;
 
 	if (addr & ~PAGE_MASK)
@@ -388,6 +392,9 @@
 			if (vma->vm_flags & VM_MAYSHARE)
 				map_flags |= MAP_SHARED;
 
+			if (flags & MAP_32BIT)
+				map_flags |= MAP_32BIT;
+
 			new_addr = get_unmapped_area(vma->vm_file, 0, new_len,
 						vma->vm_pgoff, map_flags);
 			ret = new_addr;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
