Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2B56B00BB
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:28:14 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so3989836qcv.26
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 05:28:13 -0700 (PDT)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id n8si4376470qag.105.2014.06.13.05.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 05:28:12 -0700 (PDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so3296886qac.39
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 05:28:12 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 13 Jun 2014 14:27:52 +0200
Message-ID: <CAKgNAkgnnWjrbE+2KAETsmiyrnrMQu0h7-MrYLvkiwj--_nxcQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi David,

On Fri, Jun 13, 2014 at 12:36 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
> that you can pass to mmap(). It can support sealing and avoids any
> connection to user-visible mount-points. Thus, it's not subject to quotas
> on mounted file-systems, but can be used like malloc()'ed memory, but
> with a file-descriptor to it.
>
> memfd_create() returns the raw shmem file, so calls like ftruncate() can
> be used to modify the underlying inode. Also calls like fstat()
> will return proper information and mark the file as regular file. If you
> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
> supported (like on all other regular files).
>
> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
> subject to quotas and alike. It is still properly accounted to memcg
> limits, though.

Where do I find / is there detailed documentation (ideally, a man
page) for this new system call?

Cheers,

Michael


>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---
>  arch/x86/syscalls/syscall_32.tbl |  1 +
>  arch/x86/syscalls/syscall_64.tbl |  1 +
>  include/linux/syscalls.h         |  1 +
>  include/uapi/linux/memfd.h       |  8 +++++
>  kernel/sys_ni.c                  |  1 +
>  mm/shmem.c                       | 72 ++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 84 insertions(+)
>  create mode 100644 include/uapi/linux/memfd.h
>
> diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
> index d6b8679..e7495b4 100644
> --- a/arch/x86/syscalls/syscall_32.tbl
> +++ b/arch/x86/syscalls/syscall_32.tbl
> @@ -360,3 +360,4 @@
>  351    i386    sched_setattr           sys_sched_setattr
>  352    i386    sched_getattr           sys_sched_getattr
>  353    i386    renameat2               sys_renameat2
> +354    i386    memfd_create            sys_memfd_create
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index ec255a1..28be0e1 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -323,6 +323,7 @@
>  314    common  sched_setattr           sys_sched_setattr
>  315    common  sched_getattr           sys_sched_getattr
>  316    common  renameat2               sys_renameat2
> +317    common  memfd_create            sys_memfd_create
>
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index b0881a0..0be5d4d 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -802,6 +802,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
>  asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>  asmlinkage long sys_eventfd(unsigned int count);
>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
> +asmlinkage long sys_memfd_create(const char *uname_ptr, unsigned int flags);
>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
>  asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
>  asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
> diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
> new file mode 100644
> index 0000000..534e364
> --- /dev/null
> +++ b/include/uapi/linux/memfd.h
> @@ -0,0 +1,8 @@
> +#ifndef _UAPI_LINUX_MEMFD_H
> +#define _UAPI_LINUX_MEMFD_H
> +
> +/* flags for memfd_create(2) (unsigned int) */
> +#define MFD_CLOEXEC            0x0001U
> +#define MFD_ALLOW_SEALING      0x0002U
> +
> +#endif /* _UAPI_LINUX_MEMFD_H */
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 36441b5..489a4e6 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -197,6 +197,7 @@ cond_syscall(compat_sys_timerfd_settime);
>  cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
> +cond_syscall(sys_memfd_create);
>
>  /* performance counters: */
>  cond_syscall(sys_perf_event_open);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1438b3e..e7c5fe1 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -66,7 +66,9 @@ static struct vfsmount *shm_mnt;
>  #include <linux/highmem.h>
>  #include <linux/seq_file.h>
>  #include <linux/magic.h>
> +#include <linux/syscalls.h>
>  #include <linux/fcntl.h>
> +#include <uapi/linux/memfd.h>
>
>  #include <asm/uaccess.h>
>  #include <asm/pgtable.h>
> @@ -2662,6 +2664,76 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
>         shmem_show_mpol(seq, sbinfo->mpol);
>         return 0;
>  }
> +
> +#define MFD_NAME_PREFIX "memfd:"
> +#define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
> +#define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
> +
> +#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING)
> +
> +SYSCALL_DEFINE2(memfd_create,
> +               const char*, uname,
> +               unsigned int, flags)
> +{
> +       struct shmem_inode_info *info;
> +       struct file *file;
> +       int fd, error;
> +       char *name;
> +       long len;
> +
> +       if (flags & ~(unsigned int)MFD_ALL_FLAGS)
> +               return -EINVAL;
> +
> +       /* length includes terminating zero */
> +       len = strnlen_user(uname, MFD_NAME_MAX_LEN + 1);
> +       if (len <= 0)
> +               return -EFAULT;
> +       if (len > MFD_NAME_MAX_LEN + 1)
> +               return -EINVAL;
> +
> +       name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_TEMPORARY);
> +       if (!name)
> +               return -ENOMEM;
> +
> +       strcpy(name, MFD_NAME_PREFIX);
> +       if (copy_from_user(&name[MFD_NAME_PREFIX_LEN], uname, len)) {
> +               error = -EFAULT;
> +               goto err_name;
> +       }
> +
> +       /* terminating-zero may have changed after strnlen_user() returned */
> +       if (name[len + MFD_NAME_PREFIX_LEN - 1]) {
> +               error = -EFAULT;
> +               goto err_name;
> +       }
> +
> +       fd = get_unused_fd_flags((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0);
> +       if (fd < 0) {
> +               error = fd;
> +               goto err_name;
> +       }
> +
> +       file = shmem_file_setup(name, 0, VM_NORESERVE);
> +       if (IS_ERR(file)) {
> +               error = PTR_ERR(file);
> +               goto err_fd;
> +       }
> +       info = SHMEM_I(file_inode(file));
> +       file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
> +       if (flags & MFD_ALLOW_SEALING)
> +               info->seals &= ~F_SEAL_SEAL;
> +
> +       fd_install(fd, file);
> +       kfree(name);
> +       return fd;
> +
> +err_fd:
> +       put_unused_fd(fd);
> +err_name:
> +       kfree(name);
> +       return error;
> +}
> +
>  #endif /* CONFIG_TMPFS */
>
>  static void shmem_put_super(struct super_block *sb)
> --
> 2.0.0
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
