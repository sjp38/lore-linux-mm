Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8B78E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 20:22:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so4893175pfe.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 17:22:16 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id f62-v6si3453148pfb.218.2018.09.27.17.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 17:22:14 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 3/3] mm: return zero_resv_unavail optimization
Date: Fri, 28 Sep 2018 00:19:44 +0000
Message-ID: <20180928001944.GA9242@hori1.linux.bs1.fc.nec.co.jp>
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
 <20180925153532.6206-4-msys.mizuma@gmail.com>
In-Reply-To: <20180925153532.6206-4-msys.mizuma@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3A91CF9D70C2E0439334BF262801CB9F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Sep 25, 2018 at 11:35:32AM -0400, Masayoshi Mizuma wrote:
> From: Pavel Tatashin <pavel.tatashin@microsoft.com>
>=20
> When checking for valid pfns in zero_resv_unavail(), it is not necessary =
to
> verify that pfns within pageblock_nr_pages ranges are valid, only the fir=
st
> one needs to be checked. This is because memory for pages are allocated i=
n
> contiguous chunks that contain pageblock_nr_pages struct pages.
>=20
> Signed-off-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

According to convention, review tag is formatted like "Reviewed-by: ...",
Otherwise, looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/page_alloc.c | 46 ++++++++++++++++++++++++++--------------------
>  1 file changed, 26 insertions(+), 20 deletions(-)
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3b9d89e..bd5b7e4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6440,6 +6440,29 @@ void __init free_area_init_node(int nid, unsigned =
long *zones_size,
>  }
> =20
>  #if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
> +
> +/*
> + * Zero all valid struct pages in range [spfn, epfn), return number of s=
truct
> + * pages zeroed
> + */
> +static u64 zero_pfn_range(unsigned long spfn, unsigned long epfn)
> +{
> +	unsigned long pfn;
> +	u64 pgcnt =3D 0;
> +
> +	for (pfn =3D spfn; pfn < epfn; pfn++) {
> +		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
> +			pfn =3D ALIGN_DOWN(pfn, pageblock_nr_pages)
> +				+ pageblock_nr_pages - 1;
> +			continue;
> +		}
> +		mm_zero_struct_page(pfn_to_page(pfn));
> +		pgcnt++;
> +	}
> +
> +	return pgcnt;
> +}
> +
>  /*
>   * Only struct pages that are backed by physical memory are zeroed and
>   * initialized by going through __init_single_page(). But, there are som=
e
> @@ -6455,7 +6478,6 @@ void __init free_area_init_node(int nid, unsigned l=
ong *zones_size,
>  void __init zero_resv_unavail(void)
>  {
>  	phys_addr_t start, end;
> -	unsigned long pfn;
>  	u64 i, pgcnt;
>  	phys_addr_t next =3D 0;
> =20
> @@ -6465,34 +6487,18 @@ void __init zero_resv_unavail(void)
>  	pgcnt =3D 0;
>  	for_each_mem_range(i, &memblock.memory, NULL,
>  			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
> -		if (next < start) {
> -			for (pfn =3D PFN_DOWN(next); pfn < PFN_UP(start); pfn++) {
> -				if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> -					continue;
> -				mm_zero_struct_page(pfn_to_page(pfn));
> -				pgcnt++;
> -			}
> -		}
> +		if (next < start)
> +			pgcnt +=3D zero_pfn_range(PFN_DOWN(next), PFN_UP(start));
>  		next =3D end;
>  	}
> -	for (pfn =3D PFN_DOWN(next); pfn < max_pfn; pfn++) {
> -		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> -			continue;
> -		mm_zero_struct_page(pfn_to_page(pfn));
> -		pgcnt++;
> -	}
> -
> +	pgcnt +=3D zero_pfn_range(PFN_DOWN(next), max_pfn);
> =20
>  	/*
>  	 * Struct pages that do not have backing memory. This could be because
>  	 * firmware is using some of this memory, or for some other reasons.
> -	 * Once memblock is changed so such behaviour is not allowed: i.e.
> -	 * list of "reserved" memory must be a subset of list of "memory", then
> -	 * this code can be removed.
>  	 */
>  	if (pgcnt)
>  		pr_info("Zeroed struct page in unavailable ranges: %lld pages", pgcnt)=
;
> -
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
> =20
> --=20
> 2.18.0
>=20
> =
