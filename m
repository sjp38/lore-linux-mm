Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5826B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:40:23 -0400 (EDT)
Received: by mail-oi0-f49.google.com with SMTP id i17so28259405oib.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 16:40:23 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id f5si660776otb.223.2016.03.22.16.40.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 16:40:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] arch:mm: Use hugetlb_bad_size
Date: Tue, 22 Mar 2016 23:38:10 +0000
Message-ID: <20160322233809.GB24819@hori1.linux.bs1.fc.nec.co.jp>
References: <1458641159-13643-1-git-send-email-vaishali.thakkar@oracle.com>
In-Reply-To: <1458641159-13643-1-git-send-email-vaishali.thakkar@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FFF1ABDB1F1E474E9B72297C37B82DAF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Mar 22, 2016 at 03:35:59PM +0530, Vaishali Thakkar wrote:
> Update the setup_hugepagesz function to call the routine
> hugetlb_bad_size when unsupported hugepage size is found.
>=20
> Misc:
>   - Silent 80 characters warning
>=20
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

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> - Please note that the patch is tested for x86 only. But as this
>   is one line change I just changed them. So, it would be good if
>   the patch can be tested for other architectures before adding
>   this in to mainline.
> - Not sure if printk related checkpatch.pl warning should be resolved
>   with this patch as code is not consistent in architectures. May be
>   one separate patch for changing all printk's to pr_<level> kind of
>   debugging functions would be good.
> ---
>  arch/arm64/mm/hugetlbpage.c   | 1 +
>  arch/metag/mm/hugetlbpage.c   | 1 +
>  arch/powerpc/mm/hugetlbpage.c | 7 +++++--
>  arch/tile/mm/hugetlbpage.c    | 7 ++++++-
>  arch/x86/mm/hugetlbpage.c     | 1 +
>  5 files changed, 14 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 589fd28..aa8aee7 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -307,6 +307,7 @@ static __init int setup_hugepagesz(char *opt)
>  	} else if (ps =3D=3D PUD_SIZE) {
>  		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
>  	} else {
> +		hugetlb_bad_size();
>  		pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
>  		return 0;
>  	}
> diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
> index b38700a..db1b7da 100644
> --- a/arch/metag/mm/hugetlbpage.c
> +++ b/arch/metag/mm/hugetlbpage.c
> @@ -239,6 +239,7 @@ static __init int setup_hugepagesz(char *opt)
>  	if (ps =3D=3D (1 << HPAGE_SHIFT)) {
>  		hugetlb_add_hstate(HPAGE_SHIFT - PAGE_SHIFT);
>  	} else {
> +		hugetlb_bad_size();
>  		pr_err("hugepagesz: Unsupported page size %lu M\n",
>  		       ps >> 20);
>  		return 0;
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.=
c
> index 6dd272b..a437ff7 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -772,8 +772,11 @@ static int __init hugepage_setup_sz(char *str)
> =20
>  	size =3D memparse(str, &str);
> =20
> -	if (add_huge_page_size(size) !=3D 0)
> -		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n", size);
> +	if (add_huge_page_size(size) !=3D 0) {
> +		hugetlb_bad_size();
> +		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n",
> +		       size);
> +	}
> =20
>  	return 1;
>  }
> diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
> index e212c64..77ceaa3 100644
> --- a/arch/tile/mm/hugetlbpage.c
> +++ b/arch/tile/mm/hugetlbpage.c
> @@ -308,11 +308,16 @@ static bool saw_hugepagesz;
> =20
>  static __init int setup_hugepagesz(char *opt)
>  {
> +	int rc;
> +
>  	if (!saw_hugepagesz) {
>  		saw_hugepagesz =3D true;
>  		memset(huge_shift, 0, sizeof(huge_shift));
>  	}
> -	return __setup_hugepagesz(memparse(opt, NULL));
> +	rc =3D __setup_hugepagesz(memparse(opt, NULL));
> +	if (rc)
> +		hugetlb_bad_size();
> +	return rc;
>  }
>  __setup("hugepagesz=3D", setup_hugepagesz);
> =20
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 740d7ac..3ec44f8 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -165,6 +165,7 @@ static __init int setup_hugepagesz(char *opt)
>  	} else if (ps =3D=3D PUD_SIZE && cpu_has_gbpages) {
>  		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
>  	} else {
> +		hugetlb_bad_size();
>  		printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
>  			ps >> 20);
>  		return 0;
> --=20
> 2.1.4
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
