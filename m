Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BF7196B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 22:21:15 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id x10so95838pdj.38
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:21:15 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ym9si22248255pab.72.2014.05.19.19.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 19:21:14 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so6565662pad.16
        for <linux-mm@kvack.org>; Mon, 19 May 2014 19:21:14 -0700 (PDT)
Date: Mon, 19 May 2014 19:20:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 2/3] shm: add memfd_create() syscall
In-Reply-To: <1397587118-1214-3-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1405191916300.2970@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <1397587118-1214-3-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirsky <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Tue, 15 Apr 2014, David Herrmann wrote:

> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
> that you can pass to mmap(). It can support sealing and avoids any
> connection to user-visible mount-points. Thus, it's not subject to quotas
> on mounted file-systems, but can be used like malloc()'ed memory, but
> with a file-descriptor to it.
> 
> memfd_create() does not create a front-FD, but instead returns the raw

What is a front-FD?

> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
> will return proper information and mark the file as regular file. If you
> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
> support (like on all other regular files).
> 
> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
> subject to quotas and alike.

You mention quotas a couple of times, and I want to be clear about that.

I think you are mainly thinking of the "df" size limitation which comes
by default on a tmpfs mount, but can be retuned or removed with the
size= or nr_block= mount options.  You want memfd_create() to be free
of that limitation, which indeed it is.

(I'm not proud of the way in which an unlimited tmpfs mount can easily
be used to OOM the system, killing processes which do little to give
back the memory needed; but that's how it is, and you're not making
that worse, just adding a further interface to it.)

And we have never implemented fs/quota/-style quotas on tmpfs,
so you're certainly free from those.

But a created memfd is still subject to an RLIMIT_FSIZE limit, and
to a memcg's memory.limit_in_bytes and memory.memsw.limit_in_bytes:
I expect you don't care about those, that they would be unlimited
in the cases that you care about.

And a created memfd is still subject to __vm_enough_memory() limiting:
unlimited when OVERCOMMIT_ALWAYS, a little unpredictable when
OVERCOMMIT_GUESS, strictly accounted when OVERCOMMIT_NEVER.  I don't
think we can compromise on OVERCOMMIT_NEVER, but if OVERCOMMIT_GUESS
gives you a problem, we could probably tweak it for your case.
More on this below, when considering the size arg to memfd_create().

> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---
>  arch/x86/syscalls/syscall_32.tbl |  1 +
>  arch/x86/syscalls/syscall_64.tbl |  1 +

Okay.  No point in cluttering the patchset with other architectures
until this is closer to merge.  Miklos Szeredi's recent patches
"add renameat2 syscall" provide a very helpful precedent to follow.

>  include/linux/syscalls.h         |  1 +
>  include/uapi/linux/memfd.h       | 10 ++++++
>  kernel/sys_ni.c                  |  1 +
>  mm/shmem.c                       | 74 ++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 88 insertions(+)
>  create mode 100644 include/uapi/linux/memfd.h
> 
> diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
> index 96bc506..c943b8a 100644
> --- a/arch/x86/syscalls/syscall_32.tbl
> +++ b/arch/x86/syscalls/syscall_32.tbl
> @@ -359,3 +359,4 @@
>  350	i386	finit_module		sys_finit_module
>  351	i386	sched_setattr		sys_sched_setattr
>  352	i386	sched_getattr		sys_sched_getattr
> +353	i386	memfd_create		sys_memfd_create
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index 04376ac..dfcfd6f 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -323,6 +323,7 @@
>  314	common	sched_setattr		sys_sched_setattr
>  315	common	sched_getattr		sys_sched_getattr
>  316	common	renameat2		sys_renameat2
> +317	common	memfd_create		sys_memfd_create
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index a4a0588..133b705 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -802,6 +802,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
>  asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>  asmlinkage long sys_eventfd(unsigned int count);
>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
> +asmlinkage long sys_memfd_create(const char *uname_ptr, u64 size, u64 flags);
>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
>  asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
>  asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
> diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
> new file mode 100644
> index 0000000..c4a6db0
> --- /dev/null
> +++ b/include/uapi/linux/memfd.h
> @@ -0,0 +1,10 @@
> +#ifndef _UAPI_LINUX_MEMFD_H
> +#define _UAPI_LINUX_MEMFD_H
> +
> +#include <linux/types.h>

Why include linux/types.h in this one?

> +
> +/* flags for memfd_create(2) (u64) */
> +#define MFD_CLOEXEC		0x0001ULL
> +#define MFD_ALLOW_SEALING	0x0002ULL
> +
> +#endif /* _UAPI_LINUX_MEMFD_H */
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index bc8d1b7..f96c329 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -195,6 +195,7 @@ cond_syscall(compat_sys_timerfd_settime);
>  cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
> +cond_syscall(sys_memfd_create);
>  
>  /* performance counters: */
>  cond_syscall(sys_perf_event_open);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 175a5b8..203cc4e 100644
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
> @@ -2919,6 +2921,78 @@ out4:
>  	return error;
>  }
>  

