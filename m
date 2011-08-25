Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 121576B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 13:37:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d0b4c414-e90f-4ae0-9b70-fd5b54d2b011@default>
Date: Thu, 25 Aug 2011 10:37:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 2/4] mm: frontswap: core code
References: <20110823145815.GA23190@ca-server1.us.oracle.com
 20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code
>=20
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V7 2/4] mm: frontswap: core code
> >
> > This second patch of four in this frontswap series provides the core co=
de
>=20
> I think you should add diffstat...

The diffstat is in [PATCH V7 0/4] for the whole patchset.  I didn't
think a separate diffstat for each patch in the patchset was necessary?

> and add include changes to Makefile in the same patch.

The Makefile change must be in a patch after the patch that
creates frontswap.o or the build will fail.

> I have small questions.
>=20
> > +/*
> > + * frontswap_ops is set by frontswap_register_ops to contain the point=
ers
> > + * to the frontswap "backend" implementation functions.
> > + */
> > +static struct frontswap_ops frontswap_ops;
> > +
>=20
> Hmm, only one frontswap_ops can be registered to the system ?
> Then...why it required to be registered ? This just comes from problem in
> coding ?

Yes, currently only one frontswap_ops can be registered.  However there
are different users (zcache and Xen tmem) that will register different
callbacks for the frontswap_ops.  A future enhancement may allow "chaining"
(see https://lkml.org/lkml/2011/6/3/202 which describes chaining for
cleancache).

> BTW, Do I have a chance to implement frontswap accounting per cgroup
> (under memcg) ? Or Do I need to enable/disale switch for frontswap per me=
mcg ?
> Do you think it is worth to do ?

I'm not very familiar with cgroups or memcg but I think it may be possible
to implement transcendent memory with cgroup as the "guest" and the default
cgroup as the "host" to allow for more memory elasticity for cgroups.
(See http://lwn.net/Articles/454795/ for a good overview of all of
transcendent memory.)

> > +/*
> > + * This global enablement flag reduces overhead on systems where front=
swap_ops
> > + * has not been registered, so is preferred to the slower alternative:=
 a
> > + * function call that checks a non-global.
> > + */
> > +int frontswap_enabled;
> > +EXPORT_SYMBOL(frontswap_enabled);
> > +
> > +/* useful stats available in /sys/kernel/mm/frontswap */
> > +static unsigned long frontswap_gets;
> > +static unsigned long frontswap_succ_puts;
> > +static unsigned long frontswap_failed_puts;
> > +static unsigned long frontswap_flushes;
> > +
>=20
> What lock guard these ? swap_lock ?

These are informational statistics so do not need to be protected
by a lock or an atomic-type.  If an increment is lost due to a cpu
race, it is not a problem.

> > +/*
> > + * register operations for frontswap, returning previous thus allowing
> > + * detection of multiple backends and possible nesting
> > + */
> > +struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
> > +{
> > +=09struct frontswap_ops old =3D frontswap_ops;
> > +
> > +=09frontswap_ops =3D *ops;
> > +=09frontswap_enabled =3D 1;
> > +=09return old;
> > +}
> > +EXPORT_SYMBOL(frontswap_register_ops);
> > +
>=20
> No lock ? and there is no unregister_ops() ?

Right now only one "backend" can register with frontswap.  Existing
backends (zcache and Xen tmem) only register when enabled via a
kernel parameter.  In the future, there will need to be better
ways to do this, but I think this is sufficient for now.

So since only one backend can register, no lock is needed and
no unregister is needed yet.

> > +/* Called when a swap device is swapon'd */
> > +void __frontswap_init(unsigned type)
> > +{
> > +=09struct swap_info_struct *sis =3D swap_info[type];
> > +
> > +=09BUG_ON(sis =3D=3D NULL);
> > +=09if (sis->frontswap_map =3D=3D NULL)
> > +=09=09return;
> > +=09if (frontswap_enabled)
> > +=09=09(*frontswap_ops.init)(type);
> > +}
> > +EXPORT_SYMBOL(__frontswap_init);
> > +
> > +/*
> > + * "Put" data from a page to frontswap and associate it with the page'=
s
> > + * swaptype and offset.  Page must be locked and in the swap cache.
> > + * If frontswap already contains a page with matching swaptype and
> > + * offset, the frontswap implmentation may either overwrite the data
> > + * and return success or flush the page from frontswap and return fail=
ure
> > + */
>=20
> What lock should be held to guard global variables ? swap_lock ?

Which global variables do you mean and in what routines?  I think the
page lock is required for put/get (as documented in the comments)
but not the swap_lock.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
