Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 40DB26B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:29:52 -0400 (EDT)
Received: by ykec202 with SMTP id c202so26049426yke.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:29:52 -0700 (PDT)
Received: from mail-vn0-x22b.google.com (mail-vn0-x22b.google.com. [2607:f8b0:400c:c0f::22b])
        by mx.google.com with ESMTPS id g30si13575391yhc.66.2015.04.28.06.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 06:29:51 -0700 (PDT)
Received: by vnbg129 with SMTP id g129so15991168vnb.4
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:29:50 -0700 (PDT)
Date: Tue, 28 Apr 2015 09:28:13 -0400
From: Michael Tirado <mtirado418@gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd: F_SEAL_WRITE_PEER
Message-ID: <20150428092813.54e73766@yak.slack>
In-Reply-To: <CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
References: <20150416032316.00b79732@yak.slack>
 <CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org

On Thu, 16 Apr 2015 11:14:11 +0300
Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> Keeping pointer to priviledged task is a bad idea.
> There is no easy way to drop it when task exits and this doesn't work
> for threads.
> I think it's better to keep pointer to priveledged struct file and
> drop it in method
> f_op->release() when task closes fd or exits. Server task could obtain second
> non-priveledged fd and struct file for that inode via
> open(/proc/../fd/), dup3(),
> openat() or something else and send it to read-only users.
 

Do you mind taking a second look at my changes? I am wondering if you or anyone
else see problems with this version.

I have changed the authentication variable to use files_struct instead of
privileged task, this is set to NULL when the owner closes the file. There
are a few other fixes here too. Overall this seems like a much better patch
than the original, thanks for your valuable input. I will continue trying to
break this thing and hope to re-send it to the main mailing list with the
updated name if it holds up. This is for my own system, but maybe others will
find it useful?

---
 include/linux/shmem_fs.h                   |   1 +
 include/uapi/linux/fcntl.h                 |   1 +
 mm/shmem.c                                 | 119 ++++++++++++++++++++++++++++-
 tools/testing/selftests/memfd/memfd_test.c |  94 +++++++++++++++++++++++
 4 files changed, 212 insertions(+), 3 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5..a3cffc3 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -12,6 +12,7 @@
 
 struct shmem_inode_info {
 	spinlock_t		lock;
+	void			*auth;		/* owner's task->files addr */
 	unsigned int		seals;		/* shmem seals */
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index beed138..7138bb6 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -40,6 +40,7 @@
 #define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
 #define F_SEAL_GROW	0x0004	/* prevent file from growing */
 #define F_SEAL_WRITE	0x0008	/* prevent writes */
+#define F_SEAL_WRITE_PEER 0x0010 /*prevent writes from peers */
 /* (1U << 31) is reserved for signed error codes */
 
 /*
diff --git a/mm/shmem.c b/mm/shmem.c
index de98137..e3a926f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1481,7 +1481,10 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 
 	/* i_mutex is held by caller */
-	if (unlikely(info->seals)) {
+	if (info->seals) {
+		if (info->seals & F_SEAL_WRITE_PEER 
+				&& info->auth != current->files)
+			return -EPERM;
 		if (info->seals & F_SEAL_WRITE)
 			return -EPERM;
 		if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
@@ -1938,10 +1941,79 @@ continue_resched:
 	return error;
 }
 
+/* 
+ * returns 0 if ok. error if seal cannot be applied .
+ */
+static int shmem_seal_write_peer(struct file *file, unsigned int seals,
+		struct shmem_inode_info *info)
+{
+	struct vm_area_struct *vma;
+	struct vm_area_struct *curvma;
+	int c = 0;
+	int retval;
+
+
+	if (seals & F_SEAL_WRITE || info->seals & F_SEAL_WRITE)
+		return -EPERM;
+		
+	if (atomic_read(&file->f_mapping->i_mmap_writable) < 0
+		       || atomic_read(&file->f_mapping->i_mmap_writable) > 1
+		       || current->files != info->auth)
+		return -EPERM;
+
+	/* lock current->mm */
+	task_lock(current);
+
+	/* 
+	 * search current task vma's for references to file.
+	 * ensure that only one writable shared mapping exists
+	 */
+	vma = NULL;
+	for (curvma = current->mm->mmap; curvma; curvma = curvma->vm_next) {
+		if (curvma->vm_file == file
+				&& curvma->vm_flags & (VM_WRITE | VM_SHARED)) {
+			if (++c > 1) {
+				retval = -EPERM;
+				goto unlock;
+			}
+			vma = curvma;
+		}
+	}
+
+	if (vma == NULL) {
+		retval = mapping_deny_writable(file->f_mapping);
+		goto unlock;
+	}
+
+	/* 1 shared write mapping remains */
+	mapping_unmap_writable(file->f_mapping);
+	retval = mapping_deny_writable(file->f_mapping);
+	if (retval) { 
+		mapping_allow_writable(file->f_mapping);
+		goto unlock;
+	}
+	retval = shmem_wait_for_pins(file->f_mapping);
+	if (retval) {
+		atomic_inc(&file->f_mapping->i_mmap_writable);
+		mapping_allow_writable(file->f_mapping);
+		goto unlock;
+	}
+
+	/* do not dupe */
+	vma->vm_flags |= VM_DONTCOPY;
+	retval = 0;
+
+unlock:
+	task_unlock(current);
+	return retval;
+}
+
+
 #define F_ALL_SEALS (F_SEAL_SEAL | \
 		     F_SEAL_SHRINK | \
 		     F_SEAL_GROW | \
-		     F_SEAL_WRITE)
+		     F_SEAL_WRITE | \
+		     F_SEAL_WRITE_PEER)
 
 int shmem_add_seals(struct file *file, unsigned int seals)
 {
@@ -1965,6 +2037,11 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 	 *   SEAL_SHRINK: Prevent the file from shrinking
 	 *   SEAL_GROW: Prevent the file from growing
 	 *   SEAL_WRITE: Prevent write access to the file
+	 *   SEAL_WRITE_PEER:	Same effect as SEAL_WRITE, except the task
+	 *			that created the file is allowed to write, and
+	 *			retain a single writable shared mapping.
+	 *			authentication is done using the the tasks
+	 *			files_struct address.
 	 *
 	 * As we don't require any trust relationship between two parties, we
 	 * must prevent seals from being removed. Therefore, sealing a file
@@ -1993,7 +2070,22 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 		goto unlock;
 	}
 
