Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 041D56B00E9
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:01:33 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so3469210bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:01:33 -0700 (PDT)
Subject: [PATCH v2 08/10] mm: kill vma flag VM_EXECUTABLE
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:01:29 +0400
Message-ID: <20120407190129.9726.96427.stgit@zurg>
In-Reply-To: <20120407185546.9726.62260.stgit@zurg>
References: <20120407185546.9726.62260.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Matt Helsley <matthltc@us.ibm.com>, Oleg Nesterov <oleg@redhat.com>

Currently the kernel sets mm->exe_file during sys_execve() and then tracks
number of vmas with VM_EXECUTABLE flag in mm->num_exe_file_vmas, as soon as
this counter drops to zero kernel resets mm->exe_file to NULL. Plus it resets
mm->exe_file at last mmput() when mm->mm_users drops to zero.

Vma with VM_EXECUTABLE flag appears after mapping file with flag MAP_EXECUTABLE,
such vmas can appears only at sys_execve() or after vma splitting, because
sys_mmap ignores this flag. Usually binfmt module sets mm->exe_file and mmaps
some executable vmas with this file, they hold mm->exe_file while task is running.

comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
where all this stuff was introduced:

> The kernel implements readlink of /proc/pid/exe by getting the file from
> the first executable VMA.  Then the path to the file is reconstructed and
> reported as the result.
>
> Because of the VMA walk the code is slightly different on nommu systems.
> This patch avoids separate /proc/pid/exe code on nommu systems.  Instead of
> walking the VMAs to find the first executable file-backed VMA we store a
> reference to the exec'd file in the mm_struct.
>
> That reference would prevent the filesystem holding the executable file
> from being unmounted even after unmapping the VMAs.  So we track the number
> of VM_EXECUTABLE VMAs and drop the new reference when the last one is
> unmapped.  This avoids pinning the mounted filesystem.

After this patch we track the number of VMAs with vma->vm_file == mm->exe_file,
instead of vmas with VM_EXECUTABLE. Behaviour is nearly the same: kernel will
reset mm->exe_file as soon as task unmap its executable file.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/mm.h   |    1 -
 include/linux/mman.h |    1 -
 mm/mmap.c            |   12 ++++++------
 mm/nommu.c           |   11 ++++++-----
 4 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 553d134..8e82b79 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -88,7 +88,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
-#define VM_EXECUTABLE	0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 8b74e9b..77cec2f 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -86,7 +86,6 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
 	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 #endif /* __KERNEL__ */
diff --git a/mm/mmap.c b/mm/mmap.c
index 3d254ca..bc67ed7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -232,7 +232,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file) {
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
+		if (vma->vm_file == vma->vm_mm->exe_file)
 			removed_exe_file_vma(vma->vm_mm);
 	}
 	mpol_put(vma_policy(vma));
@@ -618,7 +618,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (remove_next) {
 		if (file) {
 			fput(file);
-			if (next->vm_flags & VM_EXECUTABLE)
+			if (file == mm->exe_file)
 				removed_exe_file_vma(mm);
 		}
 		if (next->anon_vma)
@@ -1293,7 +1293,7 @@ munmap_back:
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
-		if (vm_flags & VM_EXECUTABLE)
+		if (file == mm->exe_file)
 			added_exe_file_vma(mm);
 
 		/* Can addr have changed??
@@ -1971,7 +1971,7 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 
 	if (new->vm_file) {
 		get_file(new->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
+		if (new->vm_file == mm->exe_file)
 			added_exe_file_vma(mm);
 	}
 
@@ -1992,7 +1992,7 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	if (new->vm_ops && new->vm_ops->close)
 		new->vm_ops->close(new);
 	if (new->vm_file) {
-		if (vma->vm_flags & VM_EXECUTABLE)
+		if (new->vm_file == mm->exe_file)
 			removed_exe_file_vma(mm);
 		fput(new->vm_file);
 	}
@@ -2379,7 +2379,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			new_vma->vm_pgoff = pgoff;
 			if (new_vma->vm_file) {
 				get_file(new_vma->vm_file);
-				if (vma->vm_flags & VM_EXECUTABLE)
+				if (new_vma->vm_file == mm->exe_file)
 					added_exe_file_vma(mm);
 			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
diff --git a/mm/nommu.c b/mm/nommu.c
index afa0a15..db8da78 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -791,7 +791,7 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file) {
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
+		if (vma->vm_file == mm->exe_file)
 			removed_exe_file_vma(mm);
 	}
 	put_nommu_region(vma->vm_region);
@@ -1287,7 +1287,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 		get_file(file);
 		vma->vm_file = file;
 		get_file(file);
-		if (vm_flags & VM_EXECUTABLE) {
+		if (file == current->mm->exe_file) {
 			added_exe_file_vma(current->mm);
 			vma->vm_mm = current->mm;
 		}
@@ -1441,10 +1441,11 @@ error:
 	if (region->vm_file)
 		fput(region->vm_file);
 	kmem_cache_free(vm_region_jar, region);
-	if (vma->vm_file)
+	if (vma->vm_file) {
 		fput(vma->vm_file);
-	if (vma->vm_flags & VM_EXECUTABLE)
-		removed_exe_file_vma(vma->vm_mm);
+		if (vma->vm_file == vma->vm_mm->exe_file)
+			removed_exe_file_vma(vma->vm_mm);
+	}
 	kmem_cache_free(vm_area_cachep, vma);
 	kleave(" = %d", ret);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
