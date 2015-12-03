From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] fs: clear file privilege bits when mmap writing
Date: Thu, 3 Dec 2015 11:22:12 -0800
Message-ID: <20151203192212.GA31034@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Normally, when a user can modify a file that has setuid or setgid bits,
those bits are cleared when they are not the file owner or a member
of the group. This is enforced when using write and truncate but not
when writing to a shared mmap on the file. This could allow the file
writer to gain privileges by changing a binary without losing the
setuid/setgid/caps bits.

Changing the bits requires holding inode->i_mutex, so it cannot be done
during the page fault (due to mmap_sem being held during the fault).
Instead, clear the bits if PROT_WRITE is being used at mmap open time.
But we can't do the check in the right place inside mmap, so we have to
do it before holding mmap_sem, which means duplicating some checks, which
have to be available to the non-MMU builds too.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
This just keeps getting uglier. :(

v3:
- move outside of mmap_sem for real now, fengguang
- check return code of file_remove_privs, akpm
v2:
- move to mmap from fault handler, jack
---
 include/linux/mm.h |  1 +
 mm/mmap.c          | 19 ++++---------------
 mm/util.c          | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad7793788..b264c8be7114 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1912,6 +1912,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
+extern int do_mmap_shared_checks(struct file *file, unsigned long prot);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..bcbe592a2c49 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1321,24 +1321,13 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 
 	if (file) {
 		struct inode *inode = file_inode(file);
+		int err;
 
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
-			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
-
-			/*
-			 * Make sure we don't allow writing to an append-only
-			 * file..
-			 */
-			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
-				return -EACCES;
-
-			/*
-			 * Make sure there are no mandatory locks on the file.
-			 */
-			if (locks_verify_locked(file))
-				return -EAGAIN;
+			err = do_mmap_shared_checks(file, prot);
+			if (err)
+				return err;
 
 			vm_flags |= VM_SHARED | VM_MAYSHARE;
 			if (!(file->f_mode & FMODE_WRITE))
diff --git a/mm/util.c b/mm/util.c
index 9af1c12b310c..1882eaf33a37 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -283,6 +283,29 @@ int __weak get_user_pages_fast(unsigned long start,
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+int do_mmap_shared_checks(struct file *file, unsigned long prot)
+{
+	struct inode *inode = file_inode(file);
+
+	if ((prot & PROT_WRITE) && !(file->f_mode & FMODE_WRITE))
+		return -EACCES;
+
+	/*
+	 * Make sure we don't allow writing to an append-only
+	 * file..
+	 */
+	if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
+		return -EACCES;
+
+	/*
+	 * Make sure there are no mandatory locks on the file.
+	 */
+	if (locks_verify_locked(file))
+		return -EAGAIN;
+
+	return 0;
+}
+
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff)
@@ -291,6 +314,33 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
 
+	/*
+	 * If we must remove privs, we do it here since doing it during
+	 * page fault may be expensive and cannot hold inode->i_mutex,
+	 * since mm->mmap_sem is already held.
+	 */
+	if (file && (flag & MAP_TYPE) == MAP_SHARED && (prot & PROT_WRITE)) {
+		struct inode *inode = file_inode(file);
+		int err;
+
+		if (!IS_NOSEC(inode)) {
+			/*
+			 * Make sure we can't strip privs from a file that
+			 * wouldn't otherwise be allowed to be mmapped.
+			 */
+			err = do_mmap_shared_checks(file, prot);
+			if (err)
+				return err;
+
+			mutex_lock(&inode->i_mutex);
+			err = file_remove_privs(file);
+			mutex_unlock(&inode->i_mutex);
+
+			if (err)
+				return err;
+		}
+	}
+
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
 		down_write(&mm->mmap_sem);
-- 
1.9.1


-- 
Kees Cook
Chrome OS & Brillo Security
