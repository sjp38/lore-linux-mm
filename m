Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6A62C6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:48:38 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so4220090qgf.6
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 09:48:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o6si15484918qac.7.2014.09.15.09.48.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 09:48:33 -0700 (PDT)
Message-ID: <54171829.3090108@redhat.com>
Date: Mon, 15 Sep 2014 18:47:37 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 5/5] mm, shmem: Show location of non-resident shmem
 pages in smaps
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com> <1410791077-5300-6-git-send-email-jmarchan@redhat.com> <20140915162131.GA22768@redhat.com>
In-Reply-To: <20140915162131.GA22768@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="bVD1OPQdIR0iBiXkwXeDAPwH088WoRpcP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bVD1OPQdIR0iBiXkwXeDAPwH088WoRpcP
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/15/2014 06:21 PM, Oleg Nesterov wrote:
> Hi Jerome,
>=20
> Not sure I understand this patch correctly, will try to read it later.
> But a couple of nits/questions anyway,
>=20
> On 09/15, Jerome Marchand wrote:
>>
>> +The ShmXXX lines only appears for shmem mapping. They show the amount=
 of memory
>> +from the mapping that is currently:
>> + - resident in RAM but not mapped into any process (ShmNotMapped)
>=20
> But how can we know that it is not mapped by another process?

Its mapcount is zero.

>=20
> And in fact "not mapped" looks confusing (at least to me).

"Not mapped" as "not present in a page table". It does belong to a
userspace mapping though. I wonder if there is a less ambiguous terminolo=
gy.

> IIUC it is actually
> mapped even by this process, just it never tried to fault these (reside=
nt or
> swapped) pages in. Right?

No these pages are in the page cache. This can happen when the only
process which have accessed these exits or munmap() the mapping.

>=20
>> +void update_shmem_stats(struct mem_size_stats *mss, struct vm_area_st=
ruct *vma,
>> +			pgoff_t pgoff, unsigned long size)
>=20
> static?
>=20
>> +{
>> +	int count =3D 0;
>> +
>> +	switch (shmem_locate(vma, pgoff, &count)) {
>> +	case SHMEM_RESIDENT:
>> +		if (!count)
>> +			mss->shmem_notmapped +=3D size;
>> +		break;
>> +	case SHMEM_SWAP:
>> +		mss->shmem_swap +=3D size;
>> +		break;
>> +	}
>> +}
>=20
> It seems that shmem_locate() and shmem_vma() are only defined if CONFIG=
_SHMEM,
> probably this series needs more ifdef's.

Now I wonder. Did I try to compile this with CONFIG_SHMEM unset?

>=20
> And I am not sure why we ignore SHMEM_SWAPCACHE...

Hugh didn't like it as it is a small and transient value.

Thanks,
Jerome

>=20
> Oleg.
>=20



--bVD1OPQdIR0iBiXkwXeDAPwH088WoRpcP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUFxguAAoJEHTzHJCtsuoC31gH/3FfHNjSV00R8MdgB6PJ0r2D
hVB9Q/mJRjeKF5douSp/cLQposRdWpIxH8UqqhtdYBfQtv8w9v5bENpg3JLWKL/8
tLjFwHFc+GdSV5r/SlzyX+UQPS4YzMcVIlYeI8Lz5A8K/W2VTijYHJLDsRbaTta1
6ZlvGon0JviFV/2fkYUZCKMYPp7JtIErHa2Vj87CcHNDNP5TaceFjxu40EvbKEWw
QWh+OFPKNJZr5SKBvvyWf/dSFFmnJK2u3JhDeYDjclAL/+Xoxh3s8BEMQbTIz7td
ZvjzYnd4Vpmzzb82ZyIBMg5Bgt5UVa7e5L+DmRNzoH8jBFN5O9Jd2SBRyiFqLm0=
=U+SD
-----END PGP SIGNATURE-----

--bVD1OPQdIR0iBiXkwXeDAPwH088WoRpcP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
