Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2141A8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:24:24 -0500 (EST)
Received: by iyj17 with SMTP id 17so2395994iyj.14
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 23:24:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128064851.GB5054@balbir.in.ibm.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
Date: Fri, 28 Jan 2011 16:24:19 +0900
Message-ID: <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 3:48 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * MinChan Kim <minchan.kim@gmail.com> [2011-01-28 14:44:50]:
>
>> On Fri, Jan 28, 2011 at 11:56 AM, Balbir Singh
>> <balbir@linux.vnet.ibm.com> wrote:
>> > On Thu, Jan 27, 2011 at 4:42 AM, Minchan Kim <minchan.kim@gmail.com> w=
rote:
>> > [snip]
>> >
>> >>> index 7b56473..2ac8549 100644
>> >>> --- a/mm/page_alloc.c
>> >>> +++ b/mm/page_alloc.c
>> >>> @@ -1660,6 +1660,9 @@ zonelist_scan:
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0unsigned long mark;
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0int ret;
>> >>>
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (should_reclaim_unmapped_pages(zone))
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wakeup_kswapd(zone, order, classzone=
_idx);
>> >>> +
>> >>
>> >> Do we really need the check in fastpath?
>> >> There are lost of caller of alloc_pages.
>> >> Many of them are not related to mapped pages.
>> >> Could we move the check into add_to_page_cache_locked?
>> >
>> > The check is a simple check to see if the unmapped pages need
>> > balancing, the reason I placed this check here is to allow other
>> > allocations to benefit as well, if there are some unmapped pages to be
>> > freed. add_to_page_cache_locked (check under a critical section) is
>> > even worse, IMHO.
>>
>> It just moves the overhead from general into specific case(ie,
>> allocates page for just page cache).
>> Another cases(ie, allocates pages for other purpose except page cache,
>> ex device drivers or fs allocation for internal using) aren't
>> affected.
>> So, It would be better.
>>
>> The goal in this patch is to remove only page cache page, isn't it?
>> So I think we could the balance check in add_to_page_cache and trigger r=
eclaim.
>> If we do so, what's the problem?
>>
>
> I see it as a tradeoff of when to check? add_to_page_cache or when we
> are want more free memory (due to allocation). It is OK to wakeup
> kswapd while allocating memory, somehow for this purpose (global page
> cache), add_to_page_cache or add_to_page_cache_locked does not seem
> the right place to hook into. I'd be open to comments/suggestions
> though from others as well.
>
>> >
>> >
>> >>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0mark =3D zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0if (zone_watermark_ok(zone, order, mark,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0classzone_idx, a=
lloc_flags))
>> >>> @@ -4167,8 +4170,12 @@ static void __paginginit free_area_init_core(=
struct pglist_data *pgdat,
>> >>>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->spanned=
_pages =3D size;
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->present=
_pages =3D realsize;
>> >>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->min_unm=
apped_pages =3D (realsize*sysctl_min_unmapped_ratio)
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0/ 100;
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->max_unmappe=
d_pages =3D (realsize*sysctl_max_unmapped_ratio)
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 / 100;
>> >>> +#endif
>> >>> =C2=A0#ifdef CONFIG_NUMA
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->node =
=3D nid;
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->min_sla=
b_pages =3D (realsize * sysctl_min_slab_ratio) / 100;
>> >>> @@ -5084,6 +5091,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *=
table, int write,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> >>> =C2=A0}
>> >>>
>> >>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>> >>> =C2=A0int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table,=
 int write,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0void __user *buffer, size_t *length, loff=
_t *ppos)
>> >>> =C2=A0{
>> >>> @@ -5100,6 +5108,23 @@ int sysctl_min_unmapped_ratio_sysctl_handler(=
ctl_table *table, int write,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> >>> =C2=A0}
>> >>>
>> >>> +int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int =
write,
>> >>> + =C2=A0 =C2=A0 =C2=A0 void __user *buffer, size_t *length, loff_t *=
ppos)
>> >>> +{
>> >>> + =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
>> >>> + =C2=A0 =C2=A0 =C2=A0 int rc;
>> >>> +
>> >>> + =C2=A0 =C2=A0 =C2=A0 rc =3D proc_dointvec_minmax(table, write, buf=
fer, length, ppos);
>> >>> + =C2=A0 =C2=A0 =C2=A0 if (rc)
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rc;
>> >>> +
>> >>> + =C2=A0 =C2=A0 =C2=A0 for_each_zone(zone)
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->max_unmappe=
d_pages =3D (zone->present_pages *
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sysctl_max_unmapped_ratio) / 100;
>> >>> + =C2=A0 =C2=A0 =C2=A0 return 0;
>> >>> +}
>> >>> +#endif
>> >>> +
>> >>> =C2=A0#ifdef CONFIG_NUMA
>> >>> =C2=A0int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int=
 write,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0void __user *buffer, size_t *length, loff=
