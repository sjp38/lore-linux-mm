Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 330AD6B00E7
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:29:33 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1494120bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:29:32 -0700 (PDT)
Subject: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:29:29 +0400
Message-ID: <20120331092929.19920.54540.stgit@zurg>
In-Reply-To: <20120331091049.19373.28994.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Eric Paris <eparis@redhat.com>, linux-security-module@vger.kernel.org, oprofile-list@lists.sf.net, Matt Helsley <matthltc@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

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

So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
fix some hypothetical pinning fs from umounting by mm which already unmapped all
its executable files, but still alive. Does anyone know any real world example?
mm can be borrowed by swapoff or some get_task_mm() user, but it's not a big problem.

Thus, we can remove all this stuff together with VM_EXECUTABLE flag and
keep mm->exe_file alive till final mmput().

After that we can access current->mm->exe_file without any locks
(after checking current->mm and mm->exe_file for NULL)

Some code around security and oprofile still uses VM_EXECUTABLE for retrieving
task's executable file, after this patch they will use mm->exe_file directly.
In tomoyo and audit mm is always current->mm, oprofile uses get_task_mm().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Eric Paris <eparis@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linux-security-module@vger.kernel.org
Cc: oprofile-list@lists.sf.net
---
 arch/powerpc/oprofile/cell/spu_task_sync.c |   15 ++++----------
 arch/tile/mm/elf.c                         |   12 ++++--------
 drivers/oprofile/buffer_sync.c             |   17 +++-------------
 include/linux/mm.h                         |    4 ----
 include/linux/mm_types.h                   |    1 -
 include/linux/mman.h                       |    1 -
 kernel/auditsc.c                           |   17 ++--------------
 kernel/fork.c                              |   29 ++++------------------------
 mm/mmap.c                                  |   27 +++++---------------------
 mm/nommu.c                                 |   11 +----------
 security/tomoyo/util.c                     |   14 +++-----------
 11 files changed, 26 insertions(+), 122 deletions(-)

diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 642fca1..28f1af2 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -304,7 +304,7 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 	return cookie;
 }
 
-/* Look up the dcookie for the task's first VM_EXECUTABLE mapping,
+/* Look up the dcookie for the task's mm->exe_file,
  * which corresponds loosely to "application name". Also, determine
  * the offset for the SPU ELF object.  If computed offset is
  * non-zero, it implies an embedded SPU object; otherwise, it's a
@@ -321,7 +321,6 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 {
 	unsigned long app_cookie = 0;
 	unsigned int my_offset = 0;
-	struct file *app = NULL;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = spu->mm;
 
@@ -330,16 +329,10 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 
 	down_read(&mm->mmap_sem);
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (!vma->vm_file)
-			continue;
-		if (!(vma->vm_flags & VM_EXECUTABLE))
-			continue;
-		app_cookie = fast_get_dcookie(&vma->vm_file->f_path);
+	if (mm->exe_file) {
+		app_cookie = fast_get_dcookie(&mm->exe_file->f_path);
 		pr_debug("got dcookie for %s\n",
-			 vma->vm_file->f_dentry->d_name.name);
-		app = vma->vm_file;
-		break;
+			 mm->exe_file->f_dentry->d_name.name);
 	}
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 758b603..43e5279 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -39,16 +39,12 @@ static void sim_notify_exec(const char *binary_name)
 static int notify_exec(void)
 {
 	int retval = 0;  /* failure */
