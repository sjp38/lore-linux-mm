Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D5DB960021B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 17:05:50 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/6] NOMMU: Fix shared mmap after truncate shrinkage problems
Date: Fri, 08 Jan 2010 22:05:43 +0000
Message-ID: <20100108220543.23489.76204.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix a problem in NOMMU mmap with ramfs whereby a shared mmap can happen over
the end of a truncation.  The problem is that ramfs_nommu_check_mappings()
checks that the reduced file size against the VMA tree, but not the vm_region
tree.

The following sequence of events can cause the problem:

	fd = open("/tmp/x", O_RDWR|O_TRUNC|O_CREAT, 0600);
	ftruncate(fd, 32 * 1024);
	a = mmap(NULL, 32 * 1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	b = mmap(NULL, 16 * 1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	munmap(a, 32 * 1024);
	ftruncate(fd, 16 * 1024);
	c = mmap(NULL, 32 * 1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

Mapping 'a' creates a vm_region covering 32KB of the file.  Mapping 'b' sees
that the vm_region from 'a' is covering the region it wants and so shares it,
pinning it in memory.

Mapping 'a' then goes away and the file is truncated to the end of VMA 'b'.
However, the region allocated by 'a' is still in effect, and has _not_ been
reduced.

Mapping 'c' is then created, and because there's a vm_region covering the
desired region, get_unmapped_area() is _not_ called to repeat the check, and
the mapping is granted, even though the pages from the latter half of the
mapping have been discarded.

However:

	d = mmap(NULL, 16 * 1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

Mapping 'd' should work, and should end up sharing the region allocated by
'a'.

To deal with this, we shrink the vm_region struct during the truncation, lest
do_mmap_pgoff() take it as licence to share the full region automatically
without calling the get_unmapped_area() file op again.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ramfs/file-nommu.c |   31 +------------------------
 include/linux/mm.h    |    1 +
 mm/nommu.c            |   62 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 30 deletions(-)


diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 2665313..1739a4a 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -123,35 +123,6 @@ add_error:
 
 /*****************************************************************************/
 /*
- * check that file shrinkage doesn't leave any VMAs dangling in midair
- */
-static int ramfs_nommu_check_mappings(struct inode *inode,
-				      size_t newsize, size_t size)
-{
-	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
-
-	down_write(&nommu_region_sem);
-
-	/* search for VMAs that fall within the dead zone */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      newsize >> PAGE_SHIFT,
-			      (size + PAGE_SIZE - 1) >> PAGE_SHIFT
-			      ) {
-		/* found one - only interested if it's shared out of the page
-		 * cache */
-		if (vma->vm_flags & VM_SHARED) {
-			up_write(&nommu_region_sem);
-			return -ETXTBSY; /* not quite true, but near enough */
-		}
-	}
-
-	up_write(&nommu_region_sem);
-	return 0;
-}
-
-/*****************************************************************************/
-/*
  *
  */
 static int ramfs_nommu_resize(struct inode *inode, loff_t newsize, loff_t size)
@@ -169,7 +140,7 @@ static int ramfs_nommu_resize(struct inode *inode, loff_t newsize, loff_t size)
 
 	/* check that a decrease in size doesn't cut off any shared mappings */
 	if (newsize < size) {
-		ret = ramfs_nommu_check_mappings(inode, newsize, size);
+		ret = nommu_shrink_inode_mappings(inode, size, newsize);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2265f28..60c467b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1089,6 +1089,7 @@ extern void zone_pcp_update(struct zone *zone);
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
+extern int nommu_shrink_inode_mappings(struct inode *, size_t, size_t);
 
 /* prio_tree.c */
 void vma_prio_tree_add(struct vm_area_struct *, struct vm_area_struct *old);
diff --git a/mm/nommu.c b/mm/nommu.c
index 32be0cf..5e09ab6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1914,3 +1914,65 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
 	mmput(mm);
 	return len;
 }
+
+/**
+ * nommu_shrink_inode_mappings - Shrink the shared mappings on an inode
+ * @inode: The inode to check
+ * @size: The current filesize of the inode
+ * @newsize: The proposed filesize of the inode
+ *
+ * Check the shared mappings on an inode on behalf of a shrinking truncate to
+ * make sure that that any outstanding VMAs aren't broken and then shrink the
+ * vm_regions that extend that beyond so that do_mmap_pgoff() doesn't
+ * automatically grant mappings that are too large.
+ */
+int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
+				size_t newsize)
+{
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	struct vm_region *region;
+	pgoff_t low, high;
+	size_t r_size, r_top;
+
+	low = newsize >> PAGE_SHIFT;
+	high = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	
+	down_write(&nommu_region_sem);
+
+	/* search for VMAs that fall within the dead zone */
+	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
+			      low, high) {
+		/* found one - only interested if it's shared out of the page
+		 * cache */
+		if (vma->vm_flags & VM_SHARED) {
+			up_write(&nommu_region_sem);
+			return -ETXTBSY; /* not quite true, but near enough */
+		}
+	}
+
+	/* reduce any regions that overlap the dead zone - if in existence,
+	 * these will be pointed to by VMAs that don't overlap the dead zone
+	 *
+	 * we don't check for any regions that start beyond the EOF as there
+	 * shouldn't be any
+	 */
+	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
+			      0, ULONG_MAX) {
+		if (!(vma->vm_flags & VM_SHARED))
+			continue;
+
+		region = vma->vm_region;
+		r_size = region->vm_top - region->vm_start;
+		r_top = (region->vm_pgoff << PAGE_SHIFT) + r_size;
+
+		if (r_top > newsize) {
+			region->vm_top -= r_top - newsize;
+			if (region->vm_end > region->vm_top)
+				region->vm_end = region->vm_top;
+		}
+	}
+
+	up_write(&nommu_region_sem);
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
