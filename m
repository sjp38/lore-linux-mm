Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F24526B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:19:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e3so45443263qkd.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:19:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v64si1972645qki.77.2016.07.07.09.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 09:19:47 -0700 (PDT)
Message-ID: <1467908376.13253.15.camel@redhat.com>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
From: Rik van Riel <riel@redhat.com>
Date: Thu, 07 Jul 2016 12:19:36 -0400
In-Reply-To: <1467843928-29351-2-git-send-email-keescook@chromium.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
	 <1467843928-29351-2-git-send-email-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bCzF1/yF0tAe6uxTAuvj"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--=-bCzF1/yF0tAe6uxTAuvj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-06 at 15:25 -0700, Kees Cook wrote:
> This is the start of porting PAX_USERCOPY into the mainline kernel.
> This
> is the first set of features, controlled by CONFIG_HARDENED_USERCOPY.
> The
> work is based on code by PaX Team and Brad Spengler, and an earlier
> port
> from Casey Schaufler. Additional non-slab page tests are from Rik van
> Riel.

Feel free to add my S-O-B for the code I wrote. The rest
looks good, too.

There may be some room for optimization later on, by putting
the most likely branches first, annotating with likely/unlikely,
etc, but I suspect the less likely checks are already towards
the ends of the functions.

Signed-off-by: Rik van Riel <riel@redhat.com>

