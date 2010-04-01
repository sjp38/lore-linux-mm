Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9542B6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:37:38 -0400 (EDT)
Received: by pvg2 with SMTP id 2so369761pvg.14
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 06:37:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270128280-2996-1-git-send-email-lliubbo@gmail.com>
References: <1270128280-2996-1-git-send-email-lliubbo@gmail.com>
Date: Thu, 1 Apr 2010 21:37:30 +0800
Message-ID: <v2ycf18f8341004010637mca686ed6oea7bcef79e00e250@mail.gmail.com>
Subject: Re: [PATCH] __isolate_lru_page:skip unneeded "not"
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 1, 2010 at 9:24 PM, Bob Liu <lliubbo@gmail.com> wrote:
> PageActive(page) will return int 0 or 1, mode is also int 0 or 1,
> they are comparible so "not" is unneeded to be sure to boolean
> values.
> I also collected the ISOLATE_BOTH check together.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 16 +++++-----------
> =C2=A01 files changed, 5 insertions(+), 11 deletions(-)
>

There is a problem, and I have resent one.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0e5f15..46d1d52 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -862,17 +862,11 @@ int __isolate_lru_page(struct page *page, int mode,=
 int file)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageLRU(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* When checking the active state, we need to=
 be sure we are
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* dealing with comparible boolean values. =
=C2=A0Take the logical not
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* of each.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH && (!PageActive(page) !=
=3D !mode))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH && page_is_file_cache(p=
age) !=3D file)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> -
> + =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if((PageActive(page) !=
=3D mode) ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 (page_is_file_cache(page) !=3D file))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * When this function is being called for lump=
y reclaim, we
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * initially look into all LRU pages, active, =
inactive and
> --
> 1.5.6.3
>
>



--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
