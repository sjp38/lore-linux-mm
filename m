Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 611236B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:48:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x18-v6so2226976wmc.7
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 01:48:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l79-v6si3625766wmg.0.2018.06.27.01.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 01:48:09 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5R8idgn073336
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:48:07 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jv36t2f2m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:48:07 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <frankja@linux.ibm.com>;
	Wed, 27 Jun 2018 09:48:05 +0100
Subject: Re: [PATCH] userfaultfd: hugetlbfs: Fix userfaultfd_huge_must_wait
 pte access
References: <20180626132421.78084-1-frankja@linux.ibm.com>
 <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>
From: Janosch Frank <frankja@linux.ibm.com>
Date: Wed, 27 Jun 2018 10:47:44 +0200
MIME-Version: 1.0
In-Reply-To: <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="EOx6EeNelUcnckrJL4sELenaLgzAW7D4j"
Message-Id: <961dc253-b071-8a72-c046-c23cae377e2c@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, aarcange@redhat.com
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EOx6EeNelUcnckrJL4sELenaLgzAW7D4j
Content-Type: multipart/mixed; boundary="y0PnyKh8xwW8SWzdhueygGCUBDtCbMUus";
 protected-headers="v1"
From: Janosch Frank <frankja@linux.ibm.com>
To: Mike Kravetz <mike.kravetz@oracle.com>, aarcange@redhat.com
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <961dc253-b071-8a72-c046-c23cae377e2c@linux.ibm.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: Fix userfaultfd_huge_must_wait
 pte access
References: <20180626132421.78084-1-frankja@linux.ibm.com>
 <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>
In-Reply-To: <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>

--y0PnyKh8xwW8SWzdhueygGCUBDtCbMUus
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 26.06.2018 19:00, Mike Kravetz wrote:
> On 06/26/2018 06:24 AM, Janosch Frank wrote:
>> Use huge_ptep_get to translate huge ptes to normal ptes so we can
>> check them with the huge_pte_* functions. Otherwise some architectures=

>> will check the wrong values and will not wait for userspace to bring
>> in the memory.
>>
>> Signed-off-by: Janosch Frank <frankja@linux.ibm.com>
>> Fixes: 369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wa=
it for hugepmd ranges")
> Adding linux-mm and Andrew on Cc:
>=20
> Thanks for catching and fixing this.

Sure
I'd be happy if we get less of these problems with time, this one was
rather painful to debug. :)

> I think this needs to be fixed in stable as well.  Correct?  Assuming
> userfaultfd is/can be enabled for impacted architectures.

Correct, it seems I forgot the CC stable...

>=20
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks

> -- Mike Kravetz
>> ---
>>  fs/userfaultfd.c | 12 +++++++-----
>>  1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
>> index 123bf7d516fc..594d192b2331 100644
>> --- a/fs/userfaultfd.c
>> +++ b/fs/userfaultfd.c
>> @@ -222,24 +222,26 @@ static inline bool userfaultfd_huge_must_wait(st=
ruct userfaultfd_ctx *ctx,
>>  					 unsigned long reason)
>>  {
>>  	struct mm_struct *mm =3D ctx->mm;
>> -	pte_t *pte;
>> +	pte_t *ptep, pte;
>>  	bool ret =3D true;
>> =20
>>  	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
>> =20
>> -	pte =3D huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
>> -	if (!pte)
>> +	ptep =3D huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
>> +
>> +	if (!ptep)
>>  		goto out;
>> =20
>>  	ret =3D false;
>> +	pte =3D huge_ptep_get(ptep);
>> =20
>>  	/*
>>  	 * Lockless access: we're in a wait_event so it's ok if it
>>  	 * changes under us.
>>  	 */
>> -	if (huge_pte_none(*pte))
>> +	if (huge_pte_none(pte))
>>  		ret =3D true;
>> -	if (!huge_pte_write(*pte) && (reason & VM_UFFD_WP))
>> +	if (!huge_pte_write(pte) && (reason & VM_UFFD_WP))
>>  		ret =3D true;
>>  out:
>>  	return ret;
>>



--y0PnyKh8xwW8SWzdhueygGCUBDtCbMUus--

--EOx6EeNelUcnckrJL4sELenaLgzAW7D4j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJbM09BAAoJEBcO/8Q8ZEV5i9oQAIqm1ue34kTJFM07C7AD3/H0
FU7fNoU9KCPnqyq9eyS3AWeW/tKu53JtuOn8zEtsExGpv1UkQKxfEmUd5PuOlAam
vdnxGv/xjVwggismVKu27LP39RhspCEPoZG4tGcPOMrCdM/xqE/3QSoSGdRVzab5
g9AykXJ9hOGd73VCBAMTAtVLFEBuqjY+kxlptxM0IuMQfBvltCsdGpncOIkF8UWQ
MiToGV1hF1r/MnOQn8IlkQZu3Ftgsm4Z8sGc3jfON+oad+P2OtaU1vbjMN3l0qW4
V9fWNN2QL7fMpqpV8AXDMYkLTo3iB6+ryd7BAt0Fo0nLt4NIo6eU+A809Wnx62d2
IhkbRpe0raZzDuK93LuhDeSp9Q4Xp597/u5cuIfL+kz2IugekVVc1E0wySZtvYoG
nscene1bQH9OJG7KnfUkEOm8Wpx5b0ys0/oqJgg7uSLaAoH591wgEYBAXZMvtJuD
afzap8+hSaLcyPC6QHMS+juh39YD/P0CVT1MvkOi6SaClKM2AUYH0UJep0BkA5Te
YCq22Qjy5KB8ruXwlgBtIrPxw3ADY9bOjpOglyd4lCoCge08FGaeWrB7t6aPZpjp
oqlcZ15gSMFmg/g7oCe5C7FuCTKwaoYLZU0TmLx2kny78WvrkPOjh6QkchYmpNgw
rY5WahobUYtljzX/yFqN
=8cRD
-----END PGP SIGNATURE-----

--EOx6EeNelUcnckrJL4sELenaLgzAW7D4j--
