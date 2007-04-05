In-reply-to: <E1HZOHe-0000RL-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Thu, 05 Apr 2007 11:29:34 +0200)
Subject: [patch 2/2] only allow nonlinear vmas for ram backed filesystems
References: <E1HZOHe-0000RL-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HZOIr-0000Rv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 05 Apr 2007 11:30:49 +0200
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

page_mkclean() doesn't re-protect ptes for non-linear mappings, so a
later re-dirty through such a mapping will not generate a fault,
PG_dirty will not reflect the dirty state and the dirty count will be
skewed.  This implies that msync() is also currently broken for
nonlinear mappings.

Peter Zijlstra writes:
> In order to make page_mkclean() work for nonlinear vmas we need to do a
> full pte scan for each invocation (we could perhaps only scan 1 in n
> times to try and limit the damage) and that hurts. This will basically
> render it useless.
> 
> The other solution is adding rmap information to nonlinear vmas but
> doubling the memory overhead for nonlinear mappings was not deemed a
> good idea.

The easiest solution is to emulate remap_file_pages on non-linear
mappings with simple mmap() for non ram-backed filesystems.
Applications continue to work (albeit slower), as long as the number
of remappings remain below the maximum vma count.

However all currently known real uses of non-linear mappings are for
ram backed filesystems, which this patch doesn't affect.

William Lee Irwin III writes:
> It's used for > 3GB files on tmpfs and also ramfs, sometimes
> substantially larger than 3GB.
> 
> It's not used for the database proper. It's used for the buffer pool,
> which is the in-core destination and source of direct I/O, the on-disk
> source and destination of the I/O being the database.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

Index: linux/mm/fremap.c
===================================================================
--- linux.orig/mm/fremap.c	2007-04-05 11:18:21.000000000 +0200
+++ linux/mm/fremap.c	2007-04-05 11:18:25.000000000 +0200
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
