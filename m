Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE890600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 13:03:05 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id l26so300735fgb.8
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:03:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100625212106.384650677@quilx.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212106.384650677@quilx.com>
Date: Mon, 28 Jun 2010 20:03:03 +0300
Message-ID: <AANLkTikSzWZme6kioKJ7DJbS0nhYqeDTPas1D9rb_LY-@mail.gmail.com>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 26, 2010 at 12:20 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> allocpercpu() may be used during early boot after the page allocator
> has been bootstrapped but when interrupts are still off. Make sure
> that we do not do GFP_KERNEL allocations if this occurs.
>
> Cc: tj@kernel.org
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>
> ---
> =A0mm/percpu.c | =A0 =A05 +++--
> =A01 file changed, 3 insertions(+), 2 deletions(-)
>
> Index: linux-2.6/mm/percpu.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/percpu.c =A02010-06-23 14:43:54.000000000 -0500
> +++ linux-2.6/mm/percpu.c =A0 =A0 =A0 2010-06-23 14:44:05.000000000 -0500
> @@ -275,7 +275,8 @@ static void __maybe_unused pcpu_next_pop
> =A0* memory is always zeroed.
> =A0*
> =A0* CONTEXT:
> - * Does GFP_KERNEL allocation.
> + * Does GFP_KERNEL allocation (May be called early in boot when
> + * interrupts are still disabled. Will then do GFP_NOWAIT alloc).
> =A0*
> =A0* RETURNS:
> =A0* Pointer to the allocated area on success, NULL on failure.
> @@ -286,7 +287,7 @@ static void *pcpu_mem_alloc(size_t size)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> =A0 =A0 =A0 =A0if (size <=3D PAGE_SIZE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_KERNEL & gfp_allow=
ed_mask);
> =A0 =A0 =A0 =A0else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *ptr =3D vmalloc(size);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr)

This looks wrong to me. All slab allocators should do gfp_allowed_mask
magic under the hood. Maybe it's triggering kmalloc_large() path that
needs the masking too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
