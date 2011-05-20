Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 782176B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:17:11 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2340006qyk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 17:17:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
	<BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
	<BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
Date: Fri, 20 May 2011 09:17:09 +0900
Message-ID: <BANLkTim7j=q=SANBMOrSbzJKB_rMCNk4Vw@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, May 19, 2011 at 11:16 PM, Andrew Lutomirski <luto@mit.edu> wrote:
> I just booted 2.6.38.6 with exactly two patches applied. =C2=A0Config was
> the same as I emailed yesterday. =C2=A0Userspace is F15. =C2=A0First was
> "aesni-intel: Merge with fpu.ko" because dracut fails to boot my
> system without it. =C2=A0Second was this (sorry for whitespace damage):
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0665520..3f44b81 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -307,7 +307,7 @@ static void set_reclaim_mode(int priority, struct
> scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->reclaim_mode |=
=3D syncmode;
> - =C2=A0 =C2=A0 =C2=A0 else if (sc->order && priority < DEF_PRIORITY - 2)
> + =C2=A0 =C2=A0 =C2=A0 else if ((sc->order && priority < DEF_PRIORITY - 2=
) ||
> priority <=3D DEF_PRIORITY / 3)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->reclaim_mode |=
=3D syncmode;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->reclaim_mode =
=3D RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
> @@ -1342,10 +1342,6 @@ static inline bool
> should_reclaim_stall(unsigned long nr_taken,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (current_is_kswapd())
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
>
> - =C2=A0 =C2=A0 =C2=A0 /* Only stall on lumpy reclaim */
> - =C2=A0 =C2=A0 =C2=A0 if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If we have relaimed everything on the isola=
ted list, no stall */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr_freed =3D=3D nr_taken)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
>
> I started GNOME and Firefox, enabled swap, and ran test_mempressure.sh
> 1500 1400 1. =C2=A0The system quickly gave the attached oops.
>
> The oops was the ud2 here:
>
> =C2=A0 0xffffffff810d251b <+215>: =C2=A0 mov =C2=A0 =C2=A0-0x28(%rbx),%ra=
x
> =C2=A0 0xffffffff810d251f <+219>: =C2=A0 test =C2=A0 $0x40,%al
> =C2=A0 0xffffffff810d2521 <+221>: =C2=A0 je =C2=A0 =C2=A0 0xffffffff810d2=
525 <shrink_page_list+225>
> =C2=A0 0xffffffff810d2523 <+223>: =C2=A0 ud2
>
> Please let me know what the next test to run is.

Okay. My first patch(!pgdat_balanced and cond_resched right after
balance_pgdat) sent you was successful. But the version removed
cond_resched was hang.

Let's not make the problem complex.
So let's put aside the above my patch.

Would you be willing to test one more with below patch?
(Of course, it would be damage by white space. I can't do anything for
it in my office. Sorry.)
If below patch still fix your problem like my first patch, we will
push this patch into mainline.

Thanks. Andrew.

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



>
> --Andy
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
