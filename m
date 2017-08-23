Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9779E280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:50:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x137so8246167pfd.14
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 00:50:03 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id f23si705399pli.889.2017.08.23.00.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 00:50:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 1/4] mm: madvise: read loop's step size beforehand
 in madvise_inject_error(), prepare for THP support.
Date: Wed, 23 Aug 2017 07:49:36 +0000
Message-ID: <20170823074933.GA3527@hori1.linux.bs1.fc.nec.co.jp>
References: <20170815015216.31827-1-zi.yan@sent.com>
 <20170815015216.31827-2-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-2-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <38E2DBFF1986C04786357EDC7E522137@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zi Yan <zi.yan@cs.rutgers.edu>

On Mon, Aug 14, 2017 at 09:52:13PM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
>=20
> The loop in madvise_inject_error() reads its step size from a page
> after it is soft-offlined. It works because the page is:
> 1) a hugetlb page: the page size does not change;
> 2) a base page: the page size does not change;
> 3) a THP: soft-offline always splits THPs, thus, it is OK to use
>    PAGE_SIZE as step size.
>=20
> It will be a problem when soft-offline supports THP migrations.
> When a THP is migrated without split during soft-offlining, the THP
> is split after migration, thus, before and after soft-offlining page
> sizes do not match. This causes a THP to be unnecessarily soft-lined,
> at most, 511 times, wasting free space.

Hi Zi Yan,

Thank you for the suggestion.

I think that when madvise(MADV_SOFT_OFFLINE) is called with some range
over more than one 4kB page, the caller clearly intends to call
soft_offline_page() over all 4kB pages within the range in order to
simulate the multiple soft-offline events. Please note that the caller
only knows that specific pages are half-broken, and expect that all such
pages are offlined. So the end result should be same, whether the given
range is backed by thp or not.

>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  mm/madvise.c | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 47d8d8a25eae..49f6774db259 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -612,19 +612,22 @@ static long madvise_remove(struct vm_area_struct *v=
ma,
>  static int madvise_inject_error(int behavior,
>  		unsigned long start, unsigned long end)
>  {
> -	struct page *page;
> +	struct page *page =3D NULL;
> +	unsigned long page_size =3D PAGE_SIZE;
> =20
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> =20
> -	for (; start < end; start +=3D PAGE_SIZE <<
> -				compound_order(compound_head(page))) {
> +	for (; start < end; start +=3D page_size) {
>  		int ret;
> =20
>  		ret =3D get_user_pages_fast(start, 1, 0, &page);
>  		if (ret !=3D 1)
>  			return ret;
> =20
> +		page_size =3D (PAGE_SIZE << compound_order(compound_head(page))) -
> +			(PAGE_SIZE * (page - compound_head(page)));
> +

Assigning a value which is not 4kB or some hugepage size into page_size
might be confusing because that's not what the name says. You can introduce
'next' virtual address and ALIGN() might be helpful to calculate it.

Thanks,
Naoya Horiguchi


>  		if (PageHWPoison(page)) {
>  			put_page(page);
>  			continue;
> @@ -637,6 +640,12 @@ static int madvise_inject_error(int behavior,
>  			ret =3D soft_offline_page(page, MF_COUNT_INCREASED);
>  			if (ret)
>  				return ret;
> +			/*
> +			 * Non hugetlb pages either have PAGE_SIZE
> +			 * or are split into PAGE_SIZE
> +			 */
> +			if (!PageHuge(page))
> +				page_size =3D PAGE_SIZE;
>  			continue;
>  		}
>  		pr_info("Injecting memory failure for pfn %#lx at process virtual addr=
ess %#lx\n",
> @@ -645,6 +654,12 @@ static int madvise_inject_error(int behavior,
>  		ret =3D memory_failure(page_to_pfn(page), 0, MF_COUNT_INCREASED);
>  		if (ret)
>  			return ret;
> +		/*
> +		 * Non hugetlb pages either have PAGE_SIZE
> +		 * or are split into PAGE_SIZE
> +		 */
> +		if (!PageHuge(page))
> +			page_size =3D PAGE_SIZE;
>  	}
>  	return 0;
>  }
> --=20
> 2.13.2
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
