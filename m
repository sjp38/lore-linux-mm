Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 367DB6B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 00:55:22 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h72so16888561iod.0
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 21:55:22 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id c76si19753013ioa.132.2017.04.11.21.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 21:55:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH RESEND] mm/madvise: Clean up MADV_SOFT_OFFLINE and
 MADV_HWPOISON
Date: Wed, 12 Apr 2017 04:54:18 +0000
Message-ID: <20170412045418.GA4566@hori1.linux.bs1.fc.nec.co.jp>
References: <20170410082903.8828-1-khandual@linux.vnet.ibm.com>
 <20170410084701.11248-1-khandual@linux.vnet.ibm.com>
In-Reply-To: <20170410084701.11248-1-khandual@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <87C70D7D9EF6CA4DA9DF802437794BE8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, Apr 10, 2017 at 02:17:01PM +0530, Anshuman Khandual wrote:
> This cleans up handling MADV_SOFT_OFFLINE and MADV_HWPOISON called
> through madvise() system call.
>=20
> * madvise_memory_failure() was misleading to accommodate handling of
>   both memory_failure() as well as soft_offline_page() functions.
>   Basically it handles memory error injection from user space which
>   can go either way as memory failure or soft offline. Renamed as
>   madvise_inject_error() instead.
>=20
> * Renamed struct page pointer 'p' to 'page'.
>=20
> * pr_info() was essentially printing PFN value but it said 'page'
>   which was misleading. Made the process virtual address explicit.
>=20
> Before the patch:
>=20
> Soft offlining page 0x15e3e at 0x3fff8c230000
> Soft offlining page 0x1f3 at 0x3fffa0da0000
> Soft offlining page 0x744 at 0x3fff7d200000
> Soft offlining page 0x1634d at 0x3fff95e20000
> Soft offlining page 0x16349 at 0x3fff95e30000
> Soft offlining page 0x1d6 at 0x3fff9e8b0000
> Soft offlining page 0x5f3 at 0x3fff91bd0000
>=20
> Injecting memory failure for page 0x15c8b at 0x3fff83280000
> Injecting memory failure for page 0x16190 at 0x3fff83290000
> Injecting memory failure for page 0x740 at 0x3fff9a2e0000
> Injecting memory failure for page 0x741 at 0x3fff9a2f0000
>=20
> After the patch:
>=20
> Soft offlining pfn 0x1484e at process virtual address 0x3fff883c0000
> Soft offlining pfn 0x1484f at process virtual address 0x3fff883d0000
> Soft offlining pfn 0x14850 at process virtual address 0x3fff883e0000
> Soft offlining pfn 0x14851 at process virtual address 0x3fff883f0000
> Soft offlining pfn 0x14852 at process virtual address 0x3fff88400000
> Soft offlining pfn 0x14853 at process virtual address 0x3fff88410000
> Soft offlining pfn 0x14854 at process virtual address 0x3fff88420000
> Soft offlining pfn 0x1521c at process virtual address 0x3fff6bc70000
>=20
> Injecting memory failure for pfn 0x10fcf at process virtual address 0x3ff=
f86310000
> Injecting memory failure for pfn 0x10fd0 at process virtual address 0x3ff=
f86320000
> Injecting memory failure for pfn 0x10fd1 at process virtual address 0x3ff=
f86330000
> Injecting memory failure for pfn 0x10fd2 at process virtual address 0x3ff=
f86340000
> Injecting memory failure for pfn 0x10fd3 at process virtual address 0x3ff=
f86350000
> Injecting memory failure for pfn 0x10fd4 at process virtual address 0x3ff=
f86360000
> Injecting memory failure for pfn 0x10fd5 at process virtual address 0x3ff=
f86370000
>=20
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> Removed timestamp from the kernel log to reduce the width of the
> commit message. No changes in the code.
>=20
>  mm/madvise.c | 34 ++++++++++++++++++++--------------
>  1 file changed, 20 insertions(+), 14 deletions(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 7a2abf0..efd4721 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -606,34 +606,40 @@ static long madvise_remove(struct vm_area_struct *v=
ma,
>  /*
>   * Error injection support for memory error handling.
>   */
> -static int madvise_hwpoison(int bhv, unsigned long start, unsigned long =
end)
> +static int madvise_inject_error(int behavior,
> +		unsigned long start, unsigned long end)
>  {
> -	struct page *p;
> +	struct page *page;
> +
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> +
>  	for (; start < end; start +=3D PAGE_SIZE <<
> -				compound_order(compound_head(p))) {
> +				compound_order(compound_head(page))) {
>  		int ret;
> =20
> -		ret =3D get_user_pages_fast(start, 1, 0, &p);
> +		ret =3D get_user_pages_fast(start, 1, 0, &page);
>  		if (ret !=3D 1)
>  			return ret;
> =20
> -		if (PageHWPoison(p)) {
> -			put_page(p);
> +		if (PageHWPoison(page)) {
> +			put_page(page);
>  			continue;
>  		}
> -		if (bhv =3D=3D MADV_SOFT_OFFLINE) {
> -			pr_info("Soft offlining page %#lx at %#lx\n",
> -				page_to_pfn(p), start);
> -			ret =3D soft_offline_page(p, MF_COUNT_INCREASED);
> +
> +		if (behavior =3D=3D MADV_SOFT_OFFLINE) {
> +			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
> +						page_to_pfn(page), start);
> +
> +			ret =3D soft_offline_page(page, MF_COUNT_INCREASED);
>  			if (ret)
>  				return ret;
>  			continue;
>  		}
> -		pr_info("Injecting memory failure for page %#lx at %#lx\n",
> -		       page_to_pfn(p), start);
> -		ret =3D memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
> +		pr_info("Injecting memory failure for pfn %#lx at process virtual addr=
ess %#lx\n",
> +						page_to_pfn(page), start);
> +
> +		ret =3D memory_failure(page_to_pfn(page), 0, MF_COUNT_INCREASED);
>  		if (ret)
>  			return ret;
>  	}
> @@ -763,7 +769,7 @@ static int madvise_hwpoison(int bhv, unsigned long st=
art, unsigned long end)
> =20
>  #ifdef CONFIG_MEMORY_FAILURE
>  	if (behavior =3D=3D MADV_HWPOISON || behavior =3D=3D MADV_SOFT_OFFLINE)
> -		return madvise_hwpoison(behavior, start, start+len_in);
> +		return madvise_inject_error(behavior, start, start + len_in);
>  #endif
>  	if (!madvise_behavior_valid(behavior))
>  		return error;
> --=20
> 1.8.5.2
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
