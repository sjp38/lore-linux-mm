Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90F3A6B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 16:56:04 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r144so18834285wme.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 13:56:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si3492876wmg.133.2017.01.13.13.56.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 13:56:03 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sat, 14 Jan 2017 08:55:53 +1100
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
In-Reply-To: <20170113115128.GB4981@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com> <20170111050356.ldlx73n66zjdkh6i@thunk.org> <20170111114023.GA4813@noname.redhat.com> <87y3yfftqa.fsf@notabene.neil.brown.name> <20170113115128.GB4981@noname.redhat.com>
Message-ID: <87pojqfwuu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 13 2017, Kevin Wolf wrote:

> [ Unknown signature status ]
> Am 13.01.2017 um 05:51 hat NeilBrown geschrieben:
>> On Wed, Jan 11 2017, Kevin Wolf wrote:
>>=20
>> > Am 11.01.2017 um 06:03 hat Theodore Ts'o geschrieben:
>> >> A couple of thoughts.
>> >>=20
>> >> First of all, one of the reasons why this probably hasn't been
>> >> addressed for so long is because programs who really care about issues
>> >> like this tend to use Direct I/O, and don't use the page cache at all.
>> >> And perhaps this is an option open to qemu as well?
>> >
>> > For our immediate case, yes, O_DIRECT can be enabled as an option in
>> > qemu, and it is generally recommended to do that at least for long-liv=
ed
>> > VMs. For other cases it might be nice to use the cache e.g. for quicker
>> > startup, but those might be cases where error recovery isn't as
>> > important.
>> >
>> > I just see a much broader problem here than just for qemu. Essentially
>> > this approach would mean that every program that cares about the state
>> > it sees being safe on disk after a successful fsync() would have to use
>> > O_DIRECT. I'm not sure if that's what we want.
>>=20
>> This is not correct.  If an application has exclusive write access to a
>> file (which is common, even if only enforced by convention) and if that
>> program checks the return of every write() and every fsync() (which, for
>> example, stdio does, allowing ferror() to report if there have ever been
>> errors), then it will know if its data if safe.
>>=20
>> If any of these writes returned an error, then there is NOTHING IT CAN
>> DO about that file.  It should be considered to be toast.
>> If there is a separate filesystem it can use, then maybe there is a way
>> forward, but normally it would just report an error in whatever way is
>> appropriate.
>>=20
>> My position on this is primarily that if you get a single write error,
>> then you cannot trust anything any more.
>
> But why? Do you think this is inevitable and therefore it is the most
> useful approach to handle errors, or is it just more convenient because
> then you don't have to think as much about error cases?

If you get an EIO from a write, or fsync, it tells you that the
underlying storage module has run out of options and cannot cope.
Maybe it was a media error, then the drive tried writing is a reserved
area but got a media error there as well, or found it was full.
Maybe it was a drive mechanism error - the head won't move properly any
more.
Maybe the flash storage is too worn and it won't hold data any more.
Maybe the network-attached server said "that object doesn't exist any more"
Maybe .... all sorts of other possibilities.

What is the chance that the underlying storage mechanism has failed to
store this one block for you, but everything else is working smoothly?
I would suggest that the chance is very close to zero.

Trying recovery strategies when you have no idea what went wrong, is an
exercise in futility.  "EIO" doesn't carry enough information, in
general, for you to do anything other the bail-out and admit failure.

NeilBrown


>
> The semantics I know is that a failed write means that the contents of
> the blocks touched by a failed write request is undefined now, but why
> can't I trust anything else in the same file (we're talking about what
> is often a whole block device in the case of qemu) any more?
>
>> You suggested before that NFS problems can cause errors which can be
>> fixed by the sysadmin so subsequent writes succeed.  I disagreed - NFS
>> will block, not return an error.  Your last paragraph below indicates
>> that you agree.  So I ask again: can you provide a genuine example of a
>> case where a write might result in an error, but that sysadmin
>> involvement can allow a subsequent attempt to write to succeed.   I
>> don't think you can, but I'm open...
>
> I think I replied to that in the other email now, so in order to keep it
> in one place I don't repeat my answer here
>
>> I note that ext4 has an option "errors=3Dremount-ro".  I think that
>> actually makes a lot of sense.  I could easily see an argument for
>> supporting this at the file level, when it isn't enabled at the
>> filesystem level. If there is any write error, then all subsequent
>> writes should cause an error, only reads should be allowed.
>
> Obviously, that doesn't solve the problems we have to recover, but makes
> them only worse. However, I admit it would be the only reasonable choice
> if "after a single write error, you can't trust the whole file" is the
> official semantics. (Which I hope it isn't.)
>
> Kevin

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh5TOkACgkQOeye3VZi
gbltYg//bU2KaXUPxCu9Vfz4bddFngCCkNqncbL6I9mcNaZ0Gj06UEwjKosY+kX1
4zP2d6eTza4oWyXmUO2k42C5yDVhx26j2o/s0gxBXjMY3S1NXvZGc6rzCuM4S36+
C1biui/UPXqrSteAaI3rLFKTHoc7w97anx15aBIMQpRllJmftE5zcqKMxgNjc5P9
iWzlzTZJs2okOs1sDsyR8668yUYTugKz8/pJA8OOvCGY9zZdwnM9wpaNNSO50uQO
b5z8jxowQklMRCjJ6paWoL4NLwJiEyWje8sDTTfSmed4QP2CohEMwAv+ACguhmwq
M3vGrSODcMLQMSt84Bx42HJB4wSKnxhKnDgGHT/d5khbMJe3FxMunjrhNtH8cnhl
gHe3bBkblbbo6BvafvTdLyOnnKG2vN44w7uJyp3KBOrhDegxJwz0yzDz6HvuI2Kt
SyZSxIFle0MAiIHBkJjgNF7IkoXwZ7RamYqrrKmWNZG6EHdYtg5qM16rK3ci4aJa
5KOSDoUbM3VH9rAlyaNnzDz8fl/8yWVL4FMLm5gfsF6/9YvuECJfcsjkJpAhCz6X
FKZfYmI4M50wmXJTEufgpYCFPdBT3ysLu5ANWTATirSwk0NgcqG7kt1ByqL8G7zZ
/O31l5QN0UqahsqWyln2imXkub4H2AR8b9XxkQONwViNRKit4LQ=
=kfZ2
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
