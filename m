Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84BA96B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:19:58 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id s36so16930348otd.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:19:58 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id l17si4405546otb.206.2017.02.09.01.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 01:19:57 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 13/14] mm: migrate: move_pages() supports thp
 migration
Date: Thu, 9 Feb 2017 09:16:56 +0000
Message-ID: <20170209091655.GB15890@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-14-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-14-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <80BC796DC48B7A4C837EB889F0E9D3F1@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Sun, Feb 05, 2017 at 11:12:51AM -0500, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> This patch enables thp migration for move_pages(2).
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/migrate.c | 37 ++++++++++++++++++++++++++++---------
>  1 file changed, 28 insertions(+), 9 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 84181a3668c6..9bcaccb481ac 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1413,7 +1413,17 @@ static struct page *new_page_node(struct page *p, =
unsigned long private,
>  	if (PageHuge(p))
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  					pm->node);
> -	else
> +	else if (thp_migration_supported() && PageTransHuge(p)) {
> +		struct page *thp;
> +
> +		thp =3D alloc_pages_node(pm->node,
> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	} else
>  		return __alloc_pages_node(pm->node,
>  				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
>  }
> @@ -1440,6 +1450,8 @@ static int do_move_page_to_node_array(struct mm_str=
uct *mm,
>  	for (pp =3D pm; pp->node !=3D MAX_NUMNODES; pp++) {
>  		struct vm_area_struct *vma;
>  		struct page *page;
> +		struct page *head;
> +		unsigned int follflags;
> =20
>  		err =3D -EFAULT;
>  		vma =3D find_vma(mm, pp->addr);
> @@ -1447,8 +1459,10 @@ static int do_move_page_to_node_array(struct mm_st=
ruct *mm,
>  			goto set_status;
> =20
>  		/* FOLL_DUMP to ignore special (like zero) pages */
> -		page =3D follow_page(vma, pp->addr,
> -				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
> +		follflags =3D FOLL_GET | FOLL_SPLIT | FOLL_DUMP;

FOLL_SPLIT should be added depending on thp_migration_supported().

Thanks,
Naoya Horiguchi

> +		if (!thp_migration_supported())
> +			follflags |=3D FOLL_SPLIT;
> +		page =3D follow_page(vma, pp->addr, follflags);
> =20
>  		err =3D PTR_ERR(page);
>  		if (IS_ERR(page))
> @@ -1458,7 +1472,6 @@ static int do_move_page_to_node_array(struct mm_str=
uct *mm,
>  		if (!page)
>  			goto set_status;
> =20
> -		pp->page =3D page;
>  		err =3D page_to_nid(page);
> =20
>  		if (err =3D=3D pp->node)
> @@ -1473,16 +1486,22 @@ static int do_move_page_to_node_array(struct mm_s=
truct *mm,
>  			goto put_and_set;
> =20
>  		if (PageHuge(page)) {
> -			if (PageHead(page))
> +			if (PageHead(page)) {
>  				isolate_huge_page(page, &pagelist);
> +				err =3D 0;
> +				pp->page =3D page;
> +			}
>  			goto put_and_set;
>  		}
> =20
> -		err =3D isolate_lru_page(page);
> +		pp->page =3D compound_head(page);
> +		head =3D compound_head(page);
> +		err =3D isolate_lru_page(head);
>  		if (!err) {
> -			list_add_tail(&page->lru, &pagelist);
> -			inc_node_page_state(page, NR_ISOLATED_ANON +
> -					    page_is_file_cache(page));
> +			list_add_tail(&head->lru, &pagelist);
> +			mod_node_page_state(page_pgdat(head),
> +				NR_ISOLATED_ANON + page_is_file_cache(head),
> +				hpage_nr_pages(head));
>  		}
>  put_and_set:
>  		/*
> --=20
> 2.11.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
