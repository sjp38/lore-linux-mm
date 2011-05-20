Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 561106B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 22:59:12 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1944654pzk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 19:59:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
 <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
 <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com> <20110514165346.GV6008@one.firstfloor.org>
 <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com> <20110514174333.GW6008@one.firstfloor.org>
 <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com> <20110515152747.GA25905@localhost>
 <BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com> <20110517060001.GC24069@localhost>
 <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com> <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
 <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com> <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
 <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Thu, 19 May 2011 22:58:49 -0400
Message-ID: <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, May 19, 2011 at 10:16 AM, Andrew Lutomirski <luto@mit.edu> wrote:
> I just booted 2.6.38.6 with exactly two patches applied. =A0Config was
> the same as I emailed yesterday. =A0Userspace is F15. =A0First was
> "aesni-intel: Merge with fpu.ko" because dracut fails to boot my
> system without it. =A0Second was this (sorry for whitespace damage):
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0665520..3f44b81 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -307,7 +307,7 @@ static void set_reclaim_mode(int priority, struct
> scan_control *sc,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->reclaim_mode |=3D syncmode;
> - =A0 =A0 =A0 else if (sc->order && priority < DEF_PRIORITY - 2)
> + =A0 =A0 =A0 else if ((sc->order && priority < DEF_PRIORITY - 2) ||
> priority <=3D DEF_PRIORITY / 3)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->reclaim_mode |=3D syncmode;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->reclaim_mode =3D RECLAIM_MODE_SINGLE |=
 RECLAIM_MODE_ASYNC;
> @@ -1342,10 +1342,6 @@ static inline bool
> should_reclaim_stall(unsigned long nr_taken,
> =A0 =A0 =A0 =A0if (current_is_kswapd())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> - =A0 =A0 =A0 /* Only stall on lumpy reclaim */
> - =A0 =A0 =A0 if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> -
> =A0 =A0 =A0 =A0/* If we have relaimed everything on the isolated list, no=
 stall */
> =A0 =A0 =A0 =A0if (nr_freed =3D=3D nr_taken)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> I started GNOME and Firefox, enabled swap, and ran test_mempressure.sh
> 1500 1400 1. =A0The system quickly gave the attached oops.
>

I haven't applied Minchan's latest patch yet, but given the OOPS it
seems like the root cause might be something other than kswapd not
going sleep.  So I applied this additional patch:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f44b81..1beea0f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -729,7 +729,15 @@ static unsigned long shrink_page_list(struct
list_head *page_list,
                if (!trylock_page(page))
                        goto keep;

-               VM_BUG_ON(PageActive(page));
+               if (PageActive(page)) {
+                       printk(KERN_ERR "shrink_page_list
(nr_scanned=3D%lu nr_reclaimed=3D%lu nr_to_reclaim=3D%lu gfp_mask=3D%X) fou=
nd
inactive
+                              sc->nr_scanned, sc->nr_reclaimed,
+                              sc->nr_to_reclaim, sc->gfp_mask, page,
+                              page->flags);
+                       //VM_BUG_ON(PageActive(page));
+                       msleep(1);
+                       continue;
+               }
                VM_BUG_ON(page_zone(page) !=3D zone);

                sc->nr_scanned++;

and saw:

[   63.609661] Adding 6291452k swap on /dev/mapper/vg_antithesis-swap.
 Priority:-1 extents:1 across:6291452k
[   70.148767] shrink_page_list (nr_scanned=3D33620 nr_reclaimed=3D2122
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea00014220d0
with flags=3D100000000008005D
[   70.148929] shrink_page_list (nr_scanned=3D23477 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001423f38
with flags=3D100000000008005D
[   70.150036] shrink_page_list (nr_scanned=3D33620 nr_reclaimed=3D2122
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0001422060
with flags=3D100000000008005D
[   70.150132] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea00014249f0
with flags=3D100000000008005D
[   70.152032] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424a28
with flags=3D100000000008005D
[   70.152123] shrink_page_list (nr_scanned=3D33632 nr_reclaimed=3D2122
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea00014224c0
with flags=3D100000000008005D
[   70.154027] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424a60
with flags=3D100000000008005D
[   70.154180] shrink_page_list (nr_scanned=3D33733 nr_reclaimed=3D2122
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0001424bb0
with flags=3D100000000008005D
[   70.156022] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424a98
with flags=3D100000000008005D
[   70.156247] shrink_page_list (nr_scanned=3D33930 nr_reclaimed=3D2168
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea000125e860
with flags=3D100000000002004D
[   70.158035] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424ad0
with flags=3D100000000008005D
[   70.158101] shrink_page_list (nr_scanned=3D33930 nr_reclaimed=3D2168
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea000125f238
with flags=3D100000000002004D
[   70.160010] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424b08
with flags=3D100000000008005D
[   70.160075] shrink_page_list (nr_scanned=3D33930 nr_reclaimed=3D2168
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea000125f200
with flags=3D100000000002004D
[   70.162013] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424b40
with flags=3D100000000008005D
[   70.162080] shrink_page_list (nr_scanned=3D33930 nr_reclaimed=3D2168
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea000125f1c8
with flags=3D100000000002004D
[   70.164015] shrink_page_list (nr_scanned=3D23507 nr_reclaimed=3D2198
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0001424b78
with flags=3D100000000008005D
[   70.168859] shrink_page_list (nr_scanned=3D24706 nr_reclaimed=3D2239
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea00012ae030
with flags=3D1000000000080049
[   70.168959] shrink_page_list (nr_scanned=3D40170 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea000125b488
with flags=3D100000000008005D
[   70.170004] shrink_page_list (nr_scanned=3D24706 nr_reclaimed=3D2239
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea00012adf88
with flags=3D1000000000080049
[   70.175980] shrink_page_list (nr_scanned=3D566 nr_reclaimed=3D81
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000e00f18
with flags=3D100000000002004D
[   70.176140] shrink_page_list (nr_scanned=3D846 nr_reclaimed=3D94
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000df2428
with flags=3D100000000002004D
[   70.176160] shrink_page_list (nr_scanned=3D41061 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000df29d8
with flags=3D100000000002004D
[   70.176364] shrink_page_list (nr_scanned=3D28440 nr_reclaimed=3D2350
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000de9240
with flags=3D100000000002004D
[   70.178086] shrink_page_list (nr_scanned=3D41061 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000df2a10
with flags=3D100000000002004D
[   70.178161] shrink_page_list (nr_scanned=3D846 nr_reclaimed=3D94
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000df2268
with flags=3D100000000002004D
[   70.178189] shrink_page_list (nr_scanned=3D28493 nr_reclaimed=3D2350
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000de92b0
with flags=3D100000000002004D
[   70.178215] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de98d0
with flags=3D100000000002004D
[   70.180063] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9908
with flags=3D100000000002004D
[   70.180081] shrink_page_list (nr_scanned=3D28493 nr_reclaimed=3D2350
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000de9320
with flags=3D100000000002004D
[   70.180192] shrink_page_list (nr_scanned=3D897 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dea0e8
with flags=3D100000000002004D
[   70.180197] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deac80
with flags=3D100000000002004D
[   70.182031] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9940
with flags=3D100000000002004D
[   70.182048] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deacb8
with flags=3D100000000002004D
[   70.182063] shrink_page_list (nr_scanned=3D28493 nr_reclaimed=3D2350
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000de9358
with flags=3D100000000002004D
[   70.182079] shrink_page_list (nr_scanned=3D897 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dea120
with flags=3D100000000002004D
[   70.183986] shrink_page_list (nr_scanned=3D28493 nr_reclaimed=3D2350
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000de9828
with flags=3D100000000002004D
[   70.183990] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deacf0
with flags=3D100000000002004D
[   70.183993] shrink_page_list (nr_scanned=3D897 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dea158
with flags=3D100000000002004D
[   70.185982] shrink_page_list (nr_scanned=3D897 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dea190
with flags=3D100000000002004D
[   70.185986] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deadd0
with flags=3D100000000002004D
[   70.186117] shrink_page_list (nr_scanned=3D28621 nr_reclaimed=3D2382
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da5118
with flags=3D100000000002004D
[   70.187991] shrink_page_list (nr_scanned=3D897 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dea1c8
with flags=3D100000000002004D
[   70.187994] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deae40
with flags=3D100000000002004D
[   70.187998] shrink_page_list (nr_scanned=3D28621 nr_reclaimed=3D2382
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da5348
with flags=3D100000000002004D
[   70.189977] shrink_page_list (nr_scanned=3D28621 nr_reclaimed=3D2382
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da5540
with flags=3D100000000002004D
[   70.189980] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deae78
with flags=3D100000000002004D
[   70.190026] shrink_page_list (nr_scanned=3D950 nr_reclaimed=3D136
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000da5b98
with flags=3D100000000002004D
[   70.191975] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deaeb0
with flags=3D100000000002004D
[   70.191982] shrink_page_list (nr_scanned=3D28621 nr_reclaimed=3D2382
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da5578
with flags=3D100000000002004D
[   70.192096] shrink_page_list (nr_scanned=3D1149 nr_reclaimed=3D170
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000da5c78
with flags=3D100000000002004D
[   70.193973] shrink_page_list (nr_scanned=3D41119 nr_reclaimed=3D2787
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000deaee8
with flags=3D100000000002004D
[   70.194025] shrink_page_list (nr_scanned=3D1213 nr_reclaimed=3D170
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000da5ff8
with flags=3D100000000002004D
[   70.194190] shrink_page_list (nr_scanned=3D28849 nr_reclaimed=3D2414
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da6a78
with flags=3D100000000002004D
[   70.195970] shrink_page_list (nr_scanned=3D1213 nr_reclaimed=3D170
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000da6378
with flags=3D100000000002004D
[   70.195981] shrink_page_list (nr_scanned=3D28849 nr_reclaimed=3D2414
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da6ab0
with flags=3D100000000002004D
[   70.196022] shrink_page_list (nr_scanned=3D41176 nr_reclaimed=3D2821
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000da7178
with flags=3D100000000002004D
[   70.197975] shrink_page_list (nr_scanned=3D1213 nr_reclaimed=3D170
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000da66c0
with flags=3D100000000002004D
[   70.197982] shrink_page_list (nr_scanned=3D28849 nr_reclaimed=3D2414
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000da7140
with flags=3D100000000002004D
[   70.198197] shrink_page_list (nr_scanned=3D41527 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000daa198
with flags=3D100000000002004D
[   70.199965] shrink_page_list (nr_scanned=3D41527 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000daa4a8
with flags=3D100000000002004D
[   70.200070] shrink_page_list (nr_scanned=3D1341 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000daaa58
with flags=3D100000000002004D
[   70.200116] shrink_page_list (nr_scanned=3D28963 nr_reclaimed=3D2414
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d90188
with flags=3D100000000002004D
[   70.201962] shrink_page_list (nr_scanned=3D1341 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000daaac8
with flags=3D100000000002004D
[   70.201965] shrink_page_list (nr_scanned=3D41527 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000daa4e0
with flags=3D100000000002004D
[   70.202069] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d907e0
with flags=3D100000000002004D
[   70.203959] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d90818
with flags=3D100000000002004D
[   70.203964] shrink_page_list (nr_scanned=3D41527 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000daa630
with flags=3D100000000002004D
[   70.204009] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90b28
with flags=3D100000000002004D
[   70.205955] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90b98
with flags=3D100000000002004D
[   70.205959] shrink_page_list (nr_scanned=3D41527 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000daa8d0
with flags=3D100000000002004D
[   70.205962] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d90850
with flags=3D100000000002004D
[   70.207962] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90bd0
with flags=3D100000000002004D
[   70.207968] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d90888
with flags=3D100000000002004D
[   70.208015] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d90f88
with flags=3D100000000002004D
[   70.209950] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90d20
with flags=3D100000000002004D
[   70.209954] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d917a0
with flags=3D100000000002004D
[   70.210095] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d908f8
with flags=3D100000000002004D
[   70.211948] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90d58
with flags=3D100000000002004D
[   70.211952] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d91ab0
with flags=3D100000000002004D
[   70.211955] shrink_page_list (nr_scanned=3D29077 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d90af0
with flags=3D100000000002004D
[   70.213946] shrink_page_list (nr_scanned=3D1399 nr_reclaimed=3D205
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d90f18
with flags=3D100000000002004D
[   70.213949] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d91c70
with flags=3D100000000002004D
[   70.214034] shrink_page_list (nr_scanned=3D29165 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d92648
with flags=3D100000000002004D
[   70.215944] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d91ca8
with flags=3D100000000002004D
[   70.215948] shrink_page_list (nr_scanned=3D29165 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d92680
with flags=3D100000000002004D
[   70.216002] shrink_page_list (nr_scanned=3D1462 nr_reclaimed=3D247
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d92728
with flags=3D100000000002004D
[   70.217949] shrink_page_list (nr_scanned=3D1462 nr_reclaimed=3D247
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d92760
with flags=3D100000000002004D
[   70.217952] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d925d8
with flags=3D100000000002004D
[   70.218017] shrink_page_list (nr_scanned=3D29202 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d93bf0
with flags=3D100000000002004D
[   70.219939] shrink_page_list (nr_scanned=3D41591 nr_reclaimed=3D2920
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d92610
with flags=3D100000000002004D
[   70.220036] shrink_page_list (nr_scanned=3D29266 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d94018
with flags=3D100000000002004D
[   70.220054] shrink_page_list (nr_scanned=3D1562 nr_reclaimed=3D290
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000dcdbe0
with flags=3D100000000002004D
[   70.221934] shrink_page_list (nr_scanned=3D29266 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d940c0
with flags=3D100000000002004D
[   70.221938] shrink_page_list (nr_scanned=3D1562 nr_reclaimed=3D290
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d95470
with flags=3D100000000002004D
[   70.222585] shrink_page_list (nr_scanned=3D42665 nr_reclaimed=3D3127
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d8d7f8
with flags=3D100000000002004D
[   70.223931] shrink_page_list (nr_scanned=3D29266 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d94130
with flags=3D100000000002004D
[   70.223935] shrink_page_list (nr_scanned=3D42665 nr_reclaimed=3D3127
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d8d830
with flags=3D100000000002004D
[   70.223976] shrink_page_list (nr_scanned=3D1612 nr_reclaimed=3D290
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d8f238
with flags=3D100000000002004D
[   70.225929] shrink_page_list (nr_scanned=3D42665 nr_reclaimed=3D3127
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d8f468
with flags=3D100000000002004D
[   70.225932] shrink_page_list (nr_scanned=3D1612 nr_reclaimed=3D290
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d8f158
with flags=3D100000000002004D
[   70.225935] shrink_page_list (nr_scanned=3D29266 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d941a0
with flags=3D100000000002004D
[   70.227934] shrink_page_list (nr_scanned=3D29266 nr_reclaimed=3D2460
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d944b0
with flags=3D100000000002004D
[   70.228134] shrink_page_list (nr_scanned=3D42824 nr_reclaimed=3D3199
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d76cd8
with flags=3D100000000002004D
[   70.228427] shrink_page_list (nr_scanned=3D2225 nr_reclaimed=3D409
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d7ad28
with flags=3D100000000002004D
[   70.230232] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d695d0
with flags=3D100000000002004D
[   70.230251] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d69870
with flags=3D100000000002004D
[   70.230446] shrink_page_list (nr_scanned=3D29609 nr_reclaimed=3D2544
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6b978
with flags=3D100000000002004D
[   70.231920] shrink_page_list (nr_scanned=3D29609 nr_reclaimed=3D2544
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6b898
with flags=3D100000000002004D
[   70.231924] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a018
with flags=3D100000000002004D
[   70.231927] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69608
with flags=3D100000000002004D
[   70.233918] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69640
with flags=3D100000000002004D
[   70.233921] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a050
with flags=3D100000000002004D
[   70.233925] shrink_page_list (nr_scanned=3D29609 nr_reclaimed=3D2544
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6b6a0
with flags=3D100000000002004D
[   70.235916] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69720
with flags=3D100000000002004D
[   70.235920] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a088
with flags=3D100000000002004D
[   70.236115] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6cf58
with flags=3D100000000002004D
[   70.237922] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6cf90
with flags=3D100000000002004D
[   70.237926] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69758
with flags=3D100000000002004D
[   70.237929] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a130
with flags=3D100000000002004D
[   70.239910] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6cfc8
with flags=3D100000000002004D
[   70.239914] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d697c8
with flags=3D100000000002004D
[   70.239917] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a168
with flags=3D100000000002004D
[   70.241908] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69800
with flags=3D100000000002004D
[   70.241911] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a1a0
with flags=3D100000000002004D
[   70.241917] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d000
with flags=3D100000000002004D
[   70.243906] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d038
with flags=3D100000000002004D
[   70.243909] shrink_page_list (nr_scanned=3D43013 nr_reclaimed=3D3247
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d69838
with flags=3D100000000002004D
[   70.243913] shrink_page_list (nr_scanned=3D2405 nr_reclaimed=3D458
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6a408
with flags=3D100000000002004D
[   70.245906] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d070
with flags=3D100000000002004D
[   70.245977] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e1f0
with flags=3D100000000002004D
[   70.245982] shrink_page_list (nr_scanned=3D2456 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6d428
with flags=3D100000000002004D
[   70.247909] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e228
with flags=3D100000000002004D
[   70.247912] shrink_page_list (nr_scanned=3D2456 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d6d508
with flags=3D100000000002004D
[   70.247915] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d0a8
with flags=3D100000000002004D
[   70.249897] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d230
with flags=3D100000000002004D
[   70.249901] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e260
with flags=3D100000000002004D
[   70.249941] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d70330
with flags=3D100000000002004D
[   70.251895] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e298
with flags=3D100000000002004D
[   70.251899] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d702f8
with flags=3D100000000002004D
[   70.251911] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d2a0
with flags=3D100000000002004D
[   70.253891] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d2d8
with flags=3D100000000002004D
[   70.253895] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d70288
with flags=3D100000000002004D
[   70.253898] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e2d0
with flags=3D100000000002004D
[   70.255888] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d310
with flags=3D100000000002004D
[   70.255893] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e308
with flags=3D100000000002004D
[   70.255896] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d70250
with flags=3D100000000002004D
[   70.257896] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e420
with flags=3D100000000002004D
[   70.257900] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d70218
with flags=3D100000000002004D
[   70.257903] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d348
with flags=3D100000000002004D
[   70.259885] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e458
with flags=3D100000000002004D
[   70.259889] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d701a8
with flags=3D100000000002004D
[   70.259892] shrink_page_list (nr_scanned=3D29846 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d6d380
with flags=3D100000000002004D
[   70.261883] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e490
with flags=3D100000000002004D
[   70.261886] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d70138
with flags=3D100000000002004D
[   70.261971] shrink_page_list (nr_scanned=3D29929 nr_reclaimed=3D2578
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d726a0
with flags=3D100000000002004D
[   70.263882] shrink_page_list (nr_scanned=3D2510 nr_reclaimed=3D502
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d700c8
with flags=3D100000000002004D
[   70.263976] shrink_page_list (nr_scanned=3D43067 nr_reclaimed=3D3282
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d6e650
with flags=3D100000000002004D
[   70.264520] shrink_page_list (nr_scanned=3D30546 nr_reclaimed=3D2709
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d4dad8
with flags=3D100000000002004D
[   70.266038] shrink_page_list (nr_scanned=3D30674 nr_reclaimed=3D2741
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d50bd8
with flags=3D100000000002004D
[   70.266122] shrink_page_list (nr_scanned=3D43361 nr_reclaimed=3D3364
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d51818
with flags=3D100000000002004D
[   70.266387] shrink_page_list (nr_scanned=3D2848 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d57890
with flags=3D100000000002004D
[   70.268009] shrink_page_list (nr_scanned=3D30754 nr_reclaimed=3D2741
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d57d28
with flags=3D100000000002004D
[   70.268014] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d42eb0
with flags=3D100000000002004D
[   70.268070] shrink_page_list (nr_scanned=3D43559 nr_reclaimed=3D3419
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d433b8
with flags=3D100000000002004D
[   70.269875] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d42ee8
with flags=3D100000000002004D
[   70.270288] shrink_page_list (nr_scanned=3D44119 nr_reclaimed=3D3492
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d1f350
with flags=3D100000000002004D
[   70.270814] shrink_page_list (nr_scanned=3D31538 nr_reclaimed=3D2904
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d08bb0
with flags=3D100000000002004D
[   70.271870] shrink_page_list (nr_scanned=3D44119 nr_reclaimed=3D3492
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d1f318
with flags=3D100000000002004D
[   70.271874] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d42f20
with flags=3D100000000002004D
[   70.271963] shrink_page_list (nr_scanned=3D31617 nr_reclaimed=3D2904
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d08c58
with flags=3D100000000002004D
[   70.273867] shrink_page_list (nr_scanned=3D44119 nr_reclaimed=3D3492
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d1f2e0
with flags=3D100000000002004D
[   70.273870] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d42fc8
with flags=3D100000000002004D
[   70.273874] shrink_page_list (nr_scanned=3D31617 nr_reclaimed=3D2904
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d08d38
with flags=3D100000000002004D
[   70.275864] shrink_page_list (nr_scanned=3D44119 nr_reclaimed=3D3492
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000d1f2a8
with flags=3D100000000002004D
[   70.275867] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d431c0
with flags=3D100000000002004D
[   70.275870] shrink_page_list (nr_scanned=3D31617 nr_reclaimed=3D2904
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000d08ec0
with flags=3D100000000002004D
[   70.277926] shrink_page_list (nr_scanned=3D2904 nr_reclaimed=3D627
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000d431f8
with flags=3D100000000002004D
[   70.278125] shrink_page_list (nr_scanned=3D44344 nr_reclaimed=3D3492
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000cf79d0
with flags=3D100000000002004D
[   70.278222] shrink_page_list (nr_scanned=3D31962 nr_reclaimed=3D2978
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000cf7e30
with flags=3D100000000002004D
[   70.279858] shrink_page_list (nr_scanned=3D31962 nr_reclaimed=3D2978
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000cf7f80
with flags=3D100000000002004D
[   70.279930] shrink_page_list (nr_scanned=3D2954 nr_reclaimed=3D664
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000cf8fb0
with flags=3D100000000002004D
[   70.281855] shrink_page_list (nr_scanned=3D31962 nr_reclaimed=3D2978
nr_to_reclaim=3D32 gfp_mask=3D11212) found inactive page ffffea0000cf7fb8
with flags=3D100000000002004D
[   70.286255] shrink_page_list (nr_scanned=3D6204 nr_reclaimed=3D1203
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000eca388
with flags=3D100000000002004D
[   70.287863] shrink_page_list (nr_scanned=3D6204 nr_reclaimed=3D1203
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000eca350
with flags=3D100000000002004D
[   70.289847] shrink_page_list (nr_scanned=3D6204 nr_reclaimed=3D1203
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000eca318
with flags=3D100000000002004D
[   70.290123] shrink_page_list (nr_scanned=3D58419 nr_reclaimed=3D4751
nr_to_reclaim=3D32 gfp_mask=3D11210) found inactive page ffffea0000ed8200
with flags=3D1000000000000841
[   70.291845] shrink_page_list (nr_scanned=3D6204 nr_reclaimed=3D1203
nr_to_reclaim=3D32 gfp_mask=3D200D2) found inactive page ffffea0000eca2e0
with flags=3D100000000002004D
[   70.400259] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9eb8
with flags=3D100000000002004D
[   70.403707] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9ef0
with flags=3D100000000002004D
[   70.406705] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9f60
with flags=3D100000000002004D
[   70.409706] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9f98
with flags=3D100000000002004D
[   70.412711] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000de9fd0
with flags=3D100000000002004D
[   70.415697] shrink_page_list (nr_scanned=3D618 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0000dea008
with flags=3D100000000002004D
[   70.418828] shrink_page_list (nr_scanned=3D682 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea0001a4f650
with flags=3D1000000000020849
[   70.421696] shrink_page_list (nr_scanned=3D682 nr_reclaimed=3D117
nr_to_reclaim=3D32 gfp_mask=3D2005A) found inactive page ffffea00000824b0
with flags=3D1000000000020849

Right after that happened, I hit ctrl-c to kill test_mempressure.sh.
The system was OK until I typed sync, and then everything hung.

I'm really confused.  shrink_inactive_list in
RECLAIM_MODE_LUMPYRECLAIM will call one of the isolate_pages functions
with ISOLATE_BOTH.  The resulting list goes into shrink_page_list,
which does VM_BUG_ON(PageActive(page)).

How is that supposed to work?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
