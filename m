Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A706160021B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 17:05:44 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 5/6] NOMMU: Fix race between ramfs truncation and shared mmap
Date: Fri, 08 Jan 2010 22:05:38 +0000
Message-ID: <20100108220538.23489.15477.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix the race between the truncation of a ramfs file and an attempt to make a
shared mmap of region of that file.

The problem is that do_mmap_pgoff() calls f_op->get_unmapped_area() to verify
that the file region is made of contiguous pages and to find its base address -
but there isn't any locking to guarantee this region until
vma_prio_tree_insert() is called by add_vma_to_mm().

Note that moving the functionality into f_op->mmap() doesn't help as that is
also called before vma_prio_tree_insert().

Instead make ramfs_nommu_check_mappings() grab nommu_region_sem whilst it does
its checks.  This means that this function will wait whilst mmaps take place.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ramfs/file-nommu.c |    7 ++++++-
 include/linux/sched.h |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)


diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 2efc571..2665313 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -131,6 +131,8 @@ static int ramfs_nommu_check_mappings(struct inode *inode,
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
+	down_write(&nommu_region_sem);
+
 	/* search for VMAs that fall within the dead zone */
 	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
 			      newsize >> PAGE_SHIFT,
@@ -138,10 +140,13 @@ static int ramfs_nommu_check_mappings(struct inode *inode,
 			      ) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
-		if (vma->vm_flags & VM_SHARED)
+		if (vma->vm_flags & VM_SHARED) {
+			up_write(&nommu_region_sem);
 			return -ETXTBSY; /* not quite true, but near enough */
+		}
 	}
 
+	up_write(&nommu_region_sem);
 	return 0;
 }
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 08a2523..6f7bba9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -389,7 +389,7 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 #else
-extern void arch_pick_mmap_layout(struct mm_struct *mm) {}
+static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
 #endif
 
 #if USE_SPLIT_PTLOCKS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
