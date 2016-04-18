Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9EF6B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 19:18:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c20so356089526pfc.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 16:18:41 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id dz4si2094189pab.12.2016.04.18.16.18.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 16:18:40 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure: fix race with compound page
 split/merge
Date: Mon, 18 Apr 2016 23:15:52 +0000
Message-ID: <20160418231551.GA18493@hori1.linux.bs1.fc.nec.co.jp>
References: <146097982568.15733.13924990169211134049.stgit@buzz>
In-Reply-To: <146097982568.15733.13924990169211134049.stgit@buzz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4B278F902506DF4D8F83D712A4EAA78F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

# CCed Andrew,

On Mon, Apr 18, 2016 at 02:43:45PM +0300, Konstantin Khlebnikov wrote:
> Get_hwpoison_page() must recheck relation between head and tail pages.
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Looks good to me. Without this recheck, the race causes kernel to pin
an irrelevant page, and finally makes kernel crash for refcount mismcach...

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 78f5f2641b91..ca5acee53b7a 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -888,7 +888,15 @@ int get_hwpoison_page(struct page *page)
>  		}
>  	}
> =20
> -	return get_page_unless_zero(head);
> +	if (get_page_unless_zero(head)) {
> +		if (head =3D=3D compound_head(page))
> +			return 1;
> +
> +		pr_info("MCE: %#lx cannot catch tail\n", page_to_pfn(page));

Recently Chen Yucong replaced the label "MCE:" with "Memory failure:",
but the resolution is trivial, I think.

Thanks,
Naoya Horiguchi

> +		put_page(head);
> +	}
> +
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(get_hwpoison_page);
> =20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