_t *ppos)
>> >>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >>> index 02cc82e..6377411 100644
>> >>> --- a/mm/vmscan.c
>> >>> +++ b/mm/vmscan.c
>> >>> @@ -159,6 +159,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
>> >>> =C2=A0#define scanning_global_lru(sc) =C2=A0 =C2=A0 =C2=A0 =C2=A0(1)
>> >>> =C2=A0#endif
>> >>>
>> >>> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
>> >>> +static unsigned long reclaim_unmapped_pages(int priority, struct zo=
ne *zone,
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 struct scan_control *sc);
>> >>> +static int unmapped_page_control __read_mostly;
>> >>> +
>> >>> +static int __init unmapped_page_control_parm(char *str)
>> >>> +{
>> >>> + =C2=A0 =C2=A0 =C2=A0 unmapped_page_control =3D 1;
>> >>> + =C2=A0 =C2=A0 =C2=A0 /*
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: Should we tweak swappiness here?
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >>> + =C2=A0 =C2=A0 =C2=A0 return 1;
>> >>> +}
>> >>> +__setup("unmapped_page_control", unmapped_page_control_parm);
>> >>> +
>> >>> +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
>> >>> +static inline unsigned long reclaim_unmapped_pages(int priority,
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone, struct scan_contr=
ol *sc)
>> >>> +{
>> >>> + =C2=A0 =C2=A0 =C2=A0 return 0;
>> >>> +}
>> >>> +#endif
>> >>> +
>> >>> =C2=A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone =
*zone,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control *sc)
>> >>> =C2=A0{
>> >>> @@ -2359,6 +2382,12 @@ loop_again:
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_list(SWAP_CLUSTE=
R_MAX, zone,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&sc, priority, 0);
>> >>>
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /*
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* We do unmapped page reclaim once here and once
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* below, so that we don't lose out
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0*/
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 reclaim_unmapped_pages(priority, zone, &sc);
>> >>> +
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0if (!zone_watermark_ok_safe(zone, order,
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hi=
gh_wmark_pages(zone), 0, 0)) {
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0end_zone =3D i;
>> >>> @@ -2396,6 +2425,11 @@ loop_again:
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>> >>>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0sc.nr_scanned =3D 0;
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /*
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* Reclaim unmapped pages upfront, this should be
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* really cheap
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0*/
>> >>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 reclaim_unmapped_pages(priority, zone, &sc);
>> >>
>> >> Why should we do by two phase?
>> >> It's not a direct reclaim path. I mean it doesn't need to reclaim tig=
hly
>> >> If we can't reclaim enough, next allocation would wake up kswapd agai=
n
>> >> and kswapd try it again.
>> >>
>> >
>> > I am not sure I understand, the wakeup will occur only if the unmapped
>> > pages are still above the max_unmapped_ratio. They are tunable control
>> > points.
>>
>> I mean you try to reclaim twice in one path.
>> one is when select highest zone to reclaim.
>> one is when VM reclaim the zone.
>>
>> What's your intention?
>>
>
> That is because some zones can be skipped, we need to ensure we go
> through all zones, rather than selective zones (limited via search for
> end_zone).

If kswapd is wake up by unmapped memory of some zone, we have to
include the zone while selective victim zones to prevent miss the
zone.
I think it would be better than reclaiming twice

>
>>
>> >
>> >> And I have a concern. I already pointed out.
>> >> If memory pressure is heavy and unmappd_pages is more than our
>> >> threshold, this can move inactive's tail pages which are mapped into
>> >> heads by reclaim_unmapped_pages. It can make confusing LRU order so
>> >> working set can be evicted.
>> >>
>> >
>> > Sorry, not sure =C2=A0I understand completely? The LRU order is disrup=
ted
>> > because we selectively scan unmapped pages. shrink_page_list() will
>> > ignore mapped pages and put them back in the LRU at head? Here is a
>> > quick take on what happens
>> >
>> > zone_reclaim() will be invoked as a result of these patches and the
>> > pages it tries to reclaim is very few (1 << order). Active list will
>> > be shrunk only when the inactive anon or inactive list is low in size.
>> > I don't see a major churn happening unless we keep failing to reclaim
>> > unmapped pages. In any case we isolate inactive pages and try to
>> > reclaim minimal memory, the churn is mostly in the inactive list if
>> > the page is not reclaimed (am I missing anything?).
>>
>> You understand my question completely. :)
>> In inactive list, page order is important, too although it's weak
>> lumpy and compaction as time goes by.
>> If threshold up and down happens =C2=A0frequently, victim pages in inact=
ive
>> list could move into head and it's not good.
>
> But the assumption for LRU order to change happens only if the page
> cannot be successfully freed, which means it is in some way active..
> and needs to be moved no?

1. holded page by someone
2. mapped pages
3. active pages

1 is rare so it isn't the problem.
Of course, in case of 3, we have to activate it so no problem.
The problem is 2.

>
> Thanks for the detailed review!

Thanks for giving the fun to me. :)

>
> --
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Three Cheers,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Balbir
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
