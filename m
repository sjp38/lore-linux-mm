Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF936B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:39:45 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so30864951wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:39:45 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id gk6si4659737wib.34.2015.07.24.07.39.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 07:39:44 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so31962881wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:39:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150716222621.GB21791@redhat.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150713165323.GA7906@redhat.com> <55A3EFE9.7080101@linux.intel.com>
 <20150716110503.9A4F5196@black.fi.intel.com> <55A7D38C.7070907@linux.intel.com>
 <20150716160927.GA27037@node.dhcp.inet.fi> <20150716222603.GA21791@redhat.com>
 <20150716222621.GB21791@redhat.com>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 24 Jul 2015 10:39:13 -0400
Message-ID: <CAP=VYLp+5Co5PyHcbfkdkNUmyy259DuG4ov=+da+UeRAGFUe1Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On Thu, Jul 16, 2015 at 6:26 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> Add the additional "vm_flags_t vm_flags" argument to do_mmap_pgoff(),
> rename it to do_mmap(), and re-introduce do_mmap_pgoff() as a simple
> wrapper on top of do_mmap(). Perhaps we should update the callers of
> do_mmap_pgoff() and kill it later.

It seems that the version of this patch in linux-next breaks all nommu
builds (m86k, some arm, etc).

mm/nommu.c: In function 'do_mmap':
mm/nommu.c:1248:30: error: 'vm_flags' redeclared as different kind of symbol
mm/nommu.c:1241:15: note: previous definition of 'vm_flags' was here
scripts/Makefile.build:258: recipe for target 'mm/nommu.o' failed

http://kisskb.ellerman.id.au/kisskb/buildresult/12470285/

Bisect says:

31705a3a633bb63683918f055fe6032939672b61 is the first bad commit
commit 31705a3a633bb63683918f055fe6032939672b61
Author: Oleg Nesterov <oleg@redhat.com>
Date:   Fri Jul 24 09:20:30 2015 +1000

    mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()

Paul.
--

>
> This way mpx_mmap() can simply call do_mmap(vm_flags => VM_MPX) and
> do not play with vm internals.
>
> After this change mmap_region() has a single user outside of mmap.c,
> arch/tile/mm/elf.c:arch_setup_additional_pages(). It would be nice
> to change arch/tile/ and unexport mmap_region().
>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
>  arch/x86/mm/mpx.c  |   51 +++++++--------------------------------------------
>  include/linux/mm.h |   12 ++++++++++--
>  mm/mmap.c          |   10 ++++------
>  mm/nommu.c         |   15 ++++++++-------
>  4 files changed, 29 insertions(+), 59 deletions(-)
>
> diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
> index 4d1c11c..fdbd3e0 100644
> --- a/arch/x86/mm/mpx.c
> +++ b/arch/x86/mm/mpx.c
> @@ -24,58 +24,21 @@
>   */
>  static unsigned long mpx_mmap(unsigned long len)
>  {
> -       unsigned long ret;
> -       unsigned long addr, pgoff;
>         struct mm_struct *mm = current->mm;
> -       vm_flags_t vm_flags;
> -       struct vm_area_struct *vma;
> +       unsigned long addr, populate;
>
>         /* Only bounds table and bounds directory can be allocated here */
>         if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
>                 return -EINVAL;
>
>         down_write(&mm->mmap_sem);
> -
> -       /* Too many mappings? */
> -       if (mm->map_count > sysctl_max_map_count) {
> -               ret = -ENOMEM;
> -               goto out;
> -       }
> -
> -       /* Obtain the address to map to. we verify (or select) it and ensure
> -        * that it represents a valid section of the address space.
> -        */
> -       addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
> -       if (addr & ~PAGE_MASK) {
> -               ret = addr;
> -               goto out;
> -       }
> -
> -       vm_flags = VM_READ | VM_WRITE | VM_MPX |
> -                       mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
> -
> -       /* Set pgoff according to addr for anon_vma */
> -       pgoff = addr >> PAGE_SHIFT;
> -
> -       ret = mmap_region(NULL, addr, len, vm_flags, pgoff);
> -       if (IS_ERR_VALUE(ret))
> -               goto out;
> -
> -       vma = find_vma(mm, ret);
> -       if (!vma) {
> -               ret = -ENOMEM;
> -               goto out;
> -       }
> -
> -       if (vm_flags & VM_LOCKED) {
> -               up_write(&mm->mmap_sem);
> -               mm_populate(ret, len);
> -               return ret;
> -       }
> -
> -out:
> +       addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
> +                       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
>         up_write(&mm->mmap_sem);
> -       return ret;
> +       if (populate)
> +               mm_populate(addr, populate);
> +
> +       return addr;
>  }
>
>  enum reg_type {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0207ffa..1f0a56e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1849,11 +1849,19 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
>
>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>         unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
> -extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
> +extern unsigned long do_mmap(struct file *file, unsigned long addr,
>         unsigned long len, unsigned long prot, unsigned long flags,
> -       unsigned long pgoff, unsigned long *populate);
> +       vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
>  extern int do_munmap(struct mm_struct *, unsigned long, size_t);
>
> +static inline unsigned long
> +do_mmap_pgoff(struct file *file, unsigned long addr,
> +       unsigned long len, unsigned long prot, unsigned long flags,
> +       unsigned long pgoff, unsigned long *populate)
> +{
> +       return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate);
> +}
> +
>  #ifdef CONFIG_MMU
>  extern int __mm_populate(unsigned long addr, unsigned long len,
>                          int ignore_errors);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2185cd9..2f36ebc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1247,14 +1247,12 @@ static inline int mlock_future_check(struct mm_struct *mm,
>  /*
>   * The caller must hold down_write(&current->mm->mmap_sem).
>   */
> -
> -unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
> +unsigned long do_mmap(struct file *file, unsigned long addr,
>                         unsigned long len, unsigned long prot,
> -                       unsigned long flags, unsigned long pgoff,
> -                       unsigned long *populate)
> +                       unsigned long flags, vm_flags_t vm_flags,
> +                       unsigned long pgoff, unsigned long *populate)
>  {
>         struct mm_struct *mm = current->mm;
> -       vm_flags_t vm_flags;
>
>         *populate = 0;
>
> @@ -1298,7 +1296,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>          * to. we assume access permissions have been handled by the open
>          * of the memory object, so we don't do any here.
>          */
> -       vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
> +       vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
>                         mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>
>         if (flags & MAP_LOCKED)
> diff --git a/mm/nommu.c b/mm/nommu.c
> index e544508..e3026fd 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1271,13 +1271,14 @@ enomem:
>  /*
>   * handle mapping creation for uClinux
>   */
> -unsigned long do_mmap_pgoff(struct file *file,
> -                           unsigned long addr,
> -                           unsigned long len,
> -                           unsigned long prot,
> -                           unsigned long flags,
> -                           unsigned long pgoff,
> -                           unsigned long *populate)
> +unsigned long do_mmap(struct file *file,
> +                       unsigned long addr,
> +                       unsigned long len,
> +                       unsigned long prot,
> +                       unsigned long flags,
> +                       vm_flags_t vm_flags,
> +                       unsigned long pgoff,
> +                       unsigned long *populate)
>  {
>         struct vm_area_struct *vma;
>         struct vm_region *region;
> --
> 1.5.5.1
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
