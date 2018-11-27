Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7D8F6B490D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:33:53 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so12237776pfj.4
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:33:53 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id t130si4100589pgb.521.2018.11.27.08.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:33:52 -0800 (PST)
From: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
Subject: RE: [PATCH v2] makedumpfile: exclude pages that are logically
 offline
Date: Tue, 27 Nov 2018 16:32:07 +0000
Message-ID: <4AE2DC15AC0B8543882A74EA0D43DBEC03561800@BPXM09GP.gisp.nec.co.jp>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100938.5567-1-david@redhat.com>
In-Reply-To: <20181122100938.5567-1-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, kexec-ml <kexec@lists.infradead.org>, "pv-drivers@vmware.com" <pv-drivers@vmware.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Linux marks pages that are logically offline via a page flag (map count).
> Such pages e.g. include pages infated as part of a balloon driver or
> pages that were not actually onlined when onlining the whole section.
>=20
> While the hypervisor usually allows to read such inflated memory, we
> basically read and dump data that is completely irrelevant. Also, this
> might result in quite some overhead in the hypervisor. In addition,
> we saw some problems under Hyper-V, whereby we can crash the kernel by
> dumping, when reading memory of a partially onlined memory segment
> (for memory added by the Hyper-V balloon driver).
>=20
> Therefore, don't read and dump pages that are marked as being logically
> offline.
>=20
> Signed-off-by: David Hildenbrand <david@redhat.com>

Thanks for the v2 update.
I'm going to merge this patch after the kernel patches are merged
and it tests fine with the kernel.

Kazu

