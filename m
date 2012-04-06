Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B028A6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 19:52:11 -0400 (EDT)
Received: by lagz14 with SMTP id z14so3354126lag.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 16:52:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332950783-31662-2-git-send-email-mgorman@suse.de>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de>
	<1332950783-31662-2-git-send-email-mgorman@suse.de>
Date: Fri, 6 Apr 2012 16:52:09 -0700
Message-ID: <CALWz4iymXkJ-88u9Aegc2DjwO2vZp3xVuw_5qTRW2KgPP8ti=g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: vmscan: Remove lumpy reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On Wed, Mar 28, 2012 at 9:06 AM, Mel Gorman <mgorman@suse.de> wrote:
> Lumpy reclaim had a purpose but in the mind of some, it was to kick
> the system so hard it trashed. For others the purpose was to complicate
> vmscan.c. Over time it was giving softer shoes and a nicer attitude but
> memory compaction needs to step up and replace it so this patch sends
> lumpy reclaim to the farm.
>
> Here are the important notes related to the patch.
>
> 1. The tracepoint format changes for isolating LRU pages.
>
> 2. This patch stops reclaim/compaction entering sync reclaim as this
> =A0 was only intended for lumpy reclaim and an oversight. Page migration
> =A0 has its own logic for stalling on writeback pages if necessary and
> =A0 memory compaction is already using it. This is a behaviour change.
>
> 3. RECLAIM_MODE_SYNC no longer exists. pageout() does not stall
> =A0 on PageWriteback with CONFIG_COMPACTION has been this way for a while=
.
> =A0 I am calling it out in case this is a surpise to people.

Mel,

Can you point me the commit making that change? I am looking at
v3.4-rc1 where set_reclaim_mode() still set RECLAIM_MODE_SYNC for
COMPACTION_BUILD.

--Ying

