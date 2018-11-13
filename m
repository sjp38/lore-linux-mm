Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E65C6B0008
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 02:47:22 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t5-v6so8957694plo.2
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 23:47:22 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id go17si20175942plb.266.2018.11.12.23.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 23:47:20 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix incorrect call put_hwpoison_page()
 when isolate_huge_page() return false
Date: Tue, 13 Nov 2018 07:46:41 +0000
Message-ID: <20181113074641.GA7645@hori1.linux.bs1.fc.nec.co.jp>
References: <CAJtqMcZVQFp8U0aFqrMDD2-UGuLkWYvg3rytcCswnOT_ZMSzjQ@mail.gmail.com>
In-Reply-To: <CAJtqMcZVQFp8U0aFqrMDD2-UGuLkWYvg3rytcCswnOT_ZMSzjQ@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4753732714411E4CAE164C0F4FCE3269@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Nov 13, 2018 at 03:00:09PM +0800, Yongkai Wu wrote:
> when isolate_huge_page() return false,it won't takes a refcount of page,
> if we call put_hwpoison_page() in that case,we may hit the VM_BUG_ON_PAGE=
!
>=20
> Signed-off-by: Yongkai Wu <nic_w@163.com>
> ---
>  mm/memory-failure.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 0cd3de3..ed09f56 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1699,12 +1699,13 @@ static int soft_offline_huge_page(struct page *pa=
ge,
> int flags)
>   unlock_page(hpage);
> =20
>   ret =3D isolate_huge_page(hpage, &pagelist);
> - /*
> - * get_any_page() and isolate_huge_page() takes a refcount each,
> - * so need to drop one here.
> - */
> - put_hwpoison_page(hpage);
> - if (!ret) {
> + if (ret) {
> +        /*
> +          * get_any_page() and isolate_huge_page() takes a refcount each=
,
> +          * so need to drop one here.
> +        */
> + put_hwpoison_page(hpage);
> + } else {

Hi Yongkai,

Although the current code might look odd, it's OK. We have to release
one refcount whether this isolate_huge_page() succeeds or not, because
the put_hwpoison_page() is cancelling the refcount from get_any_page()
which always succeeds when we enter soft_offline_huge_page().

Let's consider that the isolate_huge_page() fails with your patch applied,
then the refcount taken by get_any_page() is never released after returning
from soft_offline_page(). That will lead to memory leak.

I think that current code comment doesn't explaing it well, so if you
like, you can fix the comment.  (If you do that, please check coding style.
scripts/checkpatch.pl will help you.)

Thanks,
Naoya Horiguchi=
