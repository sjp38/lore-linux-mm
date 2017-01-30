Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2C96B028E
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:31:27 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so58972890wjd.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:31:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j83si11943782wmj.140.2017.01.29.21.31.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Jan 2017 21:31:25 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jan 2017 16:30:41 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <1485349246.2736.1.camel@poochiereds.net>
References: <20170110160224.GC6179@noname.redhat.com> <87k2a2ig2c.fsf@notabene.neil.brown.name> <20170113110959.GA4981@noname.redhat.com> <20170113142154.iycjjhjujqt5u2ab@thunk.org> <20170113160022.GC4981@noname.redhat.com> <87mveufvbu.fsf@notabene.neil.brown.name> <1484568855.2719.3.camel@poochiereds.net> <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com> <878tq1ia6l.fsf@notabene.neil.brown.name> <1485218787.2786.23.camel@poochiereds.net> <87y3y0glx7.fsf@notabene.neil.brown.name> <1485349246.2736.1.camel@poochiereds.net>
Message-ID: <87poj5ru66.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 25 2017, Jeff Layton wrote:

> On Wed, 2017-01-25 at 08:58 +1100, NeilBrown wrote:
>> On Mon, Jan 23 2017, Jeff Layton wrote:
>>=20
>> > On Tue, 2017-01-24 at 11:16 +1100, NeilBrown wrote:
>> > > On Mon, Jan 23 2017, Trond Myklebust wrote:
>> > >=20
>> > > > On Mon, 2017-01-23 at 17:35 -0500, Jeff Layton wrote:
>> > > > > On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
>> > > > > >=20
>> > > > > > However, if we look at the greater problem of hanging requests=
 that
>> > > > > > came
>> > > > > > up in the more recent emails of this thread, it is only moved
>> > > > > > rather
>> > > > > > than solved. Chances are that already write() would hang now
>> > > > > > instead of
>> > > > > > only fsync(), but we still have a hard time dealing with this.
>> > > > > >=20
>> > > > >=20
>> > > > > Well, it _is_ better with O_DIRECT as you can usually at least b=
reak
>> > > > > out
>> > > > > of the I/O with SIGKILL.
>> > > > >=20
>> > > > > When I last looked at this, the problem with buffered I/O was th=
at
>> > > > > you
>> > > > > often end up waiting on page bits to clear (usually PG_writeback=
 or
>> > > > > PG_dirty), in non-killable sleeps for the most part.
>> > > > >=20
>> > > > > Maybe the fix here is as simple as changing that?
>> > > >=20
>> > > > At the risk of kicking off another O_PONIES discussion: Add an
>> > > > open(O_TIMEOUT) flag that would let the kernel know that the
>> > > > application is prepared to handle timeouts from operations such as
>> > > > read(), write() and fsync(), then add an ioctl() or syscall to all=
ow
>> > > > said application to set the timeout value.
>> > >=20
>> > > I was thinking on very similar lines, though I'd use 'fcntl()' if
>> > > possible because it would be a per-"file description" option.
>> > > This would be a function of the page cache, and a filesystem wouldn't
>> > > need to know about it at all.  Once enable, 'read', 'write', or 'fsy=
nc'
>> > > would return EWOULDBLOCK rather than waiting indefinitely.
>> > > It might be nice if 'select' could then be used on page-cache file
>> > > descriptors, but I think that is much harder.  Support O_TIMEOUT wou=
ld
>> > > be a practical first step - if someone agreed to actually try to use=
 it.
>> > >=20
>> >=20
>> > Yeah, that does seem like it might be worth exploring.=C2=A0
>> >=20
>> > That said, I think there's something even simpler we can do to make
>> > things better for a lot of cases, and it may even help pave the way for
>> > the proposal above.
>> >=20
>> > Looking closer and remembering more, I think the main problem area when
>> > the pages are stuck in writeback is the wait_on_page_writeback call in
>> > places like wait_for_stable_page and __filemap_fdatawait_range.
>>=20
>> I can't see wait_for_stable_page() being very relevant.  That only
>> blocks on backing devices which have requested stable pages.
>> raid5 sometimes does that.  Some scsi/sata devices can somehow.
>> And rbd (part of ceph) sometimes does.  I don't think NFS ever will.
>> wait_for_stable_page() doesn't currently return an error, so getting to
>> abort in SIGKILL would be a lot of work.
>>=20
>
> Ahh right, I missed that it only affects pages backed by a BDI that has
> BDI_CAP_STABLE_WRITES. Good.
>
>
>> filemap_fdatawait_range() is much easier.
>>=20
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index b772a33ef640..2773f6dde1da 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -401,7 +401,9 @@ static int __filemap_fdatawait_range(struct address_=
space *mapping,
>>  			if (page->index > end)
>>  				continue;
>>=20=20
>> -			wait_on_page_writeback(page);
>> +			if (PageWriteback(page))
>> +				if (wait_on_page_bit_killable(page, PG_writeback))
>> +					err =3D -ERESTARTSYS;
>>  			if (TestClearPageError(page))
>>  				ret =3D -EIO;
>>  		}
>>=20
>> That isn't a complete solution. There is code in f2fs which doesn't
>> check the return value and probably should.  And gfs2 calls
>> 	mapping_set_error(mapping, error);
>> with the return value, with we probably don't want in the ERESTARTSYS ca=
se.
>> There are some usages in btrfs that I'd need to double-check too.
>>=20
>> But it looks to be manageable.=20
>>=20
>> Thanks,
>> NeilBrown
>>=20
>
> Yeah, it does. The main worry I have is that this function is called all
> over the place in fairly deep call chains. It definitely needs review
> and testing (and probably a lot of related fixes like you mention).

