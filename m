Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AE41F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 21:49:32 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so7837465pad.11
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 18:49:32 -0800 (PST)
Received: from psmtp.com ([74.125.245.183])
        by mx.google.com with SMTP id t2si12048087pbq.308.2013.11.04.18.49.29
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 18:49:31 -0800 (PST)
Date: Tue, 5 Nov 2013 10:49:15 +0800 (CST)
From: =?utf-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>
Message-ID: <289468516.24288.1383619755331.JavaMail.root@bj-mail03.pku.edu.cn>
In-Reply-To: <20131104044844.GN13318@ZenIV.linux.org.uk>
Subject: =?gbk?B?UmU6IGNvbnZlcnRpbmcgdW5pY29yZTMyIHRvIGdhdGVfdm1hIGFzIGRvbmUgZm9yIGFybSAod2FzIFJlOg0KIFtQQVRDSF0gbW06IGNhY2hlIGxhcmdlc3Qgdm1hKQ==?=
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

The patch is ok for unicore32. Thanks Al.

While testing this patch, a bug is found in arch/unicore32/include/asm/pgta=
ble.h:

@@ -96,7 +96,7 @@ extern pgprot_t pgprot_kernel;
                                                                | PTE_EXEC)
 #define PAGE_READONLY          __pgprot(pgprot_val(pgprot_user | PTE_READ)
 #define PAGE_READONLY_EXEC     __pgprot(pgprot_val(pgprot_user | PTE_READ =
\
-                                                               | PTE_EXEC)
+                                                               | PTE_EXEC)=
)

In fact, all similar macros are wrong. I'll post an bug-fix patch for this =
obvious error.

Xuetao