This behaviour
> =A0 avoids a situation where we wait on a page being written back to
> =A0 slow storage like USB. Currently we depend on wait_iff_congested()
> =A0 for throttling if if too many dirty pages are scanned.
>
> 4. Reclaim/compaction can no longer queue dirty pages in pageout()
> =A0 if the underlying BDI is congested. Lumpy reclaim used this logic and
> =A0 reclaim/compaction was using it in error. This is a behaviour change.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> =A0include/trace/events/vmscan.h | =A0 36 ++-----
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0209 +++----------=
----------------------------
> =A02 files changed, 22 insertions(+), 223 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.=
h
> index f64560e..6f60b33 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -13,7 +13,7 @@
> =A0#define RECLAIM_WB_ANON =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0001u
> =A0#define RECLAIM_WB_FILE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0002u
> =A0#define RECLAIM_WB_MIXED =A0 =A0 =A0 0x0010u
> -#define RECLAIM_WB_SYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0004u
> +#define RECLAIM_WB_SYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0004u /* Unused=
, all reclaim async */
> =A0#define RECLAIM_WB_ASYNC =A0 =A0 =A0 0x0008u
>
> =A0#define show_reclaim_flags(flags) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0\
> @@ -27,13 +27,13 @@
>
> =A0#define trace_reclaim_flags(page, sync) ( \
> =A0 =A0 =A0 =A0(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_A=
NON) | \
> - =A0 =A0 =A0 (sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_AS=
YNC) =A0 \
> + =A0 =A0 =A0 (RECLAIM_WB_ASYNC) =A0 \
> =A0 =A0 =A0 =A0)
>
> =A0#define trace_shrink_flags(file, sync) ( \
> - =A0 =A0 =A0 (sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_MIXED : \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (file ? RECLAIM_WB_FILE : R=
ECLAIM_WB_ANON)) | =A0\
> - =A0 =A0 =A0 (sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_AS=
YNC) \
> + =A0 =A0 =A0 ( \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) =
| =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (RECLAIM_WB_ASYNC) \
> =A0 =A0 =A0 =A0)
>
> =A0TRACE_EVENT(mm_vmscan_kswapd_sleep,
> @@ -263,22 +263,16 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_requested,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_scanned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_failed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isolate_mode_t isolate_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int file),
>
> - =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy=
_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file),
> + =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_=
mode, file),
>
> =A0 =A0 =A0 =A0TP_STRUCT__entry(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, order)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(unsigned long, nr_requested)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(unsigned long, nr_scanned)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(unsigned long, nr_taken)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_lumpy_taken)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_lumpy_dirty)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_lumpy_failed)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(isolate_mode_t, isolate_mode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, file)
> =A0 =A0 =A0 =A0),
> @@ -288,22 +282,16 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_requested =3D nr_requested;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_scanned =3D nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_taken =3D nr_taken;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_taken =3D nr_lumpy_taken;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_dirty =3D nr_lumpy_dirty;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_failed =3D nr_lumpy_faile=
d;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->isolate_mode =3D isolate_mode;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->file =3D file;
> =A0 =A0 =A0 =A0),
>
> - =A0 =A0 =A0 TP_printk("isolate_mode=3D%d order=3D%d nr_requested=3D%lu =
nr_scanned=3D%lu nr_taken=3D%lu contig_taken=3D%lu contig_dirty=3D%lu conti=
g_failed=3D%lu file=3D%d",
> + =A0 =A0 =A0 TP_printk("isolate_mode=3D%d order=3D%d nr_requested=3D%lu =
nr_scanned=3D%lu nr_taken=3D%lu file=3D%d",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->isolate_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_requested,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_scanned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_lumpy_failed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->file)
> =A0);
>
> @@ -313,13 +301,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vms=
can_lru_isolate,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_requested,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_scanned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_failed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isolate_mode_t isolate_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int file),
>
> - =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy=
_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
> + =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_=
mode, file)
>
> =A0);
>
> @@ -329,13 +314,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vms=
can_memcg_isolate,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_requested,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_scanned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_lumpy_failed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isolate_mode_t isolate_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int file),
>
> - =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy=
_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
> + =A0 =A0 =A0 TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_=
mode, file)
>
> =A0);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33c332b..68319e4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -56,19 +56,11 @@
> =A0/*
> =A0* reclaim_mode determines how the inactive list is shrunk
> =A0* RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
> - * RECLAIM_MODE_ASYNC: =A0Do not block
> - * RECLAIM_MODE_SYNC: =A0 Allow blocking e.g. call wait_on_page_writebac=
k
> - * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a referen=
ce
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page from the LRU and reclaim=
 all pages within a
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 naturally aligned range
> =A0* RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a numbe=
r of
> =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order-0 pages and then compa=
ct the zone
> =A0*/
> =A0typedef unsigned __bitwise__ reclaim_mode_t;
> =A0#define RECLAIM_MODE_SINGLE =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_m=
ode_t)0x01u)
> -#define RECLAIM_MODE_ASYNC =A0 =A0 =A0 =A0 =A0 =A0 ((__force reclaim_mod=
e_t)0x02u)
> -#define RECLAIM_MODE_SYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_m=
ode_t)0x04u)
> -#define RECLAIM_MODE_LUMPYRECLAIM =A0 =A0 =A0((__force reclaim_mode_t)0x=
08u)
> =A0#define RECLAIM_MODE_COMPACTION =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((__for=
ce reclaim_mode_t)0x10u)
>
> =A0struct scan_control {
> @@ -364,37 +356,23 @@ out:
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void set_reclaim_mode(int priority, struct scan_control *sc,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool=
 sync)
> +static void set_reclaim_mode(int priority, struct scan_control *sc)
> =A0{
> - =A0 =A0 =A0 reclaim_mode_t syncmode =3D sync ? RECLAIM_MODE_SYNC : RECL=
AIM_MODE_ASYNC;
> -
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* Initially assume we are entering either lumpy reclaim =
or
> - =A0 =A0 =A0 =A0* reclaim/compaction.Depending on the order, we will eit=
her set the
> - =A0 =A0 =A0 =A0* sync mode or just reclaim order-0 pages later.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (COMPACTION_BUILD)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_COMPACTIO=
N;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_LUMPYRECL=
AIM;
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Avoid using lumpy reclaim or reclaim/compaction if pos=
sible by
> - =A0 =A0 =A0 =A0* restricting when its set to either costly allocations =
or when
> + =A0 =A0 =A0 =A0* Restrict reclaim/compaction to costly allocations or w=
hen
> =A0 =A0 =A0 =A0 * under memory pressure
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode |=3D syncmode;
> - =A0 =A0 =A0 else if (sc->order && priority < DEF_PRIORITY - 2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode |=3D syncmode;
> + =A0 =A0 =A0 if (COMPACTION_BUILD && sc->order &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sc->order > PAGE_ALLOC_COS=
TLY_ORDER ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priority < DEF_PRIORITY =
- 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_COMPACTIO=
N;
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_SINGLE | =
RECLAIM_MODE_ASYNC;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_SINGLE;
> =A0}
>
> =A0static void reset_reclaim_mode(struct scan_control *sc)
> =A0{
> - =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASY=
NC;
> + =A0 =A0 =A0 sc->reclaim_mode =3D RECLAIM_MODE_SINGLE;
> =A0}
>
> =A0static inline int is_page_cache_freeable(struct page *page)
> @@ -416,10 +394,6 @@ static int may_write_to_queue(struct backing_dev_inf=
o *bdi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0if (bdi =3D=3D current->backing_dev_info)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> -
> - =A0 =A0 =A0 /* lumpy reclaim for hugepage often need a lot of write */
> - =A0 =A0 =A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -710,10 +684,6 @@ static enum page_references page_check_references(st=
ruct page *page,
> =A0 =A0 =A0 =A0referenced_ptes =3D page_referenced(page, 1, mz->mem_cgrou=
p, &vm_flags);
> =A0 =A0 =A0 =A0referenced_page =3D TestClearPageReferenced(page);
>
> - =A0 =A0 =A0 /* Lumpy reclaim - ignore references */
> - =A0 =A0 =A0 if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_RECLAIM;
> -
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Mlock lost the isolation race with us. =A0Let try_to_un=
map()
> =A0 =A0 =A0 =A0 * move the page to the unevictable list.
> @@ -813,19 +783,8 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageWriteback(page)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_writeback++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Synchronous reclaim ca=
nnot queue pages for
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* writeback due to the p=
ossibility of stack overflow
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* but if it encounters a=
 page under writeback, wait
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* for the IO to complete=
.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((sc->reclaim_mode & REC=
LAIM_MODE_SYNC) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 may_enter_fs)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_on_pag=
e_writeback(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page=
(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_l=
umpy;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0references =3D page_check_references(page,=
 mz, sc);
> @@ -908,7 +867,7 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto activ=
ate_locked;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case PAGE_SUCCESS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageWr=
iteback(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto keep_lumpy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto keep;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageDi=
rty(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0goto keep;
>
> @@ -1007,8 +966,6 @@ activate_locked:
> =A0keep_locked:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlock_page(page);
> =A0keep:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reset_reclaim_mode(sc);
> -keep_lumpy:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_add(&page->lru, &ret_pages);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page) || PageUnevictable=
(page));
> =A0 =A0 =A0 =A0}
> @@ -1064,11 +1021,7 @@ int __isolate_lru_page(struct page *page, isolate_=
mode_t mode, int file)
> =A0 =A0 =A0 =A0if (!all_lru_mode && !!page_is_file_cache(page) !=3D file)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* When this function is being called for lumpy reclaim, =
we
> - =A0 =A0 =A0 =A0* initially look into all LRU pages, active, inactive an=
d
> - =A0 =A0 =A0 =A0* unevictable; only give shrink_page_list evictable page=
s.
> - =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 /* Do not give back unevictable pages for compaction */
> =A0 =A0 =A0 =A0if (PageUnevictable(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> @@ -1153,9 +1106,6 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,
> =A0 =A0 =A0 =A0struct lruvec *lruvec;
> =A0 =A0 =A0 =A0struct list_head *src;
> =A0 =A0 =A0 =A0unsigned long nr_taken =3D 0;
> - =A0 =A0 =A0 unsigned long nr_lumpy_taken =3D 0;
> - =A0 =A0 =A0 unsigned long nr_lumpy_dirty =3D 0;
> - =A0 =A0 =A0 unsigned long nr_lumpy_failed =3D 0;
> =A0 =A0 =A0 =A0unsigned long scan;
> =A0 =A0 =A0 =A0int lru =3D LRU_BASE;
>
> @@ -1168,10 +1118,6 @@ static unsigned long isolate_lru_pages(unsigned lo=
ng nr_to_scan,
>
> =A0 =A0 =A0 =A0for (scan =3D 0; scan < nr_to_scan && !list_empty(src); sc=
an++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long pfn;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long end_pfn;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long page_pfn;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zone_id;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D lru_to_page(src);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetchw_prev_lru_page(page, src, flags);
> @@ -1193,84 +1139,6 @@ static unsigned long isolate_lru_pages(unsigned lo=
ng nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sc->order || !(sc->reclaim_mode & RECL=
AIM_MODE_LUMPYRECLAIM))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Attempt to take all pages in the order=
 aligned region
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* surrounding the tag page. =A0Only take=
 those pages of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the same active state as that tag page=
. =A0We may safely
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* round the target page pfn down to the =
requested order
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* as the mem_map is guaranteed valid out=
 to MAX_ORDER,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* where that page is in a different zone=
 we will detect
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it from its zone id and abort this blo=
ck scan.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_id =3D page_zone_id(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_pfn =3D page_to_pfn(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn =3D page_pfn & ~((1 << sc->order) - 1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 end_pfn =3D pfn + (1 << sc->order);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (; pfn < end_pfn; pfn++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *cursor_page;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The target page is in th=
e block, ignore it. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(pfn =3D=3D pag=
e_pfn))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Avoid holes within the z=
one. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!pfn_valid_wit=
hin(pfn)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cursor_page =3D pfn_to_page=
(pfn);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check that we have not c=
rossed a zone boundary. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(page_zone_id(c=
ursor_page) !=3D zone_id))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we don't have enoug=
h swap space, reclaiming of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* anon page which don't =
already have a swap slot is
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pointless.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_swap_pages <=3D 0 &&=
 PageSwapBacked(cursor_page) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !PageSwapCache(curs=
or_page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__isolate_lru_page(curs=
or_page, mode, file) =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned in=
t isolated_pages;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_=
lru_del(cursor_page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&=
cursor_page->lru, dst);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 isolated_pa=
ges =3D hpage_nr_pages(cursor_page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=
=3D isolated_pages;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_lumpy_ta=
ken +=3D isolated_pages;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageDir=
ty(cursor_page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 nr_lumpy_dirty +=3D isolated_pages;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn +=3D is=
olated_pages - 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Check =
if the page is freed already.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can=
't use page_count() as that
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* requir=
es compound_head and we don't
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have a=
 pin on the page here. If a
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* page i=
s tail, we may or may not
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have i=
solated the head, so assume
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it's n=
ot free, it'd be tricky to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* track =
the head status without a
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* page p=
in.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!PageTa=
il(cursor_page) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !at=
omic_read(&cursor_page->_count))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If we break out of the loop above, lumpy=
 reclaim failed */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pfn < end_pfn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_lumpy_failed++;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0*nr_scanned =3D scan;
> @@ -1278,7 +1146,6 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,
> =A0 =A0 =A0 =A0trace_mm_vmscan_lru_isolate(sc->order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_to_scan, scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_lumpy_taken, nr_lumpy_di=
rty, nr_lumpy_failed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mode, file);
> =A0 =A0 =A0 =A0return nr_taken;
> =A0}
> @@ -1454,47 +1321,6 @@ update_isolated_counts(struct mem_cgroup_zone *mz,
> =A0}
>
> =A0/*
> - * Returns true if a direct reclaim should wait on pages under writeback=
.
> - *
> - * If we are direct reclaiming for contiguous pages and we do not reclai=
m
> - * everything in the list, try again and wait for writeback IO to comple=
te.
> - * This will stall high-order allocations noticeably. Only do that when =
really
> - * need to free the pages under high memory pressure.
> - */
> -static inline bool should_reclaim_stall(unsigned long nr_taken,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long nr_freed,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int priority,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct scan_control *sc)
> -{
> - =A0 =A0 =A0 int lumpy_stall_priority;
> -
> - =A0 =A0 =A0 /* kswapd should not stall on sync IO */
> - =A0 =A0 =A0 if (current_is_kswapd())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> -
> - =A0 =A0 =A0 /* Only stall on lumpy reclaim */
> - =A0 =A0 =A0 if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> -
> - =A0 =A0 =A0 /* If we have reclaimed everything on the isolated list, no=
 stall */
> - =A0 =A0 =A0 if (nr_freed =3D=3D nr_taken)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* For high-order allocations, there are two stall thresh=
olds.
> - =A0 =A0 =A0 =A0* High-cost allocations stall immediately where as lower
> - =A0 =A0 =A0 =A0* order allocations such as stacks require the scanning
> - =A0 =A0 =A0 =A0* priority to be much higher before stalling.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 lumpy_stall_priority =3D DEF_PRIORITY;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 lumpy_stall_priority =3D DEF_PRIORITY / 3;
> -
> - =A0 =A0 =A0 return priority <=3D lumpy_stall_priority;
> -}
> -
> -/*
> =A0* shrink_inactive_list() is a helper for shrink_zone(). =A0It returns =
the number
> =A0* of reclaimed pages
> =A0*/
> @@ -1522,9 +1348,7 @@ shrink_inactive_list(unsigned long nr_to_scan, stru=
ct mem_cgroup_zone *mz,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return SWAP_CLUSTER_MAX;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 set_reclaim_mode(priority, sc, false);
> - =A0 =A0 =A0 if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 isolate_mode |=3D ISOLATE_ACTIVE;
> + =A0 =A0 =A0 set_reclaim_mode(priority, sc);
>
> =A0 =A0 =A0 =A0lru_add_drain();
>
> @@ -1556,13 +1380,6 @@ shrink_inactive_list(unsigned long nr_to_scan, str=
uct mem_cgroup_zone *mz,
> =A0 =A0 =A0 =A0nr_reclaimed =3D shrink_page_list(&page_list, mz, sc, prio=
rity,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&nr_dirty, &nr_writeback);
>
> - =A0 =A0 =A0 /* Check if we should syncronously wait for writeback */
> - =A0 =A0 =A0 if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, =
sc)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_reclaim_mode(priority, sc, true);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D shrink_page_list(&page_li=
st, mz, sc,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 priority, &nr_dirty, &nr_writeback);
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0spin_lock_irq(&zone->lru_lock);
>
> =A0 =A0 =A0 =A0reclaim_stat->recent_scanned[0] +=3D nr_anon;
> --
> 1.7.9.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
