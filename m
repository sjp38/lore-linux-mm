Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 656386B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 21:41:59 -0500 (EST)
Received: by pzk36 with SMTP id 36so10418108pzk.23
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 18:41:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1266516162-14154-12-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	 <1266516162-14154-12-git-send-email-mel@csn.ul.ie>
Date: Fri, 19 Feb 2010 11:41:56 +0900
Message-ID: <28c262361002181841i5d1dae43vcca460eae6ec0ce@mail.gmail.com>
Subject: Re: [PATCH 11/12] Direct compact when a high-order allocation fails
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 3:02 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> Ordinarily when a high-order allocation fails, direct reclaim is entered =
to
> free pages to satisfy the allocation. =C2=A0With this patch, it is determ=
ined if
> an allocation failed due to external fragmentation instead of low memory
> and if so, the calling process will compact until a suitable page is
> freed. Compaction by moving pages in memory is considerably cheaper than
> paging out to disk and works where there are locked pages or no swap. If
> compaction fails to free a page of a suitable size, then reclaim will
> still occur.
>
> Direct compaction returns as soon as possible. As each block is compacted=
,
> it is checked if a suitable page has been freed and if so, it returns.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> =C2=A0include/linux/compaction.h | =C2=A0 16 +++++-
> =C2=A0include/linux/vmstat.h =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A011=
8 ++++++++++++++++++++++++++++++++++++++++++++
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 2=
6 ++++++++++
> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 15 +++++-
> =C2=A05 files changed, 172 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 6a2eefd..1cf95e2 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,13 +1,25 @@
> =C2=A0#ifndef _LINUX_COMPACTION_H
> =C2=A0#define _LINUX_COMPACTION_H
>
> -/* Return values for compact_zone() */
> +/* Return values for compact_zone() and try_to_compact_pages() */
> =C2=A0#define COMPACT_INCOMPLETE =C2=A0 =C2=A0 0
> -#define COMPACT_COMPLETE =C2=A0 =C2=A0 =C2=A0 1
> +#define COMPACT_PARTIAL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A01
> +#define COMPACT_COMPLETE =C2=A0 =C2=A0 =C2=A0 2
>
> =C2=A0#ifdef CONFIG_COMPACTION
> =C2=A0extern int sysctl_compaction_handler(struct ctl_table *table, int w=
rite,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0void __user *buffer, size_t *length, loff_t *ppos);
> +
> +extern int fragmentation_index(struct zone *zone, unsigned int order);
> +extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int order, gfp_t gfp_mask, nodemask_t *mask);
> +#else
> +static inline unsigned long try_to_compact_pages(struct zonelist *zoneli=
st,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int order, gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return COMPACT_INCOMPLETE;
> +}
> +
> =C2=A0#endif /* CONFIG_COMPACTION */
>
> =C2=A0#if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(=
CONFIG_NUMA)
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index d7f7236..0ea7a38 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -44,6 +44,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0KSWAPD_SKIP_CONGES=
TION_WAIT,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0PAGEOUTRUN, ALLOCS=
TALL, PGROTATED,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0COMPACTBLOCKS, COM=
PACTPAGES, COMPACTPAGEFAILED,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 COMPACTSTALL, COMPACTF=
AIL, COMPACTSUCCESS,
> =C2=A0#ifdef CONFIG_HUGETLB_PAGE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0HTLB_BUDDY_PGALLOC=
, HTLB_BUDDY_PGALLOC_FAIL,
> =C2=A0#endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 02579c2..c7c73bb 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -34,6 +34,8 @@ struct compact_control {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_anon;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_file;
>
> + =C2=A0 =C2=A0 =C2=A0 unsigned int order; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 /* order a direct compactor needs */
> + =C2=A0 =C2=A0 =C2=A0 int migratetype; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* MOVABLE, RECLAIMABLE etc */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
> =C2=A0};
>
> @@ -298,10 +300,31 @@ static void update_nr_listpages(struct compact_cont=
rol *cc)
> =C2=A0static inline int compact_finished(struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct compact_control *cc)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 unsigned int order;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long watermark =3D low_wmark_pages(zone) =
+ (1 << cc->order);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Compaction run completes if the migrate and=
 free scanner meet */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cc->free_pfn <=3D cc->migrate_pfn)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return COMPACT_COM=
PLETE;
>
> + =C2=A0 =C2=A0 =C2=A0 /* Compaction run is not finished if the watermark=
 is not met */
> + =C2=A0 =C2=A0 =C2=A0 if (!zone_watermark_ok(zone, cc->order, watermark,=
 0, 0))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return COMPACT_INCOMPL=
ETE;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (cc->order =3D=3D -1)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return COMPACT_INCOMPL=
ETE;

Where do we set cc->order =3D -1?
Sorry but I can't find it.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
