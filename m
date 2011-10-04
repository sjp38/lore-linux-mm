Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 578B6900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:41:26 -0400 (EDT)
Subject: Re: lockdep recursive locking detected (rcu_kthread / __cache_free)
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 04 Oct 2011 16:40:25 +0200
In-Reply-To: <alpine.DEB.2.00.1110040916330.8522@router.home>
References: <20111003175322.GA26122@sucs.org>
	 <20111003203139.GH2403@linux.vnet.ibm.com>
	 <alpine.DEB.2.00.1110031540560.11713@router.home>
	 <20111003214739.GK2403@linux.vnet.ibm.com>
	 <alpine.DEB.2.00.1110040916330.8522@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317739225.32543.9.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2011-10-04 at 09:28 -0500, Christoph Lameter wrote:
> On Mon, 3 Oct 2011, Paul E. McKenney wrote:
>=20
> > On Mon, Oct 03, 2011 at 03:46:11PM -0500, Christoph Lameter wrote:
> > > On Mon, 3 Oct 2011, Paul E. McKenney wrote:
> > >
> > > > The first lock was acquired here in an RCU callback.  The later loc=
k that
> > > > lockdep complained about appears to have been acquired from a recur=
sive
> > > > call to __cache_free(), with no help from RCU.  This looks to me li=
ke
> > > > one of the issues that arise from the slab allocator using itself t=
o
> > > > allocate slab metadata.
> > >
> > > Right. However, this is a false positive since the slab cache with
> > > the metadata is different from the slab caches with the slab data. Th=
e slab
> > > cache with the metadata does not use itself any metadata slab caches.
> >
> > Wouldn't it be possible to pass a new flag to the metadata slab caches
> > upon creation so that their locks could be placed in a separate lock
> > class?  Just allocate a separate lock_class_key structure for each such
> > lock in that case, and then use lockdep_set_class_and_name to associate
> > that structure with the corresponding lock.  I do this in kernel/rcutre=
e.c
> > in order to allow the rcu_node tree's locks to nest properly.
>=20
> We could give the kmalloc array a different class from created slab
> caches. That should have the desired effect.
>=20
> But that seems to be already the case (looking at init_node_lock_keys).
> Non OFF_SLAB caches seem to be getting a different lock class? Why is thi=
s
> not working?
>=20
> static void init_node_lock_keys(int q)
> {
>         struct cache_sizes *s =3D malloc_sizes;
>=20
>         if (g_cpucache_up !=3D FULL)
>                 return;
>=20
>         for (s =3D malloc_sizes; s->cs_size !=3D ULONG_MAX; s++) {
>                 struct kmem_list3 *l3;
>=20
>                 l3 =3D s->cs_cachep->nodelists[q];
>                 if (!l3 || OFF_SLAB(s->cs_cachep))
>                         continue;
>=20
>                 slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
>                                 &on_slab_alc_key, q);
>         }
> }

Right, so we recently poked at this to fix some other splats, see:

30765b92ada267c5395fc788623cb15233276f5c
83835b3d9aec8e9f666d8223d8a386814f756266

It could of course be I got confused and broke stuff instead, could
someone who knows slab (I guess that's either Pekka, Christoph or David)
stare at those patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
