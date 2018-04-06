Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 681EF6B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 22:16:58 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w9-v6so19281298plp.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 19:16:58 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0136.outbound.protection.outlook.com. [104.47.42.136])
        by mx.google.com with ESMTPS id q74si7166712pfg.295.2018.04.05.19.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 19:16:57 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH -mm] mm, gup: prevent pmd checking race in
 follow_pmd_mask()
Date: Thu, 05 Apr 2018 22:16:46 -0400
Message-ID: <85E1A3D6-3057-462E-BA93-0B309B223B82@cs.rutgers.edu>
In-Reply-To: <CAC=cRTOjybaa+nEBcagDebGWh9Ty49TkcJkWi+BcqVcu3at2vA@mail.gmail.com>
References: <20180404032257.11422-1-ying.huang@intel.com>
 <65E6BD75-FBA6-43AC-AC5A-B952DE409BC8@cs.rutgers.edu>
 <CAC=cRTOjybaa+nEBcagDebGWh9Ty49TkcJkWi+BcqVcu3at2vA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_C3D63B1E-B77C-4852-9C0E-9DECACD459C0_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_C3D63B1E-B77C-4852-9C0E-9DECACD459C0_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 5 Apr 2018, at 21:57, huang ying wrote:

> On Wed, Apr 4, 2018 at 11:02 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
>> On 3 Apr 2018, at 23:22, Huang, Ying wrote:
>>
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> mmap_sem will be read locked when calling follow_pmd_mask().  But thi=
s
>>> cannot prevent PMD from being changed for all cases when PTL is
>>> unlocked, for example, from pmd_trans_huge() to pmd_none() via
>>> MADV_DONTNEED.  So it is possible for the pmd_present() check in
>>> follow_pmd_mask() encounter a none PMD.  This may cause incorrect
>>> VM_BUG_ON() or infinite loop.  Fixed this via reading PMD entry again=

>>> but only once and checking the local variable and pmd_none() in the
>>> retry loop.
>>>
>>> As Kirill pointed out, with PTL unlocked, the *pmd may be changed
>>> under us, so read it directly again and again may incur weird bugs.
>>> So although using *pmd directly other than pmd_present() checking may=

>>> be safe, it is still better to replace them to read *pmd once and
>>> check the local variable for multiple times.
>>
>> I see you point there. The patch wants to provide a consistent value
>> for all race checks. Specifically, this patch is trying to avoid the i=
nconsistent
>> reads of *pmd for if-statements, which causes problem when both if-con=
dition reads *pmd and
>> the statements inside "if" reads *pmd again and two reads can give dif=
ferent values.
>> Am I right about this?
>
> Yes.
>
>> If yes, the problem can be solved by something like:
>>
>> if (!pmd_present(tmpval =3D *pmd)) {
>>     check tmpval instead of *pmd;
>> }
>>
>> Right?
>
> I think this isn't enough yet.  we need
>
> tmpval =3D READ_ONCE(*pmd);
>
> To prevent compiler to generate code to read *pmd again and again.
> Please check the comments of pmd_none_or_trans_huge_or_clear_bad()
> about barrier.

Got it. And if there is a barrier (implicit or explicit) inside if-statem=
ent, like
pmd_migrationt_entry_wait(mm, pmd), we need to update tmpval with READ_ON=
CE() after the barrier.

The patch looks good to me. Thanks.

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_C3D63B1E-B77C-4852-9C0E-9DECACD459C0_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlrG2I4WHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzFrTB/9SQANqE2gS7RDqLZn8VaaR4URi
M23TPiG6Sruk2AaR1TVMI4MbjdPXJc24sHo1OrVGmpJes8oSOopt5JcOUB+oK+LY
0KACPjKFNjUvBlEaQdcglL757oNWBRd88icNPaXmK7QCZaDs1l6K+idvz/7bOv7D
bhnk/sayjmPKXnw7eJbyKzfay0R3DjG8xBZCMzl7kzw5rNrFcmLSknOhprjqpsme
WeL7Zooi8qdcrKdAsb0VJBQM1tHaMsj1reNnxgCFU7CU5dLXTD6GGxAmyVG+mBr2
9rLQAQDT2uuhZjltQXTblhN9tMV+YRYjSOsrv9aqTWALsY+IJu2a3oTfbLUu
=V7Tj
-----END PGP SIGNATURE-----

--=_MailMate_C3D63B1E-B77C-4852-9C0E-9DECACD459C0_=--
