Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8C27C6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 02:39:37 -0400 (EDT)
Received: by ghbf11 with SMTP id f11so3079683ghb.8
        for <linux-mm@kvack.org>; Tue, 29 May 2012 23:39:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120523203508.434967564@linux.com>
References: <20120523203433.340661918@linux.com>
	<20120523203508.434967564@linux.com>
Date: Wed, 30 May 2012 09:39:36 +0300
Message-ID: <CAOJsxLGHZjucZUi=K3V6QDgP-UqA2GQY=z7D8poKMTO-JETZ2g@mail.gmail.com>
Subject: Re: Common 06/22] Extract common fields from struct kmem_cache
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, May 23, 2012 at 11:34 PM, Christoph Lameter <cl@linux.com> wrote:
> Define "COMMON" to include definitions for fields used in all
> slab allocators. After that it will be possible to share code that
> only operates on those fields of kmem_cache.
>
> The patch basically takes the slob definition of kmem cache and
> uses the field namees for the other allocators.
>
> The slob definition of kmem_cache is moved from slob.c to slob_def.h
> so that the location of the kmem_cache definition is the same for
> all allocators.
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> ---
> =A0include/linux/slab.h =A0 =A0 | =A0 11 +++++++++++
> =A0include/linux/slab_def.h | =A0 =A08 ++------
> =A0include/linux/slob_def.h | =A0 =A04 ++++
> =A0include/linux/slub_def.h | =A0 11 ++++-------
> =A0mm/slab.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 30 +++++++++++++++-----=
----------
> =A0mm/slob.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A07 -------
> =A06 files changed, 36 insertions(+), 35 deletions(-)
>
> Index: linux-2.6/include/linux/slab.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/slab.h 2012-05-22 09:05:49.416464029 -05=
00
> +++ linux-2.6/include/linux/slab.h =A0 =A0 =A02012-05-23 04:23:21.4230249=
39 -0500
> @@ -93,6 +93,17 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned =
long)ZERO_SIZE_PTR)
>
> =A0/*
> + * Common fields provided in kmem_cache by all slab allocators
> + */
> +#define SLAB_COMMON \
> + =A0 =A0 =A0 unsigned int size, align; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 unsigned long flags; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 const char *name; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 int refcount; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 void (*ctor)(void *); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 struct list_head list;
> +

I don't like this at all - it obscures the actual "kmem_cache"
structures. If we can't come up with a reasonable solution that makes
this a proper struct that's embedded in allocator-specific
"kmem_cache" structures, it's best that we rename the fields but keep
them inlined and drop this macro..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
