Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A22AB6B0266
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 20:24:43 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q62so263290447oih.0
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 17:24:43 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id v123si10613267itg.41.2016.07.31.17.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 17:24:42 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id d65so10848288ith.0
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 17:24:42 -0700 (PDT)
Message-ID: <1470011071.890.132.camel@gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH] [RFC] Introduce mmap
 randomization
From: Daniel Micay <danielmicay@gmail.com>
Date: Sun, 31 Jul 2016 20:24:31 -0400
In-Reply-To: <20160731222416.GZ4541@io.lakedaemon.net>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
	 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
	 <20160726200309.GJ4541@io.lakedaemon.net>
	 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
	 <20160726205944.GM4541@io.lakedaemon.net>
	 <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
	 <20160728210734.GU4541@io.lakedaemon.net>
	 <1469787002.10626.34.camel@gmail.com>
	 <20160731222416.GZ4541@io.lakedaemon.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-eXTtV7Nbz/JaAgS7vNpN"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Nick Kralevich <nnk@google.com>, "Roberts, William C" <william.c.roberts@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>


--=-eXTtV7Nbz/JaAgS7vNpN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> > It's very hard to quantify the benefits of fine-grained
> > randomization,
>=20
> ?=C2=A0=C2=A0N =3D # of possible addresses.=C2=A0=C2=A0The bigger N is, t=
he more chances the
> attacker will trip up before finding what they were looking for.

If the attacker is forcing the creation of many objects with a function
pointer and then trying to hit one, the only thing that would help is if
the heap is very sparse with random bases within it. They don't need to
hit a specific object for an exploit to work.

The details of how the randomization is done and the guarantees that are
provided certainly matter. Individual random gaps are low entropy and
they won't add up to much higher entropy randomization even for two
objects that are far apart. The entropy has no chance to build up since
the sizes will average out.

I'm not saying it doesn't make sense to do this (it's a feature that I
really want), but there are a lot of ways to approach fine-grained mmap
randomization and the design decisions should be justified and their
impact analyzed/measured.

> > but there are other useful guarantees you could provide. It would be
> > quite helpful for the kernel to expose the option to force a
> > PROT_NONE
> > mapping after every allocation. The gaps should actually be
> > enforced.
> >=20
> > So perhaps 3 things, simply exposed as off-by-default sysctl options
> > (no need for special treatment on 32-bit):
>=20
> I'm certainly not an mm-developer, but this looks to me like we're
> pushing the work of creating efficient, random mappings out to
> userspace.=C2=A0=C2=A0:-/

Exposing configuration doesn't push work to userspace. I can't see any
way that this would be done by default even on 64-bit due to the extra
VMAs, so it really needs configuration.

> > a) configurable minimum gap size in pages (for protection against
> > linear and small {under,over}flows) b) configurable minimum gap size
> > based on a ratio to allocation size (for making the heap sparse to
> > mitigate heap sprays, especially when mixed with fine-grained
> > randomization - for example 2x would add a 2M gap after a 1M
> > mapping)
>=20
> mmm, this looks like an information leak.=C2=A0=C2=A0Best to set a range =
of
> pages
> and pick a random number within that range for each call.

A minimum gap size provides guarantees not offered by randomization
alone. It might not make sense to approach making the heap sparse by
forcing it separately from randomization, but doing it isn't leaking
information.

Obviously the random gap would be chosen by picking a maximum size (n)
and choosing a size between [0, n], which was the next potential
variable, separate from these non-randomization-related guarantees.

> > c) configurable maximum random gap size (the random gap would be in
> > addition to the enforced minimums)
> >=20
> > The randomization could just be considered an extra with minor
> > benefits rather than the whole feature. A full fine-grained
> > randomization implementation would need a higher-level form of
> > randomization than gaps in the kernel along with cooperation from
> > userspace allocators. This would make sense as one part of it
> > though.
>=20
> Ok, so here's an idea.=C2=A0=C2=A0This idea could be used in conjunction =
with
> random gaps, or on it's own.=C2=A0=C2=A0It would be enhanced by userspace=
 random
