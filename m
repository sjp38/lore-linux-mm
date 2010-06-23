Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26B756B01AD
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 06:04:46 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o5NA4eBo001502
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:40 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5NA4gng1220614
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:42 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5NA4bf6005523
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:40 +1000
From: "Ian Munsie" <imunsie@au1.ibm.com>
Subject: [PATCH 32/40] trace syscalls: Record metadata for syscalls with their own wrappers
Date: Wed, 23 Jun 2010 20:03:13 +1000
Message-Id: <1277287401-28571-33-git-send-email-imunsie@au1.ibm.com>
In-Reply-To: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Cc: Jason Baron <jbaron@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <michael@ellerman.id.au>, Ian Munsie <imunsie@au1.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Alexander Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Eric Paris <eparis@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <jens.axboe@oracle.com>, Jan Blunck <jblunck@suse.de>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@elte.hu>, Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <npiggin@suse.de>, Julia Lawall <julia@diku.dk>, "Serge E. Hallyn" <serue@us.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, linux-s390@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ian Munsie <imunsie@au1.ibm.com>

This patch adds support for syscalls using the SYSCALL_DEFINE macro
(i.e. ones that require a specialised syscall wrapper) to record their
meta-data for system call tracing.

The semantics of the SYSCALL_DEFINE macro therefore change to include
the number of arguments to the syscall and the arguments and types. All
instances of this macro have been updated to the new semantics.

Signed-off-by: Ian Munsie <imunsie@au1.ibm.com>
---
 arch/s390/kernel/sys_s390.c |    4 ++--
 fs/dcookies.c               |    2 +-
 fs/open.c                   |    6 +++---
 fs/read_write.c             |    8 ++++----
 fs/sync.c                   |    8 ++++----
 include/linux/syscalls.h    |    9 +++++++--
 ipc/sem.c                   |    2 +-
 mm/fadvise.c                |    4 ++--
 mm/filemap.c                |    2 +-
 9 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/arch/s390/kernel/sys_s390.c b/arch/s390/kernel/sys_s390.c
index 7b6b0f8..7773c87 100644
--- a/arch/s390/kernel/sys_s390.c
+++ b/arch/s390/kernel/sys_s390.c
@@ -185,8 +185,8 @@ SYSCALL_DEFINE1(s390_fadvise64_64, struct fadvise64_64_args __user *, args)
  * to
  *   %r2: fd, %r3: mode, %r4/%r5: offset, 96(%r15)-103(%r15): len
  */
-SYSCALL_DEFINE(s390_fallocate)(int fd, int mode, loff_t offset,
-			       u32 len_high, u32 len_low)
+SYSCALL_DEFINE(s390_fallocate, 5, int, fd, int, mode, loff_t, offset,
+			       u32, len_high, u32, len_low)
 {
 	return sys_fallocate(fd, mode, offset, ((u64)len_high << 32) | len_low);
 }
diff --git a/fs/dcookies.c b/fs/dcookies.c
index a21cabd..794cf94 100644
--- a/fs/dcookies.c
+++ b/fs/dcookies.c
@@ -145,7 +145,7 @@ out:
 /* And here is where the userspace process can look up the cookie value
  * to retrieve the path.
  */
