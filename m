Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9986B0005
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 16:17:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b62so207905779pfa.2
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 13:17:34 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id xd8si29401584pac.276.2016.07.24.13.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jul 2016 13:17:33 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id p64so56828995pfb.1
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 13:17:33 -0700 (PDT)
Date: Sun, 24 Jul 2016 13:17:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: tmpfs ability to shrink and expand
In-Reply-To: <1469385512.6011.20.camel@debian.org>
Message-ID: <alpine.LSU.2.11.1607241226300.2694@eggly.anvils>
References: <1469385512.6011.20.camel@debian.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-2062639302-1469391451=:2694"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ritesh Raj Sarraf <rrs@debian.org>
Cc: Christoph Rohland <cr@sap.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-2062639302-1469391451=:2694
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 25 Jul 2016, Ritesh Raj Sarraf wrote:
>=20
> I am writing to you because you are listed as Maintainers for the tmpfs f=
ile
> system in the Linux kernel.
>=20
>=20
> Recently, I have had a bug in a general purpose application, where it ran=
 out of
> space in $TMPDIR. As is common, these days, most people vote for /tmp on =
tmpfs,
> for obviously good reasons (performance, efficiency etc).
>=20
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D831998

I think the problem is not so much with tmpfs itself, as with tmpfs
defaulting to a smaller size (half of RAM) of filesystem than would
be common on disk.  You would see the same problems with a 3.7G
disk partition mounted on /tmp; but tmpfs is easier to resize.

Looks like it didn't need much more space, try
$ sudo mount -o remount,size=3D4G /tmp

Or, perhaps it's just that something else left its forgotten junk
behind in /tmp, and you need to do some cleanup.

>=20
>=20
> On bringing this bug, and the topic of "TMPDIR on tmpfs" on Debian-Devel,
> there's one comment which wasn't clear to me. Hence this email to you.
>=20
> Even in the description below about tmpfs, it says, "..... to accommodate=
 the
> files it contains and is able to swap unneeded pages out to swap space."

It writes of growing and shrinking there, to distinguish the behavior of
tmpfs from that of the original ramdisks we had in v2.4: where the maximum
RAM was assigned to them at startup IIRC.  Then ramdisks were changed to
allocate on demand during v2.6.  But ramdisks have never used swap, so
cannot shrink their RAM use after it has been allocated.

And yes, it is confusing to write of growing and shrinking, when this
growth and shrinkage in RAM use makes no difference to the filesystem
size itself: that limit remains the same throughout, unless you choose
to change it with a remount, as suggested above.

>=20
> When we say "swap unneeded pages out to swap space", as I understand, wha=
t is
> being referred as "Swappable" here is any process in the kernel's namespa=
ce. And
> not referring to processes associated with /tmp ? Because those mostly wi=
ll be
> active processes.

No, it's not talking about processes there.  Under memory pressure
page reclaim uses swap for storing pages of process anonymous memory,
and for storing pages of tmpfs file memory, until it's needed in RAM again.
Similar mechanism is used for paging in both cases, and all these pages are
tracked on the same lists, but processes and files are swapped independentl=
y.

>=20
> The way I observed, it looks like whatever "/tmp on tmpfs" is capped at, =
from
> the VFS point of view, is the standard limit for processes accessing file=
s in
> /tmp. And that file system view and limitations won't change (in effect t=
o other
> processes being swapped or not).

Correct, the use of swap does not affect the filesystem size limit at all.

Hugh

