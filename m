Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE26C6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 02:50:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so14834151pfy.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 23:50:00 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id i1si2588148pfb.54.2016.05.16.23.49.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 23:49:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
Date: Tue, 17 May 2016 06:41:54 +0000
Message-ID: <20160517064153.GA23930@hori1.linux.bs1.fc.nec.co.jp>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BE4197D1B6AC3943BDC53181DFA1DFA5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> @@ -2579,20 +2612,22 @@ struct page *buffered_rmqueue(struct zone *prefer=
red_zone,
>  		struct list_head *list;
> =20
>  		local_irq_save(flags);
> -		pcp =3D &this_cpu_ptr(zone->pageset)->pcp;
> -		list =3D &pcp->lists[migratetype];
> -		if (list_empty(list)) {
> -			pcp->count +=3D rmqueue_bulk(zone, 0,
> -					pcp->batch, list,
> -					migratetype, cold);
> -			if (unlikely(list_empty(list)))
> -				goto failed;
> -		}
> +		do {
> +			pcp =3D &this_cpu_ptr(zone->pageset)->pcp;
> +			list =3D &pcp->lists[migratetype];
> +			if (list_empty(list)) {
> +				pcp->count +=3D rmqueue_bulk(zone, 0,
> +						pcp->batch, list,
> +						migratetype, cold);
> +				if (unlikely(list_empty(list)))
> +					goto failed;
> +			}
> =20
> -		if (cold)
> -			page =3D list_last_entry(list, struct page, lru);
> -		else
> -			page =3D list_first_entry(list, struct page, lru);
> +			if (cold)
> +				page =3D list_last_entry(list, struct page, lru);
> +			else
> +				page =3D list_first_entry(list, struct page, lru);
> +		} while (page && check_new_pcp(page));

This causes infinite loop when check_new_pcp() returns 1, because the bad
page is still in the list (I assume that a bad page never disappears).
The original kernel is free from this problem because we do retry after
list_del(). So moving the following 3 lines into this do-while block solves
the problem?

    __dec_zone_state(zone, NR_ALLOC_BATCH);
    list_del(&page->lru);                 =20
    pcp->count--;                         =20

There seems no infinit loop issue in order > 0 block below, because bad pag=
es
are deleted from free list in __rmqueue_smallest().

Thanks,
Naoya Horiguchi

> =20
>  		__dec_zone_state(zone, NR_ALLOC_BATCH);
>  		list_del(&page->lru);
> @@ -2605,14 +2640,16 @@ struct page *buffered_rmqueue(struct zone *prefer=
red_zone,
>  		WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
>  		spin_lock_irqsave(&zone->lock, flags);
> =20
> -		page =3D NULL;
> -		if (alloc_flags & ALLOC_HARDER) {
> -			page =3D __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> -			if (page)
> -				trace_mm_page_alloc_zone_locked(page, order, migratetype);
> -		}
> -		if (!page)
> -			page =3D __rmqueue(zone, order, migratetype);
> +		do {
> +			page =3D NULL;
> +			if (alloc_flags & ALLOC_HARDER) {
> +				page =3D __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> +				if (page)
> +					trace_mm_page_alloc_zone_locked(page, order, migratetype);
> +			}
> +			if (!page)
> +				page =3D __rmqueue(zone, order, migratetype);
> +		} while (page && check_new_pages(page, order));
>  		spin_unlock(&zone->lock);
>  		if (!page)
>  			goto failed;
> @@ -2979,8 +3016,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int=
 order, int alloc_flags,
>  		page =3D buffered_rmqueue(ac->preferred_zoneref->zone, zone, order,
>  				gfp_mask, alloc_flags, ac->migratetype);
>  		if (page) {
> -			if (prep_new_page(page, order, gfp_mask, alloc_flags))
> -				goto try_this_zone;
> +			prep_new_page(page, order, gfp_mask, alloc_flags);
> =20
>  			/*
>  			 * If this is a high-order atomic allocation then check
> --=20
> 2.6.4
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
