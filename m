Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id BB37D6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:38:25 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 9so18221828iom.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:38:25 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id j138si26628011oih.51.2016.02.16.19.38.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 19:38:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: Fix incorrect proc nr_hugepages value
Date: Wed, 17 Feb 2016 03:37:15 +0000
Message-ID: <20160217033711.GA10835@hori1.linux.bs1.fc.nec.co.jp>
References: <1455651806-25977-1-git-send-email-vaishali.thakkar@oracle.com>
In-Reply-To: <1455651806-25977-1-git-send-email-vaishali.thakkar@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BB082BE15893DC468A25915CDDB2D850@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Feb 17, 2016 at 01:13:26AM +0530, Vaishali Thakkar wrote:
> Currently incorrect default hugepage pool size is reported by proc
> nr_hugepages when number of pages for the default huge page size is
> specified twice.
>=20
> When multiple huge page sizes are supported, /proc/sys/vm/nr_hugepages
> indicates the current number of pre-allocated huge pages of the default
> size. Basically /proc/sys/vm/nr_hugepages displays default_hstate->
> max_huge_pages and after boot time pre-allocation, max_huge_pages should
> equal the number of pre-allocated pages (nr_hugepages).
>=20
> Test case:
>=20
> Note that this is specific to x86 architecture.
>=20
> Boot the kernel with command line option 'default_hugepagesz=3D1G
> hugepages=3DX hugepagesz=3D2M hugepages=3DY hugepagesz=3D1G hugepages=3DZ=
'. After
> boot, 'cat /proc/sys/vm/nr_hugepages' and 'sysctl -a | grep hugepages'
> returns the value X.  However, dmesg output shows that Z huge pages were
> pre-allocated.
>=20
> So, the root cause of the problem here is that the global variable
> default_hstate_max_huge_pages is set if a default huge page size is
> specified (directly or indirectly) on the command line. After the
> command line processing in hugetlb_init, if default_hstate_max_huge_pages
> is set, the value is assigned to default_hstae.max_huge_pages. However,
> default_hstate.max_huge_pages may have already been set based on the
> number of pre-allocated huge pages of default_hstate size.
>=20
> The solution to this problem is if hstate->max_huge_pages is already set
> then it should not set as a result of global max_huge_pages value.
> Basically if the value of the variable hugepages is set multiple times
> on a command line for a specific supported hugepagesize then proc layer
> should consider the last specified value.
>=20
> Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> The patch contains one line over 80 characters as I think limiting that
> line to 80 characters makes code look bit ugly. But if anyone is having
> issue with that then I am fine with limiting it to 80 chracters.
> ---
>  mm/hugetlb.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 06ae13e..01f2b48 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2630,8 +2630,10 @@ static int __init hugetlb_init(void)
>  			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
>  	}
>  	default_hstate_idx =3D hstate_index(size_to_hstate(default_hstate_size)=
);
> -	if (default_hstate_max_huge_pages)
> -		default_hstate.max_huge_pages =3D default_hstate_max_huge_pages;
> +	if (default_hstate_max_huge_pages) {
> +		if (!default_hstate.max_huge_pages)
> +			default_hstate.max_huge_pages =3D default_hstate_max_huge_pages;
> +	}
> =20
>  	hugetlb_init_hstates();
>  	gather_bootmem_prealloc();
> --=20
> 2.1.4
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
