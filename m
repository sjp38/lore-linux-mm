Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 056736B00E8
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 12:03:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d858d87f-6e07-4303-a9b3-e41ff93c8080@default>
Date: Wed, 4 Apr 2012 09:03:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging: zsmalloc: fix memory leak
References: <<1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Monday, April 02, 2012 8:14 AM
> To: Greg Kroah-Hartman
> Cc: Nitin Gupta; Dan Magenheimer; Konrad Rzeszutek Wilk; Robert Jennings;=
 Seth Jennings;
> devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org; linux-mm@kvack.=
org
> Subject: [PATCH] staging: zsmalloc: fix memory leak
>=20
> From: Nitin Gupta <ngupta@vflare.org>
>=20
> This patch fixes a memory leak in zsmalloc where the first
> subpage of each zspage is leaked when the zspage is freed.
>=20
> Based on 3.4-rc1.
>=20
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

This is a rather severe memory leak and will affect most
benchmarking anyone does to evaluate zcache in 3.4 (e.g. as
to whether zcache is suitable for promotion), so t'would be nice
to get this patch in for -rc2.  (Note it fixes a "regression"
since it affects zcache only in 3.4+ because the fix is to
the new zsmalloc allocator... so no change to stable trees.)

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |   30 ++++++++++++++++++------=
------
>  1 files changed, 18 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/z=
smalloc/zsmalloc-main.c
> index 09caa4f..917461c 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -267,33 +267,39 @@ static unsigned long obj_idx_to_offset(struct page =
*page,
>  =09return off + obj_idx * class_size;
>  }
>=20
> +static void reset_page(struct page *page)
> +{
> +=09clear_bit(PG_private, &page->flags);
> +=09clear_bit(PG_private_2, &page->flags);
> +=09set_page_private(page, 0);
> +=09page->mapping =3D NULL;
> +=09page->freelist =3D NULL;
> +=09reset_page_mapcount(page);
> +}
> +
>  static void free_zspage(struct page *first_page)
>  {
> -=09struct page *nextp, *tmp;
> +=09struct page *nextp, *tmp, *head_extra;
>=20
>  =09BUG_ON(!is_first_page(first_page));
>  =09BUG_ON(first_page->inuse);
>=20
> -=09nextp =3D (struct page *)page_private(first_page);
> +=09head_extra =3D (struct page *)page_private(first_page);
>=20
> -=09clear_bit(PG_private, &first_page->flags);
> -=09clear_bit(PG_private_2, &first_page->flags);
> -=09set_page_private(first_page, 0);
> -=09first_page->mapping =3D NULL;
> -=09first_page->freelist =3D NULL;
> -=09reset_page_mapcount(first_page);
> +=09reset_page(first_page);
>  =09__free_page(first_page);
>=20
>  =09/* zspage with only 1 system page */
> -=09if (!nextp)
> +=09if (!head_extra)
>  =09=09return;
>=20
> -=09list_for_each_entry_safe(nextp, tmp, &nextp->lru, lru) {
> +=09list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
>  =09=09list_del(&nextp->lru);
> -=09=09clear_bit(PG_private_2, &nextp->flags);
> -=09=09nextp->index =3D 0;
> +=09=09reset_page(nextp);
>  =09=09__free_page(nextp);
>  =09}
> +=09reset_page(head_extra);
> +=09__free_page(head_extra);
>  }
>=20
>  /* Initialize a newly allocated zspage */
> --
> 1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
