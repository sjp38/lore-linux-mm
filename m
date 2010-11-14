Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA8BB8D0001
	for <linux-mm@kvack.org>; Sat, 13 Nov 2010 21:26:25 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id oAE2QMdQ021985
	for <linux-mm@kvack.org>; Sat, 13 Nov 2010 18:26:23 -0800
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe12.cbf.corp.google.com with ESMTP id oAE2Po3K002348
	for <linux-mm@kvack.org>; Sat, 13 Nov 2010 18:26:21 -0800
Received: by qwk3 with SMTP id 3so3315510qwk.16
        for <linux-mm@kvack.org>; Sat, 13 Nov 2010 18:26:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1010211259360.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
	<alpine.DEB.2.00.1010211259360.24115@router.home>
Date: Sat, 13 Nov 2010 18:26:20 -0800
Message-ID: <AANLkTinXftrp0NxGjsQAkoroMGDXozbA0XgUhSiOJ-xz@mail.gmail.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 11:00 AM, Christoph Lameter <cl@linux.com> wrote:
> Add a field node to struct shrinker that can be used to indicate on which
> node the reclaim should occur. The node field also can be set to NUMA_NO_=
NODE
> in which case a reclaim pass over all nodes is desired.
>
> Index: linux-2.6/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/vmscan.c =A02010-10-21 12:50:21.000000000 -0500
> +++ linux-2.6/mm/vmscan.c =A0 =A0 =A0 2010-10-21 12:50:31.000000000 -0500
> @@ -202,7 +202,7 @@ EXPORT_SYMBOL(unregister_shrinker);
> =A0* Returns the number of slab objects which we shrunk.
> =A0*/
> =A0unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages, in=
t node)
> =A0{
> =A0 =A0 =A0 =A0struct shrinker *shrinker;
> =A0 =A0 =A0 =A0unsigned long ret =3D 0;
> @@ -218,6 +218,7 @@ unsigned long shrink_slab(unsigned long
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long total_scan;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long max_pass;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->node =3D node;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_pass =3D (*shrinker->shrink)(shrinker,=
 0, gfp_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta =3D (4 * scanned) / shrinker->seeks;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta *=3D max_pass;

Apologies for coming late to the party, but I have to ask - is there
anything protecting shrinker->node from concurrent modification if
several threads are trying to reclaim memory at once ?

(I note that there was already something similar done to shrinker->nr
field, so I am probably missing some subtlety in the locking ?)

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