-SYSCALL_DEFINE(lookup_dcookie)(u64 cookie64, char __user * buf, size_t len)
+SYSCALL_DEFINE(lookup_dcookie, 3, u64, cookie64, char __user *, buf, size_t, len)
 {
 	unsigned long cookie = (unsigned long)cookie64;
 	int err = -EINVAL;
diff --git a/fs/open.c b/fs/open.c
index 5463266..4107638 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -185,7 +185,7 @@ SYSCALL_DEFINE2(ftruncate, unsigned int, fd, unsigned long, length)
 
 /* LFS versions of truncate are only needed on 32 bit machines */
 #if BITS_PER_LONG == 32
-SYSCALL_DEFINE(truncate64)(const char __user * path, loff_t length)
+SYSCALL_DEFINE(truncate64, 2, const char __user *, path, loff_t, length)
 {
 	return do_sys_truncate(path, length);
 }
@@ -197,7 +197,7 @@ asmlinkage long SyS_truncate64(long path, loff_t length)
 SYSCALL_ALIAS(sys_truncate64, SyS_truncate64);
 #endif
 
-SYSCALL_DEFINE(ftruncate64)(unsigned int fd, loff_t length)
+SYSCALL_DEFINE(ftruncate64, 2, unsigned int, fd, loff_t, length)
 {
 	long ret = do_sys_ftruncate(fd, length, 0);
 	/* avoid REGPARM breakage on x86: */
@@ -256,7 +256,7 @@ int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	return inode->i_op->fallocate(inode, mode, offset, len);
 }
 
-SYSCALL_DEFINE(fallocate)(int fd, int mode, loff_t offset, loff_t len)
+SYSCALL_DEFINE(fallocate, 4, int, fd, int, mode, loff_t, offset, loff_t, len)
 {
 	struct file *file;
 	int error = -EBADF;
diff --git a/fs/read_write.c b/fs/read_write.c
index 9c04852..5b4044f 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -423,8 +423,8 @@ SYSCALL_DEFINE3(write, unsigned int, fd, const char __user *, buf,
 	return ret;
 }
 
-SYSCALL_DEFINE(pread64)(unsigned int fd, char __user *buf,
-			size_t count, loff_t pos)
+SYSCALL_DEFINE(pread64, 4, unsigned int, fd, char __user *, buf,
+			size_t, count, loff_t, pos)
 {
 	struct file *file;
 	ssize_t ret = -EBADF;
@@ -452,8 +452,8 @@ asmlinkage long SyS_pread64(long fd, long buf, long count, loff_t pos)
 SYSCALL_ALIAS(sys_pread64, SyS_pread64);
 #endif
 
-SYSCALL_DEFINE(pwrite64)(unsigned int fd, const char __user *buf,
-			 size_t count, loff_t pos)
+SYSCALL_DEFINE(pwrite64, 4, unsigned int, fd, const char __user *, buf,
+			 size_t, count, loff_t, pos)
 {
 	struct file *file;
 	ssize_t ret = -EBADF;
diff --git a/fs/sync.c b/fs/sync.c
index 15aa6f0..5cb8072 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -292,8 +292,8 @@ EXPORT_SYMBOL(generic_write_sync);
  * already-instantiated disk blocks, there are no guarantees here that the data
  * will be available after a crash.
  */
-SYSCALL_DEFINE(sync_file_range)(int fd, loff_t offset, loff_t nbytes,
-				unsigned int flags)
+SYSCALL_DEFINE(sync_file_range, 4, int, fd, loff_t, offset, loff_t, nbytes,
+				unsigned int, flags)
 {
 	int ret;
 	struct file *file;
@@ -387,8 +387,8 @@ SYSCALL_ALIAS(sys_sync_file_range, SyS_sync_file_range);
 
 /* It would be nice if people remember that not all the world's an i386
    when they introduce new system calls */
-SYSCALL_DEFINE(sync_file_range2)(int fd, unsigned int flags,
-				 loff_t offset, loff_t nbytes)
+SYSCALL_DEFINE(sync_file_range2, 4, int, fd, unsigned int, flags,
+				 loff_t, offset, loff_t, nbytes)
 {
 	return sys_sync_file_range(fd, offset, nbytes, flags);
 }
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 1076ae8..d7eaa4b 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -251,7 +251,9 @@ extern struct trace_event_functions exit_syscall_print_funcs;
 
 #ifdef CONFIG_HAVE_SYSCALL_WRAPPERS
 
-#define SYSCALL_DEFINE(name) static inline long SYSC_##name
+#define SYSCALL_DEFINE(name, x, ...)					\
+	SYSCALL_METADATAx(sys_##name, sys_##name, x, syscall, __VA_ARGS__);\
+	static inline long SYSC_##name(__SC_DECL##x(__VA_ARGS__))
 
 #define __SYSCALL_DEFINEx(x, name, ...)					\
 	asmlinkage long sys##name(__SC_DECL##x(__VA_ARGS__));		\
@@ -266,7 +268,10 @@ extern struct trace_event_functions exit_syscall_print_funcs;
 
 #else /* CONFIG_HAVE_SYSCALL_WRAPPERS */
 
-#define SYSCALL_DEFINE(name) asmlinkage long sys_##name
+#define SYSCALL_DEFINE(name, x, ...)					\
+	SYSCALL_METADATAx(sys_##name, sys_##name, x, syscall, __VA_ARGS__);\
+	asmlinkage long sys_##name(__SC_DECL##x(__VA_ARGS__))
+
 #define __SYSCALL_DEFINEx(x, name, ...)					\
 	asmlinkage long sys##name(__SC_DECL##x(__VA_ARGS__))
 
diff --git a/ipc/sem.c b/ipc/sem.c
index 506c849..1a1716b 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1074,7 +1074,7 @@ out_up:
 	return err;
 }
 
-SYSCALL_DEFINE(semctl)(int semid, int semnum, int cmd, union semun arg)
+SYSCALL_DEFINE(semctl, 4, int, semid, int, semnum, int, cmd, union semun, arg)
 {
 	int err = -EINVAL;
 	int version;
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 8d723c9..5105afa 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -24,7 +24,7 @@
  * POSIX_FADV_WILLNEED could set PG_Referenced, and POSIX_FADV_NOREUSE could
  * deactivate the pages and clear PG_Referenced.
  */
-SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
+SYSCALL_DEFINE(fadvise64_64, 4, int, fd, loff_t, offset, loff_t, len, int, advice)
 {
 	struct file *file = fget(fd);
 	struct address_space *mapping;
@@ -144,7 +144,7 @@ SYSCALL_ALIAS(sys_fadvise64_64, SyS_fadvise64_64);
 
 #ifdef __ARCH_WANT_SYS_FADVISE64
 
-SYSCALL_DEFINE(fadvise64)(int fd, loff_t offset, size_t len, int advice)
+SYSCALL_DEFINE(fadvise64, 4, int, fd, loff_t, offset, size_t, len, int, advice)
 {
 	return sys_fadvise64_64(fd, offset, len, advice);
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index 20e5642..967d6bb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1372,7 +1372,7 @@ do_readahead(struct address_space *mapping, struct file *filp,
 	return 0;
 }
 
-SYSCALL_DEFINE(readahead)(int fd, loff_t offset, size_t count)
+SYSCALL_DEFINE(readahead, 3, int, fd, loff_t, offset, size_t, count)
 {
 	ssize_t ret;
 	struct file *file;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
