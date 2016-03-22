Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id C5B546B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:38:37 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id m7so212365624obh.3
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 16:38:37 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id i130si581344oih.53.2016.03.22.16.38.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 16:38:36 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] mm/hugetlb: Introduce hugetlb_bad_size
Date: Tue, 22 Mar 2016 23:36:52 +0000
Message-ID: <20160322233651.GA24819@hori1.linux.bs1.fc.nec.co.jp>
References: <1458640843-13483-1-git-send-email-vaishali.thakkar@oracle.com>
In-Reply-To: <1458640843-13483-1-git-send-email-vaishali.thakkar@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <75FBB824EB65A54C85D7594532551B8C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Mar 22, 2016 at 03:30:43PM +0530, Vaishali Thakkar wrote:
> When any unsupported hugepage size is specified, 'hugepagesz=3D' and
> 'hugepages=3D' should be ignored during command line parsing until any
> supported hugepage size is found. But currently incorrect number of
> hugepages are allocated when unsupported size is specified as it fails
> to ignore the 'hugepages=3D' command.
>=20
> Test case:
>=20
> Note that this is specific to x86 architecture.
>=20
> Boot the kernel with command line option 'hugepagesz=3D256M hugepages=3DX=
'.
> After boot, dmesg output shows that X number of hugepages of the size 2M
> is pre-allocated instead of 0.
>=20
> So, to handle such command line options, introduce new routine
> hugetlb_bad_size. The routine hugetlb_bad_size sets the global variable
> parsed_valid_hugepagesz. We are using parsed_valid_hugepagesz to save the
> state when unsupported hugepagesize is found so that we can ignore the
> 'hugepages=3D' parameters after that and then reset the variable when
> supported hugepage size is found.
>=20
> The routine hugetlb_bad_size can be called while setting 'hugepagesz=3D'
> parameter in an architecture specific code.

> Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>

Maybe parsed_hstate can do what parsed_valid_hugepagesz does, but both
are __initdata so it's not a big deal.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> The patch is having 2 checkpatch.pl warnings. I have just followed
> the current code to maintain consistency. If we decide to silent
> these warnings then may be we should silent those warnings as well.
> I am fine with any option whichever works best for everyone else.=20
> ---
>  include/linux/hugetlb.h |  1 +
>  mm/hugetlb.c            | 14 +++++++++++++-
>  2 files changed, 14 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 7d953c2..e44c578 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -338,6 +338,7 @@ int huge_add_to_page_cache(struct page *page, struct =
address_space *mapping,
>  /* arch callback */
>  int __init alloc_bootmem_huge_page(struct hstate *h);
> =20
> +void __init hugetlb_bad_size(void);
>  void __init hugetlb_add_hstate(unsigned order);
>  struct hstate *size_to_hstate(unsigned long size);
> =20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 06058ea..44fae6a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -51,6 +51,7 @@ __initdata LIST_HEAD(huge_boot_pages);
>  static struct hstate * __initdata parsed_hstate;
>  static unsigned long __initdata default_hstate_max_huge_pages;
>  static unsigned long __initdata default_hstate_size;
> +static bool __initdata parsed_valid_hugepagesz =3D true;
> =20
>  /*
>   * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_=
pages,
> @@ -2659,6 +2660,11 @@ static int __init hugetlb_init(void)
>  subsys_initcall(hugetlb_init);
> =20
>  /* Should be called on processing a hugepagesz=3D... option */
> +void __init hugetlb_bad_size(void)
> +{
> +	parsed_valid_hugepagesz =3D false;
> +}
> +
>  void __init hugetlb_add_hstate(unsigned int order)
>  {
>  	struct hstate *h;
> @@ -2691,11 +2697,17 @@ static int __init hugetlb_nrpages_setup(char *s)
>  	unsigned long *mhp;
>  	static unsigned long *last_mhp;
> =20
> +	if (!parsed_valid_hugepagesz) {
> +		pr_warn("hugepages =3D %s preceded by "
> +			"an unsupported hugepagesz, ignoring\n", s);
> +		parsed_valid_hugepagesz =3D true;
> +		return 1;
> +	}
>  	/*
>  	 * !hugetlb_max_hstate means we haven't parsed a hugepagesz=3D paramete=
r yet,
>  	 * so this hugepages=3D parameter goes to the "default hstate".
>  	 */
> -	if (!hugetlb_max_hstate)
> +	else if (!hugetlb_max_hstate)
>  		mhp =3D &default_hstate_max_huge_pages;
>  	else
>  		mhp =3D &parsed_hstate->max_huge_pages;
> --=20
> 2.1.4
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
