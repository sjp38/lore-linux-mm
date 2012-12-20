Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 77F106B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 00:54:25 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so1327638dae.21
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 21:54:24 -0800 (PST)
Subject: Re: [PATCH v3] mm: Downgrade mmap_sem before locking or populating
 on mmap
From: Simon Jeons <simon.jeons@gmail.com>
In-Reply-To: <182c75b1b598afe3ba6d59b392c223ed87c2ea00.1355791798.git.luto@amacapital.net>
References: <20121217095231.GA1134@gmail.com>
	 <182c75b1b598afe3ba6d59b392c223ed87c2ea00.1355791798.git.luto@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Dec 2012 21:22:01 -0500
Message-ID: <1355970121.1357.2.camel@kernel-VirtualBox>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>

On Mon, 2012-12-17 at 16:54 -0800, Andy Lutomirski wrote:
> This is a serious cause of mmap_sem contention.  MAP_POPULATE
> and MCL_FUTURE, in particular, are disastrous in multithreaded programs.
> 
> This is not a complete solution due to reader/writer fairness.
> 

Hi Andy, could you explain what issue you meet, which part of kernel
will be influence by it and how you resolve the issue in details, it's
too hard for other guys to get useful information form your patch
changlog.

> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
> 
> Changes from v2:
> 
> The mmap functions now unconditionally downgrade mmap_sem.  This is
> slightly slower but a lot simpler.
> 
> Changes from v1:
> 
> The non-unlocking versions of do_mmap_pgoff and mmap_region are still
> available for aio_setup_ring's benefit.  In theory, aio_setup_ring
> would do better with a lock-downgrading version, but that would be
> somewhat ugly and doesn't help my workload.
> 
>  arch/tile/mm/elf.c |  11 +++--
>  fs/aio.c           |  11 ++---
>  include/linux/mm.h |  15 +++++--
>  ipc/shm.c          |   8 +++-
>  mm/fremap.c        |   9 +++-
>  mm/mmap.c          | 122 ++++++++++++++++++++++++++++++++++++-----------------
>  mm/util.c          |   5 ++-
>  7 files changed, 123 insertions(+), 58 deletions(-)
> 
> diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
> index 3cfa98b..313acb2 100644
> --- a/arch/tile/mm/elf.c
> +++ b/arch/tile/mm/elf.c
> @@ -129,12 +129,15 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
>  	 */
>  	if (!retval) {
>  		unsigned long addr = MEM_USER_INTRPT;
> -		addr = mmap_region(NULL, addr, INTRPT_SIZE,
> -				   MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
> -				   VM_READ|VM_EXEC|
> -				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
> +		addr = mmap_region_downgrade_write(
> +			NULL, addr, INTRPT_SIZE,
> +			MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
> +			VM_READ|VM_EXEC|
> +			VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
> +		up_read(&mm->mmap-sem);
>  		if (addr > (unsigned long) -PAGE_SIZE)
>  			retval = (int) addr;
> +		return retval;  /* We already unlocked mmap_sem. */
>  	}
>  #endif
>  
> diff --git a/fs/aio.c b/fs/aio.c
> index 71f613c..912d3d8 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -127,11 +127,12 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	info->mmap_size = nr_pages * PAGE_SIZE;
>  	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
>  	down_write(&ctx->mm->mmap_sem);
> -	info->mmap_base = do_mmap_pgoff(NULL, 0, info->mmap_size, 
> -					PROT_READ|PROT_WRITE,
> -					MAP_ANONYMOUS|MAP_PRIVATE, 0);
> +	info->mmap_base = do_mmap_pgoff_downgrade_write(
> +		NULL, 0, info->mmap_size,
> +		PROT_READ|PROT_WRITE,
> +		MAP_ANONYMOUS|MAP_PRIVATE, 0);
>  	if (IS_ERR((void *)info->mmap_base)) {
> -		up_write(&ctx->mm->mmap_sem);
> +		up_read(&ctx->mm->mmap_sem);
>  		info->mmap_size = 0;
>  		aio_free_ring(ctx);
>  		return -EAGAIN;
> @@ -141,7 +142,7 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	info->nr_pages = get_user_pages(current, ctx->mm,
>  					info->mmap_base, nr_pages, 
>  					1, 0, info->ring_pages, NULL);
> -	up_write(&ctx->mm->mmap_sem);
> +	up_read(&ctx->mm->mmap_sem);
>  
>  	if (unlikely(info->nr_pages != nr_pages)) {
>  		aio_free_ring(ctx);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bcaab4e..a44aa00 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1441,12 +1441,19 @@ extern int install_special_mapping(struct mm_struct *mm,
>  
>  extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
>  
> -extern unsigned long mmap_region(struct file *file, unsigned long addr,
> +/*
> + * These functions are called with mmap_sem held for write and they return
> + * with mmap_sem held for read.
> + */
> +extern unsigned long mmap_region_downgrade_write(
> +	struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long flags,
>  	vm_flags_t vm_flags, unsigned long pgoff);
> -extern unsigned long do_mmap_pgoff(struct file *, unsigned long,
> -        unsigned long, unsigned long,
> -        unsigned long, unsigned long);
> +extern unsigned long do_mmap_pgoff_downgrade_write(
> +	struct file *, unsigned long addr,
> +	unsigned long len, unsigned long prot,
> +	unsigned long flags, unsigned long pgoff);
> +
>  extern int do_munmap(struct mm_struct *, unsigned long, size_t);
>  
>  /* These take the mm semaphore themselves */
> diff --git a/ipc/shm.c b/ipc/shm.c
> index dff40c9..482f3d6 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -1068,12 +1068,16 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>  		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
>  			goto invalid;
>  	}
> -		
> -	user_addr = do_mmap_pgoff(file, addr, size, prot, flags, 0);
> +
> +	user_addr = do_mmap_pgoff_downgrade_write(file, addr, size,
> +						  prot, flags, 0);
> +	up_read(&current->mm->mmap_sem);
>  	*raddr = user_addr;
>  	err = 0;
>  	if (IS_ERR_VALUE(user_addr))
>  		err = (long)user_addr;
> +	goto out_fput;
> +
>  invalid:
>  	up_write(&current->mm->mmap_sem);
>  
> diff --git a/mm/fremap.c b/mm/fremap.c
> index a0aaf0e..55c4a9b 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -200,8 +200,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  			struct file *file = get_file(vma->vm_file);
>  
>  			flags &= MAP_NONBLOCK;
> -			addr = mmap_region(file, start, size,
> -					flags, vma->vm_flags, pgoff);
> +			addr = mmap_region_downgrade_write(
> +				file, start, size, flags, vma->vm_flags, pgoff);
> +			has_write_lock = 0;
>  			fput(file);
>  			if (IS_ERR_VALUE(addr)) {
>  				err = addr;
> @@ -237,6 +238,10 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  			/*
>  			 * might be mapping previously unmapped range of file
>  			 */
> +			if (unlikely(has_write_lock)) {
> +				downgrade_write(&mm->mmap_sem);
> +				has_write_lock = 0;
> +			}
>  			mlock_vma_pages_range(vma, start, start + size);
>  		} else {
>  			if (unlikely(has_write_lock)) {
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9a796c4..3913262 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -999,9 +999,10 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
>   * The caller must hold down_write(&current->mm->mmap_sem).
>   */
>  
> -unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
> -			unsigned long len, unsigned long prot,
> -			unsigned long flags, unsigned long pgoff)
> +unsigned long do_mmap_pgoff_downgrade_write(
> +	struct file *file, unsigned long addr,
> +	unsigned long len, unsigned long prot,
> +	unsigned long flags, unsigned long pgoff)
>  {
>  	struct mm_struct * mm = current->mm;
>  	struct inode *inode;
> @@ -1017,31 +1018,39 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
>  			prot |= PROT_EXEC;
>  
> -	if (!len)
> -		return -EINVAL;
> +	if (!len) {
> +		addr = -EINVAL;
> +		goto out_downgrade;
> +	}
>  
>  	if (!(flags & MAP_FIXED))
>  		addr = round_hint_to_min(addr);
>  
>  	/* Careful about overflows.. */
>  	len = PAGE_ALIGN(len);
> -	if (!len)
> -		return -ENOMEM;
> +	if (!len) {
> +		addr = -ENOMEM;
> +		goto out_downgrade;
> +	}
>  
>  	/* offset overflow? */
> -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> -               return -EOVERFLOW;
> +	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff) {
> +		addr = -EOVERFLOW;
> +		goto out_downgrade;
> +	}
>  
>  	/* Too many mappings? */
> -	if (mm->map_count > sysctl_max_map_count)
> -		return -ENOMEM;
> +	if (mm->map_count > sysctl_max_map_count) {
> +		addr = -ENOMEM;
> +		goto out_downgrade;
> +	}
>  
>  	/* Obtain the address to map to. we verify (or select) it and ensure
>  	 * that it represents a valid section of the address space.
>  	 */
>  	addr = get_unmapped_area(file, addr, len, pgoff, flags);
>  	if (addr & ~PAGE_MASK)
> -		return addr;
> +		goto out_downgrade;
>  
>  	/* Do simple checking here so the lower-level routines won't have
>  	 * to. we assume access permissions have been handled by the open
> @@ -1050,9 +1059,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
>  			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>  
> -	if (flags & MAP_LOCKED)
> -		if (!can_do_mlock())
> -			return -EPERM;
> +	if (flags & MAP_LOCKED) {
> +		if (!can_do_mlock()) {
> +			addr = -EPERM;
> +			goto out_downgrade;
> +		}
> +	}
>  
>  	/* mlock MCL_FUTURE? */
>  	if (vm_flags & VM_LOCKED) {
> @@ -1061,8 +1073,10 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  		locked += mm->locked_vm;
>  		lock_limit = rlimit(RLIMIT_MEMLOCK);
>  		lock_limit >>= PAGE_SHIFT;
> -		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> -			return -EAGAIN;
> +		if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
> +			addr = -EAGAIN;
> +			goto out_downgrade;
> +		}
>  	}
>  
>  	inode = file ? file->f_path.dentry->d_inode : NULL;
> @@ -1070,21 +1084,27 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	if (file) {
>  		switch (flags & MAP_TYPE) {
>  		case MAP_SHARED:
> -			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
> -				return -EACCES;
> +			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE)) {
> +				addr = -EACCES;
> +				goto out_downgrade;
> +			}
>  
>  			/*
>  			 * Make sure we don't allow writing to an append-only
>  			 * file..
>  			 */
> -			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
> -				return -EACCES;
> +			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE)) {
> +				addr = -EACCES;
> +				goto out_downgrade;
> +			}
>  
>  			/*
>  			 * Make sure there are no mandatory locks on the file.
>  			 */
> -			if (locks_verify_locked(inode))
> -				return -EAGAIN;
> +			if (locks_verify_locked(inode)) {
> +				addr = -EAGAIN;
> +				goto out_downgrade;
> +			}
>  
>  			vm_flags |= VM_SHARED | VM_MAYSHARE;
>  			if (!(file->f_mode & FMODE_WRITE))
> @@ -1092,20 +1112,27 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  
>  			/* fall through */
>  		case MAP_PRIVATE:
> -			if (!(file->f_mode & FMODE_READ))
> -				return -EACCES;
> +			if (!(file->f_mode & FMODE_READ)) {
> +				addr = -EACCES;
> +				goto out_downgrade;
> +			}
>  			if (file->f_path.mnt->mnt_flags & MNT_NOEXEC) {
> -				if (vm_flags & VM_EXEC)
> -					return -EPERM;
> +				if (vm_flags & VM_EXEC) {
> +					addr = -EPERM;
> +					goto out_downgrade;
> +				}
>  				vm_flags &= ~VM_MAYEXEC;
>  			}
>  
> -			if (!file->f_op || !file->f_op->mmap)
> -				return -ENODEV;
> +			if (!file->f_op || !file->f_op->mmap) {
> +				addr = -ENODEV;
> +				goto out_downgrade;
> +			}
>  			break;
>  
>  		default:
> -			return -EINVAL;
> +			addr = -EINVAL;
> +			goto out_downgrade;
>  		}
>  	} else {
>  		switch (flags & MAP_TYPE) {
> @@ -1123,11 +1150,17 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  			pgoff = addr >> PAGE_SHIFT;
>  			break;
>  		default:
> -			return -EINVAL;
> +			addr = -EINVAL;
> +			goto out_downgrade;
>  		}
>  	}
>  
> -	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
> +	return mmap_region_downgrade_write(file, addr, len,
> +		flags, vm_flags, pgoff);
> +
> +out_downgrade:
> +	downgrade_write(&mm->mmap_sem);
> +	return addr;
>  }
>  
>  SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
> @@ -1240,9 +1273,10 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
>  	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
>  }
>  
> -unsigned long mmap_region(struct file *file, unsigned long addr,
> -			  unsigned long len, unsigned long flags,
> -			  vm_flags_t vm_flags, unsigned long pgoff)
> +unsigned long mmap_region_downgrade_write(
> +	struct file *file, unsigned long addr,
> +	unsigned long len, unsigned long flags,
> +	vm_flags_t vm_flags, unsigned long pgoff)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> @@ -1262,8 +1296,10 @@ munmap_back:
>  	}
>  
>  	/* Check against address space limit. */
> -	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
> -		return -ENOMEM;
> +	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
> +		error = -ENOMEM;
> +		goto unacct_error;
> +	}
>  
>  	/*
>  	 * Set 'VM_NORESERVE' if we should not account for the
> @@ -1284,8 +1320,10 @@ munmap_back:
>  	 */
>  	if (accountable_mapping(file, vm_flags)) {
>  		charged = len >> PAGE_SHIFT;
> -		if (security_vm_enough_memory_mm(mm, charged))
> -			return -ENOMEM;
> +		if (security_vm_enough_memory_mm(mm, charged)) {
> +			error = -ENOMEM;
> +			goto unacct_error;
> +		}
>  		vm_flags |= VM_ACCOUNT;
>  	}
>  
> @@ -1369,9 +1407,12 @@ munmap_back:
>  	if (correct_wcount)
>  		atomic_inc(&inode->i_writecount);
>  out:
> +	downgrade_write(&mm->mmap_sem);
> +
>  	perf_event_mmap(vma);
>  
>  	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
> +
>  	if (vm_flags & VM_LOCKED) {
>  		if (!mlock_vma_pages_range(vma, addr, addr + len))
>  			mm->locked_vm += (len >> PAGE_SHIFT);
> @@ -1397,6 +1438,9 @@ free_vma:
>  unacct_error:
>  	if (charged)
>  		vm_unacct_memory(charged);
> +
> +	downgrade_write(&mm->mmap_sem);
> +
>  	return error;
>  }
>  
> diff --git a/mm/util.c b/mm/util.c
> index dc3036c..ab489a7 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -359,8 +359,9 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
>  	ret = security_mmap_file(file, prot, flag);
>  	if (!ret) {
>  		down_write(&mm->mmap_sem);
> -		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff);
> -		up_write(&mm->mmap_sem);
> +		ret = do_mmap_pgoff_downgrade_write(
> +			file, addr, len, prot, flag, pgoff);
> +		up_read(&mm->mmap_sem);
>  	}
>  	return ret;
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
