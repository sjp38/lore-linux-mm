Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9D816B068C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 22:53:15 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id l200-v6so1431193ita.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 19:53:15 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x186-v6si4322865iof.143.2018.11.08.19.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 19:53:14 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] tmpfs: let lseek return ENXIO with a negative offset
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181108150700.f9c321f8853053877d3f3fe6@linux-foundation.org>
Date: Thu, 8 Nov 2018 20:52:50 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E532662D-524A-4F9C-AA6F-0ECB9A39812C@oracle.com>
References: <1540434176-14349-1-git-send-email-yuyufen@huawei.com>
 <20181107151955.777fcbcf9a5932677e245287@linux-foundation.org>
 <EDFDF8C6-F164-4C5A-A5D3-010802D02DC2@oracle.com>
 <20181108150700.f9c321f8853053877d3f3fe6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yufen Yu <yuyufen@huawei.com>, viro@zeniv.linux.org.uk, hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-unionfs@vger.kernel.org


> On Nov 8, 2018, at 4:07 PM, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> I think that at this stage we should make tmpfs behaviour match the
> other filesystems.
>=20
> If the manpage doesn't match the kernel's behaviour for this
> linux-specific feature(?) then we should fix the manpage.
>=20
> If we find that the behaviour should actually change (and there's a =
way
> of doing that in a reasonably back-compatible manner) then let's =
change
> all filesystems and the manpage.
>=20
> OK?

I did a little research, and according to lseek(2):

       SEEK_DATA and SEEK_HOLE are nonstandard extensions also present =
in
       Solaris, FreeBSD, and DragonFly BSD; they are proposed for =
inclusion
       in the next POSIX revision (Issue 8).
=20
I wrote a brief test program that operated on a file of 1024 zeroes and =
found
that on an ext4 file system, lseek(2) matches Solaris' behavior on ZFS:

Solaris/ZFS
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
lseek(3, -1, SEEK_HOLE) error, errno 6 (ENXIO)
lseek(3, 0, SEEK_HOLE) returned 1024
lseek(3, 1, SEEK_HOLE) returned 1024

lseek(3, -1, SEEK_DATA) error, errno 6 (ENXIO)
lseek(3, 0, SEEK_DATA) returned 0
lseek(3, 1, SEEK_DATA) returned 1

Linux/ext4
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
lseek(3, -1, SEEK_HOLE) error, errno 6 (ENXIO)
lseek(3, 0, SEEK_HOLE) returned 1024
lseek(3, 1, SEEK_HOLE) returned 1024

lseek(3, -1, SEEK_DATA) error, errno 6 (ENXIO)
lseek(3, 0, SEEK_DATA) returned 0
lseek(3, 1, SEEK_DATA) returned 1

That validates the xfstest expectations that a negative passed offset =
should
return ENXIO.

I suggest the man page wording be changed to read:

       ENXIO  whence is SEEK_DATA or SEEK_HOLE, and the file offset is =
negative or
              beyond the end of the file.

unless you'd prefer an alternative statement.

Thanks!!=
