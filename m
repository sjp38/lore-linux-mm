Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 727A46B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 04:11:12 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e79so33631611ioi.6
        for <linux-mm@kvack.org>; Fri, 12 May 2017 01:11:12 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 23si2334767ioc.12.2017.05.12.01.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 01:11:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/madvise: Dont poison entire HugeTLB page for single
 page errors
Date: Fri, 12 May 2017 08:10:01 +0000
Message-ID: <20170512081001.GA13069@hori1.linux.bs1.fc.nec.co.jp>
References: <893ecbd7-e9fa-7a54-fc62-43f8a5b8107f@linux.vnet.ibm.com>
 <20170420110627.12307-1-khandual@linux.vnet.ibm.com>
In-Reply-To: <20170420110627.12307-1-khandual@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <57BB4D2CF3C3E44FA7F709499D589F35@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, Apr 20, 2017 at 04:36:27PM +0530, Anshuman Khandual wrote:
> Currently soft_offline_page() migrates the entire HugeTLB page, then
> dequeues it from the active list by making it a dangling HugeTLB page
> which ofcourse can not be used further and marks the entire HugeTLB
> page as poisoned. This might be a costly waste of memory if the error
> involved affects only small section of the entire page.
>=20
> This changes the behaviour so that only the affected page is marked
> poisoned and then the HugeTLB page is released back to buddy system.

Hi Anshuman,

This is a good catch, and we can solve this issue now because freeing
hwpoisoned page (previously forbidden) is available now.

And I'm thinking that the same issue for hard/soft-offline on free
hugepages can be solved, so I'll submit a patchset which includes
updated version of your patch.

Thanks,
Naoya Horiguchi

>=20
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
> The number of poisoned pages on the system has reduced as seen from
> dmesg triggered with 'echo m > /proc/sysrq-enter' on powerpc.
>=20
>  include/linux/hugetlb.h | 1 +
>  mm/hugetlb.c            | 2 +-
>  mm/memory-failure.c     | 9 ++++-----
>  3 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 7a5917d..f6b80a4 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -470,6 +470,7 @@ static inline pgoff_t basepage_index(struct page *pag=
e)
>  	return __basepage_index(page);
>  }
> =20
> +extern int dissolve_free_huge_page(struct page *page);
>  extern int dissolve_free_huge_pages(unsigned long start_pfn,
>  				    unsigned long end_pfn);
>  static inline bool hugepage_migration_supported(struct hstate *h)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1edfdb8..2fb9ba3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1444,7 +1444,7 @@ static int free_pool_huge_page(struct hstate *h, no=
demask_t *nodes_allowed,
>   * number of free hugepages would be reduced below the number of reserve=
d
>   * hugepages.
>   */
> -static int dissolve_free_huge_page(struct page *page)
> +int dissolve_free_huge_page(struct page *page)
>  {
>  	int rc =3D 0;
> =20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 27f7210..1e377fd 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1597,13 +1597,12 @@ static int soft_offline_huge_page(struct page *pa=
ge, int flags)
>  			ret =3D -EIO;
>  	} else {
>  		/* overcommit hugetlb page will be freed to buddy */
> +		SetPageHWPoison(page);
> +		num_poisoned_pages_inc();
> +
>  		if (PageHuge(page)) {
> -			set_page_hwpoison_huge_page(hpage);
>  			dequeue_hwpoisoned_huge_page(hpage);
> -			num_poisoned_pages_add(1 << compound_order(hpage));
> -		} else {
> -			SetPageHWPoison(page);
> -			num_poisoned_pages_inc();
> +			dissolve_free_huge_page(hpage);
>  		}
>  	}
>  	return ret;
> --=20
> 1.8.5.2
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
