Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D74F6B28EB
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:27:11 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so11904923plt.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:27:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r1-v6si52269278plb.153.2018.11.21.18.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 18:27:09 -0800 (PST)
Date: Wed, 21 Nov 2018 18:27:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-Id: <20181121182701.0d8a775fda6af1f8d2be8f25@linux-foundation.org>
In-Reply-To: <20181120211335.GC22801@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
	<CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
	<20181120183926.GA124387@google.com>
	<20181121070658.011d576d@canb.auug.org.au>
	<469B80CB-D982-4802-A81D-95AC493D7E87@amacapital.net>
	<20181120204710.GB22801@google.com>
	<F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
	<20181120211335.GC22801@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Stephen Rothwell <sfr@canb.auug.org.au>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

On Tue, 20 Nov 2018 13:13:35 -0800 Joel Fernandes <joel@joelfernandes.org> wrote:

> > > I am Ok with whatever Andrew wants to do, if it is better to squash it with
> > > the original, then I can do that and send another patch.
> > > 
> > > 
> > 
> > From experience, Andrew will food in fixups on request :)
> 
> Andrew, could you squash this patch into the one titled ("mm: Add an
> F_SEAL_FUTURE_WRITE seal to memfd")? 

Sure.

I could of course queue them separately but I rarely do so - I don't
think that the intermediate development states are useful in the
infinite-term, and I make them available via additional Link: tags in
the changelog footers anyway.

I think that the magnitude of these patches is such that John Stultz's
Reviewed-by is invalidated, so this series is now in the "unreviewed"
state.

So can we have a re-review please?  For convenience, here's the
folded-together [1/1] patch, as it will go to Linus.


From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: mm: Add an F_SEAL_FUTURE_WRITE seal to memfd

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
keeping the existing mmap active.  The following program shows the seal
working in action:

 #include <stdio.h>
 #include <errno.h>
 #include <sys/mman.h>
 #include <linux/memfd.h>
 #include <linux/fcntl.h>
 #include <asm/unistd.h>
 #include <unistd.h>
 #define F_SEAL_FUTURE_WRITE 0x0010
 #define REGION_SIZE (5 * 1024 * 1024)

int memfd_create_region(const char *name, size_t size)
{
    int ret;
    int fd = syscall(__NR_memfd_create, name, MFD_ALLOW_SEALING);
    if (fd < 0) return fd;
    ret = ftruncate(fd, size);
    if (ret < 0) { close(fd); return ret; }
    return fd;
}

int main() {
    int ret, fd;
    void *addr, *addr2, *addr3, *addr1;
    ret = memfd_create_region("test_region", REGION_SIZE);
    printf("ret=%d\n", ret);
    fd = ret;

    // Create map
    addr = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr == MAP_FAILED)
	    printf("map 0 failed\n");
    else
	    printf("map 0 passed\n");

    if ((ret = write(fd, "test", 4)) != 4)
	    printf("write failed even though no future-write seal "
		   "(ret=%d errno =%d)\n", ret, errno);
    else
	    printf("write passed\n");

    addr1 = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr1 == MAP_FAILED)
	    perror("map 1 prot-write failed even though no seal\n");
    else
	    printf("map 1 prot-write passed as expected\n");

    ret = fcntl(fd, F_ADD_SEALS, F_SEAL_FUTURE_WRITE |
				 F_SEAL_GROW |
				 F_SEAL_SHRINK);
    if (ret == -1)
	    printf("fcntl failed, errno: %d\n", errno);
    else
	    printf("future-write seal now active\n");

    if ((ret = write(fd, "test", 4)) != 4)
	    printf("write failed as expected due to future-write seal\n");
    else
	    printf("write passed (unexpected)\n");

    addr2 = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr2 == MAP_FAILED)
	    perror("map 2 prot-write failed as expected due to seal\n");
    else
	    printf("map 2 passed\n");

    addr3 = mmap(0, REGION_SIZE, PROT_READ, MAP_SHARED, fd, 0);
    if (addr3 == MAP_FAILED)
	    perror("map 3 failed\n");
    else
	    printf("map 3 prot-read passed as expected\n");
}

The output of running this program is as follows:
ret=3
map 0 passed
write passed
map 1 prot-write passed as expected
future-write seal now active
write failed as expected due to future-write seal
map 2 prot-write failed as expected due to seal
: Permission denied
map 3 prot-read passed as expected

[joel@joelfernandes.org: make F_SEAL_FUTURE_WRITE seal more robust]
  Link: http://lkml.kernel.org/r/20181120052137.74317-1-joel@joelfernandes.org
Link: http://lkml.kernel.org/r/20181108041537.39694-1-joel@joelfernandes.org
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: John Reck <jreck@google.com>
Cc: Todd Kjos <tkjos@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Daniel Colascione <dancol@google.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Lei Yang <Lei.Yang@windriver.com>
Cc: Marc-Andr Lureau <marcandre.lureau@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Jann Horn <jannh@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---


--- a/include/uapi/linux/fcntl.h~mm-add-an-f_seal_future_write-seal-to-memfd
+++ a/include/uapi/linux/fcntl.h
@@ -41,6 +41,7 @@
 #define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
 #define F_SEAL_GROW	0x0004	/* prevent file from growing */
 #define F_SEAL_WRITE	0x0008	/* prevent writes */
+#define F_SEAL_FUTURE_WRITE	0x0010  /* prevent future writes while mapped */
 /* (1U << 31) is reserved for signed error codes */
 
 /*
--- a/mm/memfd.c~mm-add-an-f_seal_future_write-seal-to-memfd
+++ a/mm/memfd.c
@@ -131,7 +131,8 @@ static unsigned int *memfd_file_seals_pt
 #define F_ALL_SEALS (F_SEAL_SEAL | \
 		     F_SEAL_SHRINK | \
 		     F_SEAL_GROW | \
-		     F_SEAL_WRITE)
+		     F_SEAL_WRITE | \
+		     F_SEAL_FUTURE_WRITE)
 
 static int memfd_add_seals(struct file *file, unsigned int seals)
 {
--- a/fs/hugetlbfs/inode.c~mm-add-an-f_seal_future_write-seal-to-memfd
+++ a/fs/hugetlbfs/inode.c
@@ -530,7 +530,7 @@ static long hugetlbfs_punch_hole(struct
 		inode_lock(inode);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			inode_unlock(inode);
 			return -EPERM;
 		}
--- a/mm/shmem.c~mm-add-an-f_seal_future_write-seal-to-memfd
+++ a/mm/shmem.c
@@ -2119,6 +2119,23 @@ out_nomem:
 
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
@@ -2344,8 +2361,9 @@ shmem_write_begin(struct file *file, str
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
@@ -2608,7 +2626,7 @@ static long shmem_fallocate(struct file
 		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			error = -EPERM;
 			goto out;
 		}
_
