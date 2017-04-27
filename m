Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3553D6B02FA
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:40:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z142so8670093qkz.8
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:40:10 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0090.outbound.protection.outlook.com. [104.47.33.90])
        by mx.google.com with ESMTPS id m20si3412606qta.3.2017.04.27.09.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 09:40:09 -0700 (PDT)
Message-ID: <59021EC1.8070500@cs.rutgers.edu>
Date: Thu, 27 Apr 2017 11:39:29 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/11] mm: hwpoison: soft offline supports thp migration
References: <20170420204752.79703-1-zi.yan@sent.com> <20170420204752.79703-9-zi.yan@sent.com> <62d7eea3-96c8-3230-3e1b-fdc2bfbea6bd@linux.vnet.ibm.com> <58FA2B85.5040904@cs.rutgers.edu> <20170427044112.GA18781@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20170427044112.GA18781@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enigDA12915245F7B5AF1519DADD"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Zi Yan <zi.yan@sent.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDA12915245F7B5AF1519DADD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Naoya Horiguchi wrote:
> On Fri, Apr 21, 2017 at 10:55:49AM -0500, Zi Yan wrote:
>>
>> Anshuman Khandual wrote:
>>> On 04/21/2017 02:17 AM, Zi Yan wrote:
>>>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>>
>>>> This patch enables thp migration for soft offline.
>>>>
>>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>>
>>>> ChangeLog: v1 -> v5:
>>>> - fix page isolation counting error
>>>>
>>>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>>>> ---
>>>>  mm/memory-failure.c | 35 ++++++++++++++---------------------
>>>>  1 file changed, 14 insertions(+), 21 deletions(-)
>>>>
>>>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>>>> index 9b77476ef31f..23ff02eb3ed4 100644
>>>> --- a/mm/memory-failure.c
>>>> +++ b/mm/memory-failure.c
>>>> @@ -1481,7 +1481,17 @@ static struct page *new_page(struct page *p, =
unsigned long private, int **x)
>>>>  	if (PageHuge(p))
>>>>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>>>>  						   nid);
>>>> -	else
>>>> +	else if (thp_migration_supported() && PageTransHuge(p)) {
>>>> +		struct page *thp;
>>>> +
>>>> +		thp =3D alloc_pages_node(nid,
>>>> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
>>> Why not __GFP_RECLAIM ? Its soft offline path we wait a bit before
>>> declaring that THP page cannot be allocated and hence should invoke
>>> reclaim methods as well.
>> I am not sure how much effort the kernel wants to put here to soft
>> offline a THP. Naoya knows more here.
>=20
> What I thought at first was that soft offline is not an urgent user
> and no need to reclaim (i.e. give a little impact on other thread.)
> But that's not a strong opinion, so if you like __GFP_RECLAIM here,
> I'm fine about that.

OK, I will add __GFP_RECLAIM.

>=20
>>
>>>> +			HPAGE_PMD_ORDER);
>>>> +		if (!thp)
>>>> +			return NULL;
>>>> +		prep_transhuge_page(thp);
>>>> +		return thp;
>>>> +	} else
>>>>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>>>>  }
>>>> =20
>>>> @@ -1665,8 +1675,8 @@ static int __soft_offline_page(struct page *pa=
ge, int flags)
>>>>  		 * cannot have PAGE_MAPPING_MOVABLE.
>>>>  		 */
>>>>  		if (!__PageMovable(page))
>>>> -			inc_node_page_state(page, NR_ISOLATED_ANON +
>>>> -						page_is_file_cache(page));
>>>> +			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
>>>> +						page_is_file_cache(page), hpage_nr_pages(page));
>>>>  		list_add(&page->lru, &pagelist);
>>>>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL=
,
>>>>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>>>> @@ -1689,28 +1699,11 @@ static int __soft_offline_page(struct page *=
page, int flags)
>>>>  static int soft_offline_in_use_page(struct page *page, int flags)
>>>>  {
>>>>  	int ret;
>>>> -	struct page *hpage =3D compound_head(page);
>>>> -
>>>> -	if (!PageHuge(page) && PageTransHuge(hpage)) {
>>>> -		lock_page(hpage);
>>>> -		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
>>>> -			unlock_page(hpage);
>>>> -			if (!PageAnon(hpage))
>>>> -				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(=
page));
>>>> -			else
>>>> -				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(p=
age));
>>>> -			put_hwpoison_page(hpage);
>>>> -			return -EBUSY;
>>>> -		}
>>>> -		unlock_page(hpage);
>>>> -		get_hwpoison_page(page);
>>>> -		put_hwpoison_page(hpage);
>>>> -	}
>>>> =20
>>>>  	if (PageHuge(page))
>>>>  		ret =3D soft_offline_huge_page(page, flags);
>>>>  	else
>>>> -		ret =3D __soft_offline_page(page, flags);
>>>> +		ret =3D __soft_offline_page(compound_head(page), flags);
>>> Hmm, what if the THP allocation fails in the new_page() path and
>>> we fallback for general page allocation. In that case we will
>>> always be still calling with the head page ? Because we dont
>>> split the huge page any more.
>> This could be a problem if the user wants to offline a TailPage but du=
e
>> to THP allocation failure, the HeadPage is offlined.
>=20
> Right, "retry with split" part is unfinished, so we need some improveme=
nt.
>=20
>> It may be better to only soft offline THPs if page =3D=3D
>> compound_head(page). If page !=3D compound_head(page), we still split =
THPs
>> like before.
>>
>> Because in migrate_pages(), we cannot guarantee any TailPages in that
>> THP are migrated (1. THP allocation failure causes THP splitting, then=

>> only HeadPage is going to be migrated; 2. even if we change existing
>> migrate_pages() implementation to add all TailPages to migration list
>> instead of LRU list, we still cannot guarantee the TailPage we want to=

>> migrate is migrated.).
>>
>> Naoya, what do you think?
>=20
> Maybe soft offline is a special caller of page migration because it
> basically wants to migrate only one page, but thp migration still has
> a benefit because we can avoid thp split.
> So I like that we try thp migration at first, and if it fails we fall
> back to split and migrate (only) a raw error page. This should be done
> in caller side for soft offline, because it knows where the error page =
is.