> load order.
>=20
> The benefit is that with 32bit address space, and no random gapping,
> it's still not wasting much space.
>=20
> Given a memory space, break it up into X bands such that there are 2*X
> possible addresses.
>=20
> =C2=A0 |A=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0B|C=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0D=
|E=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0F|G=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0H| ... |2*=
X-2=C2=A0=C2=A02*X-1|
> =C2=A0 |--> <--|--> <--|--> <--|--> <--| ... |-->=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0<--|
> min=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0max
>=20
> For each call to mmap, we randomly pick a value within [0 - 2*X).
> Assuming A=3D0 in the diagram above, even values grow up, odd values
> grow
> down.=C2=A0=C2=A0Gradually consuming the single gap in the middle of each=
 band.
>=20
> How many bands to use would depend on:
> =C2=A0 * 32/64bit
> =C2=A0 * Average number of mmap calls
> =C2=A0 * largest single mmap call usually seen
> =C2=A0 * if using random gaps and range used
>=20
> If the free gap in a chosen band is too small for the request, pick
> again among the other bands.
>=20
> Again, I'm not an mm dev, so I might be totally smoking crack on this
> one...
>=20
> thx,
>=20
> Jason.

Address space fragmentation matters a lot, not only wasted space due to
memory that's explicitly reserved for random gaps. The randomization
guarantees under situations like memory exhaustion also matter.

I do think fine-grained randomization would be useful, but I think it's
unclear what a good approach would be, along with what the security
benefits would be. The malloc implementation is also very relevant.

OpenBSD has fine-grained mmap randomization with a fair bit of thought
put into how it works, but I don't think there has been much analysis of
it. The security properties really aren't clear.
--=-eXTtV7Nbz/JaAgS7vNpN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIzBAABCAAdBQJXnpbAFhxkYW5pZWxtaWNheUBnbWFpbC5jb20ACgkQ+ecS5Zr1
8iqF8A//VxAtTC50CrKV42us8JtHqanMvLb+0rpQb7juUN9NpH5XPjlp7LQExyYQ
bluhfLobMR+1cstiCN1gDo6v6+5JNSDbduKhMVal1+N93XxynwkBX1jNuLSgEoLu
+Rhuoy4Zl/sIqJsO9piD7u1dinYwNCBLKRNG97Z2F2cZDfyEl6b5e8mD87ylJgj8
E+HFZ5k4UCLVVspAC5nrETdhVg8Unyn0V03Lrr4tQU0TK89p30kIvr1J60cQZwlZ
hOMiMTKzAPnZKiB5PYRP/ql2YYkK6cOUAYV5NgvlW1ZEwSCdeY8K1yHE1FgNMNHz
jTQ1iQuoSNMbPMQLN4wQArBPXHCXt0+UhxXAfTMPf3epkcvEjTRIqNllCeHRmf7L
+22/1HpMVSYJVIfzgT76wLQtHZRTlLeWQPrVt3In3lUvMtYwgR3EHHTsvhVo5eHc
V6P4/fYJqJiuenIhHcQQyIkg9JXDsvDvGj8mQql7hwwb2p2IFo5JqvHlzsmKyMap
WedC40WZ/YNiejO5kuy3xNRV8zt5kXIzGAfBHmO9enqZ+vzOiz1ot3RCpq1o2XeD
dUH//l/Nn6KdNo0M3SkLs6gzaj4oc5UjkyIMJ6ocZoNSIvECo6X5NETP1RHlQh+k
VczXnDvu6ZkUB8aCe4aP2c1tEh09J6rzDQo/KcNCZxjYHmKnT1o=
=XIbw
-----END PGP SIGNATURE-----

--=-eXTtV7Nbz/JaAgS7vNpN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
