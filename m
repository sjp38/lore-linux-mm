Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C56716B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:45:10 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so5950049vcb.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:45:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111200728.365224076@linux.com>
References: <20111111200711.156817886@linux.com>
	<20111111200728.365224076@linux.com>
Date: Mon, 14 Nov 2011 23:45:08 +0200
Message-ID: <CAOJsxLGxonAVWZkLidSZ=_5soWxFfYK1-b9NNhY_k3o7KRQX3w@mail.gmail.com>
Subject: Re: [rfc 05/18] slub: Simplify control flow in __slab_alloc()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> Simplify control flow.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Would like to merge this too.

> ---
> =A0mm/slub.c | =A0 16 ++++++++--------
> =A01 file changed, 8 insertions(+), 8 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c =A0 =A02011-11-09 11:11:22.381541568 -0600
> +++ linux-2.6/mm/slub.c 2011-11-09 11:11:25.881561697 -0600
> @@ -2219,16 +2219,16 @@ new_slab:
>
> =A0 =A0 =A0 =A0freelist =3D get_partial(s, gfpflags, node, c);
>
> - =A0 =A0 =A0 if (unlikely(!freelist)) {
> + =A0 =A0 =A0 if (!freelist)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0freelist =3D new_slab_objects(s, gfpflags,=
 node, &c);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!freelist)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfpflags & __GFP_NOWA=
RN) && printk_ratelimit())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slab_out_of=
_memory(s, gfpflags, node);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (unlikely(!freelist)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfpflags & __GFP_NOWARN) && printk_ra=
telimit())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slab_out_of_memory(s, gfpfl=
ags, node);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (likely(!kmem_cache_debug(s)))
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
