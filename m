Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 862B36B0073
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 00:58:10 -0500 (EST)
Message-ID: <4F0E76BE.1070806@freescale.com>
Date: Thu, 12 Jan 2012 13:59:26 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : check the watermark when cc->order
 is -1
References: <1325818201-1865-1-git-send-email-b32955@freescale.com>
In-Reply-To: <1325818201-1865-1-git-send-email-b32955@freescale.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, shijie8@gmail.com

=D3=DA 2012=C4=EA01=D4=C206=C8=D5 10:50, Huang Shijie =D0=B4=B5=C0:
> We get cc->order is -1 when user echos to /proc/sys/vm/compact_memory.
> In this case, we should check that if we have enough pages for
> the compaction in the zone.
>
> If we do not check this, in our MX6Q board(arm), i ever observed
> COMPACT_CLUSTER_MAX pages were compaction failed in per migrate_pages()=
.
> Thats mean we can not alloc any pages by the free scanner in the zone.
>
> This patch checks the watermark to avoid this problem.
> Tested this patch in the MX6Q board.
>
> Signed-off-by: Huang Shijie <b32955@freescale.com>
> ---
>  mm/compaction.c |   18 +++++++++---------
>  1 files changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 899d956..bf8e8b2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -479,21 +479,21 @@ unsigned long compaction_suitable(struct zone *zo=
ne, int order)
>  	unsigned long watermark;
> =20
>  	/*
> +	 * Watermarks for order-0 must be met for compaction.
> +	 * During the migration, copies of pages need to be
> +	 * allocated and for a short time, so the footprint is higher.
>  	 * order =3D=3D -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> +	 * /proc/sys/vm/compact_memory.
>  	 */
> -	if (order =3D=3D -1)
> -		return COMPACT_CONTINUE;
> +	watermark =3D low_wmark_pages(zone) +
> +		((order =3D=3D -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL << order));
> =20
> -	/*
> -	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
> -	 * This is because during migration, copies of pages need to be
> -	 * allocated and for a short time, the footprint is higher
> -	 */
> -	watermark =3D low_wmark_pages(zone) + (2UL << order);
>  	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>  		return COMPACT_SKIPPED;
> =20
> +	if (order =3D=3D -1)
> +		return COMPACT_CONTINUE;
> +
>  	/*
>  	 * fragmentation index determines if allocation failures are due to
>  	 * low memory or external fragmentation
Is this patch meaningless?
I really think this patch is useful when the zone is nearly full.

Best Regards

Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
