Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 929F06B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 22:02:47 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7483084iwn.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 19:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100831102557.87D3.A69D9226@jp.fujitsu.com>
References: <20100831095140.87C7.A69D9226@jp.fujitsu.com>
	<AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
	<20100831102557.87D3.A69D9226@jp.fujitsu.com>
Date: Tue, 31 Aug 2010 11:02:45 +0900
Message-ID: <AANLkTinhVnMW8f7+jQdDyEzD=O2YPLSyTuGRE2JnRVzm@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 10:38 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > I think both Ying's and Minchan's opnion are right and makes sense. =
=A0however I _personally_
>> > like Ying version because 1) this version is simpler 2) swap full is v=
ery rarely event 3)
>> > no swap mounting is very common on HPC. so this version could have a c=
hance to
>> > improvement hpc workload too.
>>
>> I agree.
>>
>> >
>> > In the other word, both avoiding unnecessary TLB flush and keeping pro=
per page aging are
>> > performance matter. so when we are talking performance, we always need=
 to think frequency
>> > of the event.
>>
>> Ying's one and mine both has a same effect.
>> Only difference happens swap is full. My version maintains old
>> behavior but Ying's one changes the behavior. I admit swap full is
>> rare event but I hoped not changed old behavior if we doesn't find any
>> problem.
>> If kswapd does aging when swap full happens, is it a problem?
>> We have been used to it from 2.6.28.
>>
>> If we regard a code consistency is more important than _unexpected_
>> result, Okay. I don't mind it. :)
>
> To be honest, I don't mind the difference between you and Ying's version.=
 because
> _practically_ swap full occur mean the application has a bug. so, proper =
page aging
> doesn't help so much. That's the reason why I said I prefer simper. I don=
't have
> strong opinion. I think it's not big matter.
>
>
>> But at least we should do more thing to make the patch to compile out
>> for non-swap configurable system.
>
> Yes, It makes embedded happy :)
>
>

How about this?

(Not formal patch. If we agree, I will post it later when I have a SMTP).


Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3109ff7..c3c44a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1579,7 +1579,7 @@ static void shrink_active_list(unsigned long
nr_pages, struct zone *zone,
        __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
        spin_unlock_irq(&zone->lru_lock);
 }
-
+#if CONFIG_SWAP
 static int inactive_anon_is_low_global(struct zone *zone)
 {
        unsigned long active, inactive;
@@ -1605,12 +1605,21 @@ static int inactive_anon_is_low(struct zone
*zone, struct scan_control *sc)
 {
        int low;

+       if (nr_swap_pages)
+               return 0;
+
        if (scanning_global_lru(sc))
                low =3D inactive_anon_is_low_global(zone);
        else
                low =3D mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
        return low;
 }
+#else
+static inline int inactive_anon_is_low(struct zone *zone, struct
scan_control *sc)
+{
+       return 0;
+}
+#endif

 static int inactive_file_is_low_global(struct zone *zone)
 {
@@ -1856,7 +1865,7 @@ static void shrink_zone(int priority, struct zone *zo=
ne,
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
-       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+       if (inactive_anon_is_low(zone, sc))
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0)=
;

        throttle_vm_writeout(sc->gfp_mask);


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
