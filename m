Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA7C6B0341
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 00:15:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y62so2088161pfd.3
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 21:15:29 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id t7si1245722pgs.526.2017.12.05.21.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Dec 2017 21:15:27 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
In-Reply-To: <20171129144219.22867-2-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org> <20171129144219.22867-2-mhocko@kernel.org>
Date: Wed, 06 Dec 2017 16:15:24 +1100
Message-ID: <87tvx4e8sz.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

Hi Michal,

Some comments below.

Michal Hocko <mhocko@kernel.org> writes:

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

I don't think this last sentence is correct. Or maybe I don't understand
what you're referring to.

If you specifiy MAP_FIXED on a page boundary then the mapping must be
made at that address, I don't think arch code is allowed to add any
extra alignment.

> Introduce a new MAP_FIXED_SAFE flag for mmap to achieve this behavior.
> It has the same semantic as MAP_FIXED wrt. the given address request
> with a single exception that it fails with EEXIST if the requested
> address is already covered by an existing mapping. We still do rely on
> get_unmaped_area to handle all the arch specific MAP_FIXED treatment and
> check for a conflicting vma after it returns.
>
> [fail on clashing range with EEXIST as per Florian Weimer]
> [set MAP_FIXED before round_hint_to_min as per Khalid Aziz]
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
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
> index 6bf730063e3f..ef3770262925 100644
> --- a/arch/alpha/include/uapi/asm/mman.h
> +++ b/arch/alpha/include/uapi/asm/mman.h
> @@ -32,6 +32,8 @@
>  #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
>  
> +#define MAP_FIXED_SAFE	0x200000	/* MAP_FIXED which doesn't unmap underlying mapping */
> +

Why the new line before MAP_FIXED_SAFE? It should sit with the others.

You're using a different value to other arches here, but that's OK, and
alpha doesn't use asm-generic/mman.h or mman-common.h

> diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> index e63bc37e33af..3ffd284e7160 100644
> --- a/arch/powerpc/include/uapi/asm/mman.h
> +++ b/arch/powerpc/include/uapi/asm/mman.h
> @@ -29,5 +29,6 @@
>  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
>  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> +#define MAP_FIXED_SAFE	0x800000	/* MAP_FIXED which doesn't unmap underlying mapping */

Why did you pick 0x800000?

I don't see any reason you can't use 0x8000 on powerpc.

 
> diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
> index 715a2c927e79..0c282c09fae8 100644
> --- a/arch/sparc/include/uapi/asm/mman.h
> +++ b/arch/sparc/include/uapi/asm/mman.h
> @@ -24,6 +24,7 @@
>  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
>  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> +#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */

Using 0x80000 on sparc, sparc uses mman-common.h.

> diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
> index 9b7add95926b..b212f5fd5345 100644
> --- a/arch/tile/include/uapi/asm/mman.h
> +++ b/arch/tile/include/uapi/asm/mman.h
> @@ -30,6 +30,7 @@
>  #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
>  #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
>  #define MAP_HUGETLB	0x4000		/* create a huge page mapping */
> +#define MAP_FIXED_SAFE	0x8000		/* MAP_FIXED which doesn't unmap underlying mapping */
  
That is the next free flag, but you could also use 0x80000 on tile.

tile uses mman-common.h.

> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index 2bfe590694fc..0daf199caa57 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -56,6 +56,7 @@
>  #define MAP_NONBLOCK	0x20000		/* do not block on IO */
>  #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
> +#define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */

xtensa doesn't use asm-generic/mman.h or mman-common.h

>  #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
>  # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
>  					 * uninitialized */
> @@ -63,6 +64,7 @@
>  # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
>  #endif
>  
> +

Stray new line.

>  /*
>   * Flags for msync
>   */
> diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
> index 2dffcbf705b3..56cde132a80a 100644
> --- a/include/uapi/asm-generic/mman.h
> +++ b/include/uapi/asm-generic/mman.h
> @@ -13,6 +13,7 @@
>  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
>  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> +#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */

So I think I proved above that all the arches that are using 0x80000 are
also using mman-common.h, and vice-versa.

So you can put this in mman-common.h can't you?

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 476e810cf100..e84339842bb8 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1342,6 +1342,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  		if (!(file && path_noexec(&file->f_path)))
>  			prot |= PROT_EXEC;
>  
> +	/* force arch specific MAP_FIXED handling in get_unmapped_area */
> +	if (flags & MAP_FIXED_SAFE)
> +		flags |= MAP_FIXED;
> +

The comment is misleading, because literally on the next line below we
check MAP_FIXED and change the behaviour, but not in the arch code.

>  	if (!(flags & MAP_FIXED))
>  		addr = round_hint_to_min(addr);

So it would be more accurate to say something like:

	/*
	 * Internal to the kernel MAP_FIXED_SAFE is a superset of
	 * MAP_FIXED, so set MAP_FIXED in flags if MAP_FIXED_SAFE was
	 * set by the caller. This avoids all the arch code having to
	 * check for MAP_FIXED and MAP_FIXED_SAFE.
	 */
	if (flags & MAP_FIXED_SAFE)
		flags |= MAP_FIXED;


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
