Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 308AF6B02AC
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:49:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f8-v6so1247443qth.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:49:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t188-v6sor18685885qkf.126.2018.11.05.18.48.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 18:48:59 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Date: Mon, 05 Nov 2018 21:48:56 -0500
Message-ID: <7E53DD63-4955-480D-8C0D-EB07E4FF011B@cs.rutgers.edu>
In-Reply-To: <20181106022024.ndn377ze6xljsxkb@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <FC2EB02D-3D05-4A13-A92E-4171B37B15BA@cs.rutgers.edu>
 <20181106022024.ndn377ze6xljsxkb@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_281B8E86-991E-4CD5-A12E-8C9D4D81AEF5_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_281B8E86-991E-4CD5-A12E-8C9D4D81AEF5_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 5 Nov 2018, at 21:20, Daniel Jordan wrote:

> Hi Zi,
>
> On Mon, Nov 05, 2018 at 01:49:14PM -0500, Zi Yan wrote:
>> On 5 Nov 2018, at 11:55, Daniel Jordan wrote:
>>
>> Do you think if it makes sense to use ktask for huge page migration (t=
he data
>> copy part)?
>
> It certainly could.
>
>> I did some experiments back in 2016[1], which showed that migrating on=
e 2MB page
>> with 8 threads could achieve 2.8x throughput of the existing single-th=
readed method.
>> The problem with my parallel page migration patchset at that time was =
that it
>> has no CPU-utilization awareness, which is solved by your patches now.=

>
> Did you run with fewer than 8 threads?  I'd want a bigger speedup than =
2.8x for
> 8, and a smaller thread count might improve thread utilization.

Yes. When migrating one 2MB THP with migrate_pages() system call on a two=
-socket server
with 2 E5-2650 v3 CPUs (10 cores per socket) across two sockets, here are=
 the page migration
throughput numbers:

             throughput       factor
1 thread      2.15 GB/s         1x
2 threads     3.05 GB/s         1.42x
4 threads     4.50 GB/s         2.09x
8 threads     5.98 GB/s         2.78x

>
> It would be nice to multithread at a higher granularity than 2M, too: a=
 range
> of THPs might also perform better than a single page.

Sure. But the kernel currently does not copy multiple pages altogether ev=
en if a range
of THPs is migrated. Page copy function is interleaved with page table op=
erations
for every single page.

I also did some study and modified the kernel to improve this, which I ca=
lled
concurrent page migration in https://lwn.net/Articles/714991/. It further=

improves page migration throughput.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_281B8E86-991E-4CD5-A12E-8C9D4D81AEF5_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvhARgWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzGuXB/0ZamMyImDvdSAnu6bnRamwxFic
UnxPMANlgt8DoHj33w6YPGNPvTLOpYT/23z3PC+p+GSE//6OBGlh92xBYALyynHf
MXdJ/VQPIC0HN8HrUyk5o9UzKDf4v6GJkJb29M0E2wA+XmOj8QOsQ0Hvxeyd7jA0
PAusVkLka9cnSJnACY7qqS7ybirJWeFcPFZx7hOH9U+I7kpwUQMBczv4Mx3ZWX5U
tOF2zTek/bglTVulJZwEm14d7iauZ4FqFQqMVobjSGnhvRvIDq4iJeAw4DaitBd4
e4KUl42KBLZ0Itat+o1uMmKfu4NQF2sXvmhhj+VSIvgs+3HlW//qixG+yDOS
=5hII
-----END PGP SIGNATURE-----

--=_MailMate_281B8E86-991E-4CD5-A12E-8C9D4D81AEF5_=--
