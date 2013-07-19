Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1A4096B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 03:14:28 -0400 (EDT)
Date: Fri, 19 Jul 2013 17:14:32 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] hugepage: allow parallelization of the hugepage fault
 path
Message-ID: <20130719071432.GB19634@voom.fritz.box>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
 <20130715072432.GA28053@voom.fritz.box>
 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
 <1374090625.15271.2.camel@buesod1.americas.hpqcorp.net>
 <20130718084235.GA9761@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DKU6Jbt7q3WqK7+M"
Content-Disposition: inline
In-Reply-To: <20130718084235.GA9761@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>


--DKU6Jbt7q3WqK7+M
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 18, 2013 at 05:42:35PM +0900, Joonsoo Kim wrote:
> On Wed, Jul 17, 2013 at 12:50:25PM -0700, Davidlohr Bueso wrote:
> > From: David Gibson <david@gibson.dropbear.id.au>
> >=20
> > At present, the page fault path for hugepages is serialized by a
> > single mutex. This is used to avoid spurious out-of-memory conditions
> > when the hugepage pool is fully utilized (two processes or threads can
> > race to instantiate the same mapping with the last hugepage from the
> > pool, the race loser returning VM_FAULT_OOM).  This problem is
> > specific to hugepages, because it is normal to want to use every
> > single hugepage in the system - with normal pages we simply assume
> > there will always be a few spare pages which can be used temporarily
> > until the race is resolved.
> >=20
> > Unfortunately this serialization also means that clearing of hugepages
> > cannot be parallelized across multiple CPUs, which can lead to very
> > long process startup times when using large numbers of hugepages.
> >=20
> > This patch improves the situation by replacing the single mutex with a
> > table of mutexes, selected based on a hash, which allows us to know
> > which page in the file we're instantiating. For shared mappings, the
> > hash key is selected based on the address space and file offset being f=
aulted.
> > Similarly, for private mappings, the mm and virtual address are used.
> >=20
>=20
> Hello.
>=20
> With this table mutex, we cannot protect region tracking structure.
> See below comment.
>=20
> /*
>  * Region tracking -- allows tracking of reservations and instantiated pa=
ges
>  *                    across the pages in a mapping.
>  *
>  * The region data structures are protected by a combination of the mmap_=
sem
>  * and the hugetlb_instantion_mutex.  To access or modify a region the ca=
ller
>  * must either hold the mmap_sem for write, or the mmap_sem for read and
>  * the hugetlb_instantiation mutex:
>  *
>  *      down_write(&mm->mmap_sem);
>  * or
>  *      down_read(&mm->mmap_sem);
>  *      mutex_lock(&hugetlb_instantiation_mutex);
>  */

Ugh.  Who the hell added that.  I guess you'll need to split of
another mutex for that purpose, afaict there should be no interaction
with the actual, intended purpose of the instantiation mutex.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--DKU6Jbt7q3WqK7+M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlHo51gACgkQaILKxv3ab8Zn9wCdHYvc1EFMgILPkcigkxwZ5JDG
0PcAn1iauHw+cLwCGVDnPjgpTfw/vHRe
=AG8T
-----END PGP SIGNATURE-----

--DKU6Jbt7q3WqK7+M--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