I decided to dig a bit more deeply into this.  There aren't all *that*
many calls to filemap_fdatawait() itself, but when you add in calls
through filemap_write_and_wait(), it starts to add up quite a lot.

One interesting semantic of filemap_fdatawait() is that it calls
filemap_check_errors() which clears the AS_ENOSPC and AS_EIO bits.
This means that you need to be careful to save the error status,
otherwise the application might never see that a write error happened.
Some places aren't as careful as they should be.

Several filesystems use filemap_fdatawait or similar to flush dirty
pages before setattr or file locking.  9fs is particularly guilty, but
it isn't the only one.  The filesystem cannot usefully return EIO for
either of these, so it really needs to reset the AS_E* flag.  Some do,
but many don't.
There is a filemap_fdatawait_noerror() interface to avoid clearing the
flags, but that isn't exported so filesystems don't use it.

One strangeness that caught my eye is the O_DIRECT write handling in
btrfs.
If it cannot write directly to the device (e.g. if it has to allocate
space first) it falls back to bufferred writes and then flushes.
If it successfully writes some blocks directly to the device, and only
has to fallback for part of the write, then any EIO which happens during
the later part of the write gets lost.


It is a bit of a mess really.  Some of it is simple coding errors,
possibly based on not understanding the requirements properly.  But part
of it is, I think, because the filemap_fdatawait() interface is too
easy to misuse.  It would be safer if filemap_fdatawait() never cleared
the AS_E* flags, and didn't even return any error.
Separately, filemap_check_errors() could be called separately when
needed, and possible filemap_datawait_errors() (or
filemap_write_and_wait_errors()) could then be provided if it was useful
enough.

Probably many of the places that want the errors, would be OK with EINTR
on a SIGKILL.  Certainly many places that don't check errors wouldn't be
happy with that.

I'll have a play and see how easy it is to clean bits of this up.

NeilBrown


>
> We should also note that this is not really a fix for applications,
> per-se. It's more of an administrative improvement, to allow admins to
> kill off processes stuck waiting for an inode to finish writeback.
>
> I think there may still be room for an interface like you and Trond were
> debating. But, I think this might be a good first step and would improve
> a lot of hung mount situations.
> --=20
> Jeff Layton <jlayton@poochiereds.net>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliOz4EACgkQOeye3VZi
gbnfNxAAhQk8ELnqMINCGwJroS/+DO+yIUaTRT3KZouDG9TyWfms3Iapa1SYMoUF
PaLKSaXBOXQtx3FvT7OvvF6rbCNWpIKIc1NWELWfyLCoMr3y5QmWb+jmSCQsPYSc
kxwu2QJqBj/wF7BffIJMb/N27W0Miona8fTSIMRKwYTdWPAOzPpOsdPQu9kZZ/7+
qc3DGoqkrqdqbpibkRfUInFIiBEC2m8Lurv2hXOKJEGhIRhk1cGCZwLy3K4ZOEz4
NFxwKNtfWNRfwB9lbi4stVBNETwQtp/f/RvH/iZXjGVXc7ZFe9K7BOvXrIL0GZhh
Z3IlXZdMk/eH/H3IBqVby4WrUYcNfiBl6cTd11v0ZsXrgghNjrknZmHnNDhkqGPF
psm4YFR4/LTuT9TFcbb4C66KhN89PgD4sYUNoKPu9L2Y8TAqjzSjj8gBhuu/TUGe
pijtbUfb+KAWaa6n37o+PyoypBQhrVto2t3VQD51EBao5QyzHiBBNZLS6mE5oO96
6QimJT7hqqhM3bMW2FNo0Vmn7iiwiU9yJyRuxz3okpYqn65Q7xCowFRfY2iDZCZm
liJm4O0/1MNrbhVavisN2ADISkqlvLZO2GJdPiNSNVOeMg4FBpKrvRWF9j64VyUa
IjRf5qiddnRo5uqkNtcNj9VdzLIAhhe8lRAHUtkSiLcXAtMipuo=
=eM04
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
