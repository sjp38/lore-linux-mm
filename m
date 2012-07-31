Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E3D976B006E
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:34:51 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4878076lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:34:51 -0700 (PDT)
Subject: [PATCH v3 07/10] mm: use mm->exe_file instead of first VM_EXECUTABLE
 vma->vm_file
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:34:46 +0400
Message-ID: <20120731103446.20182.58739.stgit@zurg>
In-Reply-To: <20120731102546.20182.8450.stgit@zurg>
References: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Some security modules and oprofile still uses VM_EXECUTABLE for retrieving
task's executable file, after this patch they will use mm->exe_file directly.
mm->exe_file protected with mm->mmap_sem, so locking stays the same.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>	#arch/tile
Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>	#security/tomoyo
Cc: Robert Richter <robert.richter@amd.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Eric Paris <eparis@redhat.com>
Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
Cc: James Morris <james.l.morris@oracle.com>
Cc: linux-security-module@vger.kernel.org
Cc: oprofile-list@lists.sf.net
---
 arch/powerpc/oprofile/cell/spu_task_sync.c |   15 ++++-----------
 arch/tile/mm/elf.c                         |   19 +++++++------------
 drivers/oprofile/buffer_sync.c             |   17 +++--------------
 kernel/auditsc.c                           |   13 ++-----------
 kernel/fork.c                              |    3 +--
 security/tomoyo/util.c                     |    9 ++-------
 6 files changed, 19 insertions(+), 57 deletions(-)

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
index 758b603..3cfa98b 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -36,19 +36,14 @@ static void sim_notify_exec(const char *binary_name)
 	} while (c);
 }
 
-static int notify_exec(void)
+static int notify_exec(struct mm_struct *mm)
 {
 	int retval = 0;  /* failure */
-	struct vm_area_struct *vma = current->mm->mmap;
-	while (vma) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
-			break;
-		vma = vma->vm_next;
-	}
-	if (vma) {
+
+	if (mm->exe_file) {
 		char *buf = (char *) __get_free_page(GFP_KERNEL);
 		if (buf) {
-			char *path = d_path(&vma->vm_file->f_path,
+			char *path = d_path(&mm->exe_file->f_path,
 					    buf, PAGE_SIZE);
 			if (!IS_ERR(path)) {
 				sim_notify_exec(path);
@@ -106,16 +101,16 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	unsigned long vdso_base;
 	int retval = 0;
 
+	down_write(&mm->mmap_sem);
+
 	/*
 	 * Notify the simulator that an exec just occurred.
 	 * If we can't find the filename of the mapping, just use
 	 * whatever was passed as the linux_binprm filename.
 	 */
-	if (!notify_exec())
+	if (!notify_exec(mm))
 		sim_notify_exec(bprm->filename);
 
-	down_write(&mm->mmap_sem);
-
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
 	 */
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
 
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 4b96415..31cf885 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1158,7 +1158,6 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 {
 	char name[sizeof(tsk->comm)];
 	struct mm_struct *mm = tsk->mm;
-	struct vm_area_struct *vma;
 
 	/* tsk == current */
 
@@ -1168,16 +1167,8 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 
 	if (mm) {
 		down_read(&mm->mmap_sem);
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
+		if (mm->exe_file)
+			audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
 		up_read(&mm->mmap_sem);
 	}
 	audit_log_task_context(ab);
diff --git a/kernel/fork.c b/kernel/fork.c
index 8efac1f..bd5c4c5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -659,8 +659,7 @@ struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	/* We need mmap_sem to protect against races with removal of
-	 * VM_EXECUTABLE vmas */
+	/* We need mmap_sem to protect against races with removal of exe_file */
 	down_read(&mm->mmap_sem);
 	exe_file = mm->exe_file;
 	if (exe_file)
diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
index 867558c..2952ba5 100644
--- a/security/tomoyo/util.c
+++ b/security/tomoyo/util.c
@@ -949,18 +949,13 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
 const char *tomoyo_get_exe(void)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
 	const char *cp = NULL;
 
 	if (!mm)
 		return NULL;
 	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
-			cp = tomoyo_realpath_from_path(&vma->vm_file->f_path);
-			break;
-		}
-	}
+	if (mm->exe_file)
+		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
 	up_read(&mm->mmap_sem);
 	return cp;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
