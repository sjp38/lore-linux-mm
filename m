Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 124756B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 10:45:56 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d3so25165153plj.22
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 07:45:56 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0113.outbound.protection.outlook.com. [104.47.32.113])
        by mx.google.com with ESMTPS id n74si28602917pfi.305.2017.12.29.07.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Dec 2017 07:45:54 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Date: Fri, 29 Dec 2017 10:45:46 -0500
Message-ID: <044496C5-5ACD-4845-A7A3-BD920BF9233B@cs.rutgers.edu>
In-Reply-To: <20171229113627.GB27077@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
 <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
 <20171229113627.GB27077@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_968C8C0A-88F7-4A68-B1FC-F6AA0EFDF428_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_968C8C0A-88F7-4A68-B1FC-F6AA0EFDF428_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 29 Dec 2017, at 6:36, Michal Hocko wrote:

> On Tue 26-12-17 21:19:35, Zi Yan wrote:
>> On 8 Dec 2017, at 11:15, Michal Hocko wrote:
> [...]
>>> @@ -1394,6 +1390,21 @@ int migrate_pages(struct list_head *from, new_=
page_t get_new_page,
>>>
>>>  			switch(rc) {
>>>  			case -ENOMEM:
>>> +				/*
>>> +				 * THP migration might be unsupported or the
>>> +				 * allocation could've failed so we should
>>> +				 * retry on the same page with the THP split
>>> +				 * to base pages.
>>> +				 */
>>> +				if (PageTransHuge(page)) {
>>> +					lock_page(page);
>>> +					rc =3D split_huge_page_to_list(page, from);
>>> +					unlock_page(page);
>>> +					if (!rc) {
>>> +						list_safe_reset_next(page, page2, lru);
>>> +						goto retry;
>>> +					}
>>> +				}
>>
>> The hunk splits the THP and adds all tail pages at the end of the list=
 =E2=80=9Cfrom=E2=80=9D.
>> Why do we need =E2=80=9Clist_safe_reset_next(page, page2, lru);=E2=80=9D=
 here, when page2 is not changed here?
>
> Because we need to handle the case when the page2 was the last on the
> list.

Got it. Thanks for the explanation.

>
>> And it seems a little bit strange to only re-migrate the head page, th=
en come back to all tail
>> pages after migrating the rest of pages in the list =E2=80=9Cfrom=E2=80=
=9D. Is it better to split the THP into
>> a list other than =E2=80=9Cfrom=E2=80=9D and insert the list after =E2=
=80=9Cpage=E2=80=9D, then retry from the split =E2=80=9Cpage=E2=80=9D?
>> Thus, we attempt to migrate all sub pages of the THP after it is split=
=2E
>
> Why does this matter?

Functionally, it does not matter.

This behavior is just less intuitive and a little different from current =
one,
which implicitly preserves its original order of the not-migrated pages
in the =E2=80=9Cfrom=E2=80=9D list, although no one relies on this implic=
it behavior now.

Adding one line comment about this difference would be good for code main=
tenance. :)

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_968C8C0A-88F7-4A68-B1FC-F6AA0EFDF428_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlpGYyoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzCq7B/9XVb6Em/umlP4zwIkYM/rCC+F+
tPdL8LJbfJ01tgVA6MGCe/AUT2Sk8acW39TC0IpUjTUJ6y01dboSK1sEuJU/8sBf
as7V/AAHEX6v86aP4Yv3hIlwcmT4Fpwstd0EMqGexS3xYiChM2oSHSOjgvUYo97+
EnUfgY/KUICs8qANdlz6lxeg4IMrnyghgRoXYHaV5MbGaWXk7INMtenluWsD3DL5
HlJMjPOqdFyyfvS/P8S3ntv2bsm3LyfY6XYI6qL3byGL51aJtvB99fmiTyp/8nBI
IfiARMg1oHo9qL2ln/8OCPd/Hm4rEbhVzT2aL+ivyTQObTGFA3Val/F10DJ3
=9pEm
-----END PGP SIGNATURE-----

--=_MailMate_968C8C0A-88F7-4A68-B1FC-F6AA0EFDF428_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
