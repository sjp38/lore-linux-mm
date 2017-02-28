Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5798A6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:45:58 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so8906816wrc.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:45:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 198si4225226wmy.16.2017.02.28.12.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Feb 2017 12:45:57 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Mar 2017 07:45:47 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] do we really need PG_error at all?
In-Reply-To: <1488244308.7627.5.camel@redhat.com>
References: <1488120164.2948.4.camel@redhat.com> <1488129033.4157.8.camel@HansenPartnership.com> <877f4cr7ew.fsf@notabene.neil.brown.name> <1488151856.4157.50.camel@HansenPartnership.com> <874lzgqy06.fsf@notabene.neil.brown.name> <1488208047.2876.6.camel@redhat.com> <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca> <87varvp5v1.fsf@notabene.neil.brown.name> <1488244308.7627.5.camel@redhat.com>
Message-ID: <87h93eoxhg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, Andreas Dilger <adilger@dilger.ca>
Cc: linux-block@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27 2017, Jeff Layton wrote:

> On Tue, 2017-02-28 at 10:32 +1100, NeilBrown wrote:
>> On Mon, Feb 27 2017, Andreas Dilger wrote:
>>=20
>> >=20
>> > My thought is that PG_error is definitely useful for applications to g=
et
>> > correct errors back when doing write()/sync_file_range() so that they =
know
>> > there is an error in the data that _they_ wrote, rather than receiving=
 an
>> > error for data that may have been written by another thread, and in tu=
rn
>> > clearing the error from another thread so it *doesn't* know it had a w=
rite
>> > error.
>>=20
>> It might be useful in that way, but it is not currently used that way.
>> Such usage would be a change in visible behaviour.
>>=20
>> sync_file_range() calls filemap_fdatawait_range(), which calls
>> filemap_check_errors().
>> If there have been any errors in the file recently, inside or outside
>> the range, the latter will return an error which will propagate up.
>>=20
>> >=20
>> > As for stray sync() clearing PG_error from underneath an application, =
that
>> > shouldn't happen since filemap_fdatawait_keep_errors() doesn't clear e=
rrors
>> > and is used by device flushing code (fdatawait_one_bdev(), wait_sb_ino=
des()).
>>=20
>> filemap_fdatawait_keep_errors() calls __filemap_fdatawait_range() which
>> clears PG_error on every page.
>> What it doesn't do is call filemap_check_errors(), and so doesn't clear
>> AS_ENOSPC or AS_EIO.
>>=20
>>=20
>
> I think it's helpful to get a clear idea of what happens now in the face
> of errors and what we expect to happen, and I don't quite have that yet:
>
> --------------------------8<-----------------------------
> void page_endio(struct page *page, bool is_write, int err)
> {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is_write) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0if (!err) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Set=
PageUptodate(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0} else {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Cle=
arPageUptodate(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Set=
PageError(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0}
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0unlock_page(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0if (err) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Set=
PageError(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if =
(page->mapping)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mapping_set_error(page->mappin=
g, err);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0}
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0end_page_writeback(page);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> }
> --------------------------8<-----------------------------
>
> ...not everything uses page_endio, but it's a good place to look since
> we have both flavors of error handling in one place.
>
> On a write error, we SetPageError and set the error in the mapping.
>
> What I'm not clear on is:
>
> 1) what happens to the page at that point when we get a writeback error?
> Does it just remain in-core and is allowed to service reads (assuming
> that it was uptodate before)?

Yes, it remains in core and can service reads.  It is no different from
a page on which a write recent succeeded, except that the write didn't
succeed so the contents of backing store might be different from the
contents of the page.

>
> Can I redirty it and have it retry the write? Is there standard behavior
> for this or is it just up to the whim of the filesystem?

Everything is at the whim of the filesystem, but I doubt if many differ
from the above.

NeilBrown

>
> I'll probably have questions about the read side as well, but for now it
> looks like it's mostly used in an ad-hoc way to communicate errors
> across subsystems (block to fs layer, for instance).
> --
> Jeff Layton <jlayton@redhat.com>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli14XsACgkQOeye3VZi
gbkAxw/+KrG891w3m+XtN0xeZWu2kOV5dk3TBi4HFmfFjnuZZNRsNJM3XaHip8Xu
7VjFrARSFgRGcXBlDIosIWDjvN033afHV5Nn7CFPBT3WyJB5IOTDK4290NwH83pg
6l0y8LJWRdPUu3rsvb82XwzRVldnM0GxqEqJNhN8qAWjFjKJq+MhLdlHvTQ8IpRg
ZuSIsUB6WbBrOFJTKuTSQiYEUs8sQ0vrMfk4x954Rm7hxLVRz+ohIPnzn/PF4dt8
gOkeH7wISOaZa7DuWb6b92WvhvRalj9GH6F5D9QAWr0JPq5hAtpxblkppNTmWYmz
lGYln6XZ8fvxZuZdo4J7Z5f3TwraOWf/BafLag46ni6qSVIQcXtMrvp+AIciYR24
75W+ai6o5yvwQqzJjg03JPuX2wMK6gxZ5gDmLwRLXMnswHGYdSRLvYPmeVgRN1pZ
NCsNqQWudPhwSl+glJLQmqjvIFMytrIQYEBxHN2zisZfjML4+wylLMj5K45h5/8H
2hFIEa71pUl0HeouZkVTOWpKKbTjsjp2xIkyViez1fas/2wDsjr/7PqYT53/87Ms
4hagW9McbsWGmPhfrWpKSEOPdbI0oNEQ9sOmal+6lSkp+Yt3wGRai+dLm1c3pzfd
YdH3Y13mM0+m+N/8TULPmES7rGO1qnnPu6M8yOUG1YUi8FnwutI=
=SfiP
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
