Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62B866B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 18:31:02 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so151424623pgh.2
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 15:31:02 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id o5si13585439pfj.61.2017.02.26.15.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 Feb 2017 15:31:01 -0800 (PST)
Message-ID: <1488151856.4157.50.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 26 Feb 2017 15:30:56 -0800
In-Reply-To: <877f4cr7ew.fsf@notabene.neil.brown.name>
References: <1488120164.2948.4.camel@redhat.com>
	 <1488129033.4157.8.camel@HansenPartnership.com>
	 <877f4cr7ew.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-6i+me0UBGokf5wZ4fbGq"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org


--=-6i+me0UBGokf5wZ4fbGq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-02-27 at 08:03 +1100, NeilBrown wrote:
> On Sun, Feb 26 2017, James Bottomley wrote:
>=20
> > [added linux-scsi and linux-block because this is part of our error
> > handling as well]
> > On Sun, 2017-02-26 at 09:42 -0500, Jeff Layton wrote:
> > > Proposing this as a LSF/MM TOPIC, but it may turn out to be me=20
> > > just not understanding the semantics here.
> > >=20
> > > As I was looking into -ENOSPC handling in cephfs, I noticed that
> > > PG_error is only ever tested in one place [1]=20
> > > __filemap_fdatawait_range, which does this:
> > >=20
> > > 	if (TestClearPageError(page))
> > > 		ret =3D -EIO;
> > >=20
> > > This error code will override any AS_* error that was set in the
> > > mapping. Which makes me wonder...why don't we just set this error=20
> > > in the mapping and not bother with a per-page flag? Could we
> > > potentially free up a page flag by eliminating this?
> >=20
> > Note that currently the AS_* codes are only set for write errors=20
> > not for reads and we have no mapping error handling at all for swap
> > pages, but I'm sure this is fixable.
>=20
> How is a read error different from a failure to set PG_uptodate?
> Does PG_error suppress retries?

We don't do any retries in the code above the block layer (or at least
we shouldn't). =20

> >=20
> > From the I/O layer point of view we take great pains to try to=20
> > pinpoint the error exactly to the sector.  We reflect this up by=20
> > setting the PG_error flag on the page where the error occurred.  If=20
> > we only set the error on the mapping, we lose that granularity,=20
> > because the mapping is mostly at the file level (or VMA level for
> > anon pages).
>=20
> Are you saying that the IO layer finds the page in the bi_io_vec and
> explicitly sets PG_error,

I didn't say anything about the mechanism.  I think the function you're
looking for is fs/mpage.c:mpage_end_io().  layers below block indicate
the position in the request.  Block maps the position to bio and the
bio completion maps to page.  So the actual granularity seen in the
upper layer depends on how the page to bio mapping is done.

>  rather than just passing an error indication to bi_end_io ??  That
> would seem to be wrong as the page may not be in the page cache.

Usually pages in the mpage_end_io path are pinned, I think.

>  So I guess I misunderstand you.
>=20
> >=20
> > So I think the question for filesystem people from us would be do=20
> > you care about this accuracy?  If it's OK just to know an error
> > occurred somewhere in this file, then perhaps we don't need it.
>=20
> I had always assumed that a bio would either succeed or fail, and=20
> that no finer granularity could be available.

It does ... but a bio can be as small as a single page.

> I think the question here is: Do filesystems need the pagecache to
> record which pages have seen an IO error?

It's not just filesystems.  The partition code uses PageError() ... the
metadata code might as well (those are things with no mapping).  I'm
not saying we can't remove PG_error; I am saying it's not going to be
quite as simple as using the AS_ flags.

James

> I think that for write errors, there is no value in recording
> block-oriented error status - only file-oriented status.
> For read errors, it might if help to avoid indefinite read retries,=20
> but I don't know the code well enough to be sure if this is an issue.
>=20
> NeilBrown
>=20
>=20
> >=20
> > James
> >=20
> > > The main argument I could see for keeping it is that removing it=20
> > > might subtly change the behavior of sync_file_range if you have=20
> > > tasks syncing different ranges in a file concurrently. I'm not=20
> > > sure if that would break any guarantees though.
> > >=20
> > > Even if we do need it, I think we might need some cleanup here=20
> > > anyway. A lot of readpage operations end up setting that flag=20
> > > when they hit an error. Isn't it wrong to return an error on=20
> > > fsync, just because we had a read error somewhere in the file in=20
> > > a range that was never dirtied?
> > >=20
> > > --
> > > [1]: there is another place in f2fs, but it's more or less=20
> > > equivalent to the call site in __filemap_fdatawait_range.
> > >=20

--=-6i+me0UBGokf5wZ4fbGq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYs2UwAAoJEAVr7HOZEZN4Ek8QALjr8dGSAK3wpg5WLLYejhOR
iN/WlQp8fjP/N8qCEVZjIm7oX8wrmncmbBqOp0wpd7Up/oBjEAhusPOIuscsSQbh
TtK8ddCDkDxb247dQKAOTQcCRg8HnduUCMEN4J+JGqQq1Su2M0CdljoS/IpPJYU+
4Qy8HveAd/gOtag6dAUjc8FV+wz+bzvzfXWzYVcQXQryJFt/3NNTdJHxw0crcIxM
13G4xeYPCM8kKAe44bMCFTvzsocbVnuuc6eQL5iCEMPmtiB2yzlPi2iUbTGJUnmI
LpcaUCeBAKdanp+XhgNaMZl7ikVWItWPbYxONkqMHDg6//aeO9oxokXcczzUAH7J
Gn+JqhUN/mGEgukye6kaGxDH2D927FAwO8Y06UAxauGahduIFk8jrKA0ETI/koaT
kzgL73UwXZ1mQ50Klt4RVFxRZqiW+Sa8mjGYD5FpuT8ZoYaCYd4HwTckJbRc73rn
PV3kBJQKgE50onrlpgzOrmv33d3aNHGM5H995tipkqXrkFC4j6y1hLRSWs72f0Cz
JmMEECIChkT64NmgakLGtTfJqHxEX3DZ80vO8I/t5elInUBrSh14NWm3bhDoO4uk
RWBUhTP6d4ftrKfm8iN2IfDGOgYlc6929jy3Tq52ZabDyosUBfjLQrhLgSXRLeG6
7BMCUjSIJlpjVqVNYKLs
=c8Am
-----END PGP SIGNATURE-----

--=-6i+me0UBGokf5wZ4fbGq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
