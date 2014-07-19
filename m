Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7482C6B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:29:31 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so5586833ier.27
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:29:31 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id dw5si14045594igb.18.2014.07.19.09.29.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:29:30 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so5620364iec.1
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:29:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407160306420.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-4-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407160306420.1775@eggly.anvils>
Date: Sat, 19 Jul 2014 18:29:30 +0200
Message-ID: <CANq1E4QivtLBoLz+0quKh5gxP2R0xwhCAA-oBdF_GTTRASzUcw@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] shm: add memfd_create() syscall
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Wed, Jul 16, 2014 at 12:07 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>> that you can pass to mmap(). It can support sealing and avoids any
>> connection to user-visible mount-points. Thus, it's not subject to quotas
>> on mounted file-systems, but can be used like malloc()'ed memory, but
>> with a file-descriptor to it.
>>
>> memfd_create() returns the raw shmem file, so calls like ftruncate() can
>> be used to modify the underlying inode. Also calls like fstat()
>> will return proper information and mark the file as regular file. If you
>> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
>> supported (like on all other regular files).
>>
>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>> subject to quotas and alike. It is still properly accounted to memcg
>> limits, though.
>
> It's an important point, but unclear quite what "quotas and alike" means.
> There's never been any quota support in shmem/tmpfs, but filesystem size
> can be limited.  Maybe say "and is not subject to a filesystem size limit.
> It is still properly accounted to memcg limits, though, and to the same
> overcommit or no-overcommit accounting as all user memory."

Yes, makes sense. Fixed.

>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> A comment or two below, but this is okay by me.  I'm not wildly excited
> to be getting a new system call in mm/shmem.c.  I do like it much better
> now that you've dropped the size arg, thank you, but I still find it an
> odd system call: if it were not for the name, that you want so much for
> debugging, I think we would just implement this with a /dev/sealable
> alongside /dev/zero, which gave you your own object on opening (in the
> way that /dev/zero gives you your own object on mmap'ing).

mmap() supports replacing the file by a new file. Therefore, /dev/zero
works just fine. open() doesn't allow that and it looks non-trivial to
make it work. "non-trivial" is not really a counter-argument, but the
object-name is worth a new syscall, in my opinion. And it's a really
nice feature to debug complex systems.

> I haven't checked the manpage, I hope it's made very clear that
> there's no uniqueness imposed on the name, that it's merely a tag
> attached to the object.

Yes, the man-page clearly states that names are for debugging purposes
only and exposed via /proc/self/fd/ symlink-targets. They're not
subject to conflict-tests nor do two memfd's with the same name behave
any different.

> But from a shmem point of view this seems fine: if everyone else
> is happy with memfd_create(), it's fine by me.
>
>> ---
>>  arch/x86/syscalls/syscall_32.tbl |  1 +
>>  arch/x86/syscalls/syscall_64.tbl |  1 +
>>  include/linux/syscalls.h         |  1 +
>>  include/uapi/linux/memfd.h       |  8 +++++
>>  kernel/sys_ni.c                  |  1 +
>>  mm/shmem.c                       | 72 ++++++++++++++++++++++++++++++++++++++++
>>  6 files changed, 84 insertions(+)
>>  create mode 100644 include/uapi/linux/memfd.h
>>
>> diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
>> index d6b8679..e7495b4 100644
>> --- a/arch/x86/syscalls/syscall_32.tbl
>> +++ b/arch/x86/syscalls/syscall_32.tbl
>> @@ -360,3 +360,4 @@
>>  351  i386    sched_setattr           sys_sched_setattr
>>  352  i386    sched_getattr           sys_sched_getattr
>>  353  i386    renameat2               sys_renameat2
>> +354  i386    memfd_create            sys_memfd_create
>> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
>> index ec255a1..28be0e1 100644
>> --- a/arch/x86/syscalls/syscall_64.tbl
>> +++ b/arch/x86/syscalls/syscall_64.tbl
>> @@ -323,6 +323,7 @@
>>  314  common  sched_setattr           sys_sched_setattr
>>  315  common  sched_getattr           sys_sched_getattr
>>  316  common  renameat2               sys_renameat2
>> +317  common  memfd_create            sys_memfd_create
>>
>>  #
>>  # x32-specific system call numbers start at 512 to avoid cache impact
>> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
>> index b0881a0..0be5d4d 100644
>> --- a/include/linux/syscalls.h
>> +++ b/include/linux/syscalls.h
>> @@ -802,6 +802,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
>>  asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>>  asmlinkage long sys_eventfd(unsigned int count);
>>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
>> +asmlinkage long sys_memfd_create(const char *uname_ptr, unsigned int flags);
>>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
>>  asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
>>  asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
>> diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
>> new file mode 100644
>> index 0000000..534e364
>> --- /dev/null
>> +++ b/include/uapi/linux/memfd.h
>> @@ -0,0 +1,8 @@
>> +#ifndef _UAPI_LINUX_MEMFD_H
>> +#define _UAPI_LINUX_MEMFD_H
>> +
>> +/* flags for memfd_create(2) (unsigned int) */
>> +#define MFD_CLOEXEC          0x0001U
>> +#define MFD_ALLOW_SEALING    0x0002U
>> +
>> +#endif /* _UAPI_LINUX_MEMFD_H */
>> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
>> index 36441b5..489a4e6 100644
>> --- a/kernel/sys_ni.c
>> +++ b/kernel/sys_ni.c
>> @@ -197,6 +197,7 @@ cond_syscall(compat_sys_timerfd_settime);
>>  cond_syscall(compat_sys_timerfd_gettime);
>>  cond_syscall(sys_eventfd);
>>  cond_syscall(sys_eventfd2);
>> +cond_syscall(sys_memfd_create);
>>
>>  /* performance counters: */
>>  cond_syscall(sys_perf_event_open);
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 1438b3e..e7c5fe1 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -66,7 +66,9 @@ static struct vfsmount *shm_mnt;
>>  #include <linux/highmem.h>
>>  #include <linux/seq_file.h>
>>  #include <linux/magic.h>
>> +#include <linux/syscalls.h>
>>  #include <linux/fcntl.h>
>> +#include <uapi/linux/memfd.h>
>>
>>  #include <asm/uaccess.h>
>>  #include <asm/pgtable.h>
>> @@ -2662,6 +2664,76 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
>>       shmem_show_mpol(seq, sbinfo->mpol);
>>       return 0;
>>  }
>> +
>> +#define MFD_NAME_PREFIX "memfd:"
>> +#define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
>> +#define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
>> +
>> +#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING)
>> +
>> +SYSCALL_DEFINE2(memfd_create,
>> +             const char*, uname,
>
> Jann Horn suggested "const char __user *" rather than "const char *",
> here and in syscalls.h, I think that's right (for sparse: compare
> with sys_open, for example).