> This patch contains the logic for validating several conditions when
> performing copy_to_user() and copy_from_user() on the kernel object
> being copied to/from:
> - address range doesn't wrap around
> - address range isn't NULL or zero-allocated (with a non-zero copy
> size)
> - if on the slab allocator:
> =C2=A0 - object size must be less than or equal to copy size (when check
> is
> =C2=A0=C2=A0=C2=A0=C2=A0implemented in the allocator, which appear in sub=
sequent patches)
> - otherwise, object must not span page allocations
> - if on the stack
> =C2=A0 - object must not extend before/after the current process task
> =C2=A0 - object must be contained by the current stack frame (when there
> is
> =C2=A0=C2=A0=C2=A0=C2=A0arch/build support for identifying stack frames)
> - object must not overlap with kernel text
>=20
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> =C2=A0arch/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A07 ++
> =C2=A0include/linux/slab.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0|=C2=A0=C2=A012 +++
> =C2=A0include/linux/thread_info.h |=C2=A0=C2=A015 +++
> =C2=A0mm/Makefile=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A04 +
> =C2=A0mm/usercopy.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 239
> ++++++++++++++++++++++++++++++++++++++++++++
> =C2=A0security/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A027 +++++
> =C2=A06 files changed, 304 insertions(+)
> =C2=A0create mode 100644 mm/usercopy.c
>=20
> diff --git a/arch/Kconfig b/arch/Kconfig
> index d794384a0404..3ea04d8dcf62 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -424,6 +424,13 @@ config CC_STACKPROTECTOR_STRONG
> =C2=A0
> =C2=A0endchoice
> =C2=A0
> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	bool
> +	help
> +	=C2=A0=C2=A0An architecture should select this if it has a secondary
> linear
> +	=C2=A0=C2=A0mapping of the kernel text. This is used to verify that
> kernel
> +	=C2=A0=C2=A0text exposures are not visible under
> CONFIG_HARDENED_USERCOPY.
> +
> =C2=A0config HAVE_CONTEXT_TRACKING
> =C2=A0	bool
> =C2=A0	help
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index aeb3e6d00a66..96a16a3fb7cb 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -155,6 +155,18 @@ void kfree(const void *);
> =C2=A0void kzfree(const void *);
> =C2=A0size_t ksize(const void *);
> =C2=A0
> +#ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
> +const char *__check_heap_object(const void *ptr, unsigned long n,
> +				struct page *page);
> +#else
> +static inline const char *__check_heap_object(const void *ptr,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0unsigned long n,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct page *page)
> +{
> +	return NULL;
> +}
> +#endif
> +
> =C2=A0/*
> =C2=A0 * Some archs want to perform DMA into kmalloc caches and need a
> guaranteed
> =C2=A0 * alignment larger than the alignment of a 64-bit integer.
> diff --git a/include/linux/thread_info.h
> b/include/linux/thread_info.h
> index b4c2a485b28a..a02200db9c33 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -146,6 +146,21 @@ static inline bool
> test_and_clear_restore_sigmask(void)
> =C2=A0#error "no set_restore_sigmask() provided and default one won't
> work"
> =C2=A0#endif
> =C2=A0
> +#ifdef CONFIG_HARDENED_USERCOPY
> +extern void __check_object_size(const void *ptr, unsigned long n,
> +					bool to_user);
> +
> +static inline void check_object_size(const void *ptr, unsigned long
> n,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool to_user)
> +{
> +	__check_object_size(ptr, n, to_user);
> +}
> +#else
> +static inline void check_object_size(const void *ptr, unsigned long
> n,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool to_user)
> +{ }
> +#endif /* CONFIG_HARDENED_USERCOPY */
> +
> =C2=A0#endif	/* __KERNEL__ */
> =C2=A0
> =C2=A0#endif /* _LINUX_THREAD_INFO_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index 78c6f7dedb83..32d37247c7e5 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o :=3D n
> =C2=A0KCOV_INSTRUMENT_mmzone.o :=3D n
> =C2=A0KCOV_INSTRUMENT_vmstat.o :=3D n
> =C2=A0
> +# Since __builtin_frame_address does work as used, disable the
> warning.
> +CFLAGS_usercopy.o +=3D $(call cc-disable-warning, frame-address)
> +
> =C2=A0mmu-y			:=3D nommu.o
> =C2=A0mmu-$(CONFIG_MMU)	:=3D gup.o highmem.o memory.o mincore.o \
> =C2=A0			=C2=A0=C2=A0=C2=A0mlock.o mmap.o mprotect.o mremap.o
> msync.o rmap.o \
> @@ -99,3 +102,4 @@ obj-$(CONFIG_USERFAULTFD) +=3D userfaultfd.o
> =C2=A0obj-$(CONFIG_IDLE_PAGE_TRACKING) +=3D page_idle.o
> =C2=A0obj-$(CONFIG_FRAME_VECTOR) +=3D frame_vector.o
> =C2=A0obj-$(CONFIG_DEBUG_PAGE_REF) +=3D debug_page_ref.o
> +obj-$(CONFIG_HARDENED_USERCOPY) +=3D usercopy.o
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> new file mode 100644
> index 000000000000..ad2765dd6dc4
> --- /dev/null
> +++ b/mm/usercopy.c
> @@ -0,0 +1,239 @@
> +/*
> + * This implements the various checks for CONFIG_HARDENED_USERCOPY*,
> + * which are designed to protect kernel memory from needless
> exposure
> + * and overwrite under many unintended conditions. This code is
> based
> + * on PAX_USERCOPY, which is:
> + *
> + * Copyright (C) 2001-2016 PaX Team, Bradley Spengler, Open Source
> + * Security Inc.
> + *
> + * This program is free software; you can redistribute it and/or
> modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <asm/sections.h>
> +
> +/*
> + * Checks if a given pointer and length is contained by the current
> + * stack frame (if possible).
> + *
> + *	0: not at all on the stack
> + *	1: fully on the stack (when can't do frame-checking)
> + *	2: fully inside the current stack frame
> + *	-1: error condition (invalid stack position or bad stack
> frame)
> + */
> +static noinline int check_stack_object(const void *obj, unsigned
> long len)
> +{
> +	const void * const stack =3D task_stack_page(current);
> +	const void * const stackend =3D stack + THREAD_SIZE;
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	const void *frame =3D NULL;
> +	const void *oldframe;
> +#endif
> +
> +	/* Object is not on the stack at all. */
> +	if (obj + len <=3D stack || stackend <=3D obj)
> +		return 0;
> +
> +	/*
> +	=C2=A0* Reject: object partially overlaps the stack (passing the
> +	=C2=A0* the check above means at least one end is within the
> stack,
> +	=C2=A0* so if this check fails, the other end is outside the
> stack).
> +	=C2=A0*/
> +	if (obj < stack || stackend < obj + len)
> +		return -1;
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	oldframe =3D __builtin_frame_address(1);
> +	if (oldframe)
> +		frame =3D __builtin_frame_address(2);
> +	/*
> +	=C2=A0* low ----------------------------------------------> high
> +	=C2=A0* [saved bp][saved ip][args][local vars][saved bp][saved
> ip]
> +	=C2=A0*		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^----------------^
> +	=C2=A0*=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0allow copies only within here
> +	=C2=A0*/
> +	while (stack <=3D frame && frame < stackend) {
> +		/*
> +		=C2=A0* If obj + len extends past the last frame, this
> +		=C2=A0* check won't pass and the next frame will be 0,
> +		=C2=A0* causing us to bail out and correctly report
> +		=C2=A0* the copy as invalid.
> +		=C2=A0*/
> +		if (obj + len <=3D frame)
> +			return obj >=3D oldframe + 2 * sizeof(void *)
> ? 2 : -1;
> +		oldframe =3D frame;
> +		frame =3D *(const void * const *)frame;
> +	}
> +	return -1;
> +#else
> +	return 1;
> +#endif
> +}
> +
> +static void report_usercopy(const void *ptr, unsigned long len,
> +			=C2=A0=C2=A0=C2=A0=C2=A0bool to_user, const char *type)
> +{
> +	pr_emerg("kernel memory %s attempt detected %s %p (%s) (%lu
> bytes)\n",
> +		to_user ? "exposure" : "overwrite",
> +		to_user ? "from" : "to", ptr, type ? : "unknown",
> len);
> +	dump_stack();
> +	do_group_exit(SIGKILL);
> +}
> +
> +/* Returns true if any portion of [ptr,ptr+n) over laps with
> [low,high). */
> +static bool overlaps(const void *ptr, unsigned long n, unsigned long
> low,
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0unsigned long high)
> +{
> +	unsigned long check_low =3D (uintptr_t)ptr;
> +	unsigned long check_high =3D check_low + n;
> +
> +	/* Does not overlap if entirely above or entirely below. */
> +	if (check_low >=3D high || check_high < low)
> +		return false;
> +
> +	return true;
> +}
> +
> +/* Is this address range in the kernel text area? */
> +static inline const char *check_kernel_text_object(const void *ptr,
> +						=C2=A0=C2=A0=C2=A0unsigned long n)
> +{
> +	unsigned long textlow =3D (unsigned long)_stext;
> +	unsigned long texthigh =3D (unsigned long)_etext;
> +
> +	if (overlaps(ptr, n, textlow, texthigh))
> +		return "<kernel text>";
> +
> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	/* Check against linear mapping as well. */
> +	if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(unsigned long)__va(__pa(texthigh))))
> +		return "<linear kernel text>";
> +#endif
> +
> +	return NULL;
> +}
> +
> +static inline const char *check_bogus_address(const void *ptr,
> unsigned long n)
> +{
> +	/* Reject if object wraps past end of memory. */
> +	if (ptr + n < ptr)
> +		return "<wrapped address>";
> +
> +	/* Reject if NULL or ZERO-allocation. */
> +	if (ZERO_OR_NULL_PTR(ptr))
> +		return "<null>";
> +
> +	return NULL;
> +}
> +
> +static inline const char *check_heap_object(const void *ptr,
> unsigned long n)
> +{
> +	struct page *page, *endpage;
> +	const void *end =3D ptr + n - 1;
> +
> +	if (!virt_addr_valid(ptr))
> +		return NULL;
> +
> +	page =3D virt_to_head_page(ptr);
> +
> +	/* Check slab allocator for flags and size. */
> +	if (PageSlab(page))
> +		return __check_heap_object(ptr, n, page);
> +
> +	/* Is the object wholly within one base page? */
> +	if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK)
> =3D=3D
> +		=C2=A0=C2=A0=C2=A0((unsigned long)end & (unsigned long)PAGE_MASK)))
> +		return NULL;
> +
> +	/* Allow if start and end are inside the same compound page.
> */
> +	endpage =3D virt_to_head_page(end);
> +	if (likely(endpage =3D=3D page))
> +		return NULL;
> +
> +	/* Allow special areas, device memory, and sometimes kernel
> data. */
> +	if (PageReserved(page) && PageReserved(endpage))
> +		return NULL;
> +
> +	/*
> +	=C2=A0* Sometimes the kernel data regions are not marked
> Reserved. And
> +	=C2=A0* sometimes [_sdata,_edata) does not cover rodata and/or
> bss,
> +	=C2=A0* so check each range explicitly.
> +	=C2=A0*/
> +
> +	/* Allow kernel data region (if not marked as Reserved). */
> +	if (ptr >=3D (const void *)_sdata && end <=3D (const void
> *)_edata)
> +		return NULL;
> +
> +	/* Allow kernel rodata region (if not marked as Reserved).
> */
> +	if (ptr >=3D (const void *)__start_rodata &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0end <=3D (const void *)__end_rodata)
> +		return NULL;
> +
> +	/* Allow kernel bss region (if not marked as Reserved). */
> +	if (ptr >=3D (const void *)__bss_start &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0end <=3D (const void *)__bss_stop)
> +		return NULL;
> +
> +	/* Uh oh. The "object" spans several independently allocated
> pages. */
> +	return "<spans multiple pages>";
> +}
> +
> +/*
> + * Validates that the given object is one of:
> + * - known safe heap object
> + * - known safe stack object
> + * - not in kernel text
> + */
> +void __check_object_size(const void *ptr, unsigned long n, bool
> to_user)
> +{
> +	const char *err;
> +
> +	/* Skip all tests if size is zero. */
> +	if (!n)
> +		return;
> +
> +	/* Check for invalid addresses. */
> +	err =3D check_bogus_address(ptr, n);
> +	if (err)
> +		goto report;
> +
> +	/* Check for bad heap object. */
> +	err =3D check_heap_object(ptr, n);
> +	if (err)
> +		goto report;
> +
> +	/* Check for bad stack object. */
> +	switch (check_stack_object(ptr, n)) {
> +	case 0:
> +		/* Object is not touching the current process stack.
> */
> +		break;
> +	case 1:
> +	case 2:
> +		/*
> +		=C2=A0* Object is either in the correct frame (when it
> +		=C2=A0* is possible to check) or just generally on the
> +		=C2=A0* process stack (when frame checking not
> available).
> +		=C2=A0*/
> +		return;
> +	default:
> +		err =3D "<process stack>";
> +		goto report;
> +	}
> +
> +	/* Check for object in kernel to avoid text exposure. */
> +	err =3D check_kernel_text_object(ptr, n);
> +	if (!err)
> +		return;
> +
> +report:
> +	report_usercopy(ptr, n, to_user, err);
> +}
> +EXPORT_SYMBOL(__check_object_size);
> diff --git a/security/Kconfig b/security/Kconfig
> index 176758cdfa57..63340ad0b9f9 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -118,6 +118,33 @@ config LSM_MMAP_MIN_ADDR
> =C2=A0	=C2=A0=C2=A0this low address space will need the permission specif=
ic
> to the
> =C2=A0	=C2=A0=C2=A0systems running LSM.
> =C2=A0
> +config HAVE_HARDENED_USERCOPY_ALLOCATOR
> +	bool
> +	help
> +	=C2=A0=C2=A0The heap allocator implements __check_heap_object() for
> +	=C2=A0=C2=A0validating memory ranges against heap object sizes in
> +	=C2=A0=C2=A0support of CONFIG_HARDENED_USERCOPY.
> +
> +config HAVE_ARCH_HARDENED_USERCOPY
> +	bool
> +	help
> +	=C2=A0=C2=A0The architecture supports CONFIG_HARDENED_USERCOPY by
> +	=C2=A0=C2=A0calling check_object_size() just before performing the
> +	=C2=A0=C2=A0userspace copies in the low level implementation of
> +	=C2=A0=C2=A0copy_to_user() and copy_from_user().
> +
> +config HARDENED_USERCOPY
> +	bool "Harden memory copies between kernel and userspace"
> +	depends on HAVE_ARCH_HARDENED_USERCOPY
> +	help
> +	=C2=A0=C2=A0This option checks for obviously wrong memory regions when
> +	=C2=A0=C2=A0copying memory to/from the kernel (via copy_to_user() and
> +	=C2=A0=C2=A0copy_from_user() functions) by rejecting memory ranges
> that
> +	=C2=A0=C2=A0are larger than the specified heap object, span multiple
> +	=C2=A0=C2=A0separately allocates pages, are not on the process stack,
> +	=C2=A0=C2=A0or are part of the kernel text. This kills entire classes
> +	=C2=A0=C2=A0of heap overflow exploits and similar kernel memory
> exposures.
> +
> =C2=A0source security/selinux/Kconfig
> =C2=A0source security/smack/Kconfig
> =C2=A0source security/tomoyo/Kconfig
--=20

All Rights Reversed.
--=-bCzF1/yF0tAe6uxTAuvj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXfoEZAAoJEM553pKExN6Dr+EIALflTongRlhnq+Uq2vLqU4qM
8KmROQTqriS0tuXYv4qZQJlTe0GpHf2Yn5YOjWU4KvgHUYiUdJlxHourizapawEV
spS1wh3QwgtQYeISeMAMxvMivQde1jXpHMjRw2gmGdTbFHHWEMpJKcwmeugpQd/V
/92wjmFSUbHy7FRZtlbj2td9sY8xaKc4xyzGxw2/0r476lJsWy68rv8dlLRbSa6A
1ChoWD/n1mGuYfUPL0bUztM2NZ0HTyHHsc8oKYveUMd13Pabh/KX8nkcJyUooKCa
2qWHY4I28aTng5pAZzhKIGxXCnWmcCcmZDM3S0UOUHIF6m7sh/EGy9slCAZOZFI=
=HFgp
-----END PGP SIGNATURE-----

--=-bCzF1/yF0tAe6uxTAuvj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
