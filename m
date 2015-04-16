Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id F22D96B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 04:14:13 -0400 (EDT)
Received: by lbbuc2 with SMTP id uc2so52706596lbb.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 01:14:13 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id xs10si5858609lbb.86.2015.04.16.01.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 01:14:12 -0700 (PDT)
Received: by lagv1 with SMTP id v1so50910065lag.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 01:14:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150416032316.00b79732@yak.slack>
References: <20150416032316.00b79732@yak.slack>
Date: Thu, 16 Apr 2015 11:14:11 +0300
Message-ID: <CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd: F_SEAL_WRITE_NONCREATOR
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Tirado <mtirado418@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 16, 2015 at 10:23 AM, Michael Tirado <mtirado418@gmail.com> wrote:
> Hi everyone, I have 2 questions (see comments marked with "Question:")
> that I am hoping to get some input on.  Any feedback in general you can offer
> is greatly appreciated.  Most importantly, I would like to be sure that this
> is a valid way to implement such a seal.  This is my first kernel modification
> and I haven't been following the mailing list for very long (for the record
> in case there is a dumb mistake in here)   I don't know any kernel devs and
> figured this would be the most appropriate place to find some useful feedback.
>
> This seal is similar to F_SEAL_WRITE, but will allow the task that created the
> memfd to continue writing and retain a single shared writable mapping. Needed for
> one-way communication between processes, authenticated at the task level.
> Currently the only way to accomplish this is by constantly creating, filling,
> sealing write, then sending memfd.  Also, a different name suggestion is welcome.

I guess that was in original design but was dropped for some reason.
Probably that approach couldn't be implemented without flaws or overhead.


Keeping pointer to priviledged task is a bad idea.
There is no easy way to drop it when task exits and this doesn't work
for threads.

I think it's better to keep pointer to priveledged struct file and
drop it in method
f_op->release() when task closes fd or exits. Server task could obtain second
non-priveledged fd and struct file for that inode via
open(/proc/../fd/), dup3(),
openat() or something else and send it to read-only users.