Whereas 1/3's sealing stuff was under CONFIG_TMPFS, this is in a
CONFIG_SHMEM part of mm/shmem.c, built even when !CONFIG_TMPFS: in
which case you could not write to or truncate the object created,
just mmap it and access it that way (like SysV SHM).  Not necessarily
wrong, but it may prevent surprises to put this under CONFIG_TMPFS:
the user gets an fd, so probably expects filesystem operations to work.

> +#define MFD_NAME_PREFIX "memfd:"
> +#define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
> +#define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
> +
> +#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING)
> +
> +SYSCALL_DEFINE3(memfd_create,
> +		const char*, uname,
> +		u64, size,
> +		u64, flags)

If I'd come in earlier, I'd have probably looked for another name
than memfd_create; but I don't have anything better in mind, and
you've done a great job of sounding out potential users, so let's
stick with the name everyone is expecting.

The uname: it's a funny thing, not belonging in a filesystem tree;
but you're very sure you want it, and we already make up funny
names for SysV SHM and /dev/zero objects, so okay.

The size: u64 or loff_t or size_t?  But more on size below.

The flags: u64?  That's a big future you're allowing for!
open and mmap use ints for their flags, will this really need more?

But I don't think I've been present at the birth of a syscall before:
there are probably several considerations that I'm unaware of, that
you may have factored in - listen to the experts, not to me.

> +{
> +	struct shmem_inode_info *info;
> +	struct file *shm;

"struct file *file" is more usual.

> +	char *name;
> +	int fd, r;

"int err" or "int error" rather than "int r".

> +	long len;
> +
> +	if (flags & ~(u64)MFD_ALL_FLAGS)
> +		return -EINVAL;
> +	if ((u64)(loff_t)size != size || (loff_t)size < 0)
> +		return -EINVAL;
> +
> +	/* length includes terminating zero */
> +	len = strnlen_user(uname, MFD_NAME_MAX_LEN);
> +	if (len <= 0)
> +		return -EFAULT;
> +	else if (len > MFD_NAME_MAX_LEN)

Please omit the "else ".

And, since strnlen_user() returns length including terminating NUL,
wouldn't it be more exact to use MFD_NAME_MAX_LEN + 1 in those two
places above?

> +		return -EINVAL;
> +
> +	name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_KERNEL);

Probably better to say GFP_TEMPORARY than GFP_KERNEL,
though it doesn't seem to be used very much at all.

> +	if (!name)
> +		return -ENOMEM;
> +
> +	strcpy(name, MFD_NAME_PREFIX);
> +	if (copy_from_user(&name[MFD_NAME_PREFIX_LEN], uname, len)) {
> +		r = -EFAULT;
> +		goto err_name;
> +	}
> +
> +	/* terminating-zero may have changed after strnlen_user() returned */
> +	if (name[len + MFD_NAME_PREFIX_LEN - 1]) {
> +		r = -EFAULT;
> +		goto err_name;
> +	}
> +
> +	fd = get_unused_fd_flags((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0);
> +	if (fd < 0) {
> +		r = fd;
> +		goto err_name;
> +	}
> +
> +	shm = shmem_file_setup(name, size, 0);

That's an interesting line: I am anxious to know whether you mean to
pass flags 0 there, or would rather pass VM_NORESERVE.  Passing 0
makes the object resemble mmap or SysV SHM, in accounting for the
whole size upfront; passing VM_NORESERVE makes the object resemble
a tmpfs file, accounted page by page as they are instantiated.

Accounting meaning calls to __vm_enough_memory() in mm/mmap.c:
whose behaviour is governed by /proc/sys/vm/overcommit_memory
(and overcommit_kbytes or overcommit_ratio): OVERCOMMIT_ALWAYS
(no enforcement), OVERCOMMIT_GUESS (default) or OVERCOMMIT_NEVER
(enforcing strict no-overcommit).

We have a small problem if you really intend flags 0: because then
that size is preaccounted, yet we also allow these objects to grow
or be truncated without accounting, and the number (/proc/meminfo's
Committed_AS) will go wrong.

If you really intend that preaccounting, then we need to add an
orig_size field to shmem_inode_info, and treat pages below that
as preaccounted, but pages above it to be accounted one by one.
If you don't intend preaccounting, then please pass VM_NORESERVE
to shmem_file_setup().

But this does highlight how the "size" arg to memfd_create() is
perhaps redundant.  Why give a size there, when size can be changed
afterwards?  I expect your answer is that many callers want to choose
the size at the beginning, and would prefer to avoid the extra call.
I'm not sure if that's a good enough reason for a redundant argument.

> +	if (IS_ERR(shm)) {
> +		r = PTR_ERR(shm);
> +		goto err_fd;
> +	}
> +	info = SHMEM_I(file_inode(shm));
> +	shm->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
> +	if (flags & MFD_ALLOW_SEALING)
> +		info->seals |= SHMEM_ALLOW_SEALING;

In comments on 1/3 I suggest removing F_SEAL_SEAL instead here.

> +
> +	fd_install(fd, shm);
> +	kfree(name);
> +	return fd;
> +
> +err_fd:
> +	put_unused_fd(fd);
> +err_name:
> +	kfree(name);
> +	return r;
> +}
> +
>  #else /* !CONFIG_SHMEM */
>  
>  /*
> -- 
> 1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
