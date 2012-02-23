Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0B9206B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:50:44 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/3] NOMMU: Lock i_mmap_mutex for access to the VMA prio list
Date: Thu, 23 Feb 2012 13:50:35 +0000
Message-ID: <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, uclinux-dev@uclinux.org, gerg@uclinux.org, lethal@linux-sh.org, David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

Lock i_mmap_mutex for access to the VMA prio list to prevent concurrent access.
Currently, certain parts of the mmap handling are protected by the region
mutex, but not all.

Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
cc: stable@vger.kernel.org
---

 mm/nommu.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)


diff --git a/mm/nommu.c b/mm/nommu.c
index b982290..ee7e57e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -696,9 +696,11 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
 
+		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
+		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 
 	/* add the VMA to the tree */
@@ -760,9 +762,11 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
 
+		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
+		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 
 	/* remove from the MM's tree and list */
@@ -2052,6 +2056,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	high = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	down_write(&nommu_region_sem);
+	mutex_lock(&inode->i_mapping->i_mmap_mutex);
 
 	/* search for VMAs that fall within the dead zone */
 	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
@@ -2059,6 +2064,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
+			mutex_unlock(&inode->i_mapping->i_mmap_mutex);
 			up_write(&nommu_region_sem);
 			return -ETXTBSY; /* not quite true, but near enough */
 		}
@@ -2086,6 +2092,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
+	mutex_unlock(&inode->i_mapping->i_mmap_mutex);
 	up_write(&nommu_region_sem);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
