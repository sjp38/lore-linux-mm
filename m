Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 776376B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 18:43:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so37328258wme.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 15:43:16 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id hv4si30668488wjb.279.2016.08.09.15.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 15:43:14 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id o80so65521751wme.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 15:43:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160809190822.28856-1-dvlasenk@redhat.com>
References: <20160809190822.28856-1-dvlasenk@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 9 Aug 2016 15:43:13 -0700
Message-ID: <CAGXu5j+arjRNmGVPeevMBsO6Mdpmw8Lq0GPvJvXNPJeQ8uCWkA@mail.gmail.com>
Subject: Re: [PATCH v3] powerpc: Do not make the entire heap executable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 9, 2016 at 12:08 PM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> On 32-bit powerps the ELF PLT sections of binaries (built with --bss-plt,

Typo: powerps -> powerpc

> or with a toolchain which defaults to it) look like this:
>
>   [17] .sbss             NOBITS          0002aff8 01aff8 000014 00  WA  0   0  4
>   [18] .plt              NOBITS          0002b00c 01aff8 000084 00 WAX  0   0  4
>   [19] .bss              NOBITS          0002b090 01aff8 0000a4 00  WA  0   0  4
>
> Which results in an ELF load header:
>
>   Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
>   LOAD           0x019c70 0x00029c70 0x00029c70 0x01388 0x014c4 RWE 0x10000
>
> This is all correct, the load region containing the PLT is marked as
> executable. Note that the PLT starts at 0002b00c but the file mapping ends at
> 0002aff8, so the PLT falls in the 0 fill section described by the load header,
> and after a page boundary.
>
> Unfortunately the generic ELF loader ignores the X bit in the load headers
> when it creates the 0 filled non-file backed mappings. It assumes all of these
> mappings are RW BSS sections, which is not the case for PPC.
>
> gcc/ld has an option (--secure-plt) to not do this, this is said to incur
> a small performance penalty.
>
> Currently, to support 32-bit binaries with PLT in BSS kernel maps *entire
> brk area* with executable rights for all binaries, even --secure-plt ones.
>
> Stop doing that.
>
> Teach the ELF loader to check the X bit in the relevant load header
> and create 0 filled anonymous mappings that are executable
> if the load header requests that.
>
> The patch was originally posted in 2012 by Jason Gunthorpe
> and apparently ignored:
>
> https://lkml.org/lkml/2012/9/30/138
>
> Lightly run-tested.
>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Kees Cook <keescook@chromium.org>
> CC: Oleg Nesterov <oleg@redhat.com>
> CC: Michael Ellerman <mpe@ellerman.id.au>
> CC: Florian Weimer <fweimer@redhat.com>
> CC: linux-mm@kvack.org
> CC: linuxppc-dev@lists.ozlabs.org
> CC: linux-kernel@vger.kernel.org
> ---
> Changes since v2:
> * moved capability to map with VM_EXEC into vm_brk_flags()
>
> Changes since v1:
> * wrapped lines to not exceed 79 chars
> * improved comment
> * expanded CC list
>
>  arch/powerpc/include/asm/page.h    | 10 +---------
>  arch/powerpc/include/asm/page_32.h |  2 --
>  arch/powerpc/include/asm/page_64.h |  4 ----
>  fs/binfmt_elf.c                    | 34 ++++++++++++++++++++++++++--------
>  include/linux/mm.h                 |  1 +
>  mm/mmap.c                          | 20 +++++++++++++++-----
>  6 files changed, 43 insertions(+), 28 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
> index 56398e7..42d7ea1 100644
> --- a/arch/powerpc/include/asm/page.h
> +++ b/arch/powerpc/include/asm/page.h
> @@ -225,15 +225,7 @@ extern long long virt_phys_offset;
>  #endif
>  #endif
>
> -/*
> - * Unfortunately the PLT is in the BSS in the PPC32 ELF ABI,
> - * and needs to be executable.  This means the whole heap ends
> - * up being executable.
> - */
> -#define VM_DATA_DEFAULT_FLAGS32        (VM_READ | VM_WRITE | VM_EXEC | \
> -                                VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
> -
> -#define VM_DATA_DEFAULT_FLAGS64        (VM_READ | VM_WRITE | \
> +#define VM_DATA_DEFAULT_FLAGS  (VM_READ | VM_WRITE | \
>                                  VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
>
>  #ifdef __powerpc64__
> diff --git a/arch/powerpc/include/asm/page_32.h b/arch/powerpc/include/asm/page_32.h
> index 6a8e179..6113fa8 100644
> --- a/arch/powerpc/include/asm/page_32.h
> +++ b/arch/powerpc/include/asm/page_32.h
> @@ -9,8 +9,6 @@
>  #endif
>  #endif
>
> -#define VM_DATA_DEFAULT_FLAGS  VM_DATA_DEFAULT_FLAGS32
> -
>  #ifdef CONFIG_NOT_COHERENT_CACHE
>  #define ARCH_DMA_MINALIGN      L1_CACHE_BYTES
>  #endif
> diff --git a/arch/powerpc/include/asm/page_64.h b/arch/powerpc/include/asm/page_64.h
> index dd5f071..52d8e9c 100644
> --- a/arch/powerpc/include/asm/page_64.h
> +++ b/arch/powerpc/include/asm/page_64.h
> @@ -159,10 +159,6 @@ do {                                               \
>
>  #endif /* !CONFIG_HUGETLB_PAGE */
>
> -#define VM_DATA_DEFAULT_FLAGS \
> -       (is_32bit_task() ? \
> -        VM_DATA_DEFAULT_FLAGS32 : VM_DATA_DEFAULT_FLAGS64)
> -
>  /*
>   * This is the default if a program doesn't have a PT_GNU_STACK
>   * program header entry. The PPC64 ELF ABI has a non executable stack
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index a7a28110..d4a1966 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -91,12 +91,18 @@ static struct linux_binfmt elf_format = {
>
>  #define BAD_ADDR(x) ((unsigned long)(x) >= TASK_SIZE)
>
> -static int set_brk(unsigned long start, unsigned long end)
> +static int set_brk(unsigned long start, unsigned long end, int prot)
>  {
>         start = ELF_PAGEALIGN(start);
>         end = ELF_PAGEALIGN(end);
>         if (end > start) {
> -               int error = vm_brk(start, end - start);
> +               /*
> +                * Map the last of the bss segment.
> +                * If the header is requesting these pages to be
> +                * executable, honour that (ppc32 needs this).
> +                */
> +               int error = vm_brk_flags(start, end - start,
> +                               prot & PROT_EXEC ? VM_EXEC : 0);
>                 if (error)
>                         return error;
>         }
> @@ -524,6 +530,7 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>         unsigned long load_addr = 0;
>         int load_addr_set = 0;
>         unsigned long last_bss = 0, elf_bss = 0;
> +       int bss_prot = 0;
>         unsigned long error = ~0UL;
>         unsigned long total_size;
>         int i;
> @@ -606,8 +613,10 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>                          * elf_bss and last_bss is the bss section.
>                          */
>                         k = load_addr + eppnt->p_memsz + eppnt->p_vaddr;
> -                       if (k > last_bss)
> +                       if (k > last_bss) {
>                                 last_bss = k;
> +                               bss_prot = elf_prot;
> +                       }
>                 }
>         }
>
> @@ -626,8 +635,13 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>                 /* What we have mapped so far */
>                 elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
>
> -               /* Map the last of the bss segment */
> -               error = vm_brk(elf_bss, last_bss - elf_bss);
> +               /*
> +                * Map the last of the bss segment.
> +                * If the header is requesting these pages to be
> +                * executable, honour that (ppc32 needs this).
> +                */
> +               error = vm_brk_flags(elf_bss, last_bss - elf_bss,
> +                               bss_prot & PROT_EXEC ? VM_EXEC : 0);
>                 if (error)
>                         goto out;
>         }
> @@ -672,6 +686,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>         unsigned long error;
>         struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
>         unsigned long elf_bss, elf_brk;
> +       int bss_prot = 0;
>         int retval, i;
>         unsigned long elf_entry;
>         unsigned long interp_load_addr = 0;
> @@ -879,7 +894,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                            before this one. Map anonymous pages, if needed,
>                            and clear the area.  */
>                         retval = set_brk(elf_bss + load_bias,
> -                                        elf_brk + load_bias);
> +                                        elf_brk + load_bias,
> +                                        bss_prot);
>                         if (retval)
>                                 goto out_free_dentry;
>                         nbyte = ELF_PAGEOFFSET(elf_bss);
> @@ -973,8 +989,10 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                 if (end_data < k)
>                         end_data = k;
>                 k = elf_ppnt->p_vaddr + elf_ppnt->p_memsz;
> -               if (k > elf_brk)
> +               if (k > elf_brk) {
> +                       bss_prot = elf_prot;
>                         elf_brk = k;
> +               }
>         }
>
>         loc->elf_ex.e_entry += load_bias;
> @@ -990,7 +1008,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>          * mapping in the interpreter, to make sure it doesn't wind
>          * up getting placed where the bss needs to go.
>          */
> -       retval = set_brk(elf_bss, elf_brk);
> +       retval = set_brk(elf_bss, elf_brk, bss_prot);
>         if (retval)
>                 goto out_free_dentry;
>         if (likely(elf_bss != elf_brk) && unlikely(padzero(elf_bss))) {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 08ed53e..3ffa76c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2058,6 +2058,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
>
>  /* These take the mm semaphore themselves */
>  extern int __must_check vm_brk(unsigned long, unsigned long);
> +extern int __must_check vm_brk_flags(unsigned long, unsigned long, unsigned long);
>  extern int vm_munmap(unsigned long, size_t);
>  extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
>          unsigned long, unsigned long,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d44bee9..c92527f 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2653,11 +2653,10 @@ static inline void verify_mm_writelocked(struct mm_struct *mm)
>   *  anonymous maps.  eventually we may be able to do some
>   *  brk-specific accounting here.
>   */
> -static int do_brk(unsigned long addr, unsigned long len)
> +static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
>  {
>         struct mm_struct *mm = current->mm;
>         struct vm_area_struct *vma, *prev;
> -       unsigned long flags;
>         struct rb_node **rb_link, *rb_parent;
>         pgoff_t pgoff = addr >> PAGE_SHIFT;
>         int error;
> @@ -2666,7 +2665,7 @@ static int do_brk(unsigned long addr, unsigned long len)
>         if (!len)
>                 return 0;
>
> -       flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> +       flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;

For sanity's sake, should a mask be applied here? i.e. to be extra
careful about what flags can get passed in?

Otherwise, this looks okay to me:

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>
>         error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
>         if (offset_in_page(error))
> @@ -2734,7 +2733,12 @@ out:
>         return 0;
>  }
>
> -int vm_brk(unsigned long addr, unsigned long len)
> +static int do_brk(unsigned long addr, unsigned long len)
> +{
> +       return do_brk_flags(addr, len, 0);
> +}
> +
> +int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
>  {
>         struct mm_struct *mm = current->mm;
>         int ret;
> @@ -2743,13 +2747,19 @@ int vm_brk(unsigned long addr, unsigned long len)
>         if (down_write_killable(&mm->mmap_sem))
>                 return -EINTR;
>
> -       ret = do_brk(addr, len);
> +       ret = do_brk_flags(addr, len, flags);
>         populate = ((mm->def_flags & VM_LOCKED) != 0);
>         up_write(&mm->mmap_sem);
>         if (populate && !ret)
>                 mm_populate(addr, len);
>         return ret;
>  }
> +EXPORT_SYMBOL(vm_brk_flags);
> +
> +int vm_brk(unsigned long addr, unsigned long len)
> +{
> +       return vm_brk_flags(addr, len, 0);
> +}
>  EXPORT_SYMBOL(vm_brk);
>
>  /* Release all mmaps. */
> --
> 2.9.2
>



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
