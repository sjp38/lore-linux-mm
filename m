Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 868056B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:12:35 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 11so15611260wrb.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:12:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3si4969250edd.300.2017.11.27.02.12.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 02:12:33 -0800 (PST)
Date: Mon, 27 Nov 2017 11:12:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23066.59196.909026.689706@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikael Pettersson <mikpelinux@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Sun 26-11-17 17:09:32, Mikael Pettersson wrote:
> The `vm.max_map_count' sysctl limit is IMO useless and confusing, so
> this patch disables it.
> 
> - Old ELF had a limit of 64K segments, making core dumps from processes
>   with more mappings than that problematic, but that was fixed in March
>   2010 ("elf coredump: add extended numbering support").
> 
> - There are no internal data structures sized by this limit, making it
>   entirely artificial.

each mapping has its vma structure and that in turn can be tracked by
other data structures so this is not entirely true.

> - When viewed as a limit on memory consumption, it is ineffective since
>   the number of mappings does not correspond directly to the amount of
>   memory consumed, since each mapping is variable-length.
> 
> - Reaching the limit causes various memory management system calls to
>   fail with ENOMEM, which is a lie.  Combined with the unpredictability
>   of the number of mappings in a process, especially when non-trivial
>   memory management or heavy file mapping is used, it can be difficult
>   to reproduce these events and debug them.  It's also confusing to get
>   ENOMEM when you know you have lots of free RAM.
> 
> This limit was apparently introduced in the 2.1.80 kernel (first as a
> compile-time constant, later changed to a sysctl), but I haven't been
> able to find any description for it in Git or the LKML archives, so I
> don't know what the original motivation was.
> 
> I've kept the kernel tunable to not break the API towards user-space,
> but it's a no-op now.  Also the distinction between split_vma() and
> __split_vma() disappears, so they are merged.

Could you be more explicit about _why_ we need to remove this tunable?
I am not saying I disagree, the removal simplifies the code but I do not
really see any justification here.

> Tested on x86_64 with Fedora 26 user-space.  Also built an ARM NOMMU
> kernel to make sure NOMMU compiles and links cleanly.
> 
> Signed-off-by: Mikael Pettersson <mikpelinux@gmail.com>
> ---
>  Documentation/sysctl/vm.txt           | 17 +-------------
>  Documentation/vm/ksm.txt              |  4 ----
>  Documentation/vm/remap_file_pages.txt |  4 ----
>  fs/binfmt_elf.c                       |  4 ----
>  include/linux/mm.h                    | 23 -------------------
>  kernel/sysctl.c                       |  3 +++
>  mm/madvise.c                          | 12 ++--------
>  mm/mmap.c                             | 42 ++++++-----------------------------
>  mm/mremap.c                           |  7 ------
>  mm/nommu.c                            |  3 ---
>  mm/util.c                             |  1 -
>  11 files changed, 13 insertions(+), 107 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index b920423f88cb..0fcb511d07e6 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -35,7 +35,7 @@ Currently, these files are in /proc/sys/vm:
>  - laptop_mode
>  - legacy_va_layout
>  - lowmem_reserve_ratio
> -- max_map_count
> +- max_map_count (unused, kept for backwards compatibility)
>  - memory_failure_early_kill
>  - memory_failure_recovery
>  - min_free_kbytes
> @@ -400,21 +400,6 @@ The minimum value is 1 (1/1 -> 100%).
>  
>  ==============================================================
>  
> -max_map_count:
> -
> -This file contains the maximum number of memory map areas a process
> -may have. Memory map areas are used as a side-effect of calling
> -malloc, directly by mmap, mprotect, and madvise, and also when loading
> -shared libraries.
> -
> -While most applications need less than a thousand maps, certain
> -programs, particularly malloc debuggers, may consume lots of them,
> -e.g., up to one or two maps per allocation.
> -
> -The default value is 65536.
> -
> -=============================================================
> -
>  memory_failure_early_kill:
>  
>  Control how to kill processes when uncorrected memory error (typically
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index 6686bd267dc9..4a917f88cb11 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -38,10 +38,6 @@ the range for whenever the KSM daemon is started; even if the range
>  cannot contain any pages which KSM could actually merge; even if
>  MADV_UNMERGEABLE is applied to a range which was never MADV_MERGEABLE.
>  
> -If a region of memory must be split into at least one new MADV_MERGEABLE
> -or MADV_UNMERGEABLE region, the madvise may return ENOMEM if the process
> -will exceed vm.max_map_count (see Documentation/sysctl/vm.txt).
> -
>  Like other madvise calls, they are intended for use on mapped areas of
>  the user address space: they will report ENOMEM if the specified range
>  includes unmapped gaps (though working on the intervening mapped areas),
> diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/remap_file_pages.txt
> index f609142f406a..85985a89f05d 100644
> --- a/Documentation/vm/remap_file_pages.txt
> +++ b/Documentation/vm/remap_file_pages.txt
> @@ -21,7 +21,3 @@ systems are widely available.
>  The syscall is deprecated and replaced it with an emulation now. The
>  emulation creates new VMAs instead of nonlinear mappings. It's going to
>  work slower for rare users of remap_file_pages() but ABI is preserved.
> -
> -One side effect of emulation (apart from performance) is that user can hit
> -vm.max_map_count limit more easily due to additional VMAs. See comment for
> -DEFAULT_MAX_MAP_COUNT for more details on the limit.
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 83732fef510d..8e870b6e4ad9 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -2227,10 +2227,6 @@ static int elf_core_dump(struct coredump_params *cprm)
>  	elf = kmalloc(sizeof(*elf), GFP_KERNEL);
>  	if (!elf)
>  		goto out;
> -	/*
> -	 * The number of segs are recored into ELF header as 16bit value.
> -	 * Please check DEFAULT_MAX_MAP_COUNT definition when you modify here.
> -	 */
>  	segs = current->mm->map_count;
>  	segs += elf_core_extra_phdrs();
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ee073146aaa7..cf545264eb8b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -104,27 +104,6 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
>  #endif
>  
> -/*
> - * Default maximum number of active map areas, this limits the number of vmas
> - * per mm struct. Users can overwrite this number by sysctl but there is a
> - * problem.
> - *
> - * When a program's coredump is generated as ELF format, a section is created
> - * per a vma. In ELF, the number of sections is represented in unsigned short.
> - * This means the number of sections should be smaller than 65535 at coredump.
> - * Because the kernel adds some informative sections to a image of program at
> - * generating coredump, we need some margin. The number of extra sections is
> - * 1-3 now and depends on arch. We use "5" as safe margin, here.
> - *
> - * ELF extended numbering allows more than 65535 sections, so 16-bit bound is
> - * not a hard limit any more. Although some userspace tools can be surprised by
> - * that.
> - */
> -#define MAPCOUNT_ELF_CORE_MARGIN	(5)
> -#define DEFAULT_MAX_MAP_COUNT	(USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
> -
> -extern int sysctl_max_map_count;
> -
>  extern unsigned long sysctl_user_reserve_kbytes;
>  extern unsigned long sysctl_admin_reserve_kbytes;
>  
> @@ -2134,8 +2113,6 @@ extern struct vm_area_struct *vma_merge(struct mm_struct *,
>  	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
>  	struct mempolicy *, struct vm_userfaultfd_ctx);
>  extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
> -extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
> -	unsigned long addr, int new_below);
>  extern int split_vma(struct mm_struct *, struct vm_area_struct *,
>  	unsigned long addr, int new_below);
>  extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 557d46728577..caced68ff0d0 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -110,6 +110,9 @@ extern int pid_max_min, pid_max_max;
>  extern int percpu_pagelist_fraction;
>  extern int latencytop_enabled;
>  extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
> +#ifdef CONFIG_MMU
> +static int sysctl_max_map_count = 65530; /* obsolete, kept for backwards compatibility */
> +#endif
>  #ifndef CONFIG_MMU
>  extern int sysctl_nr_trim_pages;
>  #endif
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 375cf32087e4..f63834f59ca7 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -147,11 +147,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  	*prev = vma;
>  
>  	if (start != vma->vm_start) {
> -		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
> -			error = -ENOMEM;
> -			goto out;
> -		}
> -		error = __split_vma(mm, vma, start, 1);
> +		error = split_vma(mm, vma, start, 1);
>  		if (error) {
>  			/*
>  			 * madvise() returns EAGAIN if kernel resources, such as
> @@ -164,11 +160,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  	}
>  
>  	if (end != vma->vm_end) {
> -		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
> -			error = -ENOMEM;
> -			goto out;
> -		}
> -		error = __split_vma(mm, vma, end, 0);
> +		error = split_vma(mm, vma, end, 0);
>  		if (error) {
>  			/*
>  			 * madvise() returns EAGAIN if kernel resources, such as
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 924839fac0e6..e821d9c4395d 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1354,10 +1354,6 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
>  		return -EOVERFLOW;
>  
> -	/* Too many mappings? */
> -	if (mm->map_count > sysctl_max_map_count)
> -		return -ENOMEM;
> -
>  	/* Obtain the address to map to. we verify (or select) it and ensure
>  	 * that it represents a valid section of the address space.
>  	 */
> @@ -2546,11 +2542,11 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  }
>  
>  /*
> - * __split_vma() bypasses sysctl_max_map_count checking.  We use this where it
> - * has already been checked or doesn't make sense to fail.
> + * Split a vma into two pieces at address 'addr', a new vma is allocated
> + * either for the first part or the tail.
>   */
> -int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long addr, int new_below)
> +int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
> +	      unsigned long addr, int new_below)
>  {
>  	struct vm_area_struct *new;
>  	int err;
> @@ -2612,19 +2608,6 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return err;
>  }
>  
> -/*
> - * Split a vma into two pieces at address 'addr', a new vma is allocated
> - * either for the first part or the tail.
> - */
> -int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
> -	      unsigned long addr, int new_below)
> -{
> -	if (mm->map_count >= sysctl_max_map_count)
> -		return -ENOMEM;
> -
> -	return __split_vma(mm, vma, addr, new_below);
> -}
> -
>  /* Munmap is split into 2 main parts -- this part which finds
>   * what needs doing, and the areas themselves, which do the
>   * work.  This now handles partial unmappings.
> @@ -2665,15 +2648,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	if (start > vma->vm_start) {
>  		int error;
>  
> -		/*
> -		 * Make sure that map_count on return from munmap() will
> -		 * not exceed its limit; but let map_count go just above
> -		 * its limit temporarily, to help free resources as expected.
> -		 */
> -		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
> -			return -ENOMEM;
> -
> -		error = __split_vma(mm, vma, start, 0);
> +		error = split_vma(mm, vma, start, 0);
>  		if (error)
>  			return error;
>  		prev = vma;
> @@ -2682,7 +2657,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	/* Does it split the last one? */
>  	last = find_vma(mm, end);
>  	if (last && end > last->vm_start) {
> -		int error = __split_vma(mm, last, end, 1);
> +		int error = split_vma(mm, last, end, 1);
>  		if (error)
>  			return error;
>  	}
> @@ -2694,7 +2669,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  		 * will remain splitted, but userland will get a
>  		 * highly unexpected error anyway. This is no
>  		 * different than the case where the first of the two
> -		 * __split_vma fails, but we don't undo the first
> +		 * split_vma fails, but we don't undo the first
>  		 * split, despite we could. This is unlikely enough
>  		 * failure that it's not worth optimizing it for.
>  		 */
> @@ -2915,9 +2890,6 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  	if (!may_expand_vm(mm, flags, len >> PAGE_SHIFT))
>  		return -ENOMEM;
>  
> -	if (mm->map_count > sysctl_max_map_count)
> -		return -ENOMEM;
> -
>  	if (security_vm_enough_memory_mm(mm, len >> PAGE_SHIFT))
>  		return -ENOMEM;
>  
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 049470aa1e3e..5544dd3e6e10 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -278,13 +278,6 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>  	bool need_rmap_locks;
>  
>  	/*
> -	 * We'd prefer to avoid failure later on in do_munmap:
> -	 * which may split one vma into three before unmapping.
> -	 */
> -	if (mm->map_count >= sysctl_max_map_count - 3)
> -		return -ENOMEM;
> -
> -	/*
>  	 * Advise KSM to break any KSM pages in the area to be moved:
>  	 * it would be confusing if they were to turn up at the new
>  	 * location, where they happen to coincide with different KSM
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 17c00d93de2e..0f6d37be4797 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1487,9 +1487,6 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (vma->vm_file)
>  		return -ENOMEM;
>  
> -	if (mm->map_count >= sysctl_max_map_count)
> -		return -ENOMEM;
> -
>  	region = kmem_cache_alloc(vm_region_jar, GFP_KERNEL);
>  	if (!region)
>  		return -ENOMEM;
> diff --git a/mm/util.c b/mm/util.c
> index 34e57fae959d..7e757686f186 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -516,7 +516,6 @@ EXPORT_SYMBOL_GPL(__page_mapcount);
>  int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
>  int sysctl_overcommit_ratio __read_mostly = 50;
>  unsigned long sysctl_overcommit_kbytes __read_mostly;
> -int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
>  unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
>  unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
>  
> -- 
> 2.13.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