>
> Signed-off-by: Michael R. Tirado <mtirado418@gmail.com>
> ---
>  include/linux/shmem_fs.h                   |   1 +
>  include/uapi/linux/fcntl.h                 |   1 +
>  kernel/fork.c                              |   1 +
>  mm/shmem.c                                 |  77 +++++++++++++++++++--
>  tools/testing/selftests/memfd/memfd_test.c | 107 +++++++++++++++++++++++++++++
>  5 files changed, 182 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 50777b5..ee25ab3 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -12,6 +12,7 @@
>
>  struct shmem_inode_info {
>         spinlock_t              lock;
> +       void                    *creator;       /* for authentication only */
>         unsigned int            seals;          /* shmem seals */
>         unsigned long           flags;
>         unsigned long           alloced;        /* data pages alloced to file */
> diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
> index beed138..f339f22 100644
> --- a/include/uapi/linux/fcntl.h
> +++ b/include/uapi/linux/fcntl.h
> @@ -40,6 +40,7 @@
>  #define F_SEAL_SHRINK  0x0002  /* prevent file from shrinking */
>  #define F_SEAL_GROW    0x0004  /* prevent file from growing */
>  #define F_SEAL_WRITE   0x0008  /* prevent writes */
> +#define F_SEAL_WRITE_NONCREATOR 0x0010 /* prevent writes if not creator task */
>  /* (1U << 31) is reserved for signed error codes */
>
>  /*
> diff --git a/kernel/fork.c b/kernel/fork.c
> index cf65139..f1a35d0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -434,6 +434,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>                         if (tmp->vm_flags & VM_DENYWRITE)
>                                 atomic_dec(&inode->i_writecount);
>                         i_mmap_lock_write(mapping);
> + /*Question: should this be atomic_inc_unless_negative, or is this negligible since it should never be reached?*/
>                         if (tmp->vm_flags & VM_SHARED)
>                                 atomic_inc(&mapping->i_mmap_writable);
>                         flush_dcache_mmap_lock(mapping);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index cf2d0ca..1e35bc2 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1481,9 +1481,12 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
>         pgoff_t index = pos >> PAGE_CACHE_SHIFT;
>
>         /* i_mutex is held by caller */
> -       if (unlikely(info->seals)) {
> -               if (info->seals & F_SEAL_WRITE)
> +       if (info->seals) {
> +               if (info->seals & F_SEAL_WRITE_NONCREATOR && info->creator == current)
> +                       goto skip_write_seal;
> +               if (info->seals & (F_SEAL_WRITE | F_SEAL_WRITE_NONCREATOR))
>                         return -EPERM;
> +skip_write_seal:
>                 if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
>                         return -EPERM;
>         }
> @@ -1938,10 +1941,52 @@ continue_resched:
>         return error;
>  }
>
> +/* returns 0 if ok, error if seal cannot be applied */
> +static int shmem_seal_noncreator(struct file *file, unsigned int seals,
> +               struct shmem_inode_info *info)
> +{
> +       struct vm_area_struct *vma = NULL;
> +       struct vm_area_struct *curvma;
> +       int c = 0;
> +
> +       if (seals & F_SEAL_WRITE || info->seals & F_SEAL_WRITE)
> +               return -EPERM; /* these two seals cannot coexist */
> +
> +       if (atomic_read(&file->f_mapping->i_mmap_writable) == 0
> +                       || info->seals & F_SEAL_WRITE_NONCREATOR)
> +               return 0;
> +
> +       if (atomic_read(&file->f_mapping->i_mmap_writable) > 1
> +                       || current != info->creator)
> +               return -EPERM;
> +
> +       /*
> +        * search current task vma's for the file
> +        * ensure that only one writable shared mapping exists
> +        */
> +       for (curvma = current->mm->mmap; curvma; curvma = curvma->vm_next) {
> +               if (curvma->vm_file == file) {
> +                       if (curvma->vm_flags & (VM_WRITE | VM_SHARED)) {
> +                               if (++c > 1)
> +                                       return -EPERM;
> +                               vma = curvma;
> +                       }
> +               }
> +       }
> +       if (vma == NULL)
> +               return -EPERM;
> +
> +       vma->vm_flags |= VM_DONTCOPY | VM_DENYWRITE;
> +       mapping_unmap_writable(file->f_mapping);
> +       return mapping_deny_writable(file->f_mapping);
> +}
> +
> +
>  #define F_ALL_SEALS (F_SEAL_SEAL | \
>                      F_SEAL_SHRINK | \
>                      F_SEAL_GROW | \
> -                    F_SEAL_WRITE)
> +                    F_SEAL_WRITE | \
> +                    F_SEAL_WRITE_NONCREATOR)
>
>  int shmem_add_seals(struct file *file, unsigned int seals)
>  {
> @@ -1965,6 +2010,9 @@ int shmem_add_seals(struct file *file, unsigned int seals)
>          *   SEAL_SHRINK: Prevent the file from shrinking
>          *   SEAL_GROW: Prevent the file from growing
>          *   SEAL_WRITE: Prevent write access to the file
> +        *   SEAL_WRITE_NONCREATOR: same effect as SEAL_WRITE, except the task
> +        *                      that created the file is allowed to write, and
> +        *                      retain a single writable shared mapping.
>          *
>          * As we don't require any trust relationship between two parties, we
>          * must prevent seals from being removed. Therefore, sealing a file
> @@ -1993,7 +2041,16 @@ int shmem_add_seals(struct file *file, unsigned int seals)
>                 goto unlock;
>         }
>
> +       if (seals & F_SEAL_WRITE_NONCREATOR) {
> +               error = shmem_seal_noncreator(file, seals, info);
> +               if (error)
> +                       goto unlock;
> +       }
>         if ((seals & F_SEAL_WRITE) && !(info->seals & F_SEAL_WRITE)) {
> +               if (info->seals & F_SEAL_WRITE_NONCREATOR) {
> +                       error = -EPERM;
> +                       goto unlock;
> +               }
>                 error = mapping_deny_writable(file->f_mapping);
>                 if (error)
>                         goto unlock;
> @@ -2068,11 +2125,19 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>                 DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
>
>                 /* protected by i_mutex */
> +               if (info->seals & F_SEAL_WRITE_NONCREATOR) {
> +                       if(current == info->creator)
> +                               goto skip_write_seal;
> +                       else {
> +                               error = -EPERM;
> +                               goto out;
> +                       }
> +               }
>                 if (info->seals & F_SEAL_WRITE) {
>                         error = -EPERM;
>                         goto out;
>                 }
> -
> +skip_write_seal:
>                 shmem_falloc.waitq = &shmem_falloc_waitq;
>                 shmem_falloc.start = unmap_start >> PAGE_SHIFT;
>                 shmem_falloc.next = (unmap_end + 1) >> PAGE_SHIFT;
> @@ -2960,8 +3025,10 @@ SYSCALL_DEFINE2(memfd_create,
>         info = SHMEM_I(file_inode(file));
>         file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
>         file->f_flags |= O_RDWR | O_LARGEFILE;
> -       if (flags & MFD_ALLOW_SEALING)
> +       if (flags & MFD_ALLOW_SEALING) {
>                 info->seals &= ~F_SEAL_SEAL;
> +               info->creator = current;
> +       }/* Question: do we not want a clear info->seals? why the &= ? */
>
>         fd_install(fd, file);
>         kfree(name);
> diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
> index 0b9eafb..bc1f829 100644
> --- a/tools/testing/selftests/memfd/memfd_test.c
> +++ b/tools/testing/selftests/memfd/memfd_test.c
> @@ -321,6 +321,18 @@ static void mfd_assert_write(int fd)
>         }
>  }
>
> +static void mfd_assert_write_nommap(int fd)
> +{
> +       ssize_t l;
> +
> +       /* verify write() succeeds */
> +       l = write(fd, "\0\0\0\0", 4);
> +       if (l != 4) {
> +               printf("write() failed: %m\n");
> +               abort();
> +       }
> +}
> +
>  static void mfd_fail_write(int fd)
>  {
>         ssize_t l;
> @@ -652,6 +664,99 @@ static void test_seal_write(void)
>         close(fd);
>  }
>
> +
> +/*
> + * Test SEAL_WRITE_NONCREATOR
> + * Test whether SEAL_WRITE_NONCREATOR prevents modifications for all processes
> + * except for the one that created the memfd, and also closes mapping on fork.
> + */
> +static void test_seal_write_noncreator()
> +{
> +       int fd;
> +       void *p, *p2, *privmap, *privmap2;
> +       pid_t pid;
> +       int status;
> +
> +       fd = mfd_assert_new("kern_memfd_seal_write_noncreator",
> +                                       MFD_DEF_SIZE,
> +                                       MFD_CLOEXEC | MFD_ALLOW_SEALING);
> +
> +       /* create 2 shared|writes, and one private|read */
> +       mfd_assert_has_seals(fd, 0);
> +       p = mfd_assert_mmap_shared(fd);
> +       p2 = mfd_assert_mmap_shared(fd);
> +       privmap = mfd_assert_mmap_private(fd);
> +
> +       /* verify that seal fails if multiple shared write mappings present*/
> +       mfd_fail_add_seals(fd, F_SEAL_WRITE_NONCREATOR);
> +       munmap(p2, MFD_DEF_SIZE); /*unmap so theres only 1 shared|write*/
> +
> +       /* F_SEAL_WRITE_NONCREATOR and F_SEAL_WRITE cannot coexist */
> +       mfd_assert_add_seals(fd, F_SEAL_WRITE_NONCREATOR);
> +       mfd_assert_has_seals(fd, F_SEAL_WRITE_NONCREATOR);
> +       mfd_fail_add_seals(fd, F_SEAL_WRITE);
> +
> +       /* private mappings with read|write end up having vma with
> +        * VM_SHARED set, which this seal checks and will allow only one
> +        * to exist.  If more than one VM_SHARED exists, the seal fails.
> +        * so any private mappings with PROT_WRITE need to be created after
> +        * F_SEAL_WRITE_NONCREATOR has been applied.
> +        */
> +       privmap2 = mmap(NULL, MFD_DEF_SIZE,
> +                       PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
> +       if (privmap2 == MAP_FAILED)
> +               abort();
> +
> +       /* verify that no further shared|write mappings can be made. */
> +       p2 = mmap(NULL, MFD_DEF_SIZE,
> +                       PROT_READ | PROT_WRITE,
> +                       MAP_SHARED,
> +                       fd, 0);
> +       if (p2 != MAP_FAILED)
> +               abort();
> +
> +       mfd_assert_write_nommap(fd);
> +       mfd_assert_read(fd);
> +       mfd_assert_shrink(fd);
> +       mfd_assert_grow(fd);
> +       mfd_assert_grow_write(fd);
> +       memset(p, 'A', MFD_DEF_SIZE);
> +       memset(privmap2, 'B', MFD_DEF_SIZE);
> +
> +       /* check authentication */
> +       pid = fork();
> +       if (pid == 0) /*this new process is not creator, writes should fail*/
> +       {
> +               mfd_fail_write(fd);
> +               mfd_fail_grow_write(fd);
> +               mfd_assert_read(fd);
> +               if (*(char *)privmap != 'A' || *(char *)privmap2 != 'B')
> +                       exit(-1); /* just double checking */
> +               memset(privmap2, 'Y', MFD_DEF_SIZE);
> +               printf("|----: expecting segfault in forked process...\n");
> +               memset(p, 'X', MFD_DEF_SIZE);
> +               printf("|----: did not crash :(\n");
> +               close(fd);
> +               exit(-1);
> +       }
> +
> +       /* abort if other process did not crash */
> +       pid = waitpid(pid, &status, 0);
> +       if (WIFEXITED(status))
> +               abort();
> +
> +       /*tinfoil level error checking */
> +       if (*(char *)privmap != 'A'
> +                       || *(char *)privmap2 != 'B'
> +                       || *(char *)p != 'A')
> +               abort();
> +
> +       munmap(p, MFD_DEF_SIZE);
> +       munmap(privmap, MFD_DEF_SIZE);
> +       munmap(privmap2, MFD_DEF_SIZE);
> +       close(fd);
> +}
> +
>  /*
>   * Test SEAL_SHRINK
>   * Test whether SEAL_SHRINK actually prevents shrinking
> @@ -882,6 +987,8 @@ int main(int argc, char **argv)
>         test_seal_grow();
>         printf("memfd: SEAL-RESIZE\n");
>         test_seal_resize();
> +       printf("memfd: SEAL-WRITE-NONCREATOR\n");
> +       test_seal_write_noncreator();
>
>         printf("memfd: SHARE-DUP\n");
>         test_share_dup();
> --
> 1.8.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
