Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37FBD8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 02:11:00 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE7AvXR016225
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 16:10:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EDB3745DE54
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:10:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A641145DE52
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:10:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8865CE78003
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:10:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 29B30E7800E
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:10:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <AANLkTinXftrp0NxGjsQAkoroMGDXozbA0XgUhSiOJ-xz@mail.gmail.com>
References: <alpine.DEB.2.00.1010211259360.24115@router.home> <AANLkTinXftrp0NxGjsQAkoroMGDXozbA0XgUhSiOJ-xz@mail.gmail.com>
Message-Id: <20101114161059.BED5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 14 Nov 2010 16:10:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Oct 21, 2010 at 11:00 AM, Christoph Lameter <cl@linux.com> wrote:
> > Add a field node to struct shrinker that can be used to indicate on whi=
ch
> > node the reclaim should occur. The node field also can be set to NUMA_N=
O_NODE
> > in which case a reclaim pass over all nodes is desired.
> >
> > Index: linux-2.6/mm/vmscan.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/mm/vmscan.c =A02010-10-21 12:50:21.000000000 -0500
> > +++ linux-2.6/mm/vmscan.c =A0 =A0 =A0 2010-10-21 12:50:31.000000000 -05=
00
> > @@ -202,7 +202,7 @@ EXPORT_SYMBOL(unregister_shrinker);
> > =A0* Returns the number of slab objects which we shrunk.
> > =A0*/
> > =A0unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages, =
int node)
> > =A0{
> > =A0 =A0 =A0 =A0struct shrinker *shrinker;
> > =A0 =A0 =A0 =A0unsigned long ret =3D 0;
> > @@ -218,6 +218,7 @@ unsigned long shrink_slab(unsigned long
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long total_scan;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long max_pass;
> >
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->node =3D node;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_pass =3D (*shrinker->shrink)(shrinke=
r, 0, gfp_mask);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta =3D (4 * scanned) / shrinker->seek=
s;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta *=3D max_pass;
>=20
> Apologies for coming late to the party, but I have to ask - is there
> anything protecting shrinker->node from concurrent modification if
> several threads are trying to reclaim memory at once ?

shrinker_rwsem? :)

>=20
> (I note that there was already something similar done to shrinker->nr
> field, so I am probably missing some subtlety in the locking ?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
