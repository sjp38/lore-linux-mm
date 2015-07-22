Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 548E59003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:04:45 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so47308557qge.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:04:45 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id a7si1772098qka.5.2015.07.22.07.04.44
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:04:44 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:04:43 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 1/6] mm: mlock: Refactor mlock, munlock, and
 munlockall code
Message-ID: <20150722140443.GA2859@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-2-git-send-email-emunson@akamai.com>
 <20150722104226.GA8630@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Content-Disposition: inline
In-Reply-To: <20150722104226.GA8630@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Kirill A. Shutemov wrote:

> On Tue, Jul 21, 2015 at 03:59:36PM -0400, Eric B Munson wrote:
> > @@ -648,20 +656,23 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, si=
ze_t, len)
> >  	start &=3D PAGE_MASK;
> > =20
> >  	down_write(&current->mm->mmap_sem);
> > -	ret =3D do_mlock(start, len, 0);
> > +	ret =3D apply_vma_flags(start, len, flags, false);
> >  	up_write(&current->mm->mmap_sem);
> > =20
> >  	return ret;
> >  }
> > =20
> > +SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
> > +{
> > +	return do_munlock(start, len, VM_LOCKED);
> > +}
> > +
> >  static int do_mlockall(int flags)
> >  {
> >  	struct vm_area_struct * vma, * prev =3D NULL;
> > =20
> >  	if (flags & MCL_FUTURE)
> >  		current->mm->def_flags |=3D VM_LOCKED;
> > -	else
> > -		current->mm->def_flags &=3D ~VM_LOCKED;
>=20
> I think this is wrong.
>=20
> With current code mlockall(MCL_CURRENT) after mlockall(MCL_FUTURE |
> MCL_CURRENT) would undo future mlocking, without unlocking currently
> mlocked memory.
>=20
> The change will break the use-case.

It is wrong and I have addressed it in this case as well as with the
MCL_ONFAULT flag introduced in patch 4.  I will also add to the mlockall
man page to specify this behavior.


--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVr6L7AAoJELbVsDOpoOa94JcP/00xVbldg68yFn68XqCk9RUB
rnX4dN6MizbF/fivcGEHbA+mMdTN4U720d5J7w+w3xRjfhMeVgSUJ1zijGqrXycI
IegJ44vXygDb1RklxLXtp3ZEY+eGpI3jVonPy+VqmBGYP8nt9fB/OV5UdOkzMrtM
4w68P9Ie6/3N8GkrOD3RCpPBd/LJX1H/rqUuKVZoF2XTmqRa0P2C0opB5/14Na1I
URS9VD+IjtTmJbW9F3gGc64ErRBqrCVE9LH3aZ/Ahw9MDunEVkiP6AUoRT8QOYQJ
hReJ8It5UO+vnD3pmDmnlsNEMIj/lFEfU2ivOL7Vc7nV/mDp6eDbb1bcu9lucaQc
7ZZtDWVQZVwFajFP9TkTqIUDQL2yYza5URafCvGk4nfRX/Oo0zwH8A92I1gQFheY
aekydRlcKQIcYVBSWzzY+hhQJiPdeXzLibIiB3u2GDgOas60q/fl0ow9EcErwCE3
qUuCqifLs/FHfDZRkhOBoKpCBaJrARyCeDSlblKBJfe4s3/1YXYGpEe+mLNkIGaa
2W4Hb+vfERWtllFa3+S9tfabyAvS0Enz2YbmBIInrQXsY5p1xnLnIM+2i8Lx7s4N
pFUeVuaiVxCSX3wdgOMymm2gS1+x0MpP6Oh/fYyxKmBVQJLeXnyk84udvL0jBSx3
kN19RlbEfOnvcpIra2bg
=1q3r
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
