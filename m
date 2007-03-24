In-reply-to: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Sat, 24 Mar 2007 23:07:07 +0100)
Subject: [patch 2/3] only allow nonlinear vmas for ram backed filesystems
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HVEQJ-0006gF-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 24 Mar 2007 23:09:19 +0100
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dirty page accounting/limiting doesn't work for nonlinear mappings, so
for non-ram backed filesystems emulate with linear mappings.  This
retains ABI compatibility with previous kernels at minimal code cost.

All known users of nonlinear mappings actually use tmpfs, so this
shouldn't have any negative effect.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.21-rc4-mm1/mm/fremap.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/fremap.c	2007-03-24 22:30:05.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/fremap.c	2007-03-24 22:37:59.000000000 +0100
@@ -181,6 +181,24 @@ asmlinkage long sys_remap_file_pages(uns
 			goto retry;
 		}
 		mapping = vma->vm_file->f_mapping;
+		/*
+		 * page_mkclean doesn't work on nonlinear vmas, so if dirty
+		 * pages need to be accounted, emulate with linear vmas.
+		 */
+		if (mapping_cap_account_dirty(mapping)) {
+			unsigned long addr;
+
+			flags &= MAP_NONBLOCK;
+			addr = mmap_region(vma->vm_file, start, size, flags,
+					   vma->vm_flags, pgoff, 1);
+			if (IS_ERR_VALUE(addr))
+				err = addr;
+			else {
+				BUG_ON(addr != start);
+				err = 0;
+			}
+			goto out;
+		}
 		spin_lock(&mapping->i_mmap_lock);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