Make sense. So when migrate_pages() sees the migrate reason is
MR_MEMORY_FAILURE, it will not split THP when newpage allocation fails.
Then, the soft offline caller will split failed THP and retry migrating
the error subpage. I can do that.

>=20
> As for generic case (for other migration callers which mainly want to
> migrate multiple pages for their purpose,) thp split and retry can be
> done in common migration code. After thp split, all subpages are linked=

> to migration list, then we retry without returning to the caller.
> So I think that split_huge_page() can be moved to (for example) for-loo=
p
> in migrate_pages().
>=20
> I tried to write a patch for it last year, but considering vm event
> accounting, the patch might be large (~100 lines).

Yes. I saw your code on your github. I can pick it up and send it for
review after this patchset is merged, if you are OK with it.


--=20
Best Regards,
Yan Zi


--------------enigDA12915245F7B5AF1519DADD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJZAh7gAAoJEEGLLxGcTqbMQJMH/24BAuvj58FK0lT7boCg8Rpn
hDhVX03QqvcGXU47K3/DCL/SXizE7rOF70AMQcpC/TTL4JLUymE2n+peDB/qjKdl
2oO/UVzo5OwlReb1hziG3wsBZ698BNxjACCd6j8CwXr44JlCFpeD6krcwmhjGjTu
vvs/HOvWJjeHO0sFFpgt4DJO99YxQM4rFMgQzGEF17tFQEbgtRF86ifM8UGlpHkT
8lSQJZ7cQbUR72q9kMi4AEEt1ngyBoGr4YL+non9jIQUGUY47K2ZVeh8qnpFCDPr
ZQLLoKIRiBDcuYIuAUGiliseTCFXAzcYnYjokgjeXe8E1WmqqslMePvjksg40PA=
=2Ci0
-----END PGP SIGNATURE-----

--------------enigDA12915245F7B5AF1519DADD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
