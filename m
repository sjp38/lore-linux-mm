Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1656B007B
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:55:34 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so13354507wib.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:55:34 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id gh11si6247511wjc.11.2015.06.12.02.55.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 02:55:33 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so13388181wiw.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:55:32 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/6] mm, compaction: more robust check for scanners meeting
In-Reply-To: <1433928754-966-2-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-2-git-send-email-vbabka@suse.cz>
Date: Fri, 12 Jun 2015 11:55:29 +0200
Message-ID: <xa1ttwudp7xq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10 2015, Vlastimil Babka wrote:
> Compaction should finish when the migration and free scanner meet, i.e. t=
hey
> reach the same pageblock. Currently however, the test in compact_finished=
()
> simply just compares the exact pfns, which may yield a false negative whe=
n the
> free scanner position is in the middle of a pageblock and the migration s=
canner
> reaches the beginning of the same pageblock.
>
> This hasn't been a problem until commit e14c720efdd7 ("mm, compaction: re=
member
> position within pageblock in free pages scanner") allowed the free scanner
> position to be in the middle of a pageblock between invocations.  The hot=
-fix
> 1d5bfe1ffb5b ("mm, compaction: prevent infinite loop in compact_zone")
> prevented the issue by adding a special check in the migration scanner to
> satisfy the current detection of scanners meeting.
>
> However, the proper fix is to make the detection more robust. This patch
> introduces the compact_scanners_met() function that returns true when the=
 free
> scanner position is in the same or lower pageblock than the migration sca=
nner.
> The special case in isolate_migratepages() introduced by 1d5bfe1ffb5b is
> removed.
>
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
> index 16e1b57..d46aaeb 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -902,6 +902,16 @@ static bool suitable_migration_target(struct page *p=
age)
>  }
>=20=20
>  /*
> + * Test whether the free scanner has reached the same or lower pageblock=
 than
> + * the migration scanner, and compaction should thus terminate.
> + */
> +static inline bool compact_scanners_met(struct compact_control *cc)
> +{
> +	return (cc->free_pfn >> pageblock_order)
> +		<=3D (cc->migrate_pfn >> pageblock_order);
> +}
> +
> +/*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
>   */
> @@ -1131,12 +1141,8 @@ static isolate_migrate_t isolate_migratepages(stru=
ct zone *zone,
>  	}
>=20=20
>  	acct_isolated(zone, cc);
> -	/*
> -	 * Record where migration scanner will be restarted. If we end up in
> -	 * the same pageblock as the free scanner, make the scanners fully
> -	 * meet so that compact_finished() terminates compaction.
> -	 */
> -	cc->migrate_pfn =3D (end_pfn <=3D cc->free_pfn) ? low_pfn : cc->free_pf=
n;
> +	/* Record where migration scanner will be restarted. */
> +	cc->migrate_pfn =3D low_pfn;
>=20=20
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
> @@ -1151,7 +1157,7 @@ static int __compact_finished(struct zone *zone, st=
ruct compact_control *cc,
>  		return COMPACT_PARTIAL;
>=20=20
>  	/* Compaction run completes if the migrate and free scanner meet */
> -	if (cc->free_pfn <=3D cc->migrate_pfn) {
> +	if (compact_scanners_met(cc)) {
>  		/* Let the next compaction start anew. */
>  		zone->compact_cached_migrate_pfn[0] =3D zone->zone_start_pfn;
>  		zone->compact_cached_migrate_pfn[1] =3D zone->zone_start_pfn;
> @@ -1380,7 +1386,7 @@ static int compact_zone(struct zone *zone, struct c=
ompact_control *cc)
>  			 * migrate_pages() may return -ENOMEM when scanners meet
>  			 * and we want compact_finished() to detect it
>  			 */
> -			if (err =3D=3D -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
> +			if (err =3D=3D -ENOMEM && !compact_scanners_met(cc)) {
>  				ret =3D COMPACT_PARTIAL;
>  				goto out;
>  			}
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
