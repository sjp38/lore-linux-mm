Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i4CIkO0m028081
	for <linux-mm@kvack.org>; Wed, 12 May 2004 14:46:24 -0400
Received: from [172.31.3.35] (arjanv.cipe.redhat.com [10.0.2.48])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4CIkN313006
	for <linux-mm@kvack.org>; Wed, 12 May 2004 14:46:23 -0400
Subject: Re: The long, long life of an inactive_dirty page
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <200405121824.i4CIOl64063750@newsguy.com>
References: <200405121824.i4CIOl64063750@newsguy.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Abl2hS/enJ3s/Gbn+CI1"
Message-Id: <1084387580.10949.9.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Wed, 12 May 2004 20:46:21 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-Abl2hS/enJ3s/Gbn+CI1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2004-05-12 at 20:24, Andrew Crawford wrote:
> Thanks for all your replies so far, and the helpful information.
>=20
> > well you may IF you fix  your mail setup to not send me evil mails abou=
t
> > having to confirm something.
>=20
> Just to clarify, you received that mail because you replied to this addre=
ss
> directly; This account don't accept emails from unverified addresses. Thi=
s
> account is not subscribed to linux-mm, which I read elsewhere.

I find that truely obnoxious.

> > One thing to realize is that after bdflush has written the pages out, t=
hey
> > can become dirty AGAIN for a variety of reasons, and as such the accoun=
ting
> > is not quite straightforward.
>=20
> Is it possible for a page to become dirty again while still remaining
> inactive? Could you give an example? (genuinely curious, hope this doesn'=
t
> sound like I'm arguing!)

If someone has that page mmaped for example, the app that has it mmap'd
can just write to the memory (which makes the page dirty in the
pagetable). The kernel doesn't get involved in that at all.


> > the problem is that the "becoming clean" is basically asynchronous
>=20
> Isn't this equally true for page_launder? Even if bdflush would wait unti=
l the
> next "pass" to move pages to the "clean" list it would be better than the
> current situation. There must be some mechanism that bdflush uses to avoi=
d
> writing the same page twice in a row; couldn't it say "oh, already wrote =
that
> one, into inactive_clean it goes".

It's slightly more subtle in the kernel you looked at. There is a list
for "write out pending" and a "clean" list.
Between all these lists there is a strict LRU order. You don't move it
to clean once it gets clean, you move it to "write out pending" when you
start writeout, and the VM moves the *other* side of the writeout list
to the clean list when it's clean.


> You will probably appreciate that I am coming at this from the point of v=
iew
> of performance measurement and capacity planning; I want to know how much
> actual memory is free or immediately reusable at a point in time.

That information is not achievable in a reliable way, ever. Simply
because it takes a not-even-near-inifintely small amount of time to
gather all the stats, during which the other cpu can change all the
underlying data away under your nose.


--=-Abl2hS/enJ3s/Gbn+CI1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAonD8xULwo51rQBIRAhpCAJ9imWZivF2prm8R6EN15x5Gb/HlewCeMvmG
JZtNrsVZBSDhq6PhrpMY1Sw=
=U999
-----END PGP SIGNATURE-----

--=-Abl2hS/enJ3s/Gbn+CI1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
