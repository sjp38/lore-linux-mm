Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C00556B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:17:54 -0400 (EDT)
Received: by pzk6 with SMTP id 6so144068pzk.1
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 07:17:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270044631-8576-1-git-send-email-user@bob-laptop>
References: <1270044631-8576-1-git-send-email-user@bob-laptop>
Date: Wed, 31 Mar 2010 23:17:48 +0900
Message-ID: <2f11576a1003310717y1fe1aa66p8f92135d5eec29e6@mail.gmail.com>
Subject: Re: [PATCH] __isolate_lru_page: skip unneeded mode check
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2010/3/31 Bob Liu <lliubbo@gmail.com>:
> From: Bob Liu <lliubbo@gmail.com>
>
> Whether mode is ISOLATE_BOTH or not, we should compare
> page_is_file_cache with argument file.
>
> And there is no more need not when checking the active state.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =A0mm/vmscan.c | =A0 =A09 ++-------
> =A01 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0e5f15..34d7e3d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -862,15 +862,10 @@ int __isolate_lru_page(struct page *page, int mode,=
 int file)
> =A0 =A0 =A0 =A0if (!PageLRU(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* When checking the active state, we need to be sure we =
are
> - =A0 =A0 =A0 =A0* dealing with comparible boolean values. =A0Take the lo=
gical not
> - =A0 =A0 =A0 =A0* of each.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (mode !=3D ISOLATE_BOTH && (!PageActive(page) !=3D !mode=
))
> + =A0 =A0 =A0 if (mode !=3D ISOLATE_BOTH && (PageActive(page) !=3D mode))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;

no. please read the comment.

> - =A0 =A0 =A0 if (mode !=3D ISOLATE_BOTH && page_is_file_cache(page) !=3D=
 file)
> + =A0 =A0 =A0 if (page_is_file_cache(page) !=3D file)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;

no. please consider lumpy reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
