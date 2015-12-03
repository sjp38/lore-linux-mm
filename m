From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] fs: clear file privilege bits when mmap writing
Date: Wed, 2 Dec 2015 16:03:42 -0800
Message-ID: <20151203000342.GA30015@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Normally, when a user can modify a file that has setuid or setgid bits,
those bits are cleared when they are not the file owner or a member
of the group. This is enforced when using write and truncate but not
when writing to a shared mmap on the file. This could allow the file
writer to gain privileges by changing a binary without losing the
setuid/setgid/caps bits.

Changing the bits requires holding inode->i_mutex, so it cannot be done
during the page fault (due to mmap_sem being held during the fault).
Instead, clear the bits if PROT_WRITE is being used at mmap time.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: stable@vger.kernel.org
---
v2:
 - move check from page fault to mmap open
---
 mm/mmap.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..a27735aabc73 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1340,6 +1340,17 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			if (locks_verify_locked(file))
 				return -EAGAIN;
 
+			/*
+			 * If we must remove privs, we do it here since
+			 * doing it during page COW is expensive and
+			 * cannot hold inode->i_mutex.
+			 */
+			if (prot & PROT_WRITE && !IS_NOSEC(inode)) {
+				mutex_lock(&inode->i_mutex);
+				file_remove_privs(file);
+				mutex_unlock(&inode->i_mutex);
+			}
+
 			vm_flags |= VM_SHARED | VM_MAYSHARE;
 			if (!(file->f_mode & FMODE_WRITE))
 				vm_flags &= ~(VM_MAYWRITE | VM_SHARED);
-- 
1.9.1


-- 
Kees Cook
Chrome OS & Brillo Security
