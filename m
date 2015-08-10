Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 25BFE6B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 21:06:53 -0400 (EDT)
Received: by pdco4 with SMTP id o4so65137171pdc.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 18:06:52 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id g3si30536946pdo.21.2015.08.09.18.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 18:06:52 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 2/2] mm/hwpoison: fix fail isolate hugetlbfs page w/
 refcount held
Date: Mon, 10 Aug 2015 01:05:42 +0000
Message-ID: <20150810010542.GA17762@hori1.linux.bs1.fc.nec.co.jp>
References: <1438942602-55614-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP25999BF1F67C167749C58DB80730@phx.gbl>
In-Reply-To: <BLU436-SMTP25999BF1F67C167749C58DB80730@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3FC5F8B8576CEE4B9616EB349061ED73@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Fri, Aug 07, 2015 at 06:16:42PM +0800, Wanpeng Li wrote:
> Hugetlbfs pages will get a refcount in get_any_page() or madvise_hwpoison=
()=20
> if soft offline through madvise. The refcount which held by soft offline=
=20
> path should be released if fail to isolate hugetlbfs pages. This patch fi=
x=20
> it by reducing a refcount for both isolate successfully and failure.
>=20
> Cc: <stable@vger.kernel.org> # 3.9+
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>=20

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 001f1ba..8077b1c 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1557,13 +1557,12 @@ static int soft_offline_huge_page(struct page *pa=
ge, int flags)
>  	unlock_page(hpage);
> =20
>  	ret =3D isolate_huge_page(hpage, &pagelist);
> -	if (ret) {
> -		/*
> -		 * get_any_page() and isolate_huge_page() takes a refcount each,
> -		 * so need to drop one here.
> -		 */
> -		put_page(hpage);
> -	} else {
> +	/*
> +	 * get_any_page() and isolate_huge_page() takes a refcount each,
> +	 * so need to drop one here.
> +	 */
> +	put_page(hpage);
> +	if (!ret) {
>  		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
>  		return -EBUSY;
>  	}
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
