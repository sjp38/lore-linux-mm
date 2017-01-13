Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD9F6B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:51:32 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id w194so60992419ybe.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:51:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si3596080ywe.312.2017.01.13.03.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 03:51:31 -0800 (PST)
Date: Fri, 13 Jan 2017 12:51:28 +0100
From: Kevin Wolf <kwolf@redhat.com>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170113115128.GB4981@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
 <20170111114023.GA4813@noname.redhat.com>
 <87y3yfftqa.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jq0ap7NbKX2Kqbes"
Content-Disposition: inline
In-Reply-To: <87y3yfftqa.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Theodore Ts'o <tytso@mit.edu>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>


--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Am 13.01.2017 um 05:51 hat NeilBrown geschrieben:
> On Wed, Jan 11 2017, Kevin Wolf wrote:
>=20
> > Am 11.01.2017 um 06:03 hat Theodore Ts'o geschrieben:
> >> A couple of thoughts.
> >>=20
> >> First of all, one of the reasons why this probably hasn't been
> >> addressed for so long is because programs who really care about issues
> >> like this tend to use Direct I/O, and don't use the page cache at all.
> >> And perhaps this is an option open to qemu as well?
> >
> > For our immediate case, yes, O_DIRECT can be enabled as an option in
> > qemu, and it is generally recommended to do that at least for long-lived
> > VMs. For other cases it might be nice to use the cache e.g. for quicker
> > startup, but those might be cases where error recovery isn't as
> > important.
> >
> > I just see a much broader problem here than just for qemu. Essentially
> > this approach would mean that every program that cares about the state
> > it sees being safe on disk after a successful fsync() would have to use
> > O_DIRECT. I'm not sure if that's what we want.
>=20
> This is not correct.  If an application has exclusive write access to a
> file (which is common, even if only enforced by convention) and if that
> program checks the return of every write() and every fsync() (which, for
> example, stdio does, allowing ferror() to report if there have ever been
> errors), then it will know if its data if safe.
>=20
> If any of these writes returned an error, then there is NOTHING IT CAN
> DO about that file.  It should be considered to be toast.
> If there is a separate filesystem it can use, then maybe there is a way
> forward, but normally it would just report an error in whatever way is
> appropriate.
>=20
> My position on this is primarily that if you get a single write error,
> then you cannot trust anything any more.

But why? Do you think this is inevitable and therefore it is the most
useful approach to handle errors, or is it just more convenient because
then you don't have to think as much about error cases?

The semantics I know is that a failed write means that the contents of
the blocks touched by a failed write request is undefined now, but why
can't I trust anything else in the same file (we're talking about what
is often a whole block device in the case of qemu) any more?

> You suggested before that NFS problems can cause errors which can be
> fixed by the sysadmin so subsequent writes succeed.  I disagreed - NFS
> will block, not return an error.  Your last paragraph below indicates
> that you agree.  So I ask again: can you provide a genuine example of a
> case where a write might result in an error, but that sysadmin
> involvement can allow a subsequent attempt to write to succeed.   I
> don't think you can, but I'm open...

I think I replied to that in the other email now, so in order to keep it
in one place I don't repeat my answer here

> I note that ext4 has an option "errors=3Dremount-ro".  I think that
> actually makes a lot of sense.  I could easily see an argument for
> supporting this at the file level, when it isn't enabled at the
> filesystem level. If there is any write error, then all subsequent
> writes should cause an error, only reads should be allowed.

Obviously, that doesn't solve the problems we have to recover, but makes
them only worse. However, I admit it would be the only reasonable choice
if "after a single write error, you can't trust the whole file" is the
official semantics. (Which I hope it isn't.)

Kevin

--jq0ap7NbKX2Kqbes
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJYeL9AAAoJEH8JsnLIjy/WiocP/2iwXWp9ygFRMZKPxWj1MWgO
lGI1V7dv45l27SE5xUKaYFqOUxZWkivH/GiBh3Bt6I1+eeb3lAKPptg/OYwnWit5
E0HdZ0uUbS1V66lonHgQ0GxtTO1YuxqI3HCYpzRg4kpvrsrQ7acgNkPEjsBO4TGD
IgWW9gg5GH829W3FegMZpwzmx9VBUhlsK7H3lTDZ5HzEt6w4PZFydCmsC5iQEby8
qWrBlQvYSxvT/7aoKiV6KlKYykm/oypOA3ZlJqijHIRF/KxMAvyXRrzTM/TNpjsR
NhfkpdbnUbhzpzrE4TwH/JqEmaAqt5KHRniX7kKX0uzVirwxoqqU4wRP1HEg52M3
MXByamz2CODsfOeFv4FdUgH8Z14YGTbTMLMycSdx7r7kC88+GQqNNXqFl9Zsae4w
C9F1sjDvBn80ugb54vbOjHbwVJi7UutZGNTIulhx33xSIpx8JuCjrMjwfkzUwd4u
9TkpTj2lFT1bLQ5SjBieKMP6u8qDhAd1JLnqAqTOINy9/yDfLliXvTvWjzQ38CEh
9D73pTp45ITM1Nk3ukhcbLn7yFl+tokHXo5blo3PAFc/HrV143rrbWSDLt+cm92l
cE7qBToYM6eacdT4wjMYIpXZN2vidNpHnEa6SaFx/x00ZQi3Rb2LCFxCCV9Lj5M4
ZE+zeOxNzQggCCrA6MeY
=l4dJ
-----END PGP SIGNATURE-----

--jq0ap7NbKX2Kqbes--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
