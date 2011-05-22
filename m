Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E58A76B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 19:12:52 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3708721qwa.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 16:12:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
	<20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520101120.GC11729@random.random>
	<BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com>
	<20110520153346.GA1843@barrios-desktop>
	<BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com>
	<20110520161934.GA2386@barrios-desktop>
	<BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
	<BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
	<BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com>
	<BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
	<BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com>
Date: Mon, 23 May 2011 08:12:50 +0900
Message-ID: <BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Sun, May 22, 2011 at 9:22 PM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Sat, May 21, 2011 at 10:44 AM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>> I would like to confirm this problem.
>> Could you show the diff of 2.6.38.6 with current your 2.6.38.6 + alpha?
>> (ie, I would like to know that what patches you add up on vanilla
>> 2.6.38.6 to reproduce this problem)
>> I believe you added my crap below patch. Right?
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 292582c..69d317e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -311,7 +311,8 @@ static void set_reclaim_mode(int priority, struct
>> scan_control *sc,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->reclaim_mode |=3D s=
yncmode;
>> - =C2=A0 =C2=A0 =C2=A0 else if (sc->order && priority < DEF_PRIORITY - 2=
)
>> + =C2=A0 =C2=A0 =C2=A0 else if ((sc->order && priority < DEF_PRIORITY - =
2) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prioiry <=3D DEF_PRIORITY / 3)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->reclaim_mode |=3D s=
yncmode;
>> =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->reclaim_mode =3D RE=
CLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
>> @@ -1349,10 +1350,6 @@ static inline bool
>> should_reclaim_stall(unsigned long nr_taken,
>> =C2=A0 =C2=A0 =C2=A0 if (current_is_kswapd())
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* Only stall on lumpy reclaim */
>> - =C2=A0 =C2=A0 =C2=A0 if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> -
>
> Bah. =C2=A0It's this last hunk. =C2=A0Without this I can't reproduce the =
oops.
> With this hunk, the reset_reclaim_mode doesn't work and
> shrink_page_list is incorrectly called twice.

OMG! I should have said more clearly to you.  Above my patch is totally _cr=
ap_.
I thought you have experimented test without above crap patch. :(
Sorry for consuming time of many mm guys.
My apologies.

I want to resolve your original problem(ie, hang) before digging the
OOM problem.

>
> So we're back to the original problem...

Could you test below patch based on vanilla 2.6.38.6?
The expect result is that system hang never should happen.
I hope this is last test about hang.

Thanks.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..1663d24 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -231,8 +231,11 @@ unsigned long shrink_slab(struct shrink_control *shrin=
k,
       if (scanned =3D=3D 0)
               scanned =3D SWAP_CLUSTER_MAX;

-       if (!down_read_trylock(&shrinker_rwsem))
-               return 1;       /* Assume we'll be able to shrink next time=
 */
+       if (!down_read_trylock(&shrinker_rwsem)) {
+               /* Assume we'll be able to shrink next time */
+               ret =3D 1;
+               goto out;
+       }

       list_for_each_entry(shrinker, &shrinker_list, list) {
               unsigned long long delta;
@@ -286,6 +289,8 @@ unsigned long shrink_slab(struct shrink_control *shrink=
,
               shrinker->nr +=3D total_scan;
       }
       up_read(&shrinker_rwsem);
+out:
+       cond_resched();
       return ret;
 }

@@ -2331,7 +2336,7 @@ static bool sleeping_prematurely(pg_data_t
*pgdat, int order, long remaining,
        * must be balanced
        */
       if (order)
-               return pgdat_balanced(pgdat, balanced, classzone_idx);
+               return !pgdat_balanced(pgdat, balanced, classzone_idx);
       else
               return !all_zones_ok;
 }

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