-	struct vm_area_struct *vma = current->mm->mmap;
-	while (vma) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
-			break;
-		vma = vma->vm_next;
-	}
-	if (vma) {
+	struct mm_struct *mm = current->mm;
+
+	if (mm->exe_file) {
 		char *buf = (char *) __get_free_page(GFP_KERNEL);
 		if (buf) {
-			char *path = d_path(&vma->vm_file->f_path,
+			char *path = d_path(&mm->exe_file->f_path,
 					    buf, PAGE_SIZE);
 			if (!IS_ERR(path)) {
 				sim_notify_exec(path);
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index f34b5b2..d93b2b6 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -216,7 +216,7 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 }
 
 
-/* Look up the dcookie for the task's first VM_EXECUTABLE mapping,
+/* Look up the dcookie for the task's mm->exe_file,
  * which corresponds loosely to "application name". This is
  * not strictly necessary but allows oprofile to associate
  * shared-library samples with particular applications
@@ -224,21 +224,10 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 static unsigned long get_exec_dcookie(struct mm_struct *mm)
 {
 	unsigned long cookie = NO_COOKIE;
-	struct vm_area_struct *vma;
-
-	if (!mm)
-		goto out;
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (!vma->vm_file)
-			continue;
-		if (!(vma->vm_flags & VM_EXECUTABLE))
-			continue;
-		cookie = fast_get_dcookie(&vma->vm_file->f_path);
-		break;
-	}
+	if (mm && mm->exe_file)
+		cookie = fast_get_dcookie(&mm->exe_file->f_path);
 
-out:
 	return cookie;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 553d134..3a4d721 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -88,7 +88,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
-#define VM_EXECUTABLE	0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -1374,9 +1373,6 @@ extern void exit_mmap(struct mm_struct *);
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
-/* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
-extern void added_exe_file_vma(struct mm_struct *mm);
-extern void removed_exe_file_vma(struct mm_struct *mm);
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..b480c06 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -378,7 +378,6 @@ struct mm_struct {
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file *exe_file;
-	unsigned long num_exe_file_vmas;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
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
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index af1de0f..aa27a00 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1164,21 +1164,8 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 	get_task_comm(name, tsk);
 	audit_log_format(ab, " comm=");
 	audit_log_untrustedstring(ab, name);
-
-	if (mm) {
-		down_read(&mm->mmap_sem);
-		vma = mm->mmap;
-		while (vma) {
-			if ((vma->vm_flags & VM_EXECUTABLE) &&
-			    vma->vm_file) {
-				audit_log_d_path(ab, " exe=",
-						 &vma->vm_file->f_path);
-				break;
-			}
-			vma = vma->vm_next;
-		}
-		up_read(&mm->mmap_sem);
-	}
+	if (mm && mm->exe_file)
+		audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
 	audit_log_task_context(ab);
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b9372a0..40e4b49 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -587,26 +587,6 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
-/*
- * We added or removed a vma mapping the executable. The vmas are only mapped
- * during exec and are not mapped with the mmap system call.
- * Callers must hold down_write() on the mm's mmap_sem for these
- */
-void added_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas++;
-}
-
-void removed_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas--;
-	if ((mm->num_exe_file_vmas == 0) && mm->exe_file) {
-		fput(mm->exe_file);
-		mm->exe_file = NULL;
-	}
-
-}
-
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
@@ -614,20 +594,19 @@ void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 	if (mm->exe_file)
 		fput(mm->exe_file);
 	mm->exe_file = new_exe_file;
-	mm->num_exe_file_vmas = 0;
 }
 
+/*
+ * Caller must have mm->mm_users reference,
+ * for example current->mm or acquired by get_task_mm().
+ */
 struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	/* We need mmap_sem to protect against races with removal of
-	 * VM_EXECUTABLE vmas */
-	down_read(&mm->mmap_sem);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
-	up_read(&mm->mmap_sem);
 	return exe_file;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 3d254ca..2647bb7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -230,11 +230,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(vma->vm_mm);
-	}
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
@@ -616,11 +613,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (remove_next) {
-		if (file) {
+		if (file)
 			fput(file);
-			if (next->vm_flags & VM_EXECUTABLE)
-				removed_exe_file_vma(mm);
-		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
@@ -1293,8 +1287,6 @@ munmap_back:
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
-		if (vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
 
 		/* Can addr have changed??
 		 *
@@ -1969,11 +1961,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	if (anon_vma_clone(new, vma))
 		goto out_free_mpol;
 
-	if (new->vm_file) {
+	if (new->vm_file)
 		get_file(new->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
-	}
 
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
@@ -1991,11 +1980,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	/* Clean everything up if vma_adjust failed. */
 	if (new->vm_ops && new->vm_ops->close)
 		new->vm_ops->close(new);
-	if (new->vm_file) {
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(mm);
+	if (new->vm_file)
 		fput(new->vm_file);
-	}
 	unlink_anon_vmas(new);
  out_free_mpol:
 	mpol_put(pol);
@@ -2377,11 +2363,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
-			if (new_vma->vm_file) {
+			if (new_vma->vm_file)
 				get_file(new_vma->vm_file);
-				if (vma->vm_flags & VM_EXECUTABLE)
-					added_exe_file_vma(mm);
-			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
diff --git a/mm/nommu.c b/mm/nommu.c
index afa0a15..d617d5c 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -789,11 +789,8 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 	kenter("%p", vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(mm);
-	}
 	put_nommu_region(vma->vm_region);
 	kmem_cache_free(vm_area_cachep, vma);
 }
@@ -1287,10 +1284,6 @@ unsigned long do_mmap_pgoff(struct file *file,
 		get_file(file);
 		vma->vm_file = file;
 		get_file(file);
-		if (vm_flags & VM_EXECUTABLE) {
-			added_exe_file_vma(current->mm);
-			vma->vm_mm = current->mm;
-		}
 	}
 
 	down_write(&nommu_region_sem);
@@ -1443,8 +1436,6 @@ error:
 	kmem_cache_free(vm_region_jar, region);
 	if (vma->vm_file)
 		fput(vma->vm_file);
-	if (vma->vm_flags & VM_EXECUTABLE)
-		removed_exe_file_vma(vma->vm_mm);
 	kmem_cache_free(vm_area_cachep, vma);
 	kleave(" = %d", ret);
 	return ret;
diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
index 867558c..b929dd3 100644
--- a/security/tomoyo/util.c
+++ b/security/tomoyo/util.c
@@ -949,19 +949,11 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
 const char *tomoyo_get_exe(void)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
 	const char *cp = NULL;
 
-	if (!mm)
-		return NULL;
-	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
-			cp = tomoyo_realpath_from_path(&vma->vm_file->f_path);
-			break;
-		}
-	}
-	up_read(&mm->mmap_sem);
+	if (mm && mm->exe_file)
+		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
+
 	return cp;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