----- Al Viro <viro@ZenIV.linux.org.uk> =E5=86=99=E9=81=93=EF=BC=9A
> On Sun, Nov 03, 2013 at 08:20:10PM -0800, Davidlohr Bueso wrote:
> > > > diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicor=
e32/include/asm/mmu_context.h
> > > > index fb5e4c6..38cc7fc 100644
> > > > --- a/arch/unicore32/include/asm/mmu_context.h
> > > > +++ b/arch/unicore32/include/asm/mmu_context.h
> > > > @@ -73,7 +73,7 @@ do { \
> > > >  =09=09else \
> > > >  =09=09=09mm->mmap =3D NULL; \
> > > >  =09=09rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> > > > -=09=09mm->mmap_cache =3D NULL; \
> > > > +=09=09vma_clear_caches(mm);=09=09=09\
> > > >  =09=09mm->map_count--; \
> > > >  =09=09remove_vma(high_vma); \
> > > >  =09} \
>=20
> BTW, this one needs an analog of
> commit f9d4861fc32b995b1616775614459b8f266c803c
> Author: Will Deacon <will.deacon@arm.com>
> Date:   Fri Jan 20 12:01:13 2012 +0100
>=20
>     ARM: 7294/1: vectors: use gate_vma for vectors user mapping
>=20
> This code is a copy of older arm logics rewritten in that commit; unicore=
32
> never got its counterpart.  I have a [completely untested] variant sittin=
g
> in vfs.git#vm^; it's probably worth testing - if it works, we'll get rid
> of one more place that needs to be aware of MM guts and unicore32 folks
> will have fewer potential headache sources...
>=20
> FWIW, after porting to the current tree it becomes the following; I'm not
> sure whether we want VM_DONTEXPAND | VM_DONTDUMP set for this one, though=
...
>=20
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/arch/unicore32/include/asm/elf.h b/arch/unicore32/include/as=
m/elf.h
> index 829042d..eeba258 100644
> --- a/arch/unicore32/include/asm/elf.h
> +++ b/arch/unicore32/include/asm/elf.h
> @@ -87,8 +87,4 @@ struct mm_struct;
>  extern unsigned long arch_randomize_brk(struct mm_struct *mm);
>  #define arch_randomize_brk arch_randomize_brk
> =20
> -extern int vectors_user_mapping(void);
> -#define arch_setup_additional_pages(bprm, uses_interp) vectors_user_mapp=
ing()
> -#define ARCH_HAS_SETUP_ADDITIONAL_PAGES
> -
>  #endif
> diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/in=
clude/asm/mmu_context.h
> index fb5e4c6..600b1b8 100644
> --- a/arch/unicore32/include/asm/mmu_context.h
> +++ b/arch/unicore32/include/asm/mmu_context.h
> @@ -18,6 +18,7 @@
> =20
>  #include <asm/cacheflush.h>
>  #include <asm/cpu-single.h>
> +#include <asm-generic/mm_hooks.h>
> =20
>  #define init_new_context(tsk, mm)=090
> =20
> @@ -56,32 +57,4 @@ switch_mm(struct mm_struct *prev, struct mm_struct *ne=
xt,
>  #define deactivate_mm(tsk, mm)=09do { } while (0)
>  #define activate_mm(prev, next)=09switch_mm(prev, next, NULL)
> =20
> -/*
> - * We are inserting a "fake" vma for the user-accessible vector page so
> - * gdb and friends can get to it through ptrace and /proc/<pid>/mem.
> - * But we also want to remove it before the generic code gets to see it
> - * during process exit or the unmapping of it would  cause total havoc.
> - * (the macro is used as remove_vma() is static to mm/mmap.c)
> - */
> -#define arch_exit_mmap(mm) \
> -do { \
> -=09struct vm_area_struct *high_vma =3D find_vma(mm, 0xffff0000); \
> -=09if (high_vma) { \
> -=09=09BUG_ON(high_vma->vm_next);  /* it should be last */ \
> -=09=09if (high_vma->vm_prev) \
> -=09=09=09high_vma->vm_prev->vm_next =3D NULL; \
> -=09=09else \
> -=09=09=09mm->mmap =3D NULL; \
> -=09=09rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> -=09=09mm->mmap_cache =3D NULL; \
> -=09=09mm->map_count--; \
> -=09=09remove_vma(high_vma); \
> -=09} \
> -} while (0)
> -
> -static inline void arch_dup_mmap(struct mm_struct *oldmm,
> -=09=09=09=09 struct mm_struct *mm)
> -{
> -}
> -
>  #endif
> diff --git a/arch/unicore32/include/asm/page.h b/arch/unicore32/include/a=
sm/page.h
> index 594b322..e79da8b 100644
> --- a/arch/unicore32/include/asm/page.h
> +++ b/arch/unicore32/include/asm/page.h
> @@ -28,6 +28,8 @@ extern void copy_page(void *to, const void *from);
>  #define clear_user_page(page, vaddr, pg)=09clear_page(page)
>  #define copy_user_page(to, from, vaddr, pg)=09copy_page(to, from)
> =20
> +#define __HAVE_ARCH_GATE_AREA 1
> +
>  #undef STRICT_MM_TYPECHECKS
> =20
>  #ifdef STRICT_MM_TYPECHECKS
> diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/proc=
ess.c
> index 778ebba..51d129e 100644
> --- a/arch/unicore32/kernel/process.c
> +++ b/arch/unicore32/kernel/process.c
> @@ -307,21 +307,39 @@ unsigned long arch_randomize_brk(struct mm_struct *=
mm)
> =20
>  /*
>   * The vectors page is always readable from user space for the
> - * atomic helpers and the signal restart code.  Let's declare a mapping
> - * for it so it is visible through ptrace and /proc/<pid>/mem.
> + * atomic helpers and the signal restart code. Insert it into the
> + * gate_vma so that it is visible through ptrace and /proc/<pid>/mem.
>   */
> +static struct vm_area_struct gate_vma =3D {
> +=09.vm_start=09=3D 0xffff0000,
> +=09.vm_end=09=09=3D 0xffff0000 + PAGE_SIZE,
> +=09.vm_flags=09=3D VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC |
> +=09=09=09  VM_DONTEXPAND | VM_DONTDUMP,
> +};
> +
> +static int __init gate_vma_init(void)
> +{
> +=09gate_vma.vm_page_prot=09=3D PAGE_READONLY_EXEC;
> +=09return 0;
> +}
> +arch_initcall(gate_vma_init);
> +
> +struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
> +{
> +=09return &gate_vma;
> +}
> +
> +int in_gate_area(struct mm_struct *mm, unsigned long addr)
> +{
> +=09return (addr >=3D gate_vma.vm_start) && (addr < gate_vma.vm_end);
> +}
> =20
> -int vectors_user_mapping(void)
> +int in_gate_area_no_mm(unsigned long addr)
>  {
> -=09struct mm_struct *mm =3D current->mm;
> -=09return install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
> -=09=09=09=09       VM_READ | VM_EXEC |
> -=09=09=09=09       VM_MAYREAD | VM_MAYEXEC |
> -=09=09=09=09       VM_DONTEXPAND | VM_DONTDUMP,
> -=09=09=09=09       NULL);
> +=09return in_gate_area(NULL, addr);
>  }
> =20
>  const char *arch_vma_name(struct vm_area_struct *vma)
>  {
> -=09return (vma->vm_start =3D=3D 0xffff0000) ? "[vectors]" : NULL;
> +=09return (vma =3D=3D &gate_vma) ? "[vectors]" : NULL;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
