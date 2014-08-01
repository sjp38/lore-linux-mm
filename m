Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8637F6B0036
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 10:45:31 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so5810164qgf.7
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 07:45:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u10si15892980qge.63.2014.08.01.07.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 07:45:29 -0700 (PDT)
Message-ID: <53DBA7E3.6000803@redhat.com>
Date: Fri, 01 Aug 2014 16:44:51 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm, shmem: Add shmem swap memory accounting
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-5-git-send-email-jmarchan@redhat.com> <alpine.LSU.2.11.1407312204000.3912@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407312204000.3912@eggly.anvils>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="eVTrdPo9xN7VOjmWB6FO4XAEKfD6WMhmU"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eVTrdPo9xN7VOjmWB6FO4XAEKfD6WMhmU
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/01/2014 07:05 AM, Hugh Dickins wrote:
> On Tue, 22 Jul 2014, Jerome Marchand wrote:
>=20
>> Adds get_mm_shswap() which compute the size of swaped out shmem. It
>> does so by pagewalking the mm and using the new shmem_locate() functio=
n
>> to get the physical location of shmem pages.
>> The result is displayed in the new VmShSw line of /proc/<pid>/status.
>> Use mm_walk an shmem_locate() to account paged out shmem pages.
>>
>> It significantly slows down /proc/<pid>/status acccess speed when
>> there is a big shmem mapping. If that is an issue, we can drop this
>> patch and only display this counter in the inherently slower
>> /proc/<pid>/smaps file (cf. next patch).
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>=20
> Definite NAK to this one.  As you guessed yourself, it is always a
> mistake to add one potentially very slow-to-gather number to a stats
> file showing a group of quickly gathered numbers.

What I was going for, is to have a counter for  shared swap in the same
way I did for VmShm, but I never found a way to do it. The reason I
posted this patch is that I hope than someone will have a better idea.

>=20
> Is there anything you could do instead?  I don't know if it's worth
> the (little) extra mm_struct storage and maintenance, but you could
> add a VmShmSize, which shows that subset of VmSize (total_vm) which
> is occupied by shmem mappings.
>=20
> It's ambiguous what to deduce when VmShm is less than VmShmSize:
> the difference might be swapped out, it might be holes in the sparse
> object, it might be instantiated in the object but never faulted
> into the mapping: in general it will be a mix of all of those.
> So, sometimes useful info, but easy to be misled by it.
>=20
> As I say, I don't know if VmShmSize would be worth adding, given its
> deficiencies; and it could be worked out from /proc/<pid>/maps anyway.

I don't think that would be very useful. Sparse mapping are quite common.=


Jerome

>=20
> Hugh
>=20



--eVTrdPo9xN7VOjmWB6FO4XAEKfD6WMhmU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT26fjAAoJEHTzHJCtsuoC+pUH/1O11EmBxfYoxEFZaFaQ8ISn
axppvsKfJOmeceA1AKkFUdLrnPj2ZDfdlvbczKN6DR5HjsO6dRg8SExU+8SYVlr2
io8QgEjwrrt6yFNNMhmaTob/xGySPCaepA9/YAEPXRewfueMGaCSsRoYfXiaFH/E
QiPeb1/wWCDlvisiiz5vv2NBkPEE2C8/iVDyrE8KmefMvleD7+LovaZOzNhD7DV5
cNQUj3WcVDgkMl6EcEiJS0Oriy/s3Xws31przHnfhyHGNuPhkuFptZZfApOcHn1m
RTbr4LZvft7Kd08mJBIUhPSf+BNKJzHzk32GmiKAz/YAyXiFQp+KWonflCdnyYA=
=6ENS
-----END PGP SIGNATURE-----

--eVTrdPo9xN7VOjmWB6FO4XAEKfD6WMhmU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
