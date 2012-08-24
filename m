Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2D18D6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:42:48 -0400 (EDT)
Received: by eeke49 with SMTP id e49so870928eek.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:42:46 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/4] cma: count free CMA pages
In-Reply-To: <1345805120-797-3-git-send-email-b.zolnierkie@samsung.com>
References: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com> <1345805120-797-3-git-send-email-b.zolnierkie@samsung.com>
Date: Fri, 24 Aug 2012 18:42:39 +0200
Message-ID: <xa1twr0o2qdc.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> writes:
> Add NR_FREE_CMA_PAGES counter to be later used for checking watermark
> in __zone_watermark_ok().  For simplicity and to avoid #ifdef hell make
> this counter always available (not only when CONFIG_CMA=3Dy).

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e9bbd7c..e28e506 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -559,6 +559,9 @@ static inline void __free_one_page(struct page *page,
>  			clear_page_guard_flag(buddy);
>  			set_page_private(page, 0);
>  			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> +			if (is_cma_pageblock(page))

Is reading pageblock's type necessary here?  You have migratetype
variable.

> +				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +						      1 << order);
>  		} else {
>  			list_del(&buddy->lru);
>  			zone->free_area[order].nr_free--;
> @@ -674,6 +677,8 @@ static void free_pcppages_bulk(struct zone *zone, int=
 count,
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>  			__free_one_page(page, zone, 0, page_private(page));
>  			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			if (is_cma_pageblock(page))
> +				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);

Like above, I think that checking page_private(page) should be enough.

>  		} while (--to_free && --batch_free && !list_empty(list));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> @@ -688,8 +693,12 @@ static void free_one_page(struct zone *zone, struct =
page *page, int order,
>  	zone->pages_scanned =3D 0;
>=20=20
>  	__free_one_page(page, zone, order, migratetype);
> -	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE) {
>  		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> +		if (is_cma_pageblock(page))

You are reading pageblock's migratetype twice.  Please use temporary
variable.

> +			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +					      1 << order);
> +	}
>  	spin_unlock(&zone->lock);
>  }
>=20=20
> @@ -756,6 +765,11 @@ void __meminit __free_pages_bootmem(struct page *pag=
e, unsigned int order)
>  }
>=20=20
>  #ifdef CONFIG_CMA
> +bool is_cma_pageblock(struct page *page)
> +{
> +	return get_pageblock_migratetype(page) =3D=3D MIGRATE_CMA;
> +}
> +
>  /* Free whole pageblock and set it's migration type to MIGRATE_CMA. */
>  void __init init_cma_reserved_pageblock(struct page *page)
>  {
> @@ -813,6 +827,9 @@ static inline void expand(struct zone *zone, struct p=
age *page,
>  			set_page_private(&page[size], high);
>  			/* Guard pages are not available for any usage */
>  			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
> +			if (is_cma_pageblock(&page[size]))

Like before, why not is_migrate_cma(migratetype)?

> +				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +						      -(1 << high));
>  			continue;
>  		}
>  #endif
> @@ -1414,8 +1434,12 @@ int split_free_page(struct page *page, bool check_=
wmark)
>  	zone->free_area[order].nr_free--;
>  	rmv_page_order(page);
>=20=20
> -	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE) {
>  		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> +		if (is_cma_pageblock(page))
> +			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +					      -(1UL << order));
> +	}

Please use temporary variable. :)

>=20=20
>  	/* Split into individual pages */
>  	set_page_refcounted(page);

> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d210cc8..b8dba12 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -77,11 +77,15 @@ int set_migratetype_isolate(struct page *page)
>  out:
>  	if (!ret) {
>  		unsigned long nr_pages;
> +		int mt =3D get_pageblock_migratetype(page);
>=20=20
>  		set_pageblock_isolate(page);
>  		nr_pages =3D move_freepages_block(zone, page, MIGRATE_ISOLATE);
>=20=20
>  		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
> +		if (mt =3D=3D MIGRATE_CMA)

is_migrate_cma()

> +			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +					      -nr_pages);
>  	}
>=20=20
>  	spin_unlock_irqrestore(&zone->lock, flags);
> @@ -102,6 +106,9 @@ void unset_migratetype_isolate(struct page *page, uns=
igned migratetype)
>  		goto out;
>  	nr_pages =3D move_freepages_block(zone, page, migratetype);
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
> +	if (migratetype =3D=3D MIGRATE_CMA)

is_migrate_cma()

> +		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +				      nr_pages);
>  	restore_pageblock_isolate(page, migratetype);
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQN67/AAoJECBgQBJQdR/0RVQP/03CaKSD/fDr0Rc7DcEfU0RM
P1p/aEgI7pCHkYAH83Gv6vFQrHP0ZvPzVGv1OH9b2B8Ad/UsPj3TnZyvErI37IjF
knkn/ZMf1StW1F9Tb55X1JN9QIZHxvDJHpjpE/src78buLE9zTyEUQsxrcamVAwA
jsn3ReltamP+3eCwNx1twfXBQuDJgZ/X7bdr3MKAfz9MrXVGE/Gsx78fD9GSyAHv
jG7QqSH6qPKEkkwWc7+c0ySiZoDtGhWrx56oWcfdLmr+w6MSFvQH6udSr75GYwCm
dLndzsiQuGP/vGqrpzyZotu449fzxTjR+nDu1jziw+5Rk2otKDXOny6qu6DBZKbe
y4oWuhoQvNtmP30UCIwSQ3BOckmchRSi5G5GKqRX2HHNh24LPXMKbmGX2/H3tg5V
O1lifPHPTa9QrN/EpZ4DY4YPQbRpo4Eq9jqgwvxCwew8dv13Iv/lPuIw6JG996Tk
pLz28CqRZ8T2nKIHUqaSnsyuo1/De1Kg0ZsYIQKHZ8pKovUAtfbtUIMhlabGf7es
OrrVlmBlQyCfmFokooZg6NFQeQ/oT3VU96O7OtJ+FrlDXaJJ7GZOaXO0KX3E4JVt
NTILv5UBhbTAkjc9OaW3BG5UkdAzbjS4SW/FaF6odyzf4d0eZlOuma6zoJXZYzbY
5zOduo7x+fMRieRLPgxJ
=SQsa
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
