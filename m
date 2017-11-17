Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 224B76B0253
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:27:39 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id u42so5926627ioi.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:27:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y123sor1064343ioy.189.2017.11.16.16.27.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 16:27:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171116101900.13621-2-mhocko@kernel.org>
References: <20171116101900.13621-1-mhocko@kernel.org> <20171116101900.13621-2-mhocko@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Nov 2017 16:27:36 -0800
Message-ID: <CAGXu5jKssQCcYcZujvQeFy5LTzhXSW=f-a0riB=4+caT1i38BQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Nov 16, 2017 at 2:18 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> MAP_FIXED is used quite often to enforce mapping at the particular
> range. The main problem of this flag is, however, that it is inherently
> dangerous because it unmaps existing mappings covered by the requested
> range. This can cause silent memory corruptions. Some of them even with
> serious security implications. While the current semantic might be
> really desiderable in many cases there are others which would want to
> enforce the given range but rather see a failure than a silent memory
> corruption on a clashing range. Please note that there is no guarantee
> that a given range is obeyed by the mmap even when it is free - e.g.
> arch specific code is allowed to apply an alignment.
>
> Introduce a new MAP_FIXED_SAFE flag for mmap to achieve this behavior.
> It has the same semantic as MAP_FIXED wrt. the given address request
> with a single exception that it fails with ENOMEM if the requested
> address is already covered by an existing mapping. We still do rely on
> get_unmaped_area to handle all the arch specific MAP_FIXED treatment and
> check for a conflicting vma after it returns.

I like this much more than special-casing the ELF loader. It is an
unusual property that MAP_FIXED does _two_ things, so I like having
this split out.

Bikeshedding: maybe call this MAP_NO_CLOBBER? It's a modifier to
MAP_FIXED, really...

At the end of the day, I don't really care about the name, but "SAFE"
isn't very descriptive for what the flag changes about FIXED.

-Kees

