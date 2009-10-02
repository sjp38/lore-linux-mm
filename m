Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7E5596B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 20:44:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n920j2a3011907
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Oct 2009 09:45:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6968945DE51
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 09:45:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48F3445DE4D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 09:45:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14FFD1DB803F
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 09:45:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 952D01DB8040
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 09:45:01 +0900 (JST)
Date: Fri, 2 Oct 2009 09:42:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20091002094238.6e1a1e5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910011238190.10994@sister.anvils>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC0234F.2080808@crca.org.au>
	<20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090928033624.GA11191@localhost>
	<20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0909281637160.25798@sister.anvils>
	<a0ea21a7cfe313202e2b51510aa5435a.squirrel@webmail-b.css.fujitsu.com>
	<Pine.LNX.4.64.0909282134100.11529@sister.anvils>
	<20090929105735.06eea1ee.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910011238190.10994@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009 12:38:42 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Tue, 29 Sep 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > (1) using "int"  will be never correct even on 32bit.
> > ==
> > vm_flags          242 arch/mips/mm/c-r3k.c 	int exec = vma->vm_flags & VM_EXEC;
> > vm_flags          293 drivers/char/mem.c 	return vma->vm_flags & VM_MAYSHARE;
> > vm_flags           44 mm/madvise.c   	int new_flags = vma->vm_flags;
> > vm_flags          547 mm/memory.c    	unsigned long vm_flags = vma->vm_flags;
> > 
> > But yes, it will be not a terrible bug for a while.
> 
> There may be a few, probably recently added and rarely used, vm_flags
> which we could consider moving from the low int to the high int of an
> unsigned long long, for cheaper operations where they're not involved.
> 
> But I've no intention to shuffle the majority of vm_flags around:
> VM_READ through VM_MAYSHARE will stay precisely where they are,
> and a lot of others beyond e.g. I don't see any need to make mm->
> def_flags an unsigned long long, so VM_LOCKED should stay low.
> 
> You say "using int will be never correct even on 32bit": you mean,
> when dealing with an unknown set of vm_flags, as in your madvise.c
> and memory.c examples above.  But the VM_EXEC example in arch/mips,
> I don't see any need to pester an arch maintainer to change it.
> The drivers/char/mem.c one I hadn't noticed (thanks), that one I'll
> happily change: not because it represents a bug, but just to set a
> good example to people adding such tests on higher flags in future.
> 

Sure.


> > 
> > (2) All vm macros should be defined with ULL suffix. for supporing ~ 
> > ==
> > vm_flags           30 arch/x86/mm/hugetlbpage.c 	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> > 
> > (3) vma_merge()'s vm_flags should be ULL.
> 
> At first I thought you'd saved me a lot of embarrassment by mentioning
> those ULL suffixes, I hadn't put them in.  But after a quick test of
> what I thought was going to show a problem without them, no problem.
> Please would you send me a test program which demonstrates the need
> for all those ULLs?
> 
Ah, I'm sorry if I misunderstand C's rule. 

There are some places which use ~.
like
	vm_flags = vma->vm_flags & ~(VM_LOCKED);

~VM_LOCKED is 
	0xffffdfff or 0xffffffffffffdffff ?

Is my concern.

I tried following function on my old x86 box
==
#define FLAG    (0x20)

int foo(unsigned long long x)
{
        return x & ~FLAG;
}
==
(returning "int" as "bool")

