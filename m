Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 739A06B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:43:14 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so51119071pdr.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:43:14 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id nj7si32046923pdb.158.2015.08.10.01.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 01:43:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in
 no-injection case
Date: Mon, 10 Aug 2015 08:35:30 +0000
Message-ID: <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
In-Reply-To: <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <24B41AF21A75A04BA2E3468CB07A92FF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 02:32:31PM +0800, Wanpeng Li wrote:
> Hwpoison injection takes a refcount of target page and another refcount
> of head page of THP if the target page is the tail page of a THP. However=
,
> current code doesn't release the refcount of head page if the THP is not=
=20
> supported to be injected wrt hwpoison filter.=20
>=20
> Fix it by reducing the refcount of head page if the target page is the ta=
il=20
> page of a THP and it is not supported to be injected.
>=20
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
> ---
>  mm/hwpoison-inject.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> index 5015679..c343a45 100644
> --- a/mm/hwpoison-inject.c
> +++ b/mm/hwpoison-inject.c
> @@ -56,6 +56,8 @@ inject:
>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>  put_out:
>  	put_page(p);
> +	if (p !=3D hpage)
> +		put_page(hpage);

Yes, we need this when we inject to a thp tail page and "goto put_out" is
called. But it seems that this code can be called also when injecting error
to a hugetlb tail page and hwpoison_filter() returns non-zero, which is not
expected. Unfortunately simply doing like below

+	if (!PageHuge(p) && p !=3D hpage)
+		put_page(hpage);

doesn't work, because exisiting put_page(p) can release refcount of hugetlb
tail page, while get_hwpoison_page() takes refcount of hugetlb head page.

So I feel that we need put_hwpoison_page() to properly release the refcount
taken by memory error handlers.
I'll post some patch(es) to address this problem this week.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
