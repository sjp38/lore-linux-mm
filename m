Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C41D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 17:15:29 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j92so311605451ioi.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 14:15:29 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id v69si7119227itc.47.2016.12.07.14.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 14:15:28 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id a124so737540143ioe.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 14:15:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161109170644.15821-1-dvlasenk@redhat.com>
References: <20161109170644.15821-1-dvlasenk@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 7 Dec 2016 14:15:27 -0800
Message-ID: <CAGXu5jLKFAAwgR=AoSdvhK-DtNrMk3SEOpoCHhMqrFWFiuBL5w@mail.gmail.com>
Subject: Re: [PATCH v7] powerpc: Do not make the entire heap executable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 9, 2016 at 9:06 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
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

Can you resend this patch with /proc/$pid/maps output showing the
before/after effects of this change also included here? Showing that
reduction in executable mapping should illustrate the benefit of
avoiding having the execute bit set on the brk area (which is a clear
security weakness, having writable/executable code in the process's
memory segment, especially when it was _not_ requested by the ELF
headers).

Thanks!

-Kees

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
> Acked-by: Kees Cook <keescook@chromium.org>
> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
> Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> CC: Kees Cook <keescook@chromium.org>
> CC: Oleg Nesterov <oleg@redhat.com>
> CC: Michael Ellerman <mpe@ellerman.id.au>
> CC: Florian Weimer <fweimer@redhat.com>
> CC: linux-mm@kvack.org
> CC: linuxppc-dev@lists.ozlabs.org
> CC: linux-kernel@vger.kernel.org
> ---
> Changes since v6:
> * rebased to current Linus tree
> * sending to akpm
>
> Changes since v5:
> * made do_brk_flags() error out if any bits other than VM_EXEC are set.
>   (Kees Cook: "With this, I'd be happy to Ack.")
>   See https://patchwork.ozlabs.org/patch/661595/
>
> Changes since v4:
> * if (current->personality & READ_IMPLIES_EXEC), still use VM_EXEC
>   for 32-bit executables.
>
> Changes since v3:
> * typo fix in commit message
> * rebased to current Linus tree
>
> Changes since v2:
> * moved capability to map with VM_EXEC into vm_brk_flags()
>
> Changes since v1:
> * wrapped lines to not exceed 79 chars
> * improved comment
> * expanded CC list
>
>  arch/powerpc/include/asm/page.h |  4 +++-
>  fs/binfmt_elf.c                 | 30 ++++++++++++++++++++++--------
>  include/linux/mm.h              |  1 +
>  mm/mmap.c                       | 24 +++++++++++++++++++-----
>  4 files changed, 45 insertions(+), 14 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
> index 56398e7..17d3d2c 100644
> --- a/arch/powerpc/include/asm/page.h
> +++ b/arch/powerpc/include/asm/page.h
> @@ -230,7 +230,9 @@ extern long long virt_phys_offset;
>   * and needs to be executable.  This means the whole heap ends
>   * up being executable.
>   */
> -#define VM_DATA_DEFAULT_FLAGS32        (VM_READ | VM_WRITE | VM_EXEC | \
> +#define VM_DATA_DEFAULT_FLAGS32 \
> +       (((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0) | \
> +                                VM_READ | VM_WRITE | \
>                                  VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
>
>  #define VM_DATA_DEFAULT_FLAGS64        (VM_READ | VM_WRITE | \
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 2472af2..065134b 100644
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
>                         k = load_addr + eppnt->p_vaddr + eppnt->p_memsz;
> -                       if (k > last_bss)
> +                       if (k > last_bss) {
>                                 last_bss = k;
> +                               bss_prot = elf_prot;
> +                       }
>                 }
>         }
>
> @@ -623,13 +632,14 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>         /*
>          * Next, align both the file and mem bss up to the page size,
>          * since this is where elf_bss was just zeroed up to, and where
> -        * last_bss will end after the vm_brk() below.
> +        * last_bss will end after the vm_brk_flags() below.
>          */
>         elf_bss = ELF_PAGEALIGN(elf_bss);
>         last_bss = ELF_PAGEALIGN(last_bss);
>         /* Finally, if there is still more bss to allocate, do it. */
>         if (last_bss > elf_bss) {
> -               error = vm_brk(elf_bss, last_bss - elf_bss);
> +               error = vm_brk_flags(elf_bss, last_bss - elf_bss,
> +                               bss_prot & PROT_EXEC ? VM_EXEC : 0);
>                 if (error)
>                         goto out;
>         }
> @@ -674,6 +684,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>         unsigned long error;
>         struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
>         unsigned long elf_bss, elf_brk;
> +       int bss_prot = 0;
>         int retval, i;
>         unsigned long elf_entry;
>         unsigned long interp_load_addr = 0;
> @@ -882,7 +893,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                            before this one. Map anonymous pages, if needed,
>                            and clear the area.  */
>                         retval = set_brk(elf_bss + load_bias,
> -                                        elf_brk + load_bias);
> +                                        elf_brk + load_bias,
> +                                        bss_prot);
>                         if (retval)
>                                 goto out_free_dentry;
>                         nbyte = ELF_PAGEOFFSET(elf_bss);
> @@ -976,8 +988,10 @@ static int load_elf_binary(struct linux_binprm *bprm)
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
> @@ -993,7 +1007,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>          * mapping in the interpreter, to make sure it doesn't wind
>          * up getting placed where the bss needs to go.
>          */
> -       retval = set_brk(elf_bss, elf_brk);
> +       retval = set_brk(elf_bss, elf_brk, bss_prot);
>         if (retval)
>                 goto out_free_dentry;
>         if (likely(elf_bss != elf_brk) && unlikely(padzero(elf_bss))) {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a92c8d7..2ac7e5e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2053,6 +2053,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
>
>  /* These take the mm semaphore themselves */
>  extern int __must_check vm_brk(unsigned long, unsigned long);
> +extern int __must_check vm_brk_flags(unsigned long, unsigned long, unsigned long);
>  extern int vm_munmap(unsigned long, size_t);
>  extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
>          unsigned long, unsigned long,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 1af87c1..4adcf2c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2806,11 +2806,11 @@ static inline void verify_mm_writelocked(struct mm_struct *mm)
>   *  anonymous maps.  eventually we may be able to do some
>   *  brk-specific accounting here.
>   */
> -static int do_brk(unsigned long addr, unsigned long request)
> +static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
>  {
>         struct mm_struct *mm = current->mm;
>         struct vm_area_struct *vma, *prev;
> -       unsigned long flags, len;
> +       unsigned long len;
>         struct rb_node **rb_link, *rb_parent;
>         pgoff_t pgoff = addr >> PAGE_SHIFT;
>         int error;
> @@ -2821,7 +2821,10 @@ static int do_brk(unsigned long addr, unsigned long request)
>         if (!len)
>                 return 0;
>
> -       flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> +       /* Until we need other flags, refuse anything except VM_EXEC. */
> +       if ((flags & (~VM_EXEC)) != 0)
> +               return -EINVAL;
> +       flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>
>         error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
>         if (offset_in_page(error))
> @@ -2889,7 +2892,12 @@ static int do_brk(unsigned long addr, unsigned long request)
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
> @@ -2898,13 +2906,19 @@ int vm_brk(unsigned long addr, unsigned long len)
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
