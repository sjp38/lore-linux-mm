Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E060A6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 11:36:49 -0500 (EST)
Date: Tue, 22 Nov 2011 10:36:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <1321979579.18002.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1111221033350.28197@router.home>
References: <20111121161036.GA1679@x4.trippels.de>    <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>    <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>    <20111121173556.GA1673@x4.trippels.de>   
 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>    <20111121195113.GA1678@x4.trippels.de>  <1321907275.13860.12.camel@pasglop>    <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>   
 <alpine.DEB.2.00.1111212105330.19606@router.home>    <20111122084513.GA1688@x4.trippels.de>  <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1321955185.2474.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <alpine.DEB.2.00.1111220844400.25785@router.home>
  <1321973567.2474.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1111220900330.25785@router.home>  <alpine.DEB.2.00.1111220907050.25785@router.home>  <alpine.DEB.2.00.1111221014030.28197@router.home>
 <1321979579.18002.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-873701990-1321979807=:28197"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-873701990-1321979807=:28197
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 22 Nov 2011, Eric Dumazet wrote:

> Le mardi 22 novembre 2011 =C3=A0 10:20 -0600, Christoph Lameter a =C3=A9c=
rit :
> > Argh. The Redzoning (and the general object pad initialization) is outs=
ide
> > of the slab_lock now. So I get wrong positives on those now. That
> > is already in 3.1 as far as I know. To solve that we would have to cove=
r a
> > much wider area in the alloc and free with the slab lock.
> >
> > But I do not get the count mismatches that you saw. Maybe related to
> > preemption. Will try that next.
>
> Also I note the checks (redzoning and all features) that should be done
> in kfree() are only done on slow path ???

Yes debugging forces the slow paths.

> I am considering adding a "quarantine" capability : each cpu will
> maintain in its struct kmem_cache_cpu a FIFO list of "s->quarantine_max"
> freed objects.
>
> So it should be easier to track use after free bugs, setting
> quarantine_max to a big value.

It may be easier to simply disable interrupts early in __slab_free
if debugging is on. Doesnt look nice right now. Draft patch (not tested
yet):

---
 mm/slub.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/slub.c=092011-11-22 09:04:47.000000000 -0600
+++ linux-2.6/mm/slub.c=092011-11-22 10:33:12.000000000 -0600
@@ -2391,8 +2391,13 @@ static void __slab_free(struct kmem_cach

 =09stat(s, FREE_SLOWPATH);

-=09if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
-=09=09return;
+=09if (kmem_cache_debug(s)) {
+=09=09local_irq_save(flags);
+=09=09if (!free_debug_processing(s, page, x, addr)) {
+=09=09=09local_irq_restore(flags);
+=09=09=09return;
+=09=09}
+=09}

 =09do {
 =09=09prior =3D page->freelist;
@@ -2422,8 +2427,10 @@ static void __slab_free(struct kmem_cach
 =09=09=09=09 * Otherwise the list_lock will synchronize with
 =09=09=09=09 * other processors updating the list of slabs.
 =09=09=09=09 */
-=09=09=09=09spin_lock_irqsave(&n->list_lock, flags);
+=09=09=09=09if (!kmem_cache_debug(s))
+=09=09=09=09=09local_irq_save(flags);

+=09=09=09=09spin_lock(&n->list_lock);
 =09=09=09}
 =09=09}
 =09=09inuse =3D new.inuse;
@@ -2448,6 +2455,8 @@ static void __slab_free(struct kmem_cach
 =09=09 */
                 if (was_frozen)
                         stat(s, FREE_FROZEN);
+=09=09if (kmem_cache_debug(s))
+=09=09=09local_irq_restore(flags);
                 return;
         }




---1463811839-873701990-1321979807=:28197--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
