Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6C86B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:59:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so31205684wmt.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:59:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si24319848wrk.228.2017.01.24.13.59.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 13:59:41 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jan 2017 08:58:28 +1100
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <1485218787.2786.23.camel@poochiereds.net>
References: <20170110160224.GC6179@noname.redhat.com> <87k2a2ig2c.fsf@notabene.neil.brown.name> <20170113110959.GA4981@noname.redhat.com> <20170113142154.iycjjhjujqt5u2ab@thunk.org> <20170113160022.GC4981@noname.redhat.com> <87mveufvbu.fsf@notabene.neil.brown.name> <1484568855.2719.3.camel@poochiereds.net> <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485210957.2786.19.camel@poochiereds.net> <1485212994.3722.1.camel@primarydata.com> <878tq1ia6l.fsf@notabene.neil.brown.name> <1485218787.2786.23.camel@poochiereds.net>
Message-ID: <87y3y0glx7.fsf@notabene.neil.brown.name>
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

On Mon, Jan 23 2017, Jeff Layton wrote:

> On Tue, 2017-01-24 at 11:16 +1100, NeilBrown wrote:
>> On Mon, Jan 23 2017, Trond Myklebust wrote:
>>=20
>> > On Mon, 2017-01-23 at 17:35 -0500, Jeff Layton wrote:
>> > > On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
>> > > >=20
>> > > > However, if we look at the greater problem of hanging requests that
>> > > > came
>> > > > up in the more recent emails of this thread, it is only moved
>> > > > rather
>> > > > than solved. Chances are that already write() would hang now
>> > > > instead of
>> > > > only fsync(), but we still have a hard time dealing with this.
>> > > >=20
>> > >=20
>> > > Well, it _is_ better with O_DIRECT as you can usually at least break
>> > > out
>> > > of the I/O with SIGKILL.
>> > >=20
>> > > When I last looked at this, the problem with buffered I/O was that
>> > > you
>> > > often end up waiting on page bits to clear (usually PG_writeback or
>> > > PG_dirty), in non-killable sleeps for the most part.
>> > >=20
>> > > Maybe the fix here is as simple as changing that?
>> >=20
>> > At the risk of kicking off another O_PONIES discussion: Add an
>> > open(O_TIMEOUT) flag that would let the kernel know that the
>> > application is prepared to handle timeouts from operations such as
>> > read(), write() and fsync(), then add an ioctl() or syscall to allow
>> > said application to set the timeout value.
>>=20
>> I was thinking on very similar lines, though I'd use 'fcntl()' if
>> possible because it would be a per-"file description" option.
>> This would be a function of the page cache, and a filesystem wouldn't
>> need to know about it at all.  Once enable, 'read', 'write', or 'fsync'
>> would return EWOULDBLOCK rather than waiting indefinitely.
>> It might be nice if 'select' could then be used on page-cache file
>> descriptors, but I think that is much harder.  Support O_TIMEOUT would
>> be a practical first step - if someone agreed to actually try to use it.
>>=20
>
> Yeah, that does seem like it might be worth exploring.=C2=A0
>
> That said, I think there's something even simpler we can do to make
> things better for a lot of cases, and it may even help pave the way for
> the proposal above.
>
> Looking closer and remembering more, I think the main problem area when
> the pages are stuck in writeback is the wait_on_page_writeback call in
> places like wait_for_stable_page and __filemap_fdatawait_range.

I can't see wait_for_stable_page() being very relevant.  That only
blocks on backing devices which have requested stable pages.
raid5 sometimes does that.  Some scsi/sata devices can somehow.
And rbd (part of ceph) sometimes does.  I don't think NFS ever will.
wait_for_stable_page() doesn't currently return an error, so getting to
abort in SIGKILL would be a lot of work.

filemap_fdatawait_range() is much easier.

diff --git a/mm/filemap.c b/mm/filemap.c
index b772a33ef640..2773f6dde1da 100644
=2D-- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -401,7 +401,9 @@ static int __filemap_fdatawait_range(struct address_spa=
ce *mapping,
 			if (page->index > end)
 				continue;
=20
=2D			wait_on_page_writeback(page);
+			if (PageWriteback(page))
+				if (wait_on_page_bit_killable(page, PG_writeback))
+					err =3D -ERESTARTSYS;
 			if (TestClearPageError(page))
 				ret =3D -EIO;
 		}

That isn't a complete solution. There is code in f2fs which doesn't
check the return value and probably should.  And gfs2 calls
	mapping_set_error(mapping, error);
with the return value, with we probably don't want in the ERESTARTSYS case.
There are some usages in btrfs that I'd need to double-check too.

But it looks to be manageable.=20

Thanks,
NeilBrown

>
> That uses an uninterruptible sleep and it's common to see applications
> stuck there in these situations. They're unkillable too so your only
> recourse is to hard reset the box when you can't reestablish
> connectivity.
>
> I think it might be good to consider making some of those sleeps
> TASK_KILLABLE. For instance, both of the above callers of those
> functions are int return functions. It may be possible to return
> ERESTARTSYS when the task catches a signal.
>
> --=20
> Jeff Layton <jlayton@poochiereds.net>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliHzgUACgkQOeye3VZi
gbmdVA/+J9Ur4DSwSoDKMlVCxuwqxbOR5hQcUaCXYVwUNmgTgkuDjbzzJe0du7QL
zjxQd+1pNMq7+kMdbAu3fS6HlsSNMjFlF8KOYY+V1cSvvg0+Su67AZpvRhVyI+2p
bimvi8RTfcMAjDXfHq8F5/ESUgC0mbcrF49Y4o2tRZ0NMVp6W+0wkoht14FPFhL2
B7jzzj5eEd/RCGMSLkcu7Fk9guuR3tJXxCPt+pO0AnrANPaFVzksqfD1CViki0s7
XnV5lTbykunWm72X+jDY4B2Zeg6VE0wzRimOHRnElh9YsOXnbjJTbe0dK737vtBh
jVk+bD/oy7v2JGYYztwS9E3M5sDJfWBnRSnZmsUOXI0shTrSt8wXlk+edpjHVLMg
lDmCJduzW/z2n8jq53dw1wOS6arMfy04dtJWkwJGh+K4JP7zBG/c0bMvtvnarYKw
EgsJtY8A+V3YHGsaM6ZpBetfEJFybWav2cWbLgRLpWfihsWAUFJGjlIPBZnAzuwO
0PhgnBqkfFD80WutCew3ezK0w8eGWPcyDLDfdVybcCAZmEQxI6mt6OaJu0O2Tkoz
KxKueb0ICWo2E3Vcp3JyvulQ6NaHxyLsryKqe2M6izZNUjJPA3K9vI1amYBDZd15
iuYY1NUuVZas3vOIAJ6AwnR7O5pviaoTaPek4yL1ukPPxPOEcGQ=
=gDWr
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
