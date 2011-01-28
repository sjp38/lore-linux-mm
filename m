Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB52D8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 21:56:34 -0500 (EST)
Received: by pwj8 with SMTP id 8so694657pwj.14
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:56:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
Date: Fri, 28 Jan 2011 08:26:32 +0530
Message-ID: <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 4:42 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
[snip]

>> index 7b56473..2ac8549 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1660,6 +1660,9 @@ zonelist_scan:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long mark;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_unmappe=
d_pages(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_ksw=
apd(zone, order, classzone_idx);
>> +
>
> Do we really need the check in fastpath?
> There are lost of caller of alloc_pages.
> Many of them are not related to mapped pages.
> Could we move the check into add_to_page_cache_locked?

The check is a simple check to see if the unmapped pages need
balancing, the reason I placed this check here is to allow other
allocations to benefit as well, if there are some unmapped pages to be
freed. add_to_page_cache_locked (check under a critical section) is
even worse, IMHO.


>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark =3D zone->watermark[=
alloc_flags & ALLOC_WMARK_MASK];
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone_watermark_ok(zon=
e, order, mark,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c=
lasszone_idx, alloc_flags))
>> @@ -4167,8 +4170,12 @@ static void __paginginit free_area_init_core(stru=
ct pglist_data *pgdat,
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->spanned_pages =3D size;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->present_pages =3D realsize;
>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_unmapped_pages =3D (realsize*sy=
sctl_min_unmapped_ratio)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0/ 100;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->max_unmapped_pages =3D (realsize*sys=
ctl_max_unmapped_ratio)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 / 100;
>> +#endif
>> =A0#ifdef CONFIG_NUMA
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->node =3D nid;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->min_slab_pages =3D (realsize * sysc=
tl_min_slab_ratio) / 100;
>> @@ -5084,6 +5091,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *tabl=
e, int write,
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>>
>> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>> =A0int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int wr=
ite,
>> =A0 =A0 =A0 =A0void __user *buffer, size_t *length, loff_t *ppos)
>> =A0{
>> @@ -5100,6 +5108,23 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_=
table *table, int write,
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>>
>> +int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int writ=
e,
>> + =A0 =A0 =A0 void __user *buffer, size_t *length, loff_t *ppos)
>> +{
>> + =A0 =A0 =A0 struct zone *zone;
>> + =A0 =A0 =A0 int rc;
>> +
>> + =A0 =A0 =A0 rc =3D proc_dointvec_minmax(table, write, buffer, length, =
ppos);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return rc;
>> +
>> + =A0 =A0 =A0 for_each_zone(zone)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->max_unmapped_pages =3D (zone->presen=
t_pages *
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_max=
_unmapped_ratio) / 100;
>> + =A0 =A0 =A0 return 0;
>> +}
>> +#endif
>> +
>> =A0#ifdef CONFIG_NUMA
>> =A0int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
>> =A0 =A0 =A0 =A0void __user *buffer, size_t *length, loff_t *ppos)
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 02cc82e..6377411 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -159,6 +159,29 @@ static DECLARE_RWSEM(shrinker_rwsem);
>> =A0#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(1)
>> =A0#endif
>>
>> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
>> +static unsigned long reclaim_unmapped_pages(int priority, struct zone *=
zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc);
>> +static int unmapped_page_control __read_mostly;
>> +
>> +static int __init unmapped_page_control_parm(char *str)
>> +{
>> + =A0 =A0 =A0 unmapped_page_control =3D 1;
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* XXX: Should we tweak swappiness here?
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 return 1;
>> +}
>> +__setup("unmapped_page_control", unmapped_page_control_parm);
>> +
>> +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
>> +static inline unsigned long reclaim_unmapped_pages(int priority,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zon=
e *zone, struct scan_control *sc)
>> +{
>> + =A0 =A0 =A0 return 0;
>> +}
>> +#endif
>> +
>> =A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control *sc)
>> =A0{
>> @@ -2359,6 +2382,12 @@ loop_again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_ac=
tive_list(SWAP_CLUSTER_MAX, zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&sc, priority, 0);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We do unmapped page r=
eclaim once here and once
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* below, so that we don=
't lose out
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_unmapped_pages(pri=
ority, zone, &sc);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!zone_watermark_ok_sa=
fe(zone, order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0high_wmark_pages(zone), 0, 0)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end_zone =
=3D i;
>> @@ -2396,6 +2425,11 @@ loop_again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Reclaim unmapped page=
s upfront, this should be
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* really cheap
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_unmapped_pages(pri=
ority, zone, &sc);
>
> Why should we do by two phase?
> It's not a direct reclaim path. I mean it doesn't need to reclaim tighly
> If we can't reclaim enough, next allocation would wake up kswapd again
> and kswapd try it again.
>

I am not sure I understand, the wakeup will occur only if the unmapped
pages are still above the max_unmapped_ratio. They are tunable control
points.

> And I have a concern. I already pointed out.
> If memory pressure is heavy and unmappd_pages is more than our
> threshold, this can move inactive's tail pages which are mapped into
> heads by reclaim_unmapped_pages. It can make confusing LRU order so
> working set can be evicted.
>

Sorry, not sure  I understand completely? The LRU order is disrupted
because we selectively scan unmapped pages. shrink_page_list() will
ignore mapped pages and put them back in the LRU at head? Here is a
quick take on what happens

zone_reclaim() will be invoked as a result of these patches and the
pages it tries to reclaim is very few (1 << order). Active list will
be shrunk only when the inactive anon or inactive list is low in size.
I don't see a major churn happening unless we keep failing to reclaim
unmapped pages. In any case we isolate inactive pages and try to
reclaim minimal memory, the churn is mostly in the inactive list if
the page is not reclaimed (am I missing anything?).


> zone_reclaim is used by only NUMA until now but you are opening it in the=
 world.
> I think it would be a good feature in embedded system, too.
> I hope we care of working set eviction problem.
>

I hope the above answers your questions

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
