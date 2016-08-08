Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5436B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 15:07:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so79046294wmp.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 12:07:09 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id u1si31375579wju.85.2016.08.08.12.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 12:07:07 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id q128so136824303wma.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 12:07:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160808145542.7297-1-dvlasenk@redhat.com>
References: <20160808145542.7297-1-dvlasenk@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 8 Aug 2016 12:07:05 -0700
Message-ID: <CAGXu5j+HYkAweod-CC7QhTr3rB-18fMMzthdu4f_Cg3ykQZXUg@mail.gmail.com>
Subject: Re: [PATCH v2] powerpc: Do not make the entire heap executable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 8, 2016 at 7:55 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> On 32-bit powerps the ELF PLT sections of binaries (built with --bss-plt,
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
> CC: Oleg Nesterov <oleg@redhat.com>,
> CC: Michael Ellerman <mpe@ellerman.id.au>
> CC: Florian Weimer <fweimer@redhat.com>
> CC: linux-mm@kvack.org,
> CC: linuxppc-dev@lists.ozlabs.org
> CC: linux-kernel@vger.kernel.org
> ---
> Changes since v1:
> * wrapped lines to not exceed 79 chars
> * improved comment
> * expanded CC list
>
>  arch/powerpc/include/asm/page.h    | 10 +------
>  arch/powerpc/include/asm/page_32.h |  2 --
>  arch/powerpc/include/asm/page_64.h |  4 ---
>  fs/binfmt_elf.c                    | 56 ++++++++++++++++++++++++++++++--------
>  4 files changed, 45 insertions(+), 27 deletions(-)
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
> index a7a28110..50006d0 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -91,14 +91,25 @@ static struct linux_binfmt elf_format = {
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
> -               if (error)
> -                       return error;
> +               /* Map the non-file portion of the last load header. If the
> +                  header is requesting these pages to be executeable then
> +                  we have to honour that, otherwise assume they are bss. */
> +               if (prot & PROT_EXEC) {
> +                       unsigned long addr;
> +                       addr = vm_mmap(0, start, end - start, prot,
> +                               MAP_PRIVATE | MAP_FIXED, 0);
> +                       if (BAD_ADDR(addr))
> +                               return addr;
> +               } else {
> +                       int error = vm_brk(start, end - start);
> +                       if (error)
> +                               return error;
> +               }

Rather than repeating this logic twice, I think this should be a
helper that both sections can call.

-Kees

>         }
>         current->mm->start_brk = current->mm->brk = end;
>         return 0;
> @@ -524,6 +535,7 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>         unsigned long load_addr = 0;
>         int load_addr_set = 0;
>         unsigned long last_bss = 0, elf_bss = 0;
> +       int bss_prot = 0;
>         unsigned long error = ~0UL;
>         unsigned long total_size;
>         int i;
> @@ -606,8 +618,10 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
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
> @@ -626,10 +640,27 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>                 /* What we have mapped so far */
>                 elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
>
> -               /* Map the last of the bss segment */
> -               error = vm_brk(elf_bss, last_bss - elf_bss);
> -               if (error)
> -                       goto out;
> +               if (last_bss > elf_bss) {
> +                       /*
> +                        * Map the non-file portion of the last load header.
> +                        * If the header is requesting these pages to be
> +                        * executable, honour that (ppc32 needs this).
> +                        * Otherwise assume they are bss.
> +                        */
> +                       if (bss_prot & PROT_EXEC) {
> +                               unsigned long addr;
> +                               addr = vm_mmap(0, elf_bss, last_bss - elf_bss,
> +                                       bss_prot, MAP_PRIVATE | MAP_FIXED, 0);
> +                               if (BAD_ADDR(addr)) {
> +                                       error = addr;
> +                                       goto out;
> +                               }
> +                       } else {
> +                               error = vm_brk(elf_bss, last_bss - elf_bss);
> +                               if (error)
> +                                       goto out;
> +                       }
> +               }
>         }
>
>         error = load_addr;
> @@ -672,6 +700,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>         unsigned long error;
>         struct elf_phdr *elf_ppnt, *elf_phdata, *interp_elf_phdata = NULL;
>         unsigned long elf_bss, elf_brk;
> +       int bss_prot = 0;
>         int retval, i;
>         unsigned long elf_entry;
>         unsigned long interp_load_addr = 0;
> @@ -879,7 +908,8 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                            before this one. Map anonymous pages, if needed,
>                            and clear the area.  */
>                         retval = set_brk(elf_bss + load_bias,
> -                                        elf_brk + load_bias);
> +                                        elf_brk + load_bias,
> +                                        bss_prot);
>                         if (retval)
>                                 goto out_free_dentry;
>                         nbyte = ELF_PAGEOFFSET(elf_bss);
> @@ -973,8 +1003,10 @@ static int load_elf_binary(struct linux_binprm *bprm)
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
> @@ -990,7 +1022,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>          * mapping in the interpreter, to make sure it doesn't wind
>          * up getting placed where the bss needs to go.
>          */
> -       retval = set_brk(elf_bss, elf_brk);
> +       retval = set_brk(elf_bss, elf_brk, bss_prot);
>         if (retval)
>                 goto out_free_dentry;
>         if (likely(elf_bss != elf_brk) && unlikely(padzero(elf_bss))) {
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