+	if (seals & F_SEAL_WRITE_PEER && !(info->seals & F_SEAL_WRITE_PEER)) {
+		error = shmem_seal_write_peer(file, seals, info);
+		if (error)
+			goto unlock;
+		/* 
+		 * info->auth may be cleared if fd is re-open(2)'d via /proc
+		 * because O_TRUNC causes flush. seal shrink to prevent this. 
+		 */
+		seals |= F_SEAL_SHRINK;
+	}
+
 	if ((seals & F_SEAL_WRITE) && !(info->seals & F_SEAL_WRITE)) {
+		if (info->seals & F_SEAL_WRITE_PEER) {
+			error = -EPERM;
+			goto unlock;
+		}
 		error = mapping_deny_writable(file->f_mapping);
 		if (error)
 			goto unlock;
@@ -2061,6 +2153,12 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 
 	mutex_lock(&inode->i_mutex);
 
+	if (info->seals & F_SEAL_WRITE_PEER
+			&& current->files != info->auth) {
+		error = -EPERM;
+		goto out;
+	}
+	
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		struct address_space *mapping = file->f_mapping;
 		loff_t unmap_start = round_up(offset, PAGE_SIZE);
@@ -2960,8 +3058,10 @@ SYSCALL_DEFINE2(memfd_create,
 	info = SHMEM_I(file_inode(file));
 	file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
 	file->f_flags |= O_RDWR | O_LARGEFILE;
-	if (flags & MFD_ALLOW_SEALING)
+	if (flags & MFD_ALLOW_SEALING) {
 		info->seals &= ~F_SEAL_SEAL;
+		info->auth = current->files;
+	}
 
 	fd_install(fd, file);
 	kfree(name);
@@ -2974,6 +3074,18 @@ err_name:
 	return error;
 }
 
+static int shmem_flush(struct file *file, fl_owner_t id)
+{
+	struct shmem_inode_info *info;
+	info = SHMEM_I(file_inode(file));
+	
+	/* F_SEAL_WRITE_PEER clears auth value if owner closes file */
+	if (info->auth == current->files
+			&& atomic_read(&file->f_mapping->i_mmap_writable) <= 0)
+		info->auth = NULL;
+	return 0;
+}
+
 #endif /* CONFIG_TMPFS */
 
 static void shmem_put_super(struct super_block *sb)
@@ -3124,6 +3236,7 @@ static const struct file_operations shmem_file_operations = {
 	.splice_read	= shmem_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= shmem_fallocate,
+	.flush		= shmem_flush,
 #endif
 };
 
diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 0b9eafb..b4afe2b 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -677,6 +677,98 @@ static void test_seal_shrink(void)
 }
 
 /*
+ * Test SEAL_WRITE_PEER
+ * Test whether SEAL_WRITE_PEER prevents modifications for all processes
+ * except for the one that created the memfd.
+ */
+static void test_seal_write_peer()
+{
+	int fd, fd2;
+	void *p, *p2, *privmap, *privmap2;
+	pid_t pid;
+	pid_t parent_pid;
+	int status;
+	char buf[MFD_DEF_SIZE*10];
+
+	parent_pid = getpid();
+	fd = mfd_assert_new("kern_memfd_seal_write_peer",
+					MFD_DEF_SIZE,
+					MFD_CLOEXEC | MFD_ALLOW_SEALING);
+
+	/* create 2 shared|writes, and one private|read */
+	p = mfd_assert_mmap_shared(fd);
+	p2 = mfd_assert_mmap_shared(fd);
+	privmap = mfd_assert_mmap_private(fd);
+	/* verify that seal fails if multiple shared write mappings present */
+	mfd_fail_add_seals(fd, F_SEAL_WRITE_PEER);
+	munmap(p2, MFD_DEF_SIZE); /* unmap so theres only 1 shared|write */
+
+
+	/* private mappings with read|write made before seal is applied will
+	 * end up having a MAP_SHARED set. in shmem_seal_write_peer there
+	 * were some VM_SHARED mappings in task. the function ensures that
+	 * if more than one VM_SHARED exists, the seal fails. so any private
+	 * mappings with PROT_WRITE need to be created after F_SEAL_WRITE_PEER
+	 * has been set.
+	 */ 
+	privmap2 = mmap(NULL, MFD_DEF_SIZE,
+			PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
+	if (privmap2 == MAP_FAILED)
+		abort();
+	mfd_fail_add_seals(fd, F_SEAL_WRITE_PEER);
+	munmap(privmap2, MFD_DEF_SIZE);
+
+
+	/* F_SEAL_WRITE_PEER and F_SEAL_WRITE cannot coexist */
+	mfd_assert_add_seals(fd, F_SEAL_WRITE_PEER);
+	mfd_assert_has_seals(fd, F_SEAL_WRITE_PEER | F_SEAL_SHRINK);
+	mfd_fail_add_seals(fd, F_SEAL_WRITE);
+
+	/* verify that no further shared|write mappings can be made. */
+	p2 = mmap(NULL, MFD_DEF_SIZE, 
+			PROT_READ | PROT_WRITE,
+			MAP_SHARED,
+			fd, 0);
+	if (p2 != MAP_FAILED)
+		abort();
+
+	mfd_assert_read(fd);
+	mfd_fail_shrink(fd);
+	mfd_assert_grow(fd);
+	mfd_assert_grow_write(fd);
+	
+	/* check authentication */
+	pid = fork();
+	if (pid == 0) /*this new process is not creator, writes should fail*/
+	{
+		/* attempt re-open peer fd with read/write */
+		sprintf(buf, "/proc/%d/fd/%d", parent_pid, fd);
+		/*fd = open(buf, O_RDWR | O_CREAT , S_IRUSR | S_IWUSR);*/
+		mfd_fail_shrink(fd);
+		mfd_fail_write(fd);
+		lseek(fd, 0, SEEK_SET);
+		mfd_fail_grow(fd);
+		mfd_fail_grow_write(fd);
+		mfd_assert_read(fd);
+		printf("|----: expecting segfault in forked process...\n");
+		memset(p2, 'Z', MFD_DEF_SIZE);
+		printf("|----: no segfault\n");
+		exit(-1);
+	} else if (pid == -1) {
+		printf("fork(): %m\n");
+		abort();
+	}
+	
+	/*mfd_assert_write_nommap(fd);*/
+	/* abort if other process did not crash */ 
+	pid = waitpid(pid, &status, 0);
+	if (WIFEXITED(status))
+		abort();
+
+	close(fd);
+}
+
+/*
  * Test SEAL_GROW
  * Test whether SEAL_GROW actually prevents growing
  */
@@ -878,6 +970,8 @@ int main(int argc, char **argv)
 	test_seal_write();
 	printf("memfd: SEAL-SHRINK\n");
 	test_seal_shrink();
+	printf("memfd: SEAL-WRITE-PEER\n");
+	test_seal_write_peer();
 	printf("memfd: SEAL-GROW\n");
 	test_seal_grow();
 	printf("memfd: SEAL-RESIZE\n");
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
