Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41AC76B1E55
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:21:59 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i19-v6so690710pfi.21
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:21:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor19641080pfj.12.2018.11.19.21.21.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 21:21:57 -0800 (PST)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more robust
Date: Mon, 19 Nov 2018 21:21:36 -0800
Message-Id: <20181120052137.74317-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
where we don't need to modify core VFS structures to get the same
behavior of the seal. This solves several side-effects pointed out by
Andy [2].

[1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
[2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net/

Suggested-by: Andy Lutomirski <luto@kernel.org>
Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd")
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 fs/hugetlbfs/inode.c |  2 +-
 mm/memfd.c           | 19 -------------------
 mm/shmem.c           | 24 +++++++++++++++++++++---
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 762028994f47..5b54bf893a67 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -558,7 +558,7 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		inode_lock(inode);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			inode_unlock(inode);
 			return -EPERM;
 		}
diff --git a/mm/memfd.c b/mm/memfd.c
index 63fff5e77114..650e65a46b9c 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -201,25 +201,6 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 		}
 	}
 
-	if ((seals & F_SEAL_FUTURE_WRITE) &&
-	    !(*file_seals & F_SEAL_FUTURE_WRITE)) {
-		/*
-		 * The FUTURE_WRITE seal also prevents growing and shrinking
-		 * so we need them to be already set, or requested now.
-		 */
-		int test_seals = (seals | *file_seals) &
-				 (F_SEAL_GROW | F_SEAL_SHRINK);
-
-		if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
-			error = -EINVAL;
-			goto unlock;
-		}
-
-		spin_lock(&file->f_lock);
-		file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
-		spin_unlock(&file->f_lock);
-	}
-
 	*file_seals |= seals;
 	error = 0;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 32eb29bd72c6..cee9878c87f1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2121,6 +2121,23 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct shmem_inode_info *info = SHMEM_I(file_inode(file));
+
+	/*
+	 * New PROT_READ and MAP_SHARED mmaps are not allowed when "future
+	 * write" seal active.
+	 */
+	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_WRITE) &&
+	    (info->seals & F_SEAL_FUTURE_WRITE))
+		return -EPERM;
+
+	/*
+	 * Since the F_SEAL_FUTURE_WRITE seals allow for a MAP_SHARED read-only
+	 * mapping, take care to not allow mprotect to revert protections.
+	 */
+	if (info->seals & F_SEAL_FUTURE_WRITE)
+		vma->vm_flags &= ~(VM_MAYWRITE);
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
@@ -2346,8 +2363,9 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_SHIFT;
 
 	/* i_mutex is held by caller */
-	if (unlikely(info->seals & (F_SEAL_WRITE | F_SEAL_GROW))) {
-		if (info->seals & F_SEAL_WRITE)
+	if (unlikely(info->seals & (F_SEAL_GROW |
+				   F_SEAL_WRITE | F_SEAL_FUTURE_WRITE))) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE))
 			return -EPERM;
 		if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
 			return -EPERM;
@@ -2610,7 +2628,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			error = -EPERM;
 			goto out;
 		}
-- 
2.19.1.1215.g8438c0b245-goog
