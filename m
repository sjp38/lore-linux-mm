Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A41D86B0078
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:58:41 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/6] NOMMU: struct vm_region's vm_usage count need not be
	atomic
Date: Thu, 14 Jan 2010 13:58:35 +0000
Message-ID: <20100114135835.10482.48537.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100114135830.10482.54124.stgit@warthog.procyon.org.uk>
References: <20100114135830.10482.54124.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org, dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The vm_usage count field in struct vm_region does not need to be atomic as it's
only even modified whilst nommu_region_sem is write locked.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
---

 include/linux/mm_types.h |    2 +-
 mm/nommu.c               |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)


diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 84d020b..80cfa78 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -122,7 +122,7 @@ struct vm_region {
 	unsigned long	vm_pgoff;	/* the offset in vm_file corresponding to vm_start */
 	struct file	*vm_file;	/* the backing file or NULL */
 
-	atomic_t	vm_usage;	/* region usage count */
+	int		vm_usage;	/* region usage count (access under nommu_region_sem) */
 	bool		vm_icache_flushed : 1; /* true if the icache has been flushed for
 						* this region */
 };
diff --git a/mm/nommu.c b/mm/nommu.c
index 1777386..5e39294 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -552,11 +552,11 @@ static void free_page_series(unsigned long from, unsigned long to)
 static void __put_nommu_region(struct vm_region *region)
 	__releases(nommu_region_sem)
 {
-	kenter("%p{%d}", region, atomic_read(&region->vm_usage));
+	kenter("%p{%d}", region, region->vm_usage);
 
 	BUG_ON(!nommu_region_tree.rb_node);
 
-	if (atomic_dec_and_test(&region->vm_usage)) {
+	if (--region->vm_usage == 0) {
 		if (region->vm_top > region->vm_start)
 			delete_nommu_region(region);
 		up_write(&nommu_region_sem);
@@ -1205,7 +1205,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 	if (!vma)
 		goto error_getting_vma;
 
-	atomic_set(&region->vm_usage, 1);
+	region->vm_usage = 1;
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
 
@@ -1272,7 +1272,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 			}
 
 			/* we've found a region we can share */
-			atomic_inc(&pregion->vm_usage);
+			pregion->vm_usage++;
 			vma->vm_region = pregion;
 			start = pregion->vm_start;
 			start += (pgoff - pregion->vm_pgoff) << PAGE_SHIFT;
@@ -1289,7 +1289,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 					vma->vm_region = NULL;
 					vma->vm_start = 0;
 					vma->vm_end = 0;
-					atomic_dec(&pregion->vm_usage);
+					pregion->vm_usage--;
 					pregion = NULL;
 					goto error_just_free;
 				}
@@ -1444,7 +1444,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* we're only permitted to split anonymous regions that have a single
 	 * owner */
 	if (vma->vm_file ||
-	    atomic_read(&vma->vm_region->vm_usage) != 1)
+	    vma->vm_region->vm_usage != 1)
 		return -ENOMEM;
 
 	if (mm->map_count >= sysctl_max_map_count)
@@ -1518,7 +1518,7 @@ static int shrink_vma(struct mm_struct *mm,
 
 	/* cut the backing region down to size */
 	region = vma->vm_region;
-	BUG_ON(atomic_read(&region->vm_usage) != 1);
+	BUG_ON(region->vm_usage != 1);
 
 	down_write(&nommu_region_sem);
 	delete_nommu_region(region);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
