Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D065B8D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 19:18:23 -0500 (EST)
Received: by iwl42 with SMTP id 42so2937875iwl.14
        for <linux-mm@kvack.org>; Thu, 10 Mar 2011 16:18:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110311085833.874c6c0e.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>
	<20110311085833.874c6c0e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Mar 2011 09:18:21 +0900
Message-ID: <AANLkTi=1695Wp9UheV_OKk5MixNUY2aHWfQ2WO1evSe2@mail.gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 10 Mar 2011 15:58:29 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Kame,
>>
>> Sorry for late response.
>> I had a time to test this issue shortly because these day I am very busy=
.
>> This issue was interesting to me.
>> So I hope taking a time for enough testing when I have a time.
>> I should find out root cause of livelock.
>>
>
> Thanks. I and Kosaki-san reproduced the bug with swapless system.
> Now, Kosaki-san is digging and found some issue with scheduler boost at O=
OM
> and lack of enough "wait" in vmscan.c.
>
> I myself made patch like attached one. This works well for returning TRUE=
 at
> all_unreclaimable() but livelock(deadlock?) still happens.

I saw the deadlock.
It seems to happen by following code by my quick debug but not sure. I
need to investigate further but don't have a time now. :(


                 * Note: this may have a chance of deadlock if it gets
                 * blocked waiting for another task which itself is waiting
                 * for memory. Is there a better alternative?
                 */
                if (test_tsk_thread_flag(p, TIF_MEMDIE))
                        return ERR_PTR(-1UL);
It would be wait to die the task forever without another victim selection.
If it's right, It's a known BUG and we have no choice until now. Hmm.

> I wonder vmscan itself isn't a key for fixing issue.

I agree.

> Then, I'd like to wait for Kosaki-san's answer ;)

Me, too. :)

>
> I'm now wondering how to catch fork-bomb and stop it (without using cgrou=
p).

Yes. Fork throttling without cgroup is very important.
And as off-topic, mem_notify without memcontrol you mentioned is
important to embedded people, I gues.

> I think the problem is that fork-bomb is faster than killall...

And deadlock problem I mentioned.

>
> Thanks,
> -Kame

Thanks for the investigation, Kame.

> =3D=3D
>
> This is just a debug patch.
>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 58 +++++++++++++++++++++++++++++++++++++++++++=
+++++++++++----
> =C2=A01 file changed, 54 insertions(+), 4 deletions(-)
>
> Index: mmotm-0303/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0303.orig/mm/vmscan.c
> +++ mmotm-0303/mm/vmscan.c
> @@ -1983,9 +1983,55 @@ static void shrink_zones(int priority, s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
> -static bool zone_reclaimable(struct zone *zone)
> +static bool zone_seems_empty(struct zone *zone, struct scan_control *sc)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return zone->pages_scanned < zone_reclaimable_page=
s(zone) * 6;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr, wmark, free, isolated, lru;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If scanned, zone->pages_scanned is increme=
nted and this can
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* trigger OOM.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (sc->nr_scanned)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> +
> + =C2=A0 =C2=A0 =C2=A0 free =3D zone_page_state(zone, NR_FREE_PAGES);
> + =C2=A0 =C2=A0 =C2=A0 isolated =3D zone_page_state(zone, NR_ISOLATED_FIL=
E);
> + =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolated +=3D zone_pag=
e_state(zone, NR_ISOLATED_ANON);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* In we cannot do scan, don't count LRU pages. */
> + =C2=A0 =C2=A0 =C2=A0 if (!zone->all_unreclaimable) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D zone_page_stat=
e(zone, NR_ACTIVE_FILE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru +=3D zone_page_sta=
te(zone, NR_INACTIVE_FILE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru +=3D zone_page_state(zone, NR_ACTIVE_ANON);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru +=3D zone_page_state(zone, NR_INACTIVE_ANON);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 nr =3D free + isolated + lru;
> + =C2=A0 =C2=A0 =C2=A0 wmark =3D min_wmark_pages(zone);
> + =C2=A0 =C2=A0 =C2=A0 wmark +=3D zone->lowmem_reserve[gfp_zone(sc->gfp_m=
ask)];
> + =C2=A0 =C2=A0 =C2=A0 wmark +=3D 1 << sc->order;
> + =C2=A0 =C2=A0 =C2=A0 printk("thread %d/%ld all %d scanned %ld pages %ld=
/%ld/%ld/%ld/%ld/%ld\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 current->pid, sc->nr_s=
canned, zone->all_unreclaimable,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr,free,isolated,lru,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_reclaimable_pages=
(zone), wmark);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* In some case (especially noswap), almost a=
ll page cache are paged out
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* and we'll see the amount of reclaimable+fr=
ee pages is smaller than
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* zone->min. In this case, we canoot expect =
any recovery other
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* than OOM-KILL. We can't reclaim memory eno=
ugh for usual tasks.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> +
> + =C2=A0 =C2=A0 =C2=A0 return nr <=3D wmark;
> +}
> +
> +static bool zone_reclaimable(struct zone *zone, struct scan_control *sc)
> +{
> + =C2=A0 =C2=A0 =C2=A0 /* zone_reclaimable_pages() can return 0, we need =
<=3D */
> + =C2=A0 =C2=A0 =C2=A0 return zone->pages_scanned <=3D zone_reclaimable_p=
ages(zone) * 6;
> =C2=A0}
>
> =C2=A0/*
> @@ -2006,11 +2052,15 @@ static bool all_unreclaimable(struct zon
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cpuset_zone_a=
llowed_hardwall(zone, GFP_KERNEL))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone_reclaimable(z=
one)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone_seems_empty(z=
one, sc))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone_reclaimable(z=
one, sc)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0all_unreclaimable =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 if (all_unreclaimable)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk("all_unreclaima=
ble() returns TRUE\n");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return all_unreclaimable;
> =C2=A0}
> @@ -2456,7 +2506,7 @@ loop_again:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (zone->all_unreclaimable)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!compaction && nr_slab =3D=3D 0 &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 !zone_reclaimable(zone))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 !zone_reclaimable(zone, &sc))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->all_unreclaimable =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * If we've done a decent amount of scanning and
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
