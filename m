Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 547889000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 01:38:21 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1667154vxg.14
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 22:38:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107071511010.26083@router.home>
References: <alpine.DEB.2.00.1107071314320.21719@router.home>
	<1310064771.21902.55.camel@jaguar>
	<alpine.DEB.2.00.1107071402490.24248@router.home>
	<20110707.122151.314840355798805828.davem@davemloft.net>
	<CAOJsxLFsX3Q84QAeyRt5dZOdRxb3TiABPrP-YrWc91+BmR8ZBg@mail.gmail.com>
	<alpine.DEB.2.00.1107071511010.26083@router.home>
Date: Fri, 8 Jul 2011 08:38:19 +0300
Message-ID: <CAOJsxLFpqUD_TBbbdv8S6WPtZFbChv4cvNTv220cAeeOTRoUVw@mail.gmail.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Miller <davem@davemloft.net>, marcin.slusarz@gmail.com, mpm@selenic.com, linux-kernel@vger.kernel.org, rientjes@google.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 7, 2011 at 11:12 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 7 Jul 2011, Pekka Enberg wrote:
>
>> I applied the patch. I think a follow up patch that moves the function
>> to lib/string.c with proper generic name would be in order. Thanks!
>
> Well this is really straightforward. Hasnt seen much testing yet and
> needs refinement but it would be like this:
>
>
> ---
> =A0arch/x86/include/asm/string_32.h | =A0 =A02 ++
> =A0arch/x86/lib/string_32.c =A0 =A0 =A0 =A0 | =A0 17 +++++++++++++++++
> =A0include/linux/string.h =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +++
> =A0lib/string.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 25 ++++++++=
+++++++++++++++++
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 13 ++++=
++-------
> =A05 files changed, 53 insertions(+), 7 deletions(-)
>
> Index: linux-2.6/arch/x86/lib/string_32.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/arch/x86/lib/string_32.c =A0 =A0 2011-07-07 15:03:46.0=
00000000 -0500
> +++ linux-2.6/arch/x86/lib/string_32.c =A02011-07-07 15:03:56.000000000 -=
0500
> @@ -214,6 +214,23 @@ void *memscan(void *addr, int c, size_t
> =A0EXPORT_SYMBOL(memscan);
> =A0#endif
>
> +#ifdef __HAVE_ARCH_INV_MEMSCAN
> +void *inv_memscan(void *addr, int c, size_t size)
> +{
> + =A0 =A0 =A0 if (!size)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return addr;
> + =A0 =A0 =A0 asm volatile("repz; scasb\n\t"
> + =A0 =A0 =A0 =A0 =A0 "jz 1f\n\t"
> + =A0 =A0 =A0 =A0 =A0 "dec %%edi\n"
> + =A0 =A0 =A0 =A0 =A0 "1:"
> + =A0 =A0 =A0 =A0 =A0 : "=3DD" (addr), "=3Dc" (size)
> + =A0 =A0 =A0 =A0 =A0 : "0" (addr), "1" (size), "a" (c)
> + =A0 =A0 =A0 =A0 =A0 : "memory");
> + =A0 =A0 =A0 return addr;
> +}
> +EXPORT_SYMBOL(memscan);
> +#endif
> +
> =A0#ifdef __HAVE_ARCH_STRNLEN
> =A0size_t strnlen(const char *s, size_t count)
> =A0{
> Index: linux-2.6/include/linux/string.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/string.h =A0 =A0 =A0 2011-07-07 15:03:46=
.000000000 -0500
> +++ linux-2.6/include/linux/string.h =A0 =A02011-07-07 15:03:56.000000000=
 -0500
> @@ -108,6 +108,9 @@ extern void * memmove(void *,const void
> =A0#ifndef __HAVE_ARCH_MEMSCAN
> =A0extern void * memscan(void *,int,__kernel_size_t);
> =A0#endif
> +#ifndef __HAVE_ARCH_INV_MEMSCAN
> +extern void * inv_memscan(void *,int,__kernel_size_t);
> +#endif
> =A0#ifndef __HAVE_ARCH_MEMCMP
> =A0extern int memcmp(const void *,const void *,__kernel_size_t);
> =A0#endif
> Index: linux-2.6/lib/string.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/lib/string.c 2011-07-07 15:03:46.000000000 -0500
> +++ linux-2.6/lib/string.c =A0 =A0 =A02011-07-07 15:03:56.000000000 -0500
> @@ -684,6 +684,31 @@ void *memscan(void *addr, int c, size_t
> =A0EXPORT_SYMBOL(memscan);
> =A0#endif
>
> +#ifndef __HAVE_ARCH_INV_MEMSCAN
> +/**
> + * memscan - Skip characters in an area of memory.
> + * @addr: The memory area
> + * @c: The byte to skip
> + * @size: The size of the area.
> + *
> + * returns the address of the first mismatch of @c, or 1 byte past
> + * the area if @c matches to the end
> + */
> +void *inv_memscan(void *addr, int c, size_t size)

I think this needs a better name. My suggestion is memskip().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
