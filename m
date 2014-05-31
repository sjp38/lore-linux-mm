Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD466B003C
	for <linux-mm@kvack.org>; Fri, 30 May 2014 20:11:15 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so2242006pbc.14
        for <linux-mm@kvack.org>; Fri, 30 May 2014 17:11:15 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ip15si7676186pac.160.2014.05.30.17.11.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 17:11:14 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id lj1so1170854pab.40
        for <linux-mm@kvack.org>; Fri, 30 May 2014 17:11:14 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma reserved memory when not used
In-Reply-To: <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com> <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 31 May 2014 09:11:07 +0900
Message-ID: <xa1tegzahko4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 28 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> @@ -1143,10 +1223,15 @@ __rmqueue_fallback(struct zone *zone, int order, =
int start_migratetype)
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  						int migratetype)
>  {
> -	struct page *page;
> +	struct page *page =3D NULL;
> +
> +	if (IS_ENABLED(CONFIG_CMA) &&
> +		migratetype =3D=3D MIGRATE_MOVABLE && zone->managed_cma_pages)
> +		page =3D __rmqueue_cma(zone, order);

Come to think of it, I would consider:

	if (=E2=80=A6) {
		page =3D __rmqueue_cma(zone, order);
		if (page)
			goto done
	}

	=E2=80=A6

done:
	trace_mm_page_alloc_zone_locked(page, order, migratetype);
	return page;

>=20=20
>  retry_reserve:
> -	page =3D __rmqueue_smallest(zone, order, migratetype);
> +	if (!page)
> +		page =3D __rmqueue_smallest(zone, order, migratetype);
>=20=20

The above would allow this if statement to go away.

>  	if (unlikely(!page) && migratetype !=3D MIGRATE_RESERVE) {
>  		page =3D __rmqueue_fallback(zone, order, migratetype);

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
