Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4920E6B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 22:16:20 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id z25-v6so1033162otk.3
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 19:16:20 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id j41-v6si452879otb.287.2018.06.19.19.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 19:16:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: skip invalid pages block at a time in
 zero_resv_unresv
Date: Wed, 20 Jun 2018 02:14:53 +0000
Message-ID: <20180620021452.GA7241@hori1.linux.bs1.fc.nec.co.jp>
References: <20180615155733.1175-1-pasha.tatashin@oracle.com>
In-Reply-To: <20180615155733.1175-1-pasha.tatashin@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5C4BEA7B6AF786479FE83EE4EF287E8D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "willy@infradead.org" <willy@infradead.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "ying.huang@intel.com" <ying.huang@intel.com>

On Fri, Jun 15, 2018 at 11:57:33AM -0400, Pavel Tatashin wrote:
> The role of zero_resv_unavail() is to make sure that every struct page th=
at
> is allocated but is not backed by memory that is accessible by kernel is
> zeroed and not in some uninitialized state.
>=20
> Since struct pages are allocated in blocks (2M pages in x86 case), we can
> skip pageblock_nr_pages at a time, when the first one is found to be
> invalid.
>=20
> This optimization may help since now on x86 every hole in e820 maps
> is marked as reserved in memblock, and thus will go through this function=
.
>=20
> This function is called before sched_clock() is initialized, so I used my
> x86 early boot clock patches to measure the performance improvement.
>=20
> With 1T hole on i7-8700 currently we would take 0.606918s of boot time, b=
ut
> with this optimization 0.001103s.
>=20
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Looks good to me, thanks!

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/page_alloc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100f1e63..94f1b3201735 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6404,8 +6404,11 @@ void __paginginit zero_resv_unavail(void)
>  	pgcnt =3D 0;
>  	for_each_resv_unavail_range(i, &start, &end) {
>  		for (pfn =3D PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
> -			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> +			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
> +				pfn =3D ALIGN_DOWN(pfn, pageblock_nr_pages)
> +					+ pageblock_nr_pages - 1;
>  				continue;
> +			}
>  			mm_zero_struct_page(pfn_to_page(pfn));
>  			pgcnt++;
>  		}
> --=20
> 2.17.1
>=20
> =