>=20
> Consider this example:
>=20
> rrs@chutzpah:~$ df -h /tmp/
> Filesystem=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Size=C2=A0=C2=A0Used Avail =
Use% Mounted on
> tmpfs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03.=
7G=C2=A0=C2=A03.7M=C2=A0=C2=A03.7G=C2=A0=C2=A0=C2=A01% /tmp
>=20
> rrs@chutzpah:~$ dd if=3D/dev/zero of=3D/tmp/foo.img bs=3D1M count=3D4000
> dd: error writing '/tmp/foo.img': No space left on device
> 3691+0 records in
> 3690+0 records out
> 3869605888 bytes (3.9 GB, 3.6 GiB) copied, 1.12808 s, 3.4 GB/s
>=20
> rrs@chutzpah:~$ free -m
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0total=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0used=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0free=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0shared=C2=A0=C2=A0buff/cache=C2=A0=C2=A0=C2=A0available
> Mem:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0738=
7=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01882=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A04396=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0213=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01108=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04991
> Swap:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A08579=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0109=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A08470 =C2=A0
>=20
>=20
> Here's the description of tmpfs from the latest
> linux/Documentation/filesystems/tmpfs.txt
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Tmpfs is a file system which keeps all files in virtual memory.
>=20
>=20
> Everything in tmpfs is temporary in the sense that no files will be
> created on your hard drive. If you unmount a tmpfs instance,
> everything stored therein is lost.
>=20
> tmpfs puts everything into the kernel internal caches and grows and
> shrinks to accommodate the files it contains and is able to swap
> unneeded pages out to swap space. It has maximum size limits which can
> be adjusted on the fly via 'mount -o remount ...'
>=20
> If you compare it to ramfs (which was the template to create tmpfs)
> you gain swapping and limit checking. Another similar thing is the RAM
> disk (/dev/ram*), which simulates a fixed size hard disk in physical
> RAM, where you have to create an ordinary filesystem on top. Ramdisks
> cannot swap and you do not have the possibility to resize them.=C2=A0
>=20
> Since tmpfs lives completely in the page cache and on swap, all tmpfs
> pages will be shown as "Shmem" in /proc/meminfo and "Shared" in
> free(1). Notice that these counters also include shared memory
> (shmem, see ipcs(1)). The most reliable way to get the count is
> using df(1) and du(1).
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - --=20
> Ritesh Raj Sarraf | http://people.debian.org/~rrs
> Debian - The Universal Operating System
> -----BEGIN PGP SIGNATURE-----
>=20
> iQIcBAEBCgAGBQJXlQsoAAoJEKY6WKPy4XVpgCQP/RRaH8IGhUTQdjF8ao00rPXu
> RPo6ORs03Xn8E6zBP9qZbc2zv0FKTBzM9daTyLDRLzTaF91/eOlR6NQk0Gi6B+66
> RO2j7/F4OXs/Axp9Yx8LU0aTUt/A9MV8ugqPaaPRgfgVhdwPVD3zi5pP0uZAwpub
> fGicjop5vB+lv6PePioDRVOous9eomlI374PF6rP6kE2MSQSqbc+Yw4g8MC7SGZX
> Xja6OwOvGQTFkbQiT0M4BOjfKEM5S6BI4Vr7R/m4ivkDCj/dJONXQ05Escc8zDuQ
> yI5Rv39psWDxqTqnSPbENbSNTKw8KbswStgQUN66k/JpRQNNl3C+vLA0a5DWB5pQ
> q2mSFp66ynGF6DDhlMZOvHpammhecfZpcbFvGBXikuy193SXZfT+k11FJmSSJiVE
> Q4Tu6JvhADnGpfA07J9PjzV8kRsv9IdAgvFzWUsQeAi8/73ClOl3E7WHkN/zcdvO
> 5UkOne7h5hJjBNZD3pboQ2To9Wc4qeUWsdC8uHPN0h90fLp3oHA1v4JsraQ/MdbS
> yDozCgfZ7s/M4/V20OWJ+LlWohdhkeEHKHtZVabPqXpKSpU5UkvWg458Tnlzct85
> +/WMVztaF3OKsNb+CiSD0nLuLLi7Gu4TxS6JLZQEaJt/+XET7+mXPjou0g0MVg0X
> FGEVOJOwFNtQibJY70Qu
> =3DlCVO
> -----END PGP SIGNATURE-----
>=20
>=20
--0-2062639302-1469391451=:2694--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
