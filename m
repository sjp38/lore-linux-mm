Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <200703082305.43513.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <200703041450.02178.rjw@sisk.pl> <1173315625.3546.32.camel@johannes.berg>
	 <200703082305.43513.rjw@sisk.pl>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uytCzw4c2kA3c8PaJErx"
Date: Thu, 08 Mar 2007 23:10:17 +0100
Message-Id: <1173391817.3831.4.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--=-uytCzw4c2kA3c8PaJErx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 23:05 +0100, Rafael J. Wysocki wrote:

> > The easiest solution I came up with is below. Of course, the suspend
> > patches for powerpc64 are still very much work in progress and I might
> > end up changing the whole reservation scheme after some feedback... If
> > nobody else needs this then don't think about it now.
>=20
> Well, it may be needed for other things too.

Yeah, but it's probably better to wait for them :)

> I think we should pass a mask.  BTW, can you please check if the appended=
 patch
> is sufficient?

Unfortunately I won't be able to actually try this on hardware until the
20th or so.

> > With this patch and appropriate changes to my suspend code, it works.
>=20
> OK, thanks for testing!

Forgot to mention, patches are at
http://johannes.sipsolutions.net/patches/ look for the latest
powerpc-suspend-* patchset.

> +	if (system_state =3D=3D SYSTEM_BOOTING) {
> +		/* This allocation cannot fail */
> +		region =3D alloc_bootmem_low(sizeof(struct nosave_region));
> +	} else {
> +		region =3D kzalloc(sizeof(struct nosave_region), GFP_ATOMIC);
> +		if (!region) {
> +			printk(KERN_WARNING "swsusp: Not enough memory "
> +				"to register a nosave region!\n");
> +			WARN_ON(1);
> +			return;
> +		}
> +	}

I don't think that'll be sufficient, system_state =3D SYSTEM_BOOTING is
done only in init/main.c:init_post which is done after after calling the
initcalls (they are called in do_basic_setup)

johannes

--=-uytCzw4c2kA3c8PaJErx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8InH/ETPhpq3jKURAijPAJ9TnGE5MWNtuZTfW5j6FaVErVoOdwCgsZlH
G33y5rwOsL140x6h9P28yug=
=NjnH
-----END PGP SIGNATURE-----

--=-uytCzw4c2kA3c8PaJErx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
