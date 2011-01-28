Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20DEB8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:44:53 -0500 (EST)
Received: by iwn40 with SMTP id 40so2894567iwn.14
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 21:44:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
Date: Fri, 28 Jan 2011 14:44:50 +0900
Message-ID: <AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 11:56 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> On Thu, Jan 27, 2011 at 4:42 AM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
> [snip]
>
>>> index 7b56473..2ac8549 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -1660,6 +1660,9 @@ zonelist_scan:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0unsigned long mark;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0int ret;
>>>
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (should_reclaim_unmapped_pages(zone))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wakeup_kswapd(zone, order, classzone_id=
x);
>>> +
>>
>> Do we really need the check in fastpath?
>> There are lost of caller of alloc_pages.
>> Many of them are not related to mapped pages.
>> Could we move the check into add_to_page_cache_locked?
>
> The check is a simple check to see if the unmapped pages need
> balancing, the reason I placed this check here is to allow other
> allocations to benefit as well, if there are some unmapped pages to be
> freed. add_to_page_cache_locked (check under a critical section) is
> even worse, IMHO.

It just moves the overhead from general into specific case(ie,
allocates page for just page cache).
Another cases(ie, allocates pages for other purpose except page cache,
ex device drivers or fs allocation for internal using) aren't
affected.
So, It would be better.

The goal in this patch is to remove only page cache page, isn't it?
So I think we could the balance check in add_to_page_cache and trigger recl=
aim.
If we do so, what's the problem?

>
>
>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0mark =3D zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (zone_watermark_ok(zone, order, mark,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0classzone_idx, alloc=
_flags))
>>> @@ -4167,8 +4170,12 @@ static void __paginginit free_area_init_core(str=
uct pglist_data *pgdat,
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->spanned_pa=
ges =3D size;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->present_pa=
ges =3D realsize;
>>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->min_unmapp=
ed_pages =3D (realsize*sysctl_min_unmapped_ratio)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/ 100;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->max_unmapped_p=
ages =3D (realsize*sysctl_max_unmapped_ratio)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 / 100;
>>> +#endif
>>> =C2=A0#ifdef CONFIG_NUMA
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->node =3D n=
id;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->min_slab_p=
ages =3D (realsize * sysctl_min_slab_ratio) / 100;
>>> @@ -5084,6 +5091,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *tab=
le, int write,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>>> =C2=A0}
>>>
>>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>>> =C2=A0int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, in=
t write,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0void __user *buffer, size_t *length, loff_t =
*ppos)
>>> =C2=A0{
>>> @@ -5100,6 +5108,23 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl=
_table *table, int write,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>>> =C2=A0}
>>>
>>> +int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int wri=
te,
>>> + =C2=A0 =C2=A0 =C2=A0 void __user *buffer, size_t *length, loff_t *ppo=
s)
>>> +{
>>> + =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
>>> + =C2=A0 =C2=A0 =C2=A0 int rc;
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 rc =3D proc_dointvec_minmax(table, write, buffer=
, length, ppos);
>>> + =C2=A0 =C2=A0 =C2=A0 if (rc)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rc;
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 for_each_zone(zone)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->max_unmapped_p=
ages =3D (zone->present_pages *
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sysctl_max_unmapped_ratio) / 100;
>>> + =C2=A0 =C2=A0 =C2=A0 return 0;
>>> +}
>>> +#endif
>>> +
>>> =C2=A0#ifdef CONFIG_NUMA
>>> =C2=A0int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int wr=
ite,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0void __user *buffer, size_t *length, loff_t =
*ppos)
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 02cc82e..6377411 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -159,6 +159,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
>>> =C2=A0#define scanning_global_lru(sc) =C2=A0 =C2=A0 =C2=A0 =C2=A0(1)
>>> =C2=A0#endif
>>>
>>> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
>>> +static unsigned long reclaim_unmapped_pages(int priority, struct zone =
*zone,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct scan_control *sc);
>>> +static int unmapped_page_control __read_mostly;
>>> +
>>> +static int __init unmapped_page_control_parm(char *str)
>>> +{
>>> + =C2=A0 =C2=A0 =C2=A0 unmapped_page_control =3D 1;
>>> + =C2=A0 =C2=A0 =C2=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: Should we tweak swappiness here?
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 return 1;
>>> +}
>>> +__setup("unmapped_page_control", unmapped_page_control_parm);
>>> +
>>> +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
>>> +static inline unsigned long reclaim_unmapped_pages(int priority,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone, struct scan_control =
*sc)
>>> +{
>>> + =C2=A0 =C2=A0 =C2=A0 return 0;
>>> +}
>>> +#endif
>>> +
>>> =C2=A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zo=
ne,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_control *sc)
>>> =C2=A0{
>>> @@ -2359,6 +2382,12 @@ loop_again:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_list(SWAP_CLUSTER_MA=
X, zone,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&sc, priority, 0);
>>>
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* We do unmapped page reclaim once here and once
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* below, so that we don't lose out
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 reclaim_unmapped_pages(priority, zone, &sc);
>>> +
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (!zone_watermark_ok_safe(zone, order,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high_w=
mark_pages(zone), 0, 0)) {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0end_zone =3D i;
>>> @@ -2396,6 +2425,11 @@ loop_again:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0sc.nr_scanned =3D 0;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* Reclaim unmapped pages upfront, this should be
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* really cheap
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 reclaim_unmapped_pages(priority, zone, &sc);
>>
>> Why should we do by two phase?
>> It's not a direct reclaim path. I mean it doesn't need to reclaim tighly
>> If we can't reclaim enough, next allocation would wake up kswapd again
>> and kswapd try it again.
>>
>
> I am not sure I understand, the wakeup will occur only if the unmapped
> pages are still above the max_unmapped_ratio. They are tunable control
> points.

I mean you try to reclaim twice in one path.
one is when select highest zone to reclaim.
one is when VM reclaim the zone.

What's your intention?


>
>> And I have a concern. I already pointed out.
>> If memory pressure is heavy and unmappd_pages is more than our
>> threshold, this can move inactive's tail pages which are mapped into
>> heads by reclaim_unmapped_pages. It can make confusing LRU order so
>> working set can be evicted.
>>
>
> Sorry, not sure =C2=A0I understand completely? The LRU order is disrupted
> because we selectively scan unmapped pages. shrink_page_list() will
> ignore mapped pages and put them back in the LRU at head? Here is a
> quick take on what happens
>
> zone_reclaim() will be invoked as a result of these patches and the
> pages it tries to reclaim is very few (1 << order). Active list will
> be shrunk only when the inactive anon or inactive list is low in size.
> I don't see a major churn happening unless we keep failing to reclaim
> unmapped pages. In any case we isolate inactive pages and try to
> reclaim minimal memory, the churn is mostly in the inactive list if
> the page is not reclaimed (am I missing anything?).

You understand my question completely. :)
In inactive list, page order is important, too although it's weak
lumpy and compaction as time goes by.
If threshold up and down happens  frequently, victim pages in inactive
list could move into head and it's not good.


>
>
>> zone_reclaim is used by only NUMA until now but you are opening it in th=
e world.
>> I think it would be a good feature in embedded system, too.
>> I hope we care of working set eviction problem.
>>
>
> I hope the above answers your questions
>
> Balbir
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
