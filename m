Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38D926B0387
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 19:27:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id m5so23383560wrm.0
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 16:27:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 29si19378702wru.27.2017.02.26.16.27.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Feb 2017 16:27:15 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Mon, 27 Feb 2017 11:27:05 +1100
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
In-Reply-To: <1488151856.4157.50.camel@HansenPartnership.com>
References: <1488120164.2948.4.camel@redhat.com> <1488129033.4157.8.camel@HansenPartnership.com> <877f4cr7ew.fsf@notabene.neil.brown.name> <1488151856.4157.50.camel@HansenPartnership.com>
Message-ID: <874lzgqy06.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Jeff Layton <jlayton@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 26 2017, James Bottomley wrote:

> On Mon, 2017-02-27 at 08:03 +1100, NeilBrown wrote:
>> On Sun, Feb 26 2017, James Bottomley wrote:
>>=20
>> > [added linux-scsi and linux-block because this is part of our error
>> > handling as well]
>> > On Sun, 2017-02-26 at 09:42 -0500, Jeff Layton wrote:
>> > > Proposing this as a LSF/MM TOPIC, but it may turn out to be me=20
>> > > just not understanding the semantics here.
>> > >=20
>> > > As I was looking into -ENOSPC handling in cephfs, I noticed that
>> > > PG_error is only ever tested in one place [1]=20
>> > > __filemap_fdatawait_range, which does this:
>> > >=20
>> > > 	if (TestClearPageError(page))
>> > > 		ret =3D -EIO;
>> > >=20
>> > > This error code will override any AS_* error that was set in the
>> > > mapping. Which makes me wonder...why don't we just set this error=20
>> > > in the mapping and not bother with a per-page flag? Could we
>> > > potentially free up a page flag by eliminating this?
>> >=20
>> > Note that currently the AS_* codes are only set for write errors=20
>> > not for reads and we have no mapping error handling at all for swap
>> > pages, but I'm sure this is fixable.
>>=20
>> How is a read error different from a failure to set PG_uptodate?
>> Does PG_error suppress retries?
>
> We don't do any retries in the code above the block layer (or at least
> we shouldn't).

I was wondering about what would/should happen if a read request was
re-issued for some reason.  Should the error flag on the page cause an
immediate failure, or should it try again.
If read-ahead sees a read-error on some future page, is it necessary to
record the error so subsequent read-aheads don't notice the page is
missing and repeatedly try to re-load it?
When the application eventually gets to the faulty page, should a read
be tried then, or is the read-ahead failure permanent?



>
>> >=20
>> > From the I/O layer point of view we take great pains to try to=20
>> > pinpoint the error exactly to the sector.  We reflect this up by=20
>> > setting the PG_error flag on the page where the error occurred.  If=20
>> > we only set the error on the mapping, we lose that granularity,=20
>> > because the mapping is mostly at the file level (or VMA level for
>> > anon pages).
>>=20
>> Are you saying that the IO layer finds the page in the bi_io_vec and
>> explicitly sets PG_error,
>
> I didn't say anything about the mechanism.  I think the function you're
> looking for is fs/mpage.c:mpage_end_io().  layers below block indicate
> the position in the request.  Block maps the position to bio and the
> bio completion maps to page.  So the actual granularity seen in the
> upper layer depends on how the page to bio mapping is done.

If the block layer is just returning the status at a per-bio level (which
makes perfect sense), then this has nothing directly to do with the
PG_error flag.

The page cache needs to do something with bi_error, but it isn't
immediately clear that it needs to set PG_error.

