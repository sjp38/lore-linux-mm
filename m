Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 492DE6B01BA
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 19:10:44 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 3so369475eyh.6
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 16:10:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1269347146-7461-11-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	 <1269347146-7461-11-git-send-email-mel@csn.ul.ie>
Date: Wed, 24 Mar 2010 08:10:40 +0900
Message-ID: <28c262361003231610p3753a136v51720df8568cfa0a@mail.gmail.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Mel.

On Tue, Mar 23, 2010 at 9:25 PM, Mel Gorman <mel@csn.ul.ie> wrote:
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
> index c94890b..b851428 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,14 +1,26 @@
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
> =C2=A0extern int sysctl_compact_memory;
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
> index 56e4b44..b4b4d34 100644
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
> index 8df6e3d..6688700 100644
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
> @@ -301,10 +303,31 @@ static void update_nr_listpages(struct compact_cont=
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
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Direct compactor: Is a suitable page free? */
> + =C2=A0 =C2=A0 =C2=A0 for (order =3D cc->order; order < MAX_ORDER; order=
++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Job done if page is=
 free of the right migratetype */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!list_empty(&zone-=
>free_area[order].free_list[cc->migratetype]))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return COMPACT_PARTIAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Job done if allocat=
ion would set block type */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (order >=3D pageblo=
ck_order && zone->free_area[order].nr_free)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return COMPACT_PARTIAL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return COMPACT_INCOMPLETE;
> =C2=A0}
>
> @@ -348,6 +371,101 @@ static int compact_zone(struct zone *zone, struct c=
ompact_control *cc)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static inline unsigned long compact_zone_order(struct zone *zone,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 int order, gfp_t gfp_mask)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct compact_control cc =3D {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .nr_freepages =3D 0,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .nr_migratepages =3D 0=
,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .order =3D order,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .migratetype =3D alloc=
flags_to_migratetype(gfp_mask),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .zone =3D zone,
> + =C2=A0 =C2=A0 =C2=A0 };
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&cc.freepages);
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&cc.migratepages);
> +
> + =C2=A0 =C2=A0 =C2=A0 return compact_zone(zone, &cc);
> +}
> +
> +/**
> + * try_to_compact_pages - Direct compact to satisfy a high-order allocat=
ion
> + * @zonelist: The zonelist used for the current allocation
> + * @order: The order of the current allocation
> + * @gfp_mask: The GFP mask of the current allocation
> + * @nodemask: The allowed nodes to allocate from
> + *
> + * This is the main entry point for direct page compaction.
> + */
> +unsigned long try_to_compact_pages(struct zonelist *zonelist,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int order, gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> + =C2=A0 =C2=A0 =C2=A0 enum zone_type high_zoneidx =3D gfp_zone(gfp_mask)=
;
> + =C2=A0 =C2=A0 =C2=A0 int may_enter_fs =3D gfp_mask & __GFP_FS;
> + =C2=A0 =C2=A0 =C2=A0 int may_perform_io =3D gfp_mask & __GFP_IO;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long watermark;
> + =C2=A0 =C2=A0 =C2=A0 struct zoneref *z;
> + =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
> + =C2=A0 =C2=A0 =C2=A0 int rc =3D COMPACT_INCOMPLETE;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Check whether it is worth even starting compact=
ion */
> + =C2=A0 =C2=A0 =C2=A0 if (order =3D=3D 0 || !may_enter_fs || !may_perfor=
m_io)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rc;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We will not stall if the necessary conditi=
ons are not met for
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* migration but direct reclaim seems to acco=
unt stalls similarly
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/

I can't understand this comment.
In case of direct reclaim, shrink_zones's long time is just stall
by view point of allocation customer.
So "Allocation is stalled" makes sense to me.

But "Compaction is stalled" doesn't make sense to me.
How about "COMPACTION_DIRECT" like "PGSCAN_DIRECT"?
I think It's straightforward.
Naming is important since it makes ABI.

> + =C2=A0 =C2=A0 =C2=A0 count_vm_event(COMPACTSTALL);
> +





--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
