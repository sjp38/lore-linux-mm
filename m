Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B32A36B0311
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:44:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m132so3877788ith.17
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 21:44:01 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 202si2247011itv.105.2017.04.26.21.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 21:44:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 08/11] mm: hwpoison: soft offline supports thp
 migration
Date: Thu, 27 Apr 2017 04:41:13 +0000
Message-ID: <20170427044112.GA18781@hori1.linux.bs1.fc.nec.co.jp>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-9-zi.yan@sent.com>
 <62d7eea3-96c8-3230-3e1b-fdc2bfbea6bd@linux.vnet.ibm.com>
 <58FA2B85.5040904@cs.rutgers.edu>
In-Reply-To: <58FA2B85.5040904@cs.rutgers.edu>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <16528C837D5DBE48BF2753238348F7C9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Zi Yan <zi.yan@sent.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>

On Fri, Apr 21, 2017 at 10:55:49AM -0500, Zi Yan wrote:
>=20
>=20
> Anshuman Khandual wrote:
> > On 04/21/2017 02:17 AM, Zi Yan wrote:
> >> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>
> >> This patch enables thp migration for soft offline.
> >>
> >> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>
> >> ChangeLog: v1 -> v5:
> >> - fix page isolation counting error
> >>
> >> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> >> ---
> >>  mm/memory-failure.c | 35 ++++++++++++++---------------------
> >>  1 file changed, 14 insertions(+), 21 deletions(-)
> >>
> >> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> >> index 9b77476ef31f..23ff02eb3ed4 100644
> >> --- a/mm/memory-failure.c
> >> +++ b/mm/memory-failure.c
> >> @@ -1481,7 +1481,17 @@ static struct page *new_page(struct page *p, un=
signed long private, int **x)
> >>  	if (PageHuge(p))
> >>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
> >>  						   nid);
> >> -	else
> >> +	else if (thp_migration_supported() && PageTransHuge(p)) {
> >> +		struct page *thp;
> >> +
> >> +		thp =3D alloc_pages_node(nid,
> >> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> >=20
> > Why not __GFP_RECLAIM ? Its soft offline path we wait a bit before
> > declaring that THP page cannot be allocated and hence should invoke
> > reclaim methods as well.
>=20
> I am not sure how much effort the kernel wants to put here to soft
> offline a THP. Naoya knows more here.

What I thought at first was that soft offline is not an urgent user
and no need to reclaim (i.e. give a little impact on other thread.)
But that's not a strong opinion, so if you like __GFP_RECLAIM here,
I'm fine about that.

>=20
>=20
> >=20
> >> +			HPAGE_PMD_ORDER);
> >> +		if (!thp)
> >> +			return NULL;
> >> +		prep_transhuge_page(thp);
> >> +		return thp;
> >> +	} else
> >>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> >>  }
> >> =20
> >> @@ -1665,8 +1675,8 @@ static int __soft_offline_page(struct page *page=
, int flags)
> >>  		 * cannot have PAGE_MAPPING_MOVABLE.
> >>  		 */
> >>  		if (!__PageMovable(page))
> >> -			inc_node_page_state(page, NR_ISOLATED_ANON +
> >> -						page_is_file_cache(page));
> >> +			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
> >> +						page_is_file_cache(page), hpage_nr_pages(page));
> >>  		list_add(&page->lru, &pagelist);
> >>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
> >>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
> >> @@ -1689,28 +1699,11 @@ static int __soft_offline_page(struct page *pa=
ge, int flags)
> >>  static int soft_offline_in_use_page(struct page *page, int flags)
> >>  {
> >>  	int ret;
> >> -	struct page *hpage =3D compound_head(page);
> >> -
> >> -	if (!PageHuge(page) && PageTransHuge(hpage)) {
> >> -		lock_page(hpage);
> >> -		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> >> -			unlock_page(hpage);
> >> -			if (!PageAnon(hpage))
> >> -				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(pa=
ge));
> >> -			else
> >> -				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(pag=
e));
> >> -			put_hwpoison_page(hpage);
> >> -			return -EBUSY;
> >> -		}
> >> -		unlock_page(hpage);
> >> -		get_hwpoison_page(page);
> >> -		put_hwpoison_page(hpage);
> >> -	}
> >> =20
> >>  	if (PageHuge(page))
> >>  		ret =3D soft_offline_huge_page(page, flags);
> >>  	else
> >> -		ret =3D __soft_offline_page(page, flags);
> >> +		ret =3D __soft_offline_page(compound_head(page), flags);
> >=20
> > Hmm, what if the THP allocation fails in the new_page() path and
> > we fallback for general page allocation. In that case we will
> > always be still calling with the head page ? Because we dont
> > split the huge page any more.
>=20
> This could be a problem if the user wants to offline a TailPage but due
> to THP allocation failure, the HeadPage is offlined.

Right, "retry with split" part is unfinished, so we need some improvement.

>=20
> It may be better to only soft offline THPs if page =3D=3D
> compound_head(page). If page !=3D compound_head(page), we still split THP=
s
> like before.
>=20
> Because in migrate_pages(), we cannot guarantee any TailPages in that
> THP are migrated (1. THP allocation failure causes THP splitting, then
> only HeadPage is going to be migrated; 2. even if we change existing
> migrate_pages() implementation to add all TailPages to migration list
> instead of LRU list, we still cannot guarantee the TailPage we want to
> migrate is migrated.).
>=20
> Naoya, what do you think?

Maybe soft offline is a special caller of page migration because it
basically wants to migrate only one page, but thp migration still has
a benefit because we can avoid thp split.
So I like that we try thp migration at first, and if it fails we fall
back to split and migrate (only) a raw error page. This should be done
in caller side for soft offline, because it knows where the error page is.

As for generic case (for other migration callers which mainly want to
migrate multiple pages for their purpose,) thp split and retry can be
done in common migration code. After thp split, all subpages are linked
to migration list, then we retry without returning to the caller.
So I think that split_huge_page() can be moved to (for example) for-loop
in migrate_pages().

I tried to write a patch for it last year, but considering vm event
accounting, the patch might be large (~100 lines).

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
