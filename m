Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2C116B0038
	for <linux-mm@kvack.org>; Sun,  9 Apr 2017 21:00:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r203so96857767oib.15
        for <linux-mm@kvack.org>; Sun, 09 Apr 2017 18:00:24 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 9si5727401ota.26.2017.04.09.18.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Apr 2017 18:00:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/softoffline: Add page flag description in error paths
Date: Mon, 10 Apr 2017 00:15:23 +0000
Message-ID: <20170410001522.GA31515@hori1.linux.bs1.fc.nec.co.jp>
References: <20170409023829.10788-1-khandual@linux.vnet.ibm.com>
In-Reply-To: <20170409023829.10788-1-khandual@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8C2EBC6C2C8DB344A9EAED6237A4F4C5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Sun, Apr 09, 2017 at 08:08:29AM +0530, Anshuman Khandual wrote:
> It helps to provide page flag description along with the raw value in
> error paths during soft offline process. From sample experiments
>=20
> Before the patch:
>=20
> [  132.317977] soft offline: 0x6100: migration failed 1, type 3ffff800008=
018
> [  132.359057] soft offline: 0x7400: migration failed 1, type 3ffff800008=
018
>=20
> After the patch:
>=20
> [   87.694325] soft offline: 0x5900: migration failed 1, type 3ffff800008=
018 (uptodate|dirty|head)
> [   87.736273] soft offline: 0x6c00: migration failed 1, type 3ffff800008=
018 (uptodate|dirty|head)
>=20
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Looks good to me, thank you!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 27f7210..fe64d77 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1543,8 +1543,8 @@ static int get_any_page(struct page *page, unsigned=
 long pfn, int flags)
>  		if (ret =3D=3D 1 && !PageLRU(page)) {
>  			/* Drop page reference which is from __get_any_page() */
>  			put_hwpoison_page(page);
> -			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
> -				pfn, page->flags);
> +			pr_info("soft_offline: %#lx: unknown non LRU page type %lx (%pGp)\n",
> +				pfn, page->flags, &page->flags);
>  			return -EIO;
>  		}
>  	}
> @@ -1585,8 +1585,8 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
>  	ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  				MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  	if (ret) {
> -		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> -			pfn, ret, page->flags);
> +		pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
> +			pfn, ret, page->flags, &page->flags);
>  		/*
>  		 * We know that soft_offline_huge_page() tries to migrate
>  		 * only one hugepage pointed to by hpage, so we need not
> @@ -1677,14 +1677,14 @@ static int __soft_offline_page(struct page *page,=
 int flags)
>  			if (!list_empty(&pagelist))
>  				putback_movable_pages(&pagelist);
> =20
> -			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> -				pfn, ret, page->flags);
> +			pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
> +				pfn, ret, page->flags, &page->flags);
>  			if (ret > 0)
>  				ret =3D -EIO;
>  		}
>  	} else {
> -		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type=
 %lx\n",
> -			pfn, ret, page_count(page), page->flags);
> +		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type=
 %lx (%pGp)\n",
> +			pfn, ret, page_count(page), page->flags, &page->flags);
>  	}
>  	return ret;
>  }
> --=20
> 1.8.5.2
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
