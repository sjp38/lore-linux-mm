Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76E422806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:00:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g74so144493483ioi.4
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 09:00:49 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0091.outbound.protection.outlook.com. [104.47.41.91])
        by mx.google.com with ESMTPS id 22si10699535pfs.104.2017.04.21.09.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 09:00:38 -0700 (PDT)
Message-ID: <58FA2C9C.5030107@cs.rutgers.edu>
Date: Fri, 21 Apr 2017 11:00:28 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v5 09/11] mm: mempolicy: mbind and migrate_pages support
 thp migration
References: <20170420204752.79703-1-zi.yan@sent.com> <20170420204752.79703-10-zi.yan@sent.com> <1ebd80d1-7bb1-db6d-a60c-7f4b7b6afe0f@linux.vnet.ibm.com>
In-Reply-To: <1ebd80d1-7bb1-db6d-a60c-7f4b7b6afe0f@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig205088B714ED82955BB884A6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig205088B714ED82955BB884A6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Anshuman Khandual wrote:
> On 04/21/2017 02:17 AM, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> This patch enables thp migration for mbind(2) and migrate_pages(2).
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
>> ChangeLog v1 -> v2:
>> - support pte-mapped and doubly-mapped thp
>> ---
>>  mm/mempolicy.c | 108 +++++++++++++++++++++++++++++++++++++++++-------=
---------
>>  1 file changed, 79 insertions(+), 29 deletions(-)
>=20
> Snip
>=20
>> @@ -981,7 +1012,17 @@ static struct page *new_node_page(struct page *p=
age, unsigned long node, int **x
>>  	if (PageHuge(page))
>>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>>  					node);
>> -	else
>> +	else if (thp_migration_supported() && PageTransHuge(page)) {
>> +		struct page *thp;
>> +
>> +		thp =3D alloc_pages_node(node,
>> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
>> +			HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>> +	} else
>>  		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
>>  						    __GFP_THISNODE, 0);
>>  }
>> @@ -1147,6 +1188,15 @@ static struct page *new_page(struct page *page,=
 unsigned long start, int **x)
>>  	if (PageHuge(page)) {
>>  		BUG_ON(!vma);
>>  		return alloc_huge_page_noerr(vma, address, 1);
>> +	} else if (thp_migration_supported() && PageTransHuge(page)) {
>> +		struct page *thp;
>> +
>> +		thp =3D alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
>> +					 HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>=20
> GFP flags in both these new page allocation functions should be the sam=
e.
> Does alloc_hugepage_vma() will eventually call page allocation with the=

> following flags.
>=20
> (GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM

Sure. This is equivalent to (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
which I am going to use.

--=20
Best Regards,
Yan Zi


--------------enig205088B714ED82955BB884A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY+iycAAoJEEGLLxGcTqbMyJsH/3PAy8AjdqxW0GcLsg/Cvgm5
+o/dKUWmtCQTdqSTI+RmY/zp+ml3nuyZG7dZKhnrFBsy1691a28xmjVgNpSFs8WP
TdPv361dfIxPprfA57z8lTPVz2KulrIus5IXQEk0b7nckL5CW+4FDwnlZZEtpiYW
5HXErmgsvyMU5tdh2NWk6K1aDTcOtig+5/FBaFLG09rXEkQsb5NuFJXApJgLZscd
GIUpMIpUkQyg+AAcbVVTFzPzlFG9K7v+GPpbUt83dToD1UAS14Ifmi/driraaIAU
UkQWGhBBJzPneXT+t5SuDqZVzZF3yvZaxYnt0jP3cLymYSj5mxKe6MHbs3PlSxY=
=5D4c
-----END PGP SIGNATURE-----

--------------enig205088B714ED82955BB884A6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