compile this with gcc -S -O2 (gcc's version is 4.0)
==
foo:
        pushl   %ebp
        movl    %esp, %ebp
        movl    8(%ebp), %eax
        andl    $-33, %eax
        leave
        ret
==
Them, it seems higher bits are ignored for returning bool.


> Certainly the added higher flags would need ULLs to get through the
> compiler (or preprocessor); and I don't mind adding ULLs throughout
> as an example (though VM_EXEC will give ARM a slight problem), they
> do seem to shave about 30 bytes off my build, presumably nudge the
> compiler towards making better choices in a few places.  But I've
> not yet seen why they're necessary.
> 
> I am *not* intending to pursue this further right now: I'd still
> prefer us to be looking for vm_flags we can weed out.  But the day
> is sure to come when we need to extend, so here for the record (and
> for your curiosity!) is the patch I built up: complete so far as I
> know, except for a VMA_VM_FLAGS endian question in ARM (I'm pretty
> sure I'd get it wrong if I tried to adjust that one myself).
> 
thanks.

Regards,
-Kame

> arch_mmap_check() was amusing: I should probably extract that
> part and send it in as a separate patch, but no hurry.
> 
> I still don't understand why this adds 100 bytes to do_mmap_pgoff():
> things I experimented with (e.g. changing vm_stat_account back to
> taking unsigned long, changing the calc_vm algorithm back to not
> be mixing types) only made a few bytes difference.
> 
> Hugh
> 
>  arch/arm/include/asm/cacheflush.h            |    7 -
>  arch/arm/kernel/asm-offsets.c                |    3 
>  arch/ia64/include/asm/mman.h                 |    5 
>  arch/ia64/kernel/sys_ia64.c                  |    3 
>  arch/powerpc/include/asm/mman.h              |    6 
>  arch/s390/include/asm/mman.h                 |    2 
>  arch/sh/mm/tlbflush_64.c                     |    2 
>  arch/sparc/include/asm/mman.h                |    2 
>  arch/x86/mm/hugetlbpage.c                    |    4 
>  drivers/char/mem.c                           |    2 
>  drivers/infiniband/hw/ipath/ipath_file_ops.c |    4 
>  drivers/staging/android/binder.c             |    6 
>  fs/binfmt_elf_fdpic.c                        |   12 -
>  fs/exec.c                                    |    5 
>  include/linux/hugetlb.h                      |    2 
>  include/linux/ksm.h                          |    4 
>  include/linux/mm.h                           |  109 +++++++----------
>  include/linux/mm_types.h                     |    4 
>  include/linux/mman.h                         |    8 -
>  include/linux/rmap.h                         |    4 
>  mm/filemap.c                                 |    6 
>  mm/fremap.c                                  |    2 
>  mm/ksm.c                                     |    2 
>  mm/madvise.c                                 |    2 
>  mm/memory.c                                  |   12 -
>  mm/mlock.c                                   |   14 --
>  mm/mmap.c                                    |   53 ++++----
>  mm/mprotect.c                                |   12 -
>  mm/mremap.c                                  |    2 
>  mm/nommu.c                                   |   15 +-
>  mm/rmap.c                                    |   10 -
>  mm/shmem.c                                   |    2 
>  mm/vmscan.c                                  |    4 
>  33 files changed, 158 insertions(+), 172 deletions(-)
> 
> --- 2.6.32-rc1/arch/arm/include/asm/cacheflush.h	2009-09-28 00:27:55.000000000 +0100
> +++ ull_vm_flags/arch/arm/include/asm/cacheflush.h	2009-09-29 16:48:15.000000000 +0100
> @@ -169,7 +169,7 @@
>   *		specified address space before a change of page tables.
>   *		- start - user start address (inclusive, page aligned)
>   *		- end   - user end address   (exclusive, page aligned)
> - *		- flags - vma->vm_flags field
> + *		- flags - low unsigned long of vma->vm_flags field
>   *
>   *	coherent_kern_range(start, end)
>   *
> @@ -343,7 +343,7 @@ flush_cache_range(struct vm_area_struct
>  {
>  	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm)))
>  		__cpuc_flush_user_range(start & PAGE_MASK, PAGE_ALIGN(end),
> -					vma->vm_flags);
> +					(unsigned long)vma->vm_flags);
>  }
>  
>  static inline void
> @@ -351,7 +351,8 @@ flush_cache_page(struct vm_area_struct *
>  {
>  	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm))) {
>  		unsigned long addr = user_addr & PAGE_MASK;
> -		__cpuc_flush_user_range(addr, addr + PAGE_SIZE, vma->vm_flags);
> +		__cpuc_flush_user_range(addr, addr + PAGE_SIZE,
> +					(unsigned long)vma->vm_flags);
>  	}
>  }
>  
> --- 2.6.32-rc1/arch/arm/kernel/asm-offsets.c	2008-07-13 22:51:29.000000000 +0100
> +++ ull_vm_flags/arch/arm/kernel/asm-offsets.c	2009-09-29 16:48:15.000000000 +0100
> @@ -88,8 +88,9 @@ int main(void)
>  #endif
>    DEFINE(VMA_VM_MM,		offsetof(struct vm_area_struct, vm_mm));
>    DEFINE(VMA_VM_FLAGS,		offsetof(struct vm_area_struct, vm_flags));
> +				/* but that will be wrong for bigendian? */
>    BLANK();
> -  DEFINE(VM_EXEC,	       	VM_EXEC);
> +  DEFINE(VM_EXEC,	       	0x00000004);	/* mm.h now appends ULL */
>    BLANK();
>    DEFINE(PAGE_SZ,	       	PAGE_SIZE);
>    BLANK();
> --- 2.6.32-rc1/arch/ia64/include/asm/mman.h	2009-09-28 00:27:59.000000000 +0100
> +++ ull_vm_flags/arch/ia64/include/asm/mman.h	2009-09-29 16:48:15.000000000 +0100
> @@ -14,9 +14,8 @@
>  
>  #ifdef __KERNEL__
>  #ifndef __ASSEMBLY__
> -#define arch_mmap_check	ia64_mmap_check
> -int ia64_mmap_check(unsigned long addr, unsigned long len,
> -		unsigned long flags);
> +#define arch_mmap_check(addr, len)	ia64_mmap_check(addr, len)
> +int ia64_mmap_check(unsigned long addr, unsigned long len);
>  #endif
>  #endif
>  
> --- 2.6.32-rc1/arch/ia64/kernel/sys_ia64.c	2009-03-23 23:12:14.000000000 +0000
> +++ ull_vm_flags/arch/ia64/kernel/sys_ia64.c	2009-09-29 16:48:15.000000000 +0100
> @@ -169,8 +169,7 @@ sys_ia64_pipe (void)
>  	return retval;
>  }
>  
> -int ia64_mmap_check(unsigned long addr, unsigned long len,
> -		unsigned long flags)
> +int ia64_mmap_check(unsigned long addr, unsigned long len)
>  {
>  	unsigned long roff;
>  
> --- 2.6.32-rc1/arch/powerpc/include/asm/mman.h	2009-09-28 00:28:03.000000000 +0100
> +++ ull_vm_flags/arch/powerpc/include/asm/mman.h	2009-09-29 16:48:15.000000000 +0100
> @@ -38,13 +38,13 @@
>   * This file is included by linux/mman.h, so we can't use cacl_vm_prot_bits()
>   * here.  How important is the optimization?
>   */
> -static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
> +static inline unsigned long long arch_calc_vm_prot_bits(unsigned long prot)
>  {
> -	return (prot & PROT_SAO) ? VM_SAO : 0;
> +	return (prot & PROT_SAO) ? VM_SAO : 0ULL;
>  }
>  #define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
>  
> -static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
> +static inline pgprot_t arch_vm_get_page_prot(unsigned long long vm_flags)
>  {
>  	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
>  }
> --- 2.6.32-rc1/arch/s390/include/asm/mman.h	2009-09-28 00:28:04.000000000 +0100
> +++ ull_vm_flags/arch/s390/include/asm/mman.h	2009-09-29 16:48:15.000000000 +0100
> @@ -12,8 +12,8 @@
>  #include <asm-generic/mman.h>
>  
>  #if defined(__KERNEL__) && !defined(__ASSEMBLY__) && defined(CONFIG_64BIT)
> +#define arch_mmap_check(addr, len)	s390_mmap_check(addr, len)
>  int s390_mmap_check(unsigned long addr, unsigned long len);
> -#define arch_mmap_check(addr,len,flags)	s390_mmap_check(addr,len)
>  #endif
>  
>  #endif /* __S390_MMAN_H__ */
> --- 2.6.32-rc1/arch/sh/mm/tlbflush_64.c	2009-09-28 00:28:11.000000000 +0100
> +++ ull_vm_flags/arch/sh/mm/tlbflush_64.c	2009-09-29 16:48:15.000000000 +0100
> @@ -48,7 +48,7 @@ static inline void print_vma(struct vm_a
>  	printk("vma end   0x%08lx\n", vma->vm_end);
>  
>  	print_prots(vma->vm_page_prot);
> -	printk("vm_flags 0x%08lx\n", vma->vm_flags);
> +	printk("vm_flags 0x%08llx\n", vma->vm_flags);
>  }
>  
>  static inline void print_task(struct task_struct *tsk)
> --- 2.6.32-rc1/arch/sparc/include/asm/mman.h	2009-09-28 00:28:11.000000000 +0100
> +++ ull_vm_flags/arch/sparc/include/asm/mman.h	2009-09-29 16:48:15.000000000 +0100
> @@ -25,7 +25,7 @@
>  
>  #ifdef __KERNEL__
>  #ifndef __ASSEMBLY__
> -#define arch_mmap_check(addr,len,flags)	sparc_mmap_check(addr,len)
> +#define arch_mmap_check(addr, len)	sparc_mmap_check(addr, len)
>  int sparc_mmap_check(unsigned long addr, unsigned long len);
>  #endif
>  #endif
> --- 2.6.32-rc1/arch/x86/mm/hugetlbpage.c	2009-06-10 04:05:27.000000000 +0100
> +++ ull_vm_flags/arch/x86/mm/hugetlbpage.c	2009-09-29 16:48:15.000000000 +0100
> @@ -27,8 +27,8 @@ static unsigned long page_table_shareabl
>  	unsigned long s_end = sbase + PUD_SIZE;
>  
>  	/* Allow segments to share if only one is marked locked */
> -	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> -	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
> +	unsigned long long vm_flags = vma->vm_flags & ~VM_LOCKED;
> +	unsigned long long svm_flags = svma->vm_flags & ~VM_LOCKED;
>  
>  	/*
>  	 * match the virtual addresses, permission and the alignment of the
> --- 2.6.32-rc1/drivers/char/mem.c	2009-09-28 00:28:15.000000000 +0100
> +++ ull_vm_flags/drivers/char/mem.c	2009-09-29 16:48:15.000000000 +0100
> @@ -290,7 +290,7 @@ static unsigned long get_unmapped_area_m
>  /* can't do an in-place private mapping if there's no MMU */
>  static inline int private_mapping_ok(struct vm_area_struct *vma)
>  {
> -	return vma->vm_flags & VM_MAYSHARE;
> +	return (vma->vm_flags & VM_MAYSHARE) != 0;
>  }
>  #else
>  #define get_unmapped_area_mem	NULL
> --- 2.6.32-rc1/drivers/infiniband/hw/ipath/ipath_file_ops.c	2009-09-28 00:28:17.000000000 +0100
> +++ ull_vm_flags/drivers/infiniband/hw/ipath/ipath_file_ops.c	2009-09-29 16:48:15.000000000 +0100
> @@ -1112,7 +1112,7 @@ static int mmap_rcvegrbufs(struct vm_are
>  
>  	if (vma->vm_flags & VM_WRITE) {
>  		dev_info(&dd->pcidev->dev, "Can't map eager buffers as "
> -			 "writable (flags=%lx)\n", vma->vm_flags);
> +			 "writable (flags=%llx)\n", vma->vm_flags);
>  		ret = -EPERM;
>  		goto bail;
>  	}
> @@ -1201,7 +1201,7 @@ static int mmap_kvaddr(struct vm_area_st
>                  if (vma->vm_flags & VM_WRITE) {
>                          dev_info(&dd->pcidev->dev,
>                                   "Can't map eager buffers as "
> -                                 "writable (flags=%lx)\n", vma->vm_flags);
> +                                 "writable (flags=%llx)\n", vma->vm_flags);
>                          ret = -EPERM;
>                          goto bail;
>                  }
> --- 2.6.32-rc1/drivers/staging/android/binder.c	2009-09-28 00:28:28.000000000 +0100
> +++ ull_vm_flags/drivers/staging/android/binder.c	2009-09-29 16:48:15.000000000 +0100
> @@ -2737,7 +2737,7 @@ static void binder_vma_open(struct vm_ar
>  {
>  	struct binder_proc *proc = vma->vm_private_data;
>  	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
> -		     "binder: %d open vm area %lx-%lx (%ld K) vma %lx pagep %lx\n",
> +		     "binder: %d open vm area %lx-%lx (%ld K) vma %llx pagep %lx\n",
>  		     proc->pid, vma->vm_start, vma->vm_end,
>  		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
>  		     (unsigned long)pgprot_val(vma->vm_page_prot));
> @@ -2748,7 +2748,7 @@ static void binder_vma_close(struct vm_a
>  {
>  	struct binder_proc *proc = vma->vm_private_data;
>  	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
> -		     "binder: %d close vm area %lx-%lx (%ld K) vma %lx pagep %lx\n",
> +		     "binder: %d close vm area %lx-%lx (%ld K) vma %llx pagep %lx\n",
>  		     proc->pid, vma->vm_start, vma->vm_end,
>  		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
>  		     (unsigned long)pgprot_val(vma->vm_page_prot));
> @@ -2773,7 +2773,7 @@ static int binder_mmap(struct file *filp
>  		vma->vm_end = vma->vm_start + SZ_4M;
>  
>  	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
> -		     "binder_mmap: %d %lx-%lx (%ld K) vma %lx pagep %lx\n",
> +		     "binder_mmap: %d %lx-%lx (%ld K) vma %llx pagep %lx\n",
>  		     proc->pid, vma->vm_start, vma->vm_end,
>  		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
>  		     (unsigned long)pgprot_val(vma->vm_page_prot));
> --- 2.6.32-rc1/fs/binfmt_elf_fdpic.c	2009-09-28 00:28:34.000000000 +0100
> +++ ull_vm_flags/fs/binfmt_elf_fdpic.c	2009-09-29 16:48:15.000000000 +0100
> @@ -1235,7 +1235,7 @@ static int maydump(struct vm_area_struct
>  
>  	/* Do not dump I/O mapped devices or special mappings */
>  	if (vma->vm_flags & (VM_IO | VM_RESERVED)) {
> -		kdcore("%08lx: %08lx: no (IO)", vma->vm_start, vma->vm_flags);
> +		kdcore("%08lx: %08llx: no (IO)", vma->vm_start, vma->vm_flags);
>  		return 0;
>  	}
>  
> @@ -1243,7 +1243,7 @@ static int maydump(struct vm_area_struct
>  	 * them either. "dump_write()" can't handle it anyway.
>  	 */
>  	if (!(vma->vm_flags & VM_READ)) {
> -		kdcore("%08lx: %08lx: no (!read)", vma->vm_start, vma->vm_flags);
> +		kdcore("%08lx: %08llx: no (!read)", vma->vm_start, vma->vm_flags);
>  		return 0;
>  	}
>  
> @@ -1251,13 +1251,13 @@ static int maydump(struct vm_area_struct
>  	if (vma->vm_flags & VM_SHARED) {
>  		if (vma->vm_file->f_path.dentry->d_inode->i_nlink == 0) {
>  			dump_ok = test_bit(MMF_DUMP_ANON_SHARED, &mm_flags);
> -			kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
> +			kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
>  			       vma->vm_flags, dump_ok ? "yes" : "no");
>  			return dump_ok;
>  		}
>  
>  		dump_ok = test_bit(MMF_DUMP_MAPPED_SHARED, &mm_flags);
> -		kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
> +		kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
>  		       vma->vm_flags, dump_ok ? "yes" : "no");
>  		return dump_ok;
>  	}
> @@ -1266,14 +1266,14 @@ static int maydump(struct vm_area_struct
>  	/* By default, if it hasn't been written to, don't write it out */
>  	if (!vma->anon_vma) {
>  		dump_ok = test_bit(MMF_DUMP_MAPPED_PRIVATE, &mm_flags);
> -		kdcore("%08lx: %08lx: %s (!anon)", vma->vm_start,
> +		kdcore("%08lx: %08llx: %s (!anon)", vma->vm_start,
>  		       vma->vm_flags, dump_ok ? "yes" : "no");
>  		return dump_ok;
>  	}
>  #endif
>  
>  	dump_ok = test_bit(MMF_DUMP_ANON_PRIVATE, &mm_flags);
> -	kdcore("%08lx: %08lx: %s", vma->vm_start, vma->vm_flags,
> +	kdcore("%08lx: %08llx: %s", vma->vm_start, vma->vm_flags,
>  	       dump_ok ? "yes" : "no");
>  	return dump_ok;
>  }
> --- 2.6.32-rc1/fs/exec.c	2009-09-28 00:28:35.000000000 +0100
> +++ ull_vm_flags/fs/exec.c	2009-09-29 16:48:15.000000000 +0100
> @@ -570,7 +570,7 @@ int setup_arg_pages(struct linux_binprm
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma = bprm->vma;
>  	struct vm_area_struct *prev = NULL;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  	unsigned long stack_base;
>  
>  #ifdef CONFIG_STACK_GROWSUP
> @@ -615,8 +615,7 @@ int setup_arg_pages(struct linux_binprm
>  		vm_flags &= ~VM_EXEC;
>  	vm_flags |= mm->def_flags;
>  
> -	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
> -			vm_flags);
> +	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags);
>  	if (ret)
>  		goto out_unlock;
>  	BUG_ON(prev != vma);
> --- 2.6.32-rc1/include/linux/hugetlb.h	2009-09-28 00:28:38.000000000 +0100
> +++ ull_vm_flags/include/linux/hugetlb.h	2009-09-29 16:48:15.000000000 +0100
> @@ -16,7 +16,7 @@ int PageHuge(struct page *page);
>  
>  static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
>  {
> -	return vma->vm_flags & VM_HUGETLB;
> +	return (vma->vm_flags & VM_HUGETLB) != 0;
>  }
>  
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
> --- 2.6.32-rc1/include/linux/ksm.h	2009-09-28 00:28:38.000000000 +0100
> +++ ull_vm_flags/include/linux/ksm.h	2009-09-29 16:48:15.000000000 +0100
> @@ -14,7 +14,7 @@
>  
>  #ifdef CONFIG_KSM
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -		unsigned long end, int advice, unsigned long *vm_flags);
> +		unsigned long end, int advice, unsigned long long *vm_flags);
>  int __ksm_enter(struct mm_struct *mm);
>  void __ksm_exit(struct mm_struct *mm);
>  
> @@ -54,7 +54,7 @@ static inline void page_add_ksm_rmap(str
>  #else  /* !CONFIG_KSM */
>  
>  static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -		unsigned long end, int advice, unsigned long *vm_flags)
> +		unsigned long end, int advice, unsigned long long *vm_flags)
>  {
>  	return 0;
>  }
> --- 2.6.32-rc1/include/linux/mm.h	2009-09-28 00:28:38.000000000 +0100
> +++ ull_vm_flags/include/linux/mm.h	2009-09-29 16:48:15.000000000 +0100
> @@ -65,46 +65,49 @@ extern unsigned int kobjsize(const void
>  /*
>   * vm_flags in vm_area_struct, see mm_types.h.
>   */
> -#define VM_READ		0x00000001	/* currently active flags */
> -#define VM_WRITE	0x00000002
> -#define VM_EXEC		0x00000004
> -#define VM_SHARED	0x00000008
> +#define VM_READ		0x00000001ULL	/* currently active flags */
> +#define VM_WRITE	0x00000002ULL
> +#define VM_EXEC		0x00000004ULL
> +#define VM_SHARED	0x00000008ULL
>  
>  /* mprotect() hardcodes VM_MAYREAD >> 4 == VM_READ, and so for r/w/x bits. */
> -#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
> -#define VM_MAYWRITE	0x00000020
> -#define VM_MAYEXEC	0x00000040
> -#define VM_MAYSHARE	0x00000080
> -
> -#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
> -#define VM_GROWSUP	0x00000200
> -#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
> -#define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
> -
> -#define VM_EXECUTABLE	0x00001000
> -#define VM_LOCKED	0x00002000
> -#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
> +#define VM_MAYREAD	0x00000010ULL	/* limits for mprotect() etc */
> +#define VM_MAYWRITE	0x00000020ULL
> +#define VM_MAYEXEC	0x00000040ULL
> +#define VM_MAYSHARE	0x00000080ULL
> +
> +#define VM_GROWSDOWN	0x00000100ULL	/* general info on the segment */
> +#define VM_GROWSUP	0x00000200ULL
> +#define VM_PFNMAP	0x00000400ULL	/* Page-ranges managed without "struct page", just pure PFN */
> +#define VM_DENYWRITE	0x00000800ULL	/* ETXTBSY on write attempts.. */
> +
> +#define VM_EXECUTABLE	0x00001000ULL
> +#define VM_LOCKED	0x00002000ULL
> +#define VM_IO   	0x00004000ULL	/* Memory mapped I/O or similar */
>  
>  					/* Used by sys_madvise() */
> -#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
> -#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
> +#define VM_SEQ_READ	0x00008000ULL	/* App will access data sequentially */
> +#define VM_RAND_READ	0x00010000ULL	/* App will not benefit from clustered reads */
>  
> -#define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
> -#define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
> -#define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
> -#define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
> -#define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
> -#define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
> -#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
> -#define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
> -#define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
> -#define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
> -
> -#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
> -#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
> -#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
> -#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
> -#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
> +#define VM_DONTCOPY	0x00020000ULL	/* Do not copy this vma on fork */
> +#define VM_DONTEXPAND	0x00040000ULL	/* Cannot expand with mremap() */
> +#define VM_RESERVED	0x00080000ULL	/* Count as reserved_vm like IO */
> +
> +#define VM_ACCOUNT	0x00100000ULL	/* Is a VM accounted object */
> +#define VM_NORESERVE	0x00200000ULL	/* should the VM suppress accounting */
> +#define VM_HUGETLB	0x00400000ULL	/* Huge TLB Page VM */
> +#define VM_NONLINEAR	0x00800000ULL	/* Is non-linear (remap_file_pages) */
> +
> +#define VM_MAPPED_COPY	0x01000000ULL	/* T if mapped copy of data (nommu mmap) */
> +#define VM_INSERTPAGE	0x02000000ULL	/* The vma has had "vm_insert_page()" done on it */
> +#define VM_ALWAYSDUMP	0x04000000ULL	/* Always include in core dumps */
> +
> +#define VM_CAN_NONLINEAR 0x08000000ULL	/* Has ->fault & does nonlinear pages */
> +
> +#define VM_MIXEDMAP	0x10000000ULL	/* Can contain "struct page" and pure PFN pages */
> +#define VM_SAO		0x20000000ULL	/* Strong Access Ordering (powerpc) */
> +#define VM_PFN_AT_MMAP	0x40000000ULL	/* PFNMAP vma that is fully mapped at mmap time */
> +#define VM_MERGEABLE	0x80000000ULL	/* KSM may merge identical pages */
>  
>  #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
>  #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
> @@ -116,12 +119,6 @@ extern unsigned int kobjsize(const void
>  #define VM_STACK_FLAGS	(VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
>  #endif
>  
> -#define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
> -#define VM_ClearReadHint(v)		(v)->vm_flags &= ~VM_READHINTMASK
> -#define VM_NormalReadHint(v)		(!((v)->vm_flags & VM_READHINTMASK))
> -#define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
> -#define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
> -
>  /*
>   * special vmas that are non-mergable, non-mlock()able
>   */
> @@ -147,12 +144,12 @@ extern pgprot_t protection_map[16];
>   */
>  static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
>  {
> -	return (vma->vm_flags & VM_PFN_AT_MMAP);
> +	return (vma->vm_flags & VM_PFN_AT_MMAP) != 0;
>  }
>  
>  static inline int is_pfn_mapping(struct vm_area_struct *vma)
>  {
> -	return (vma->vm_flags & VM_PFNMAP);
> +	return (vma->vm_flags & VM_PFNMAP) != 0;
>  }
>  
>  /*
> @@ -715,14 +712,6 @@ int shmem_lock(struct file *file, int lo
>  struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags);
>  int shmem_zero_setup(struct vm_area_struct *);
>  
> -#ifndef CONFIG_MMU
> -extern unsigned long shmem_get_unmapped_area(struct file *file,
> -					     unsigned long addr,
> -					     unsigned long len,
> -					     unsigned long pgoff,
> -					     unsigned long flags);
> -#endif
> -
>  extern int can_do_mlock(void);
>  extern int user_shm_lock(size_t, struct user_struct *);
>  extern void user_shm_unlock(size_t, struct user_struct *);
> @@ -845,7 +834,7 @@ extern unsigned long do_mremap(unsigned
>  			       unsigned long flags, unsigned long new_addr);
>  extern int mprotect_fixup(struct vm_area_struct *vma,
>  			  struct vm_area_struct **pprev, unsigned long start,
> -			  unsigned long end, unsigned long newflags);
> +			  unsigned long end, unsigned long long newflags);
>  
>  /*
>   * doesn't attempt to fault and will return short.
> @@ -1096,7 +1085,7 @@ extern void vma_adjust(struct vm_area_st
>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
>  extern struct vm_area_struct *vma_merge(struct mm_struct *,
>  	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
> -	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
> +	unsigned long long vm_flags, struct anon_vma *, struct file *, pgoff_t,
>  	struct mempolicy *);
>  extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
>  extern int split_vma(struct mm_struct *,
> @@ -1125,9 +1114,8 @@ static inline void removed_exe_file_vma(
>  #endif /* CONFIG_PROC_FS */
>  
>  extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
> -extern int install_special_mapping(struct mm_struct *mm,
> -				   unsigned long addr, unsigned long len,
> -				   unsigned long flags, struct page **pages);
> +extern int install_special_mapping(struct mm_struct *mm, unsigned long addr,
> +	unsigned long len, unsigned long long vm_flags, struct page **pages);
>  
>  extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
>  
> @@ -1136,7 +1124,7 @@ extern unsigned long do_mmap_pgoff(struc
>  	unsigned long flag, unsigned long pgoff);
>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long flags,
> -	unsigned int vm_flags, unsigned long pgoff);
> +	unsigned long long vm_flags, unsigned long pgoff);
>  
>  static inline unsigned long do_mmap(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long prot,
> @@ -1222,7 +1210,7 @@ static inline unsigned long vma_pages(st
>  	return (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
>  }
>  
> -pgprot_t vm_get_page_prot(unsigned long vm_flags);
> +pgprot_t vm_get_page_prot(unsigned long long vm_flags);
>  struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
> @@ -1246,10 +1234,11 @@ extern int apply_to_page_range(struct mm
>  			       unsigned long size, pte_fn_t fn, void *data);
>  
>  #ifdef CONFIG_PROC_FS
> -void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
> +void vm_stat_account(struct mm_struct *mm,
> +		unsigned long long vm_flags, struct file *file, long pages);
>  #else
>  static inline void vm_stat_account(struct mm_struct *mm,
> -			unsigned long flags, struct file *file, long pages)
> +		unsigned long long vm_flags, struct file *file, long pages)
>  {
>  }
>  #endif /* CONFIG_PROC_FS */
> --- 2.6.32-rc1/include/linux/mm_types.h	2009-09-28 00:28:38.000000000 +0100
> +++ ull_vm_flags/include/linux/mm_types.h	2009-09-29 16:48:15.000000000 +0100
> @@ -115,7 +115,7 @@ struct page {
>   */
>  struct vm_region {
>  	struct rb_node	vm_rb;		/* link in global region tree */
> -	unsigned long	vm_flags;	/* VMA vm_flags */
> +	unsigned long long vm_flags;	/* VMA vm_flags */
>  	unsigned long	vm_start;	/* start address of region */
>  	unsigned long	vm_end;		/* region initialised to here */
>  	unsigned long	vm_top;		/* region allocated to here */
> @@ -141,7 +141,7 @@ struct vm_area_struct {
>  	struct vm_area_struct *vm_next;
>  
>  	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
> -	unsigned long vm_flags;		/* Flags, see mm.h. */
> +	unsigned long long vm_flags;	/* Flags, see mm.h. */
>  
>  	struct rb_node vm_rb;
>  
> --- 2.6.32-rc1/include/linux/mman.h	2009-06-10 04:05:27.000000000 +0100
> +++ ull_vm_flags/include/linux/mman.h	2009-09-29 16:48:15.000000000 +0100
> @@ -35,7 +35,7 @@ static inline void vm_unacct_memory(long
>   */
>  
>  #ifndef arch_calc_vm_prot_bits
> -#define arch_calc_vm_prot_bits(prot) 0
> +#define arch_calc_vm_prot_bits(prot)	0ULL
>  #endif
>  
>  #ifndef arch_vm_get_page_prot
> @@ -69,8 +69,7 @@ static inline int arch_validate_prot(uns
>  /*
>   * Combine the mmap "prot" argument into "vm_flags" used internally.
>   */
> -static inline unsigned long
> -calc_vm_prot_bits(unsigned long prot)
> +static inline unsigned long long calc_vm_prot_bits(unsigned long prot)
>  {
>  	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
>  	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
> @@ -81,8 +80,7 @@ calc_vm_prot_bits(unsigned long prot)
>  /*
>   * Combine the mmap "flags" argument into "vm_flags" used internally.
>   */
> -static inline unsigned long
> -calc_vm_flag_bits(unsigned long flags)
> +static inline unsigned long long calc_vm_flag_bits(unsigned long flags)
>  {
>  	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
>  	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
> --- 2.6.32-rc1/include/linux/rmap.h	2009-09-28 00:28:39.000000000 +0100
> +++ ull_vm_flags/include/linux/rmap.h	2009-09-29 16:48:15.000000000 +0100
> @@ -80,7 +80,7 @@ static inline void page_dup_rmap(struct
>   * Called from mm/vmscan.c to handle paging out
>   */
>  int page_referenced(struct page *, int is_locked,
> -			struct mem_cgroup *cnt, unsigned long *vm_flags);
> +			struct mem_cgroup *cnt, unsigned long long *vm_flags);
>  enum ttu_flags {
>  	TTU_UNMAP = 0,			/* unmap mode */
>  	TTU_MIGRATION = 1,		/* migration mode */
> @@ -135,7 +135,7 @@ int page_mapped_in_vma(struct page *page
>  
>  static inline int page_referenced(struct page *page, int is_locked,
>  				  struct mem_cgroup *cnt,
> -				  unsigned long *vm_flags)
> +				  unsigned long long *vm_flags)
>  {
>  	*vm_flags = 0;
>  	return TestClearPageReferenced(page);
> --- 2.6.32-rc1/mm/filemap.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/filemap.c	2009-09-29 16:48:15.000000000 +0100
> @@ -1429,10 +1429,10 @@ static void do_sync_mmap_readahead(struc
>  	struct address_space *mapping = file->f_mapping;
>  
>  	/* If we don't want any read-ahead, don't bother */
> -	if (VM_RandomReadHint(vma))
> +	if (vma->vm_flags & VM_RAND_READ)
>  		return;
>  
> -	if (VM_SequentialReadHint(vma) ||
> +	if ((vma->vm_flags & VM_SEQ_READ) ||
>  			offset - 1 == (ra->prev_pos >> PAGE_CACHE_SHIFT)) {
>  		page_cache_sync_readahead(mapping, ra, file, offset,
>  					  ra->ra_pages);
> @@ -1474,7 +1474,7 @@ static void do_async_mmap_readahead(stru
>  	struct address_space *mapping = file->f_mapping;
>  
>  	/* If we don't want any read-ahead, don't bother */
> -	if (VM_RandomReadHint(vma))
> +	if (vma->vm_flags & VM_RAND_READ)
>  		return;
>  	if (ra->mmap_miss > 0)
>  		ra->mmap_miss--;
> --- 2.6.32-rc1/mm/fremap.c	2009-03-23 23:12:14.000000000 +0000
> +++ ull_vm_flags/mm/fremap.c	2009-09-29 16:48:15.000000000 +0100
> @@ -221,7 +221,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>  		/*
>  		 * drop PG_Mlocked flag for over-mapped range
>  		 */
> -		unsigned int saved_flags = vma->vm_flags;
> +		unsigned long long saved_flags = vma->vm_flags;
>  		munlock_vma_pages_range(vma, start, start + size);
>  		vma->vm_flags = saved_flags;
>  	}
> --- 2.6.32-rc1/mm/ksm.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/ksm.c	2009-09-29 16:48:15.000000000 +0100
> @@ -1366,7 +1366,7 @@ static int ksm_scan_thread(void *nothing
>  }
>  
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -		unsigned long end, int advice, unsigned long *vm_flags)
> +		unsigned long end, int advice, unsigned long long *vm_flags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	int err;
> --- 2.6.32-rc1/mm/madvise.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/madvise.c	2009-09-29 16:48:15.000000000 +0100
> @@ -42,7 +42,7 @@ static long madvise_behavior(struct vm_a
>  	struct mm_struct * mm = vma->vm_mm;
>  	int error = 0;
>  	pgoff_t pgoff;
> -	unsigned long new_flags = vma->vm_flags;
> +	unsigned long long new_flags = vma->vm_flags;
>  
>  	switch (behavior) {
>  	case MADV_NORMAL:
> --- 2.6.32-rc1/mm/memory.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/memory.c	2009-09-29 16:48:15.000000000 +0100
> @@ -437,7 +437,7 @@ static void print_bad_pte(struct vm_area
>  		page_mapcount(page), page->mapping, page->index);
>  	}
>  	printk(KERN_ALERT
> -		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
> +		"addr:%p vm_flags:%08llx anon_vma:%p mapping:%p index:%lx\n",
>  		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
>  	/*
>  	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
> @@ -452,9 +452,9 @@ static void print_bad_pte(struct vm_area
>  	add_taint(TAINT_BAD_PAGE);
>  }
>  
> -static inline int is_cow_mapping(unsigned int flags)
> +static inline int is_cow_mapping(unsigned long long vm_flags)
>  {
> -	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> +	return (vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
>  }
>  
>  #ifndef is_zero_pfn
> @@ -577,7 +577,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
>  		unsigned long addr, int *rss)
>  {
> -	unsigned long vm_flags = vma->vm_flags;
> +	unsigned long long vm_flags = vma->vm_flags;
>  	pte_t pte = *src_pte;
>  	struct page *page;
>  
> @@ -852,7 +852,7 @@ static unsigned long zap_pte_range(struc
>  				if (pte_dirty(ptent))
>  					set_page_dirty(page);
>  				if (pte_young(ptent) &&
> -				    likely(!VM_SequentialReadHint(vma)))
> +				    likely((!(vma->vm_flags & VM_SEQ_READ))))
>  					mark_page_accessed(page);
>  				file_rss--;
>  			}
> @@ -1231,7 +1231,7 @@ int __get_user_pages(struct task_struct
>  		     struct page **pages, struct vm_area_struct **vmas)
>  {
>  	int i;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  
>  	if (nr_pages <= 0)
>  		return 0;
> --- 2.6.32-rc1/mm/mlock.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/mlock.c	2009-09-29 16:48:15.000000000 +0100
> @@ -266,8 +266,7 @@ long mlock_vma_pages_range(struct vm_are
>  	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>  		goto no_mlock;
>  
> -	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> -			is_vm_hugetlb_page(vma) ||
> +	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED | VM_HUGETLB)) ||
>  			vma == get_gate_vma(current))) {
>  
>  		__mlock_vma_pages_range(vma, start, end);
> @@ -354,20 +353,19 @@ void munlock_vma_pages_range(struct vm_a
>   * For vmas that pass the filters, merge/split as appropriate.
>   */
>  static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
> -	unsigned long start, unsigned long end, unsigned int newflags)
> +	unsigned long start, unsigned long end, unsigned long long newflags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pgoff_t pgoff;
>  	int nr_pages;
>  	int ret = 0;
> -	int lock = newflags & VM_LOCKED;
> +	int lock = !!(newflags & VM_LOCKED);
>  
>  	if (newflags == vma->vm_flags ||
>  			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
>  		goto out;	/* don't set VM_LOCKED,  don't count */
>  
> -	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> -			is_vm_hugetlb_page(vma) ||
> +	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED | VM_HUGETLB)) ||
>  			vma == get_gate_vma(current)) {
>  		if (lock)
>  			make_pages_present(start, end);
> @@ -443,7 +441,7 @@ static int do_mlock(unsigned long start,
>  		prev = vma;
>  
>  	for (nstart = start ; ; ) {
> -		unsigned int newflags;
> +		unsigned long long newflags;
>  
>  		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
>  
> @@ -524,7 +522,7 @@ static int do_mlockall(int flags)
>  		goto out;
>  
>  	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
> -		unsigned int newflags;
> +		unsigned long long newflags;
>  
>  		newflags = vma->vm_flags | VM_LOCKED;
>  		if (!(flags & MCL_CURRENT))
> --- 2.6.32-rc1/mm/mmap.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/mmap.c	2009-09-29 16:48:15.000000000 +0100
> @@ -38,7 +38,7 @@
>  #include "internal.h"
>  
>  #ifndef arch_mmap_check
> -#define arch_mmap_check(addr, len, flags)	(0)
> +#define arch_mmap_check(addr, len)			(0)
>  #endif
>  
>  #ifndef arch_rebalance_pgtables
> @@ -75,7 +75,7 @@ pgprot_t protection_map[16] = {
>  	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
>  };
>  
> -pgprot_t vm_get_page_prot(unsigned long vm_flags)
> +pgprot_t vm_get_page_prot(unsigned long long vm_flags)
>  {
>  	return __pgprot(pgprot_val(protection_map[vm_flags &
>  				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
> @@ -661,7 +661,7 @@ again:			remove_next = 1 + (end > next->
>   * per-vma resources, so we don't attempt to merge those.
>   */
>  static inline int is_mergeable_vma(struct vm_area_struct *vma,
> -			struct file *file, unsigned long vm_flags)
> +			struct file *file, unsigned long long vm_flags)
>  {
>  	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
>  	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
> @@ -691,7 +691,7 @@ static inline int is_mergeable_anon_vma(
>   * wrap, nor mmaps which cover the final page at index -1UL.
>   */
>  static int
> -can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
> +can_vma_merge_before(struct vm_area_struct *vma, unsigned long long vm_flags,
>  	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
>  {
>  	if (is_mergeable_vma(vma, file, vm_flags) &&
> @@ -710,7 +710,7 @@ can_vma_merge_before(struct vm_area_stru
>   * anon_vmas, nor if same anon_vma is assigned but offsets incompatible.
>   */
>  static int
> -can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
> +can_vma_merge_after(struct vm_area_struct *vma, unsigned long long vm_flags,
>  	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
>  {
>  	if (is_mergeable_vma(vma, file, vm_flags) &&
> @@ -754,7 +754,7 @@ can_vma_merge_after(struct vm_area_struc
>   */
>  struct vm_area_struct *vma_merge(struct mm_struct *mm,
>  			struct vm_area_struct *prev, unsigned long addr,
> -			unsigned long end, unsigned long vm_flags,
> +			unsigned long end, unsigned long long vm_flags,
>  		     	struct anon_vma *anon_vma, struct file *file,
>  			pgoff_t pgoff, struct mempolicy *policy)
>  {
> @@ -831,7 +831,7 @@ struct vm_area_struct *vma_merge(struct
>  struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *vma)
>  {
>  	struct vm_area_struct *near;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  
>  	near = vma->vm_next;
>  	if (!near)
> @@ -885,19 +885,19 @@ none:
>  }
>  
>  #ifdef CONFIG_PROC_FS
> -void vm_stat_account(struct mm_struct *mm, unsigned long flags,
> +void vm_stat_account(struct mm_struct *mm, unsigned long long vm_flags,
>  						struct file *file, long pages)
>  {
> -	const unsigned long stack_flags
> +	const unsigned long long stack_flags
>  		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
>  
>  	if (file) {
>  		mm->shared_vm += pages;
> -		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
> +		if ((vm_flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
>  			mm->exec_vm += pages;
> -	} else if (flags & stack_flags)
> +	} else if (vm_flags & stack_flags)
>  		mm->stack_vm += pages;
> -	if (flags & (VM_RESERVED|VM_IO))
> +	if (vm_flags & (VM_RESERVED|VM_IO))
>  		mm->reserved_vm += pages;
>  }
>  #endif /* CONFIG_PROC_FS */
> @@ -912,7 +912,7 @@ unsigned long do_mmap_pgoff(struct file
>  {
>  	struct mm_struct * mm = current->mm;
>  	struct inode *inode;
> -	unsigned int vm_flags;
> +	unsigned long long vm_flags;
>  	int error;
>  	unsigned long reqprot = prot;
>  
> @@ -932,7 +932,7 @@ unsigned long do_mmap_pgoff(struct file
>  	if (!(flags & MAP_FIXED))
>  		addr = round_hint_to_min(addr);
>  
> -	error = arch_mmap_check(addr, len, flags);
> +	error = arch_mmap_check(addr, len);
>  	if (error)
>  		return error;
>  
> @@ -1077,7 +1077,7 @@ EXPORT_SYMBOL(do_mmap_pgoff);
>   */
>  int vma_wants_writenotify(struct vm_area_struct *vma)
>  {
> -	unsigned int vm_flags = vma->vm_flags;
> +	unsigned long long vm_flags = vma->vm_flags;
>  
>  	/* If it was private or non-writable, the write bit is already clear */
>  	if ((vm_flags & (VM_WRITE|VM_SHARED)) != ((VM_WRITE|VM_SHARED)))
> @@ -1105,7 +1105,8 @@ int vma_wants_writenotify(struct vm_area
>   * We account for memory if it's a private writeable mapping,
>   * not hugepages and VM_NORESERVE wasn't set.
>   */
> -static inline int accountable_mapping(struct file *file, unsigned int vm_flags)
> +static inline int accountable_mapping(struct file *file,
> +				      unsigned long long vm_flags)
>  {
>  	/*
>  	 * hugetlb has its own accounting separate from the core VM
> @@ -1119,7 +1120,7 @@ static inline int accountable_mapping(st
>  
>  unsigned long mmap_region(struct file *file, unsigned long addr,
>  			  unsigned long len, unsigned long flags,
> -			  unsigned int vm_flags, unsigned long pgoff)
> +			  unsigned long long vm_flags, unsigned long pgoff)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> @@ -1994,7 +1995,7 @@ unsigned long do_brk(unsigned long addr,
>  {
>  	struct mm_struct * mm = current->mm;
>  	struct vm_area_struct * vma, * prev;
> -	unsigned long flags;
> +	unsigned long long vm_flags;
>  	struct rb_node ** rb_link, * rb_parent;
>  	pgoff_t pgoff = addr >> PAGE_SHIFT;
>  	int error;
> @@ -2013,9 +2014,7 @@ unsigned long do_brk(unsigned long addr,
>  	if (error)
>  		return error;
>  
> -	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> -
> -	error = arch_mmap_check(addr, len, flags);
> +	error = arch_mmap_check(addr, len);
>  	if (error)
>  		return error;
>  
> @@ -2059,8 +2058,10 @@ unsigned long do_brk(unsigned long addr,
>  	if (security_vm_enough_memory(len >> PAGE_SHIFT))
>  		return -ENOMEM;
>  
> +	vm_flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> +
>  	/* Can we just expand an old private anonymous mapping? */
> -	vma = vma_merge(mm, prev, addr, addr + len, flags,
> +	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
>  					NULL, NULL, pgoff, NULL);
>  	if (vma)
>  		goto out;
> @@ -2078,12 +2079,12 @@ unsigned long do_brk(unsigned long addr,
>  	vma->vm_start = addr;
>  	vma->vm_end = addr + len;
>  	vma->vm_pgoff = pgoff;
> -	vma->vm_flags = flags;
> -	vma->vm_page_prot = vm_get_page_prot(flags);
> +	vma->vm_flags = vm_flags;
> +	vma->vm_page_prot = vm_get_page_prot(vm_flags);
>  	vma_link(mm, vma, prev, rb_link, rb_parent);
>  out:
>  	mm->total_vm += len >> PAGE_SHIFT;
> -	if (flags & VM_LOCKED) {
> +	if (vm_flags & VM_LOCKED) {
>  		if (!mlock_vma_pages_range(vma, addr, addr + len))
>  			mm->locked_vm += (len >> PAGE_SHIFT);
>  	}
> @@ -2298,7 +2299,7 @@ static const struct vm_operations_struct
>   */
>  int install_special_mapping(struct mm_struct *mm,
>  			    unsigned long addr, unsigned long len,
> -			    unsigned long vm_flags, struct page **pages)
> +			    unsigned long long vm_flags, struct page **pages)
>  {
>  	struct vm_area_struct *vma;
>  
> --- 2.6.32-rc1/mm/mprotect.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/mprotect.c	2009-09-29 16:48:15.000000000 +0100
> @@ -134,10 +134,10 @@ static void change_protection(struct vm_
>  
>  int
>  mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
> -	unsigned long start, unsigned long end, unsigned long newflags)
> +	unsigned long start, unsigned long end, unsigned long long newflags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long oldflags = vma->vm_flags;
> +	unsigned long long oldflags = vma->vm_flags;
>  	long nrpages = (end - start) >> PAGE_SHIFT;
>  	unsigned long charged = 0;
>  	pgoff_t pgoff;
> @@ -222,7 +222,7 @@ fail:
>  SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>  		unsigned long, prot)
>  {
> -	unsigned long vm_flags, nstart, end, tmp, reqprot;
> +	unsigned long vm_prots, nstart, end, tmp, reqprot;
>  	struct vm_area_struct *vma, *prev;
>  	int error = -EINVAL;
>  	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
> @@ -248,7 +248,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>  	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
>  		prot |= PROT_EXEC;
>  
> -	vm_flags = calc_vm_prot_bits(prot);
> +	vm_prots = calc_vm_prot_bits(prot);
>  
>  	down_write(&current->mm->mmap_sem);
>  
> @@ -278,11 +278,11 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>  		prev = vma;
>  
>  	for (nstart = start ; ; ) {
> -		unsigned long newflags;
> +		unsigned long long newflags;
>  
>  		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
>  
> -		newflags = vm_flags | (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
> +		newflags = vm_prots | (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
>  
>  		/* newflags >> 4 shift VM_MAY% in place of VM_% */
>  		if ((newflags & ~(newflags >> 4)) & (VM_READ | VM_WRITE | VM_EXEC)) {
> --- 2.6.32-rc1/mm/mremap.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/mremap.c	2009-09-29 16:48:15.000000000 +0100
> @@ -169,7 +169,7 @@ static unsigned long move_vma(struct vm_
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct vm_area_struct *new_vma;
> -	unsigned long vm_flags = vma->vm_flags;
> +	unsigned long long vm_flags = vma->vm_flags;
>  	unsigned long new_pgoff;
>  	unsigned long moved_len;
>  	unsigned long excess = 0;
> --- 2.6.32-rc1/mm/nommu.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/nommu.c	2009-09-29 16:48:15.000000000 +0100
> @@ -134,7 +134,7 @@ int __get_user_pages(struct task_struct
>  		     struct page **pages, struct vm_area_struct **vmas)
>  {
>  	struct vm_area_struct *vma;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  	int i;
>  
>  	/* calculate required read or write permissions.
> @@ -987,12 +987,12 @@ static int validate_mmap_request(struct
>   * we've determined that we can make the mapping, now translate what we
>   * now know into VMA flags
>   */
> -static unsigned long determine_vm_flags(struct file *file,
> -					unsigned long prot,
> -					unsigned long flags,
> -					unsigned long capabilities)
> +static unsigned long long determine_vm_flags(struct file *file,
> +					     unsigned long prot,
> +					     unsigned long flags,
> +					     unsigned long capabilities)
>  {
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  
>  	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags);
>  	vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
> @@ -1177,7 +1177,8 @@ unsigned long do_mmap_pgoff(struct file
>  	struct vm_area_struct *vma;
>  	struct vm_region *region;
>  	struct rb_node *rb;
> -	unsigned long capabilities, vm_flags, result;
> +	unsigned long long vm_flags;
> +	unsigned long capabilities, result;
>  	int ret;
>  
>  	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
> --- 2.6.32-rc1/mm/rmap.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/rmap.c	2009-09-29 16:48:15.000000000 +0100
> @@ -340,7 +340,7 @@ int page_mapped_in_vma(struct page *page
>  static int page_referenced_one(struct page *page,
>  			       struct vm_area_struct *vma,
>  			       unsigned int *mapcount,
> -			       unsigned long *vm_flags)
> +			       unsigned long long *vm_flags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long address;
> @@ -375,7 +375,7 @@ static int page_referenced_one(struct pa
>  		 * mapping is already gone, the unmap path will have
>  		 * set PG_referenced or activated the page.
>  		 */
> -		if (likely(!VM_SequentialReadHint(vma)))
> +		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
>  			referenced++;
>  	}
>  
> @@ -396,7 +396,7 @@ out:
>  
>  static int page_referenced_anon(struct page *page,
>  				struct mem_cgroup *mem_cont,
> -				unsigned long *vm_flags)
> +				unsigned long long *vm_flags)
>  {
>  	unsigned int mapcount;
>  	struct anon_vma *anon_vma;
> @@ -441,7 +441,7 @@ static int page_referenced_anon(struct p
>   */
>  static int page_referenced_file(struct page *page,
>  				struct mem_cgroup *mem_cont,
> -				unsigned long *vm_flags)
> +				unsigned long long *vm_flags)
>  {
>  	unsigned int mapcount;
>  	struct address_space *mapping = page->mapping;
> @@ -504,7 +504,7 @@ static int page_referenced_file(struct p
>  int page_referenced(struct page *page,
>  		    int is_locked,
>  		    struct mem_cgroup *mem_cont,
> -		    unsigned long *vm_flags)
> +		    unsigned long long *vm_flags)
>  {
>  	int referenced = 0;
>  
> --- 2.6.32-rc1/mm/shmem.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/shmem.c	2009-09-29 16:48:15.000000000 +0100
> @@ -2683,7 +2683,7 @@ int shmem_zero_setup(struct vm_area_stru
>  	struct file *file;
>  	loff_t size = vma->vm_end - vma->vm_start;
>  
> -	file = shmem_file_setup("dev/zero", size, vma->vm_flags);
> +	file = shmem_file_setup("dev/zero", size, (unsigned long)vma->vm_flags);
>  	if (IS_ERR(file))
>  		return PTR_ERR(file);
>  
> --- 2.6.32-rc1/mm/vmscan.c	2009-09-28 00:28:41.000000000 +0100
> +++ ull_vm_flags/mm/vmscan.c	2009-09-29 16:48:15.000000000 +0100
> @@ -581,7 +581,7 @@ static unsigned long shrink_page_list(st
>  	struct pagevec freed_pvec;
>  	int pgactivate = 0;
>  	unsigned long nr_reclaimed = 0;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  
>  	cond_resched();
>  
> @@ -1303,7 +1303,7 @@ static void shrink_active_list(unsigned
>  {
>  	unsigned long nr_taken;
>  	unsigned long pgscanned;
> -	unsigned long vm_flags;
> +	unsigned long long vm_flags;
>  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
>  	LIST_HEAD(l_active);
>  	LIST_HEAD(l_inactive);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
