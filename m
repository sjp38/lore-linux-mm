Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2F2744088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 03:28:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c28so1839023wra.12
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:28:22 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id z16si775329wmc.103.2017.08.25.00.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 00:28:20 -0700 (PDT)
Date: Fri, 25 Aug 2017 09:28:19 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170825072818.GA15494@amd>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Content-Disposition: inline
In-Reply-To: <20170825063545.GA25498@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
> On Wed 23-08-17 19:57:09, Pavel Machek wrote:
> > Hi!
> >=20
> > > From: Michal Hocko <mhocko@suse.com>
> > >=20
> > > GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
> > > and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It=
's
> > > primary motivation was to allow users to tell that an allocation is
> > > short lived and so the allocator can try to place such allocations cl=
ose
> > > together and prevent long term fragmentation. As much as this sounds
> > > like a reasonable semantic it becomes much less clear when to use the
> > > highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
> > > the context holding that memory sleep? Can it take locks? It seems
> > > there is no good answer for those questions.
> > >=20
> > > The current implementation of GFP_TEMPORARY is basically
> > > GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
> > > basically none of the existing caller provide a way to reclaim the
> > > allocated memory. So this is rather misleading and hard to evaluate f=
or
> > > any benefits.
> > >=20
> > > I have checked some random users and none of them has added the flag
> > > with a specific justification. I suspect most of them just copied from
> > > other existing users and others just thought it might be a good idea
> > > to use without any measuring. This suggests that GFP_TEMPORARY just
> > > motivates for cargo cult usage without any reasoning.
> > >=20
> > > I believe that our gfp flags are quite complex already and especially
> > > those with highlevel semantic should be clearly defined to prevent fr=
om
> > > confusion and abuse. Therefore I propose dropping GFP_TEMPORARY and
> > > replace all existing users to simply use GFP_KERNEL. Please note that
> > > SLAB users with shrinkers will still get __GFP_RECLAIMABLE heuristic
> > > and so they will be placed properly for memory fragmentation preventi=
on.
> > >=20
> > > I can see reasons we might want some gfp flag to reflect shorterm
> > > allocations but I propose starting from a clear semantic definition a=
nd
> > > only then add users with proper justification.
> >=20
> > Dunno. < 1msec probably is temporary, 1 hour probably is not. If it cau=
ses
> > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide repl=
ace,
> > and then starting again goes not look attractive to me.
>=20
> I do not think we want a highlevel GFP_TEMPORARY without any meaning.
> This just supports spreading the flag usage without a clear semantic
> and it will lead to even bigger mess. Once we can actually define what
> the flag means we can also add its users based on that new semantic.

It has real meaning.

You can define more exact meaning, and then adjust the usage. But
there's no need to do treewide replacement...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmf0ZIACgkQMOfwapXb+vInRACfazkMxonDgc6UtD8NpcwEBgmP
8vkAn0hn7Nn4yEb2gx9xGVMFI1XCbupC
=dH1k
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