Both fixed already. Sorry, I forgot to reply to Jann Horn. Thanks to
both of you!

>> +             unsigned int, flags)
>> +{
>> +     struct shmem_inode_info *info;
>> +     struct file *file;
>> +     int fd, error;
>> +     char *name;
>> +     long len;
>> +
>> +     if (flags & ~(unsigned int)MFD_ALL_FLAGS)
>> +             return -EINVAL;
>> +
>> +     /* length includes terminating zero */
>> +     len = strnlen_user(uname, MFD_NAME_MAX_LEN + 1);
>> +     if (len <= 0)
>> +             return -EFAULT;
>> +     if (len > MFD_NAME_MAX_LEN + 1)
>> +             return -EINVAL;
>> +
>> +     name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_TEMPORARY);
>> +     if (!name)
>> +             return -ENOMEM;
>> +
>> +     strcpy(name, MFD_NAME_PREFIX);
>> +     if (copy_from_user(&name[MFD_NAME_PREFIX_LEN], uname, len)) {
>> +             error = -EFAULT;
>> +             goto err_name;
>> +     }
>> +
>> +     /* terminating-zero may have changed after strnlen_user() returned */
>> +     if (name[len + MFD_NAME_PREFIX_LEN - 1]) {
>> +             error = -EFAULT;
>> +             goto err_name;
>> +     }
>> +
>> +     fd = get_unused_fd_flags((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0);
>
> Perhaps we should throw O_LARGEFILE in there too?  So 32-bit is not
> surprised when it accesses beyond MAX_NON_LFS.  I guess it's almost
> a non-issue, since the file is in memory, so not expected to be very
> large; but I seem to recall being caught out by a missing O_LARGEFILE
> in the past, and a new interface like this might do better to force it.
>
> But I'm not very sure of my ground here: please ask around, an fsdevel
> person will have a better idea than me, whether it's best included.

get_unused_fd_flags() doesn't take other flags than O_CLOEXEC, we need
to set it directly like we already do for f_mode.

On 64bit O_LARGEFILE is already forced for many syscalls. I added it
now as it makes perfect sense. It's part of the memfd ABI now.
man-page is fixed, too.

Thanks
David

>> +     if (fd < 0) {
>> +             error = fd;
>> +             goto err_name;
>> +     }
>> +
>> +     file = shmem_file_setup(name, 0, VM_NORESERVE);
>> +     if (IS_ERR(file)) {
>> +             error = PTR_ERR(file);
>> +             goto err_fd;
>> +     }
>> +     info = SHMEM_I(file_inode(file));
>> +     file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
>> +     if (flags & MFD_ALLOW_SEALING)
>> +             info->seals &= ~F_SEAL_SEAL;
>> +
>> +     fd_install(fd, file);
>> +     kfree(name);
>> +     return fd;
>> +
>> +err_fd:
>> +     put_unused_fd(fd);
>> +err_name:
>> +     kfree(name);
>> +     return error;
>> +}
>> +
>>  #endif /* CONFIG_TMPFS */
>>
>>  static void shmem_put_super(struct super_block *sb)
>> --
>> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
