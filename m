Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DECF6B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:56:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o85so11866468qkh.15
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:56:00 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0118.outbound.protection.outlook.com. [104.47.33.118])
        by mx.google.com with ESMTPS id d19si9893753qtc.150.2017.04.21.08.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 08:55:59 -0700 (PDT)
Message-ID: <58FA2B85.5040904@cs.rutgers.edu>
Date: Fri, 21 Apr 2017 10:55:49 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/11] mm: hwpoison: soft offline supports thp migration
References: <20170420204752.79703-1-zi.yan@sent.com> <20170420204752.79703-9-zi.yan@sent.com> <62d7eea3-96c8-3230-3e1b-fdc2bfbea6bd@linux.vnet.ibm.com>
In-Reply-To: <62d7eea3-96c8-3230-3e1b-fdc2bfbea6bd@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enigC72BC6CAB1D8BE27109B1681"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com
Cc: Zi Yan <zi.yan@sent.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC72BC6CAB1D8BE27109B1681
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Anshuman Khandual wrote:
> On 04/21/2017 02:17 AM, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> This patch enables thp migration for soft offline.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> ChangeLog: v1 -> v5:
>> - fix page isolation counting error
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  mm/memory-failure.c | 35 ++++++++++++++---------------------
>>  1 file changed, 14 insertions(+), 21 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 9b77476ef31f..23ff02eb3ed4 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1481,7 +1481,17 @@ static struct page *new_page(struct page *p, un=
signed long private, int **x)
>>  	if (PageHuge(p))
>>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>>  						   nid);
>> -	else
>> +	else if (thp_migration_supported() && PageTransHuge(p)) {
>> +		struct page *thp;
>> +
>> +		thp =3D alloc_pages_node(nid,
>> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
>=20
> Why not __GFP_RECLAIM ? Its soft offline path we wait a bit before
> declaring that THP page cannot be allocated and hence should invoke
> reclaim methods as well.

I am not sure how much effort the kernel wants to put here to soft
offline a THP. Naoya knows more here.


>=20
>> +			HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>> +	} else
>>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>>  }
>> =20
>> @@ -1665,8 +1675,8 @@ static int __soft_offline_page(struct page *page=
, int flags)
>>  		 * cannot have PAGE_MAPPING_MOVABLE.
>>  		 */
>>  		if (!__PageMovable(page))
>> -			inc_node_page_state(page, NR_ISOLATED_ANON +
>> -						page_is_file_cache(page));
>> +			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
>> +						page_is_file_cache(page), hpage_nr_pages(page));
>>  		list_add(&page->lru, &pagelist);
>>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>> @@ -1689,28 +1699,11 @@ static int __soft_offline_page(struct page *pa=
ge, int flags)
>>  static int soft_offline_in_use_page(struct page *page, int flags)
>>  {
>>  	int ret;
>> -	struct page *hpage =3D compound_head(page);
>> -
>> -	if (!PageHuge(page) && PageTransHuge(hpage)) {
>> -		lock_page(hpage);
>> -		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
>> -			unlock_page(hpage);
>> -			if (!PageAnon(hpage))
>> -				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(pa=
ge));
>> -			else
>> -				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(pag=
e));
>> -			put_hwpoison_page(hpage);
>> -			return -EBUSY;
>> -		}
>> -		unlock_page(hpage);
>> -		get_hwpoison_page(page);
>> -		put_hwpoison_page(hpage);
>> -	}
>> =20
>>  	if (PageHuge(page))
>>  		ret =3D soft_offline_huge_page(page, flags);
>>  	else
>> -		ret =3D __soft_offline_page(page, flags);
>> +		ret =3D __soft_offline_page(compound_head(page), flags);
>=20
> Hmm, what if the THP allocation fails in the new_page() path and
> we fallback for general page allocation. In that case we will
> always be still calling with the head page ? Because we dont
> split the huge page any more.

This could be a problem if the user wants to offline a TailPage but due
to THP allocation failure, the HeadPage is offlined.

It may be better to only soft offline THPs if page =3D=3D
compound_head(page). If page !=3D compound_head(page), we still split THP=
s
like before.

Because in migrate_pages(), we cannot guarantee any TailPages in that
THP are migrated (1. THP allocation failure causes THP splitting, then
only HeadPage is going to be migrated; 2. even if we change existing
migrate_pages() implementation to add all TailPages to migration list
instead of LRU list, we still cannot guarantee the TailPage we want to
migrate is migrated.).

Naoya, what do you think?

--=20
Best Regards,
Yan Zi


--------------enigC72BC6CAB1D8BE27109B1681
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY+iuGAAoJEEGLLxGcTqbMvzgIAKvEJxRsKtww6QWv7C+7Iaqp
s8y48C/efwK5m+krsSLkZ/y3i1q/vBBKndobWY43D0d6EmvDW4o/LsXWXr86Wth/
9j9Gd7Tcw3+wR9vYOpe9faVfjRnT+8jIbdKgxVvVEUbgnpg11tTORXJSjMM2K7QI
I75RZk2Rhh+dB3ylDYymQ66y6fDj+WUvx+rvQcp2NQWAMSXPUIX0Klx4VmyRabsY
v66h8+WT4Oj9kWgIRGPntBvI66XVyIXqVPGVY0wZ9wk97+TYrI+fvFCSkoayIFF5
SH/M1lE50AKdnKx2PpD42MGC3pFzdXmkphnsB7c36wQHHS5TApn9Jaf7G19OsNo=
=c70J
-----END PGP SIGNATURE-----

--------------enigC72BC6CAB1D8BE27109B1681--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
