Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EB6C76B0081
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 06:07:39 -0400 (EDT)
Received: by wigg3 with SMTP id g3so12333523wig.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:07:39 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id dj8si2500027wib.80.2015.06.12.03.07.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 03:07:38 -0700 (PDT)
Received: by wiga1 with SMTP id a1so12354826wig.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:07:37 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 3/6] mm, compaction: encapsulate resetting cached scanner positions
In-Reply-To: <1433928754-966-4-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-4-git-send-email-vbabka@suse.cz>
Date: Fri, 12 Jun 2015 12:07:35 +0200
Message-ID: <xa1tr3php7dk.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10 2015, Vlastimil Babka wrote:
> Resetting the cached compaction scanner positions is now done implicitly =
in
> __reset_isolation_suitable() and compact_finished(). Encapsulate the
> functionality in a new function reset_cached_positions() and call it expl=
icitly
> where needed.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7e0a814..d334bb3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -207,6 +207,13 @@ static inline bool isolation_suitable(struct compact=
_control *cc,
>  	return !get_pageblock_skip(page);
>  }
>=20=20
> +static void reset_cached_positions(struct zone *zone)
> +{
> +	zone->compact_cached_migrate_pfn[0] =3D zone->zone_start_pfn;
> +	zone->compact_cached_migrate_pfn[1] =3D zone->zone_start_pfn;
> +	zone->compact_cached_free_pfn =3D zone_end_pfn(zone);
> +}
> +
>  /*
>   * This function is called to clear all cached information on pageblocks=
 that
>   * should be skipped for page isolation when the migrate and free page s=
canner
> @@ -218,9 +225,6 @@ static void __reset_isolation_suitable(struct zone *z=
one)
>  	unsigned long end_pfn =3D zone_end_pfn(zone);
>  	unsigned long pfn;
>=20=20
> -	zone->compact_cached_migrate_pfn[0] =3D start_pfn;
> -	zone->compact_cached_migrate_pfn[1] =3D start_pfn;
> -	zone->compact_cached_free_pfn =3D end_pfn;
>  	zone->compact_blockskip_flush =3D false;
>=20=20
>  	/* Walk the zone and mark every pageblock as suitable for isolation */
> @@ -250,8 +254,10 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>  			continue;
>=20=20
>  		/* Only flush if a full compaction finished recently */
> -		if (zone->compact_blockskip_flush)
> +		if (zone->compact_blockskip_flush) {
>  			__reset_isolation_suitable(zone);
> +			reset_cached_positions(zone);
> +		}
>  	}
>  }
>=20=20
> @@ -1164,9 +1170,7 @@ static int __compact_finished(struct zone *zone, st=
ruct compact_control *cc,
>  	/* Compaction run completes if the migrate and free scanner meet */
>  	if (compact_scanners_met(cc)) {
>  		/* Let the next compaction start anew. */
> -		zone->compact_cached_migrate_pfn[0] =3D zone->zone_start_pfn;
> -		zone->compact_cached_migrate_pfn[1] =3D zone->zone_start_pfn;
> -		zone->compact_cached_free_pfn =3D zone_end_pfn(zone);
> +		reset_cached_positions(zone);
>=20=20
>  		/*
>  		 * Mark that the PG_migrate_skip information should be cleared
> @@ -1329,8 +1333,10 @@ static int compact_zone(struct zone *zone, struct =
compact_control *cc)
>  	 * is about to be retried after being deferred. kswapd does not do
>  	 * this reset as it'll reset the cached information when going to sleep.
>  	 */
> -	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
> +	if (compaction_restarting(zone, cc->order) && !current_is_kswapd()) {
>  		__reset_isolation_suitable(zone);
> +		reset_cached_positions(zone);
> +	}
>=20=20
>  	/*
>  	 * Setup to move all movable pages to the end of the zone. Used cached
> --=20
> 2.1.4
>

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
