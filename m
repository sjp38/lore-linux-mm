Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7CE9440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:05:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a110so817218wrc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:05:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26si3217188wmi.93.2017.08.24.06.04.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:04:58 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:04:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
Message-ID: <20170824130457.GD6187@quack2.suse.cz>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org

On Wed 23-08-17 16:48:51, Dan Williams wrote:
> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
> mechanism to define new behavior that is known to fail on older kernels
> without the support. Define a new mmap3 syscall that checks for
> unsupported flags at syscall entry and add a 'mmap_supported_mask' to
> 'struct file_operations' so generic code can validate the ->mmap()
> handler knows about the specified flags. This also arranges for the
> flags to be passed to the handler so it can do further local validation
> if the requested behavior can be fulfilled.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

OK, are we sold on this approach to introduction of new mmap flags? I'm
asking because working API for mmap flag is basically the only thing that's
missing from my MAP_SYNC patches so I'd like to rebase my patches onto
something that is working...

								Honza


> ---
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |    1 +
>  include/linux/fs.h                     |    1 +
>  include/linux/mm.h                     |    2 +-
>  include/linux/mman.h                   |   42 ++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h               |    3 ++
>  mm/mmap.c                              |   32 ++++++++++++++++++++++--
>  7 files changed, 78 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 448ac2161112..0618b5b38b45 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -391,3 +391,4 @@
>  382	i386	pkey_free		sys_pkey_free
>  383	i386	statx			sys_statx
>  384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
> +385	i386	mmap3			sys_mmap_pgoff_strict
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 5aef183e2f85..e204c736d7e9 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -339,6 +339,7 @@
>  330	common	pkey_alloc		sys_pkey_alloc
>  331	common	pkey_free		sys_pkey_free
>  332	common	statx			sys_statx
> +333	common  mmap3			sys_mmap_pgoff_strict
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 33d1ee8f51be..db42da9f98c4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1674,6 +1674,7 @@ struct file_operations {
>  	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
>  	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
>  	int (*mmap) (struct file *, struct vm_area_struct *, unsigned long);
> +	unsigned long mmap_supported_mask;
>  	int (*open) (struct inode *, struct file *);
>  	int (*flush) (struct file *, fl_owner_t id);
>  	int (*release) (struct inode *, struct file *);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 46b9ac5e8569..49eef48da4b7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2090,7 +2090,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
>  
>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>  	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
> -	struct list_head *uf);
> +	struct list_head *uf, unsigned long flags);
>  extern unsigned long do_mmap(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long prot, unsigned long flags,
>  	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index c8367041fafd..64b6cb3dec70 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -7,6 +7,48 @@
>  #include <linux/atomic.h>
>  #include <uapi/linux/mman.h>
>  
> +/*
> + * Arrange for undefined architecture specific flags to be rejected by
> + * default.
> + */
> +#ifndef MAP_32BIT
> +#define MAP_32BIT 0
> +#endif
> +#ifndef MAP_HUGE_2MB
> +#define MAP_HUGE_2MB 0
> +#endif
> +#ifndef MAP_HUGE_1GB
> +#define MAP_HUGE_1GB 0
> +#endif
> +#ifndef MAP_UNINITIALIZED
> +#define MAP_UNINITIALIZED 0
> +#endif
> +
> +/*
> + * The historical set of flags that all mmap implementations implicitly
> + * support when file_operations.mmap_supported_mask is zero. With the
> + * mmap3 syscall the deprecated MAP_DENYWRITE and MAP_EXECUTABLE bit
> + * values are explicitly rejected with EOPNOTSUPP rather than being
> + * silently accepted.
> + */
> +#define LEGACY_MAP_SUPPORTED_MASK (MAP_SHARED \
> +		| MAP_PRIVATE \
> +		| MAP_FIXED \
> +		| MAP_ANONYMOUS \
> +		| MAP_UNINITIALIZED \
> +		| MAP_GROWSDOWN \
> +		| MAP_LOCKED \
> +		| MAP_NORESERVE \
> +		| MAP_POPULATE \
> +		| MAP_NONBLOCK \
> +		| MAP_STACK \
> +		| MAP_HUGETLB \
> +		| MAP_32BIT \
> +		| MAP_HUGE_2MB \
> +		| MAP_HUGE_1GB)
> +
> +#define	MAP_SUPPORTED_MASK (LEGACY_MAP_SUPPORTED_MASK)
> +
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern unsigned long sysctl_overcommit_kbytes;
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 3cb15ea48aee..c0e0c99cf4ad 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -858,6 +858,9 @@ asmlinkage long sys_perf_event_open(
>  asmlinkage long sys_mmap_pgoff(unsigned long addr, unsigned long len,
>  			unsigned long prot, unsigned long flags,
>  			unsigned long fd, unsigned long pgoff);
> +asmlinkage long sys_mmap_pgoff_strict(unsigned long addr, unsigned long len,
> +			unsigned long prot, unsigned long flags,
> +			unsigned long fd, unsigned long pgoff);
>  asmlinkage long sys_old_mmap(struct mmap_arg_struct __user *arg);
>  asmlinkage long sys_name_to_handle_at(int dfd, const char __user *name,
>  				      struct file_handle __user *handle,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 744faae86781..386706831d67 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1464,7 +1464,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  			vm_flags |= VM_NORESERVE;
>  	}
>  
> -	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
> +	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
>  	if (!IS_ERR_VALUE(addr) &&
>  	    ((vm_flags & VM_LOCKED) ||
>  	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
> @@ -1521,6 +1521,32 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  	return retval;
>  }
>  
> +SYSCALL_DEFINE6(mmap_pgoff_strict, unsigned long, addr, unsigned long, len,
> +		unsigned long, prot, unsigned long, flags,
> +		unsigned long, fd, unsigned long, pgoff)
> +{
> +	if (flags & ~(MAP_SUPPORTED_MASK))
> +		return -EOPNOTSUPP;
> +
> +	if (!(flags & MAP_ANONYMOUS)) {
> +		unsigned long f_supported;
> +		struct file *file;
> +
> +		audit_mmap_fd(fd, flags);
> +		file = fget(fd);
> +		if (!file)
> +			return -EBADF;
> +		f_supported = file->f_op->mmap_supported_mask;
> +		fput(file);
> +		if (!f_supported)
> +			f_supported = LEGACY_MAP_SUPPORTED_MASK;
> +		if (flags & ~f_supported)
> +			return -EOPNOTSUPP;
> +	}
> +
> +	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
> +}
> +
>  #ifdef __ARCH_WANT_SYS_OLD_MMAP
>  struct mmap_arg_struct {
>  	unsigned long addr;
> @@ -1601,7 +1627,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
>  
>  unsigned long mmap_region(struct file *file, unsigned long addr,
>  		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
> -		struct list_head *uf)
> +		struct list_head *uf, unsigned long flags)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> @@ -1686,7 +1712,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  		 * new file must not have been exposed to user-space, yet.
>  		 */
>  		vma->vm_file = get_file(file);
> -		error = call_mmap(file, vma, 0);
> +		error = call_mmap(file, vma, flags);
>  		if (error)
>  			goto unmap_and_free_vma;
>  
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
