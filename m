Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 16D6F6B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 00:10:22 -0500 (EST)
Received: by obbuo9 with SMTP id uo9so299365obb.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 21:10:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120111185009.GA26693@dev3310.snc6.facebook.com>
References: <4F04F0B9.5040401@fb.com>
	<20120105162311.09dac4b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20120111185009.GA26693@dev3310.snc6.facebook.com>
Date: Thu, 12 Jan 2012 10:40:20 +0530
Message-ID: <CAKTCnz=Fg8DiTYUzmTiVm_bd-P9Ww9N5+T+LRGjoG2=ONL_MGA@mail.gmail.com>
Subject: Re: MAP_UNINITIALIZED (Was Re: MAP_NOZERO revisited)
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Davide Libenzi <davidel@xmailserver.org>, Johannes Weiner <hannes@cmpxchg.org>

> commit 37b83f3fb77a177a2f81ebb8aeaec28c2a46e503
> Author: Arun Sharma <asharma@fb.com>
> Date: =A0 Tue Jan 10 17:02:46 2012 -0800
>
> =A0 =A0mm: Enable MAP_UNINITIALIZED for archs with mmu
>
> =A0 =A0This enables malloc optimizations where we might
> =A0 =A0madvise(..,MADV_DONTNEED) a page only to fault it
> =A0 =A0back at a different virtual address.
>
> =A0 =A0Signed-off-by: Arun Sharma <asharma@fb.com>
>
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman=
-common.h
> index 787abbb..71e079f 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -19,11 +19,7 @@
> =A0#define MAP_TYPE =A0 =A0 =A0 0x0f =A0 =A0 =A0 =A0 =A0 =A0/* Mask for t=
ype of mapping */
> =A0#define MAP_FIXED =A0 =A0 =A00x10 =A0 =A0 =A0 =A0 =A0 =A0/* Interpret =
addr exactly */
> =A0#define MAP_ANONYMOUS =A00x20 =A0 =A0 =A0 =A0 =A0 =A0/* don't use a fi=
le */
> -#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> -# define MAP_UNINITIALIZED 0x4000000 =A0 /* For anonymous mmap, memory c=
ould be uninitialized */
> -#else
> -# define MAP_UNINITIALIZED 0x0 =A0 =A0 =A0 =A0 /* Don't support this fla=
g */
> -#endif
> +#define MAP_UNINITIALIZED 0x4000000 =A0 =A0/* For anonymous mmap, memory=
 could be uninitialized */
>

Define MAP_UNINITIALIZED - are you referring to not zeroing out pages
before handing them down? Is this safe even between threads.

> =A0#define MS_ASYNC =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* sync mem=
ory asynchronously */
> =A0#define MS_INVALIDATE =A02 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* invalidate t=
he caches */
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 3a93f73..04d838e 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -156,6 +156,11 @@ __alloc_zeroed_user_highpage(gfp_t movableflags,
> =A0 =A0 =A0 =A0struct page *page =3D alloc_page_vma(GFP_HIGHUSER | movabl=
eflags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vma, vaddr);
>
> +#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> + =A0 =A0 =A0 if (!vma->vm_file && vma->vm_flags & VM_UNINITIALIZED)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return page;
> +#endif
> +
> =A0 =A0 =A0 =A0if (page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_user_highpage(page, vaddr);
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4baadd1..6345c57 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -118,6 +118,8 @@ extern unsigned int kobjsize(const void *objp);
> =A0#define VM_SAO =A0 =A0 =A0 =A0 0x20000000 =A0 =A0 =A0/* Strong Access =
Ordering (powerpc) */
> =A0#define VM_PFN_AT_MMAP 0x40000000 =A0 =A0 =A0/* PFNMAP vma that is ful=
ly mapped at mmap time */
> =A0#define VM_MERGEABLE =A0 0x80000000 =A0 =A0 =A0/* KSM may merge identi=
cal pages */
> +#define VM_UNINITIALIZED VM_SAO =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Steal =
a powerpc bit for now, since we're out
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0bits for 32 bit archs */

Without proper checks if it can be re-used?

>
> =A0/* Bits set in the VMA until the stack is in its final location */
> =A0#define VM_STACK_INCOMPLETE_SETUP =A0 =A0 =A0(VM_RAND_READ | VM_SEQ_RE=
AD)
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index 51647b4..f7d4f60 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -88,6 +88,7 @@ calc_vm_flag_bits(unsigned long flags)
> =A0 =A0 =A0 =A0return _calc_vm_trans(flags, MAP_GROWSDOWN, =A0VM_GROWSDOW=
N ) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 _calc_vm_trans(flags, MAP_DENYWRITE, =A0VM_DE=
NYWRITE ) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXEC=
UTABLE) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0_calc_vm_trans(flags, MAP_UNINITIALIZED, VM_=
UNINITIALIZED) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 _calc_vm_trans(flags, MAP_LOCKED, =A0 =A0 VM_=
LOCKED =A0 =A0);
> =A0}
> =A0#endif /* __KERNEL__ */
> diff --git a/init/Kconfig b/init/Kconfig
> index 43298f9..428e047 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1259,7 +1259,7 @@ endchoice
>
> =A0config MMAP_ALLOW_UNINITIALIZED
> =A0 =A0 =A0 =A0bool "Allow mmapped anonymous memory to be uninitialized"
> - =A0 =A0 =A0 depends on EXPERT && !MMU
> + =A0 =A0 =A0 depends on EXPERT
> =A0 =A0 =A0 =A0default n
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0Normally, and according to the Linux spec, anonymous m=
emory obtained
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index c3fdbcb..e6dd642 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1868,6 +1868,12 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_ar=
ea_struct *vma,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_mems_allowed();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return page;
> =A0 =A0 =A0 =A0}
> +
> +#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> + =A0 =A0 =A0 if (!vma->vm_file && vma->vm_flags & VM_UNINITIALIZED)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp &=3D ~__GFP_ZERO;
> +#endif
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * fast path: =A0default or task policy
> =A0 =A0 =A0 =A0 */

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
