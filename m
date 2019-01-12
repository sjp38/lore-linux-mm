Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6C618E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 15:38:34 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so20533857qtg.14
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 12:38:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j137sor26181973qke.70.2019.01.12.12.38.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 12:38:33 -0800 (PST)
From: Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH v4 1/2] mm/memfd: Add an F_SEAL_FUTURE_WRITE seal to memfd
Date: Sat, 12 Jan 2019 15:38:15 -0500
Message-Id: <20190112203816.85534-2-joel@joelfernandes.org>
In-Reply-To: <20190112203816.85534-1-joel@joelfernandes.org>
References: <20190112203816.85534-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, dancol@google.com, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, John Stultz <john.stultz@linaro.org>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, minchan@kernel.org, Shuah Khan <shuah@kernel.org>

From: "Joel Fernandes (Google)" <joel@joelfernandes.org>

Android uses ashmem for sharing memory regions.  We are looking forward to
migrating all usecases of ashmem to memfd so that we can possibly remove
the ashmem driver in the future from staging while also benefiting from
using memfd and contributing to it.  Note staging drivers are also not ABI
and generally can be removed at anytime.

One of the main usecases Android has is the ability to create a region and
mmap it as writeable, then add protection against making any "future"
writes while keeping the existing already mmap'ed writeable-region active.
This allows us to implement a usecase where receivers of the shared
memory buffer can get a read-only view, while the sender continues to
write to the buffer.  See CursorWindow documentation in Android for more
details:
https://developer.android.com/reference/android/database/CursorWindow

This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
which prevents any future mmap and write syscalls from succeeding while
keeping the existing mmap active.

A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
where we don't need to modify core VFS structures to get the same
behavior of the seal. This solves several side-effects pointed by Andy.
self-tests are provided in later patch to verify the expected semantics.

[1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/

[Thanks a lot to Andy for suggestions to improve code]
Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 fs/hugetlbfs/inode.c       |  2 +-
 include/uapi/linux/fcntl.h |  1 +
 mm/memfd.c                 |  3 ++-
 mm/shmem.c                 | 25 ++++++++++++++++++++++---
 4 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 53ea3cef526e..3daf471bbd92 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -557,7 +557,7 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		inode_lock(inode);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			inode_unlock(inode);
 			return -EPERM;
 		}
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 6448cdd9a350..a2f8658f1c55 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -41,6 +41,7 @@
 #define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
 #define F_SEAL_GROW	0x0004	/* prevent file from growing */
 #define F_SEAL_WRITE	0x0008	/* prevent writes */
+#define F_SEAL_FUTURE_WRITE	0x0010  /* prevent future writes while mapped */
 /* (1U << 31) is reserved for signed error codes */
 
 /*
diff --git a/mm/memfd.c b/mm/memfd.c
index 97264c79d2cd..650e65a46b9c 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -131,7 +131,8 @@ static unsigned int *memfd_file_seals_ptr(struct file *file)
 #define F_ALL_SEALS (F_SEAL_SEAL | \
 		     F_SEAL_SHRINK | \
 		     F_SEAL_GROW | \
-		     F_SEAL_WRITE)
+		     F_SEAL_WRITE | \
+		     F_SEAL_FUTURE_WRITE)
 
 static int memfd_add_seals(struct file *file, unsigned int seals)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index 6ece1e2fe76e..3c98cc9655b4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2125,6 +2125,24 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct shmem_inode_info *info = SHMEM_I(file_inode(file));
+
+	if (info->seals & F_SEAL_FUTURE_WRITE) {
+		/*
+		 * New PROT_WRITE and MAP_SHARED mmaps are not allowed when
+		 * "future write" seal active.
+		 */
+		if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_WRITE))
+			return -EPERM;
+
+		/*
+		 * Since the F_SEAL_FUTURE_WRITE seals allow for a MAP_SHARED
+		 * read-only mapping, take care to not allow mprotect to revert
+		 * protections.
+		 */
+		vma->vm_flags &= ~(VM_MAYWRITE);
+	}
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
@@ -2375,8 +2393,9 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
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
@@ -2639,7 +2658,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			error = -EPERM;
 			goto out;
 		}
-- 
2.20.1.97.g81188d93c3-goog
