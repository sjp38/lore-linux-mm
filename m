Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63FE76B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 05:58:16 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so56302838wmu.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 02:58:16 -0800 (PST)
Received: from mail.mimuw.edu.pl (mail.mimuw.edu.pl. [193.0.96.6])
        by mx.google.com with ESMTPS id u189si11534811wmg.133.2016.12.01.02.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 02:58:15 -0800 (PST)
Date: Thu, 1 Dec 2016 11:58:07 +0100
From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?= <marmarek@mimuw.edu.pl>
Subject: Re: [Bug 189181] New: BUG: unable to handle kernel NULL pointer
 dereference in mem_cgroup_node_nr_lru_pages
Message-ID: <20161201105807.GC21693@mail-personal>
References: <bug-189181-27@https.bugzilla.kernel.org/>
 <20161129145654.c48bebbd684edcd6f64a03fe@linux-foundation.org>
 <20161130170040.GJ18432@dhcp22.suse.cz>
 <20161130181653.GA30558@cmpxchg.org>
 <20161130183016.GO18432@dhcp22.suse.cz>
 <20161201022454.GB21693@mail-personal>
 <20161201070213.GA18272@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R+My9LyyhiUvIEro"
Content-Disposition: inline
In-Reply-To: <20161201070213.GA18272@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>


--R+My9LyyhiUvIEro
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 01, 2016 at 08:02:13AM +0100, Michal Hocko wrote:
> On Thu 01-12-16 03:24:54, Marek Marczykowski-G=C3=B3recki wrote:
> > On Wed, Nov 30, 2016 at 07:30:17PM +0100, Michal Hocko wrote:
> > > On Wed 30-11-16 13:16:53, Johannes Weiner wrote:
> > > > Hi Michael,
> > > >=20
> > > > On Wed, Nov 30, 2016 at 06:00:40PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > diff --git a/mm/workingset.c b/mm/workingset.c
> > > > > index 617475f529f4..0f07522c5c0e 100644
> > > > > --- a/mm/workingset.c
> > > > > +++ b/mm/workingset.c
> > > > > @@ -348,7 +348,7 @@ static unsigned long count_shadow_nodes(struc=
t shrinker *shrinker,
> > > > >  	shadow_nodes =3D list_lru_shrink_count(&workingset_shadow_nodes=
, sc);
> > > > >  	local_irq_enable();
> > > > > =20
> > > > > -	if (memcg_kmem_enabled()) {
> > > > > +	if (memcg_kmem_enabled() && sc->memcg) {
> > > > >  		pages =3D mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
> > > > >  						     LRU_ALL_FILE);
> > > > >  	} else {
> > > >=20
> > > > If we do that, I'd remove the racy memcg_kmem_enabled() check
> > > > altogether and just check for whether we have a memcg or not.
> > >=20
> > > But that would make this a memcg aware shrinker even when kmem is not
> > > enabled...
> > >=20
> > > But now that I am looking into the code
> > > shrink_slab:
> > > 		if (memcg_kmem_enabled() &&
> > > 		    !!memcg !=3D !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> > > 			continue;
> > >=20
> > > this should be taken care of already. So sc->memcg should be indeed
> > > sufficient. So unless I am missing something I will respin my local
> > > patch and post it later after the reporter has some time to test the
> > > current one.
> >=20
> > The above patch seems to help. At least the problem haven't occurred for
> > the last ~40 VM startups.
>=20
> I will consider this as
> Tested-by: Marek Marczykowski-G=C3=B3recki <marmarek@mimuw.edu.pl>
>=20
> OK? Thanks for the report and testing!

Yes.

--=20
Pozdrawiam / Best Regards,
Marek Marczykowski-G=C3=B3recki  | RLU #390519
marmarek at staszic waw pl  | xmpp:marmarek at staszic waw pl

--R+My9LyyhiUvIEro
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlhAAj8ACgkQXmmj5DNap+pCRQCgmsqQwOPcC5sygwBKZ44IoD6H
JyUAn28NGnupgZt9LOk3c9z0gxAMc29Z
=7Pes
-----END PGP SIGNATURE-----

--R+My9LyyhiUvIEro--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