>
>>  rather than just passing an error indication to bi_end_io ??  That
>> would seem to be wrong as the page may not be in the page cache.
>
> Usually pages in the mpage_end_io path are pinned, I think.
>
>>  So I guess I misunderstand you.
>>=20
>> >=20
>> > So I think the question for filesystem people from us would be do=20
>> > you care about this accuracy?  If it's OK just to know an error
>> > occurred somewhere in this file, then perhaps we don't need it.
>>=20
>> I had always assumed that a bio would either succeed or fail, and=20
>> that no finer granularity could be available.
>
> It does ... but a bio can be as small as a single page.
>
>> I think the question here is: Do filesystems need the pagecache to
>> record which pages have seen an IO error?
>
> It's not just filesystems.  The partition code uses PageError() ... the
> metadata code might as well (those are things with no mapping).  I'm
> not saying we can't remove PG_error; I am saying it's not going to be
> quite as simple as using the AS_ flags.

The partition code could use PageUptodate().
mpage_end_io() calls page_endio() on each page, and on read error that
calls:

			ClearPageUptodate(page);
			SetPageError(page);

are both of these necessary?

fs/buffer.c can use several bios to read a single page.
If any one returns an error, PG_error is set.  When all of them have
completed, if PG_error is clear, PG_uptodate is then set.
This is an opportunistic use of PG_error, rather than an essential use.
It could be "fixed", and would need to be fixed if we were to deprecate
use of PG_error for read errors.
There are probably other usages like this.

Thanks,
NeilBrown


>
> James
>
>> I think that for write errors, there is no value in recording
>> block-oriented error status - only file-oriented status.
>> For read errors, it might if help to avoid indefinite read retries,=20
>> but I don't know the code well enough to be sure if this is an issue.
>>=20
>> NeilBrown
>>=20
>>=20
>> >=20
>> > James
>> >=20
>> > > The main argument I could see for keeping it is that removing it=20
>> > > might subtly change the behavior of sync_file_range if you have=20
>> > > tasks syncing different ranges in a file concurrently. I'm not=20
>> > > sure if that would break any guarantees though.
>> > >=20
>> > > Even if we do need it, I think we might need some cleanup here=20
>> > > anyway. A lot of readpage operations end up setting that flag=20
>> > > when they hit an error. Isn't it wrong to return an error on=20
>> > > fsync, just because we had a read error somewhere in the file in=20
>> > > a range that was never dirtied?
>> > >=20
>> > > --
>> > > [1]: there is another place in f2fs, but it's more or less=20
>> > > equivalent to the call site in __filemap_fdatawait_range.
>> > >=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlizclkACgkQOeye3VZi
gbmB3xAAhMb3rbqJsF2Eus5BD7J/YPlEbXALfVRTFM8ARBIJbEGbIvWr0OHIty9Y
xgLJizLFYKEYfmRnDFleZTvdfgPI/XXPfq6iBZJe4kA5pib+hlAUlU4LG56WIJoK
DliUmpSFJ87Ia7NchTNLJQPJ4gzgUrb2BRxt1uJ4jMEGcR7UTBCY0g4Ql9f4zbys
ktRFIG3JWBVbFmovcT9Aa46sQr6Cl4afB+X5gLoox3IDSGAldcEBtm0dR1+2tLiB
3OSc0JjYpR6P2jcI6kD7u1UVBbnUSJBzLNXwWw4+YU5hS8j2zVDFY0aSUu+sbnlC
yV7lpxbj4hqa6D/HTteKdLaPY99tcyUEcSL35LuRYfkZ0J3UCDuoYMgxGFqhRhYi
P4NZEdIOM4LtOgA/heYGwlneV6OJJalAvmbpjqIazGFBBYY7u8DeV8YVwFhGwdIm
IoX0r12QG9Wn5+O7Ss9q+882sq7ES5yH9VfI17pkMtTe0TVUKMWAXpeJe87RddK9
Sp6XRdQM5/PvMOqaS/rEcDDwtFcf1COO0hN+DO/I3VaQlzArt8q2ZDUNQbqSyUm3
kfNzw16C/BzVYzRZqXwK1EsPyU9becsDoXxgicI92RsfdoMcDThz1CGN7zMmMQAj
JYVUOzaILaqbmnLgrdNUzFwwW+ClYjWGyWbhccjNvS47q70AcQU=
=u1MA
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
