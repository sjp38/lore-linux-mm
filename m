Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F2D9C6B005D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:31:26 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NGSBEA002911
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:28:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NGVsfh183558
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:31:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NGVrtv012847
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:31:54 -0400
Date: Thu, 23 Apr 2009 17:31:48 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH V3] Fix Committed_AS underflow
Message-ID: <20090423163148.GB5044@us.ibm.com>
References: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com> <1240244120.32604.278.camel@nimitz> <1240256999.32604.330.camel@nimitz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i9LlY+UWpKt15+FH"
Content-Disposition: inline
In-Reply-To: <1240256999.32604.330.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>


--i9LlY+UWpKt15+FH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 20 Apr 2009, Dave Hansen wrote:

> On Mon, 2009-04-20 at 09:15 -0700, Dave Hansen wrote:
> > On Mon, 2009-04-20 at 10:09 +0100, Eric B Munson wrote:
> > > 1. Change NR_CPUS to min(64, NR_CPUS)
> > >    This will limit the amount of possible skew on kernels compiled fo=
r very
> > >    large SMP machines.  64 is an arbitrary number selected to limit t=
he worst
> > >    of the skew without using more cache lines.  min(64, NR_CPUS) is u=
sed
> > >    instead of nr_online_cpus() because nr_online_cpus() requires a sh=
ared
> > >    cache line and a call to hweight to make the calculation.  Its run=
time
> > >    overhead and keeping this counter accurate showed up in profiles a=
nd it's
> > >    possible that nr_online_cpus() would also show.
>=20
> Wow, that empty reply was really informative, wasn't it? :)
>=20
> My worry with this min(64, NR_CPUS) approach is that you effectively
> ensure that you're going to be doing a lot more cacheline bouncing, but
> it isn't quite as explicit.

Unfortunately this is a choice we have to make, do we want to avoid cache
line bouncing of fork-heavy workloads using more than 64 pages or bad
information being used for overcommit decisions?

>=20
> Now, every time there's a mapping (or set of them) created or destroyed
> that nets greater than 64 pages, you've got to go get a r/w cacheline to
> a possibly highly contended atomic.  With a number this low, you're
> almost guaranteed to hit it at fork() and exec().  Could you
> double-check that this doesn't hurt any of the fork() AIM tests?

It is unlikely that the aim9 benchmarks would show if this patch was a
problem because it forks in a tight loop and in a process that is not
necessarily beig enough to hit ACCT_THRESHOLD, likely on a single CPU.
In order to show any problems here we need a fork heavy workload with
many threads on many CPUs.

>=20
> Another thought is that, instead of trying to fix this up in meminfo, we
> could do this in a way that is guaranteed to never skew the global
> counter negative: we always keep the *percpu* skew negative.  This
> should be the same as what's in the kernel now:
>=20
> void vm_acct_memory(long pages)
> {
>         long *local;
> 	long local_min =3D -ACCT_THRESHOLD;
> 	long local_max =3D ACCT_THRESHOLD;
> 	long local_goal =3D 0;
>=20
>         preempt_disable();
>         local =3D &__get_cpu_var(committed_space);
>         *local +=3D pages;
>         if (*local > local_max || *local < local_min) {
>                 atomic_long_add(*local - local_goal, &vm_committed_space);
>                 *local =3D local_goal;
>         }
>         preempt_enable();
> }
>=20
> But now consider if we changed the local_* variables a bit:
>=20
> 	long local_min =3D -(ACCT_THRESHOLD*2);
> 	long local_max =3D 0
> 	long local_goal =3D -ACCT_THRESHOLD;
>=20
> We'll get some possibly *large* numbers in meminfo, but it will at least
> never underflow.
>=20
> -- Dave
>=20

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--i9LlY+UWpKt15+FH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknwl/QACgkQsnv9E83jkzp7WgCgt8i1ZO5eZ9fSMNaBP/PD08eC
Uu8AoNOT+hOmvYFMsf4v+R6/KrIJdUDU
=J2XF
-----END PGP SIGNATURE-----

--i9LlY+UWpKt15+FH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