> ---
>=20
> v1 -> v2:
> - Fix PAGE_BUDDY_MAPCOUNT_VALUE vs. PAGE_OFFLINE_MAPCOUNT_VALUE
>=20
>  makedumpfile.c | 34 ++++++++++++++++++++++++++++++----
>  makedumpfile.h |  1 +
>  2 files changed, 31 insertions(+), 4 deletions(-)
>=20
> diff --git a/makedumpfile.c b/makedumpfile.c
> index 8923538..a5f2ea9 100644
> --- a/makedumpfile.c
> +++ b/makedumpfile.c
> @@ -88,6 +88,7 @@ mdf_pfn_t pfn_cache_private;
>  mdf_pfn_t pfn_user;
>  mdf_pfn_t pfn_free;
>  mdf_pfn_t pfn_hwpoison;
> +mdf_pfn_t pfn_offline;
>=20
>  mdf_pfn_t num_dumped;
>=20
> @@ -249,6 +250,21 @@ isHugetlb(unsigned long dtor)
>                      && (SYMBOL(free_huge_page) =3D=3D dtor));
>  }
>=20
> +static int
> +isOffline(unsigned long flags, unsigned int _mapcount)
> +{
> +	if (NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE) =3D=3D NOT_FOUND_NUMBER)
> +		return FALSE;
> +
> +	if (flags & (1UL << NUMBER(PG_slab)))
> +		return FALSE;
> +
> +	if (_mapcount =3D=3D (int)NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE))
> +		return TRUE;
> +
> +	return FALSE;
> +}
> +
>  static int
>  is_cache_page(unsigned long flags)
>  {
> @@ -2287,6 +2303,8 @@ write_vmcoreinfo_data(void)
>  	WRITE_NUMBER("PG_hwpoison", PG_hwpoison);
>=20
>  	WRITE_NUMBER("PAGE_BUDDY_MAPCOUNT_VALUE", PAGE_BUDDY_MAPCOUNT_VALUE);
> +	WRITE_NUMBER("PAGE_OFFLINE_MAPCOUNT_VALUE",
> +		     PAGE_OFFLINE_MAPCOUNT_VALUE);
>  	WRITE_NUMBER("phys_base", phys_base);
>=20
>  	WRITE_NUMBER("HUGETLB_PAGE_DTOR", HUGETLB_PAGE_DTOR);
> @@ -2687,6 +2705,7 @@ read_vmcoreinfo(void)
>  	READ_SRCFILE("pud_t", pud_t);
>=20
>  	READ_NUMBER("PAGE_BUDDY_MAPCOUNT_VALUE", PAGE_BUDDY_MAPCOUNT_VALUE);
> +	READ_NUMBER("PAGE_OFFLINE_MAPCOUNT_VALUE", PAGE_OFFLINE_MAPCOUNT_VALUE)=
;
>  	READ_NUMBER("phys_base", phys_base);
>  #ifdef __aarch64__
>  	READ_NUMBER("VA_BITS", VA_BITS);
> @@ -6041,6 +6060,12 @@ __exclude_unnecessary_pages(unsigned long mem_map,
>  		else if (isHWPOISON(flags)) {
>  			pfn_counter =3D &pfn_hwpoison;
>  		}
> +		/*
> +		 * Exclude pages that are logically offline.
> +		 */
> +		else if (isOffline(flags, _mapcount)) {
> +			pfn_counter =3D &pfn_offline;
> +		}
>  		/*
>  		 * Unexcludable page
>  		 */
> @@ -7522,7 +7547,7 @@ write_elf_pages_cyclic(struct cache_data *cd_header=
, struct cache_data *cd_page)
>  	 */
>  	if (info->flag_cyclic) {
>  		pfn_zero =3D pfn_cache =3D pfn_cache_private =3D 0;
> -		pfn_user =3D pfn_free =3D pfn_hwpoison =3D 0;
> +		pfn_user =3D pfn_free =3D pfn_hwpoison =3D pfn_offline =3D 0;
>  		pfn_memhole =3D info->max_mapnr;
>  	}
>=20
> @@ -8804,7 +8829,7 @@ write_kdump_pages_and_bitmap_cyclic(struct cache_da=
ta *cd_header, struct cache_d
>  		 * Reset counter for debug message.
>  		 */
>  		pfn_zero =3D pfn_cache =3D pfn_cache_private =3D 0;
> -		pfn_user =3D pfn_free =3D pfn_hwpoison =3D 0;
> +		pfn_user =3D pfn_free =3D pfn_hwpoison =3D pfn_offline =3D 0;
>  		pfn_memhole =3D info->max_mapnr;
>=20
>  		/*
> @@ -9749,7 +9774,7 @@ print_report(void)
>  	pfn_original =3D info->max_mapnr - pfn_memhole;
>=20
>  	pfn_excluded =3D pfn_zero + pfn_cache + pfn_cache_private
> -	    + pfn_user + pfn_free + pfn_hwpoison;
> +	    + pfn_user + pfn_free + pfn_hwpoison + pfn_offline;
>  	shrinking =3D (pfn_original - pfn_excluded) * 100;
>  	shrinking =3D shrinking / pfn_original;
>=20
> @@ -9763,6 +9788,7 @@ print_report(void)
>  	REPORT_MSG("    User process data pages : 0x%016llx\n", pfn_user);
>  	REPORT_MSG("    Free pages              : 0x%016llx\n", pfn_free);
>  	REPORT_MSG("    Hwpoison pages          : 0x%016llx\n", pfn_hwpoison);
> +	REPORT_MSG("    Offline pages           : 0x%016llx\n", pfn_offline);
>  	REPORT_MSG("  Remaining pages  : 0x%016llx\n",
>  	    pfn_original - pfn_excluded);
>  	REPORT_MSG("  (The number of pages is reduced to %lld%%.)\n",
> @@ -9790,7 +9816,7 @@ print_mem_usage(void)
>  	pfn_original =3D info->max_mapnr - pfn_memhole;
>=20
>  	pfn_excluded =3D pfn_zero + pfn_cache + pfn_cache_private
> -	    + pfn_user + pfn_free + pfn_hwpoison;
> +	    + pfn_user + pfn_free + pfn_hwpoison + pfn_offline;
>  	shrinking =3D (pfn_original - pfn_excluded) * 100;
>  	shrinking =3D shrinking / pfn_original;
>  	total_size =3D info->page_size * pfn_original;
> diff --git a/makedumpfile.h b/makedumpfile.h
> index f02f86d..e3a2b29 100644
> --- a/makedumpfile.h
> +++ b/makedumpfile.h
> @@ -1927,6 +1927,7 @@ struct number_table {
>  	long    PG_hwpoison;
>=20
>  	long	PAGE_BUDDY_MAPCOUNT_VALUE;
> +	long	PAGE_OFFLINE_MAPCOUNT_VALUE;
>  	long	SECTION_SIZE_BITS;
>  	long	MAX_PHYSMEM_BITS;
>  	long    HUGETLB_PAGE_DTOR;
> --
> 2.17.2
>=20
