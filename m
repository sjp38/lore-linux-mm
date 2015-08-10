Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03D126B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:18:56 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so21932696pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:18:55 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id o1si19337333pdk.179.2015.08.10.01.18.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 01:18:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] mm/hwpoison: fix fail to split THP w/ refcount held
Date: Mon, 10 Aug 2015 08:10:20 +0000
Message-ID: <20150810081019.GA21282@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
In-Reply-To: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4456CF35B5399B469498D8EFA497E321@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 02:32:30PM +0800, Wanpeng Li wrote:
> THP pages will get a refcount in madvise_hwpoison() w/ MF_COUNT_INCREASED=
=20
> flag, however, the refcount is still held when fail to split THP pages.
>=20
> Fix it by reducing the refcount of THP pages when fail to split THP.
>=20
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

It seems that the same conditional put_page() would be added to
"soft offline: %#lx page already poisoned" branch too, right?

> ---
>  mm/memory-failure.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8077b1c..56b8a71 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1710,6 +1710,8 @@ int soft_offline_page(struct page *page, int flags)
>  		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
>  			pr_info("soft offline: %#lx: failed to split THP\n",
>  				pfn);
> +			if (flags & MF_COUNT_INCREASED)
> +				put_page(page);
>  			return -EBUSY;
>  		}
>  	}
> --=20
> 1.7.1
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