>
> [set MAP_FIXED before round_hint_to_min as per Khalid Aziz]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/alpha/include/uapi/asm/mman.h   |  2 ++
>  arch/mips/include/uapi/asm/mman.h    |  2 ++
>  arch/parisc/include/uapi/asm/mman.h  |  2 ++
>  arch/powerpc/include/uapi/asm/mman.h |  1 +
>  arch/sparc/include/uapi/asm/mman.h   |  1 +
>  arch/tile/include/uapi/asm/mman.h    |  1 +
>  arch/xtensa/include/uapi/asm/mman.h  |  2 ++
>  include/uapi/asm-generic/mman.h      |  1 +
>  mm/mmap.c                            | 11 +++++++++++
>  9 files changed, 23 insertions(+)
>
> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
> index 3b26cc62dadb..0e5724e4b4ad 100644
> --- a/arch/alpha/include/uapi/asm/mman.h
> +++ b/arch/alpha/include/uapi/asm/mman.h
> @@ -31,6 +31,8 @@
>  #define MAP_STACK      0x80000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x100000        /* create a huge page mapping */
>
> +#define MAP_FIXED_SAFE 0x200000        /* MAP_FIXED which doesn't unmap underlying mapping */
> +
>  #define MS_ASYNC       1               /* sync memory asynchronously */
>  #define MS_SYNC                2               /* synchronous memory sync */
>  #define MS_INVALIDATE  4               /* invalidate the caches */
> diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
> index da3216007fe0..fc5e61ef9fd4 100644
> --- a/arch/mips/include/uapi/asm/mman.h
> +++ b/arch/mips/include/uapi/asm/mman.h
> @@ -49,6 +49,8 @@
>  #define MAP_STACK      0x40000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x80000         /* create a huge page mapping */
>
> +#define MAP_FIXED_SAFE 0x100000        /* MAP_FIXED which doesn't unmap underlying mapping */
> +
>  /*
>   * Flags for msync
>   */
> diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
> index cc9ba1d34779..c926487472fa 100644
> --- a/arch/parisc/include/uapi/asm/mman.h
> +++ b/arch/parisc/include/uapi/asm/mman.h
> @@ -25,6 +25,8 @@
>  #define MAP_STACK      0x40000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x80000         /* create a huge page mapping */
>
> +#define MAP_FIXED_SAFE 0x100000        /* MAP_FIXED which doesn't unmap underlying mapping */
> +
>  #define MS_SYNC                1               /* synchronous memory sync */
>  #define MS_ASYNC       2               /* sync memory asynchronously */
>  #define MS_INVALIDATE  4               /* invalidate the caches */
> diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> index 03c06ba7464f..d97342ca25b1 100644
> --- a/arch/powerpc/include/uapi/asm/mman.h
> +++ b/arch/powerpc/include/uapi/asm/mman.h
> @@ -28,5 +28,6 @@
>  #define MAP_NONBLOCK   0x10000         /* do not block on IO */
>  #define MAP_STACK      0x20000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x40000         /* create a huge page mapping */
> +#define MAP_FIXED_SAFE 0x800000        /* MAP_FIXED which doesn't unmap underlying mapping */
>
>  #endif /* _UAPI_ASM_POWERPC_MMAN_H */
> diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
> index 9765896ecb2c..7b00477a7f9a 100644
> --- a/arch/sparc/include/uapi/asm/mman.h
> +++ b/arch/sparc/include/uapi/asm/mman.h
> @@ -23,6 +23,7 @@
>  #define MAP_NONBLOCK   0x10000         /* do not block on IO */
>  #define MAP_STACK      0x20000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x40000         /* create a huge page mapping */
> +#define MAP_FIXED_SAFE 0x80000         /* MAP_FIXED which doesn't unmap underlying mapping */
>
>
>  #endif /* _UAPI__SPARC_MMAN_H__ */
> diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
> index 63ee13faf17d..d5d58d2dc95e 100644
> --- a/arch/tile/include/uapi/asm/mman.h
> +++ b/arch/tile/include/uapi/asm/mman.h
> @@ -29,6 +29,7 @@
>  #define MAP_DENYWRITE  0x0800          /* ETXTBSY */
>  #define MAP_EXECUTABLE 0x1000          /* mark it as an executable */
>  #define MAP_HUGETLB    0x4000          /* create a huge page mapping */
> +#define MAP_FIXED_SAFE 0x8000          /* MAP_FIXED which doesn't unmap underlying mapping */
>
>
>  /*
> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index b15b278aa314..d665bd8b7cbd 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -55,6 +55,7 @@
>  #define MAP_NONBLOCK   0x20000         /* do not block on IO */
>  #define MAP_STACK      0x40000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x80000         /* create a huge page mapping */
> +#define MAP_FIXED_SAFE 0x100000        /* MAP_FIXED which doesn't unmap underlying mapping */
>  #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
>  # define MAP_UNINITIALIZED 0x4000000   /* For anonymous mmap, memory could be
>                                          * uninitialized */
> @@ -62,6 +63,7 @@
>  # define MAP_UNINITIALIZED 0x0         /* Don't support this flag */
>  #endif
>
> +
>  /*
>   * Flags for msync
>   */
> diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
> index 7162cd4cca73..64c46047fbd3 100644
> --- a/include/uapi/asm-generic/mman.h
> +++ b/include/uapi/asm-generic/mman.h
> @@ -12,6 +12,7 @@
>  #define MAP_NONBLOCK   0x10000         /* do not block on IO */
>  #define MAP_STACK      0x20000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x40000         /* create a huge page mapping */
> +#define MAP_FIXED_SAFE 0x80000         /* MAP_FIXED which doesn't unmap underlying mapping */
>
>  /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 680506faceae..89af0b5839a5 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1342,6 +1342,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>                 if (!(file && path_noexec(&file->f_path)))
>                         prot |= PROT_EXEC;
>
> +       /* force arch specific MAP_FIXED handling in get_unmapped_area */
> +       if (flags & MAP_FIXED_SAFE)
> +               flags |= MAP_FIXED;
> +
>         if (!(flags & MAP_FIXED))
>                 addr = round_hint_to_min(addr);
>
> @@ -1365,6 +1369,13 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>         if (offset_in_page(addr))
>                 return addr;
>
> +       if (flags & MAP_FIXED_SAFE) {
> +               struct vm_area_struct *vma = find_vma(mm, addr);
> +
> +               if (vma && vma->vm_start <= addr)
> +                       return -ENOMEM;
> +       }
> +
>         if (prot == PROT_EXEC) {
>                 pkey = execute_only_pkey(mm);
>                 if (pkey < 0)
> --
> 2.15.0
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
