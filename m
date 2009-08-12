Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C93CA6B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:41:36 -0400 (EDT)
Received: by ywh12 with SMTP id 12so18634ywh.12
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 06:41:38 -0700 (PDT)
Message-ID: <4A82C68F.8070306@gmail.com>
Date: Wed, 12 Aug 2009 09:41:35 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
References: <cover.1249992497.git.mst@redhat.com> <20090811212802.GC26309@redhat.com> <4A82076A.1060805@gmail.com> <20090812090219.GB26847@redhat.com> <4A82BD2F.7080405@gmail.com> <20090812132539.GD29200@redhat.com>
In-Reply-To: <20090812132539.GD29200@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3EF8735E064856490BFD866C"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, paulmck@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3EF8735E064856490BFD866C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Wed, Aug 12, 2009 at 09:01:35AM -0400, Gregory Haskins wrote:
>> I think I understand what your comment above meant:  You don't need to=

>> do synchronize_rcu() because you can flush the workqueue instead to
>> ensure that all readers have completed.
>=20
> Yes.
>=20
>>  But if thats true, to me, the
>> rcu_dereference itself is gratuitous,
>=20
> Here's a thesis on what rcu_dereference does (besides documentation):
>=20
> reader does this
>=20
> 	A: sock =3D n->sock
> 	B: use *sock
>=20
> Say writer does this:
>=20
> 	C: newsock =3D allocate socket
> 	D: initialize(newsock)
> 	E: n->sock =3D newsock
> 	F: flush
>=20
>=20
> On Alpha, reads could be reordered.  So, on smp, command A could get
> data from point F, and command B - from point D (uninitialized, from
> cache).  IOW, you get fresh pointer but stale data.
> So we need to stick a barrier in there.

Yes, that is understood.  Perhaps you should just use a normal barrier,
however.  (Or at least a comment that says "I am just using this for its
barrier").

>=20
>> and that pointer is *not* actually
>> RCU protected (nor does it need to be).
>=20
> Heh, if readers are lockless and writer does init/update/sync,
> this to me spells rcu.

More correctly: it "smells like" RCU, but its not. ;)  It's rcu-like,
but you are not really using the rcu facilities.  I think anyone that
knows RCU and reads your code will likely be scratching their heads as we=
ll.

Its probably not a big deal, as I understand your code now.  Just a
suggestion to help clarify it.

Regards,
-Greg


--------------enig3EF8735E064856490BFD866C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCxo8ACgkQP5K2CMvXmqGHNwCfeSOj6XEoQldiuqHUKtcJi8K9
NTQAniNqfbw8pAtN7bgG/hfXO+Ab81ZP
=G+NZ
-----END PGP SIGNATURE-----

--------------enig3EF8735E064856490BFD866C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
