Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31A276B0260
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:00:00 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d19so16317937ioc.23
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 01:00:00 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id h7si6652731ita.73.2017.12.22.00.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:59:59 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Date: Fri, 22 Dec 2017 08:58:48 +0000
Message-ID: <7cf6978c-5bf2-cbe4-6f7f-ba09998f482d@ah.jp.nec.com>
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
 <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
 <20171220095328.GG4831@dhcp22.suse.cz>
In-Reply-To: <20171220095328.GG4831@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <65045022CB7D1A42A02B84F592F60FE7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 12/20/2017 06:53 PM, Michal Hocko wrote:
> On Wed 20-12-17 05:33:36, Naoya Horiguchi wrote:
>>
>> On 12/15/2017 06:33 PM, Michal Hocko wrote:
>>> Naoya,
>>> this has passed Mike's review (thanks for that!), you have mentioned
>>> that you can pass this through your testing machinery earlier. While
>>> I've done some testing already I would really appreciate if you could
>>> do that as well. Review would be highly appreciated as well.
>>
>> Sorry for my slow response. I reviewed/tested this patchset and looks
>> good to me overall.
>=20
> No need to feel sorry. This doesn't have an urgent priority. Thanks for
> the review and testing. Can I assume your {Reviewed,Acked}-by or
> Tested-by?
>=20

Yes, I tested again with additional changes below, and hugetlb migration
works fine from mbind(2). Thank you very much for your work.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

for the series.

Thanks,
Naoya Horiguchi

>> I have one comment on the code path from mbind(2).
>> The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
>> calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTe=
mporary(),
>> so hugetlb migration fails when h->surplus_huge_page >=3D h->nr_overcomm=
it_huge_pages.
>=20
> Yes, I am aware of that. I should have been more explicit in the
> changelog. Sorry about that and thanks for pointing it out explicitly.
> To be honest I wasn't really sure what to do about this. The code path
> is really complex and it made my head spin. I fail to see why we have to
> call alloc_huge_page and mess with reservations at all.
>=20
>> I don't think this is a bug, but it would be better if mbind(2) works
>> more similarly with other migration callers like move_pages(2)/migrate_p=
ages(2).
>=20
> If the fix is as easy as the following I will add it to the pile.
> Otherwise I would prefer to do this separately after I find some more
> time to understand the callpath.
> ---
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index e035002d3fb6..08a4af411e25 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -345,10 +345,9 @@ struct huge_bootmem_page {
>  struct page *alloc_huge_page(struct vm_area_struct *vma,
>  				unsigned long addr, int avoid_reserve);
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
> -struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> -				unsigned long addr, int avoid_reserve);
>  struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_ni=
d,
>  				nodemask_t *nmask);
> +struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned lo=
ng address);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapp=
ing,
>  			pgoff_t idx);
> =20
> @@ -526,7 +525,7 @@ struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
>  #define alloc_huge_page_node(h, nid) NULL
>  #define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
> -#define alloc_huge_page_noerr(v, a, r) NULL
> +#define alloc_huge_page_vma(vma, address) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
>  #define hstate_sizelog(s) NULL
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4426c5b23a20..e00deabe6d17 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1672,6 +1672,25 @@ struct page *alloc_huge_page_nodemask(struct hstat=
e *h, int preferred_nid,
>  	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
>  }
> =20
> +/* mempolicy aware migration callback */
> +struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned lo=
ng address)
> +{
> +	struct mempolicy *mpol;
> +	nodemask_t *nodemask;
> +	struct page *page;
> +	struct hstate *h;
> +	gfp_t gfp_mask;
> +	int node;
> +
> +	h =3D hstate_vma(vma);
> +	gfp_mask =3D htlb_alloc_mask(h);
> +	node =3D huge_node(vma, address, gfp_mask, &mpol, &nodemask);
> +	page =3D alloc_huge_page_nodemask(h, node, nodemask);
> +	mpol_cond_put(mpol);
> +
> +	return page;
> +}
> +
>  /*
>   * Increase the hugetlb pool such that it can accommodate a reservation
>   * of size 'delta'.
> @@ -2077,20 +2096,6 @@ struct page *alloc_huge_page(struct vm_area_struct=
 *vma,
>  	return ERR_PTR(-ENOSPC);
>  }
> =20
> -/*
> - * alloc_huge_page()'s wrapper which simply returns the page if allocati=
on
> - * succeeds, otherwise NULL. This function is called from new_vma_page()=
,
> - * where no ERR_VALUE is expected to be returned.
> - */
> -struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> -				unsigned long addr, int avoid_reserve)
> -{
> -	struct page *page =3D alloc_huge_page(vma, addr, avoid_reserve);
> -	if (IS_ERR(page))
> -		page =3D NULL;
> -	return page;
> -}
> -
>  int alloc_bootmem_huge_page(struct hstate *h)
>  	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
>  int __alloc_bootmem_huge_page(struct hstate *h)
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f604b22ebb65..96823fa07f38 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1121,8 +1121,7 @@ static struct page *new_page(struct page *page, uns=
igned long start, int **x)
>  	}
> =20
>  	if (PageHuge(page)) {
> -		BUG_ON(!vma);
> -		return alloc_huge_page_noerr(vma, address, 1);
> +		return alloc_huge_page_vma(vma, address);
>  	} else if (thp_migration_supported() && PageTransHuge(page)) {
>  		struct page *thp;
> =20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
