Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 76E006B007E
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 19:37:02 -0400 (EDT)
Received: by lbao2 with SMTP id o2so1488556lba.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 16:37:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334162298-18942-1-git-send-email-mgorman@suse.de>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
Date: Wed, 11 Apr 2012 16:37:00 -0700
Message-ID: <CALWz4iyt94KdRXTwr07+s5TPYtcwBX7xScQcqUvwVCnDMLH_TA@mail.gmail.com>
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 11, 2012 at 9:38 AM, Mel Gorman <mgorman@suse.de> wrote:
> Andrew, these three patches should replace the two lumpy reclaim patches
> you already have. When applied, there is no functional difference (slight=
ly
> changes in layout) but the changelogs are better.
>
> Changelog since V1
> o Ying pointed out that compaction was waiting on page writeback and the
> =A0description of the patches in V1 was broken. This version is the same
> =A0except that it is structured differently to explain that waiting on
> =A0page writeback is removed.
> o Rebased to v3.4-rc2
>
> This series removes lumpy reclaim and some stalling logic that was
> unintentionally being used by memory compaction. The end result
> is that stalling on dirty pages during page reclaim now depends on
> wait_iff_congested().
>
> Four kernels were compared
>
> 3.3.0 =A0 =A0 vanilla
> 3.4.0-rc2 vanilla
> 3.4.0-rc2 lumpyremove-v2 is patch one from this series
> 3.4.0-rc2 nosync-v2r3 is the full series
>
> Removing lumpy reclaim saves almost 900K of text where as the full series
> removes 1200K of text.
>
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> 6740375 1927944 2260992 10929311 =A0 =A0 =A0 =A0 a6c49f vmlinux-3.4.0-rc2=
-vanilla
> 6739479 1927944 2260992 10928415 =A0 =A0 =A0 =A0 a6c11f vmlinux-3.4.0-rc2=
-lumpyremove-v2
> 6739159 1927944 2260992 10928095 =A0 =A0 =A0 =A0 a6bfdf vmlinux-3.4.0-rc2=
-nosync-v2
>
> There are behaviour changes in the series and so tests were run with
> monitoring of ftrace events. This disrupts results so the performance
> results are distorted but the new behaviour should be clearer.
>
> fs-mark running in a threaded configuration showed little of interest as
> it did not push reclaim aggressively
>
> FS-Mark Multi Threaded
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03.3.0-vanilla =A0 =A0 =A0 =
rc2-vanilla =A0 =A0 =A0 lumpyremove-v2r3 =A0 =A0 =A0 nosync-v2r3
> Files/s =A0min =A0 =A0 =A0 =A0 =A0 3.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.=
00%) =A0 =A0 =A0 =A03.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.00%)
> Files/s =A0mean =A0 =A0 =A0 =A0 =A03.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.=
00%) =A0 =A0 =A0 =A03.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.00%)
> Files/s =A0stddev =A0 =A0 =A0 =A00.00 ( 0.00%) =A0 =A0 =A0 =A00.00 ( 0.00=
%) =A0 =A0 =A0 =A00.00 ( 0.00%) =A0 =A0 =A0 =A00.00 ( 0.00%)
> Files/s =A0max =A0 =A0 =A0 =A0 =A0 3.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.=
00%) =A0 =A0 =A0 =A03.20 ( 0.00%) =A0 =A0 =A0 =A03.20 ( 0.00%)
> Overhead min =A0 =A0 =A0508667.00 ( 0.00%) =A0 521350.00 (-2.49%) =A0 544=
292.00 (-7.00%) =A0 547168.00 (-7.57%)
> Overhead mean =A0 =A0 551185.00 ( 0.00%) =A0 652690.73 (-18.42%) =A0 9912=
08.40 (-79.83%) =A0 570130.53 (-3.44%)
> Overhead stddev =A0 =A018200.69 ( 0.00%) =A0 331958.29 (-1723.88%) =A0157=
9579.43 (-8578.68%) =A0 =A0 9576.81 (47.38%)
> Overhead max =A0 =A0 =A0576775.00 ( 0.00%) =A01846634.00 (-220.17%) =A069=
01055.00 (-1096.49%) =A0 585675.00 (-1.54%)
> MMTests Statistics: duration
> Sys Time Running Test (seconds) =A0 =A0 =A0 =A0 =A0 =A0 309.90 =A0 =A0300=
.95 =A0 =A0307.33 =A0 =A0298.95
> User+Sys Time Running Test (seconds) =A0 =A0 =A0 =A0319.32 =A0 =A0309.67 =
=A0 =A0315.69 =A0 =A0307.51
> Total Elapsed Time (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 1187.85 =A0 1193=
.09 =A0 1191.98 =A0 1193.73
>
> MMTests Statistics: vmstat
> Page Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 80532 =A0 =A0 =A0 82212 =A0 =A0 =A0 81420 =A0 =A0 =A0 79480
> Page Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0111434984 =A0 111456240 =A0 111437376 =A0 111582628
> Swap Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Swap Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Direct pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
44881 =A0 =A0 =A0 27889 =A0 =A0 =A0 27453 =A0 =A0 =A0 34843
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A025841=
428 =A0 =A025860774 =A0 =A025861233 =A0 =A025843212
> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02584139=
3 =A0 =A025860741 =A0 =A025861199 =A0 =A025843179
> Direct pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 44=
881 =A0 =A0 =A0 27889 =A0 =A0 =A0 27453 =A0 =A0 =A0 34843
> Kswapd efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A099% =A0 =A0 =A0 =A0 99% =A0 =A0 =A0 =A0 99% =A0 =A0 =A0 =A0 99%
> Kswapd velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A021=
754.791 =A0 21675.460 =A0 21696.029 =A0 21649.127
> Direct efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 100% =A0 =A0 =A0 =A0100% =A0 =A0 =A0 =A0100% =A0 =A0 =A0 =A0100%
> Direct velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 37.783 =A0 =A0 =A023.375 =A0 =A0 =A023.031 =A0 =A0 =A029.188
> Percentage direct scans =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0% =A0 =A0 =A0 =A0 =A00% =A0 =A0 =A0 =A0 =A00% =A0 =A0 =A0 =A0 =A00%
>
> ftrace showed that there was no stalling on writeback or pages submitted
> for IO from reclaim context.
>
>
> postmark was similar and while it was more interesting, it also did not
> push reclaim heavily.
>
> POSTMARK
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3=
.3.0-vanilla =A0 =A0 =A0 rc2-vanilla =A0lumpyremove-v2r3 =A0 =A0 =A0 nosync=
-v2r3
> Transactions per second: =A0 =A0 =A0 =A0 =A0 =A0 =A0 16.00 ( 0.00%) =A0 =
=A020.00 (25.00%) =A0 =A018.00 (12.50%) =A0 =A017.00 ( 6.25%)
> Data megabytes read per second: =A0 =A0 =A0 =A018.80 ( 0.00%) =A0 =A024.2=
7 (29.10%) =A0 =A022.26 (18.40%) =A0 =A020.54 ( 9.26%)
> Data megabytes written per second: =A0 =A0 35.83 ( 0.00%) =A0 =A046.25 (2=
9.08%) =A0 =A042.42 (18.39%) =A0 =A039.14 ( 9.24%)
> Files created alone per second: =A0 =A0 =A0 =A028.00 ( 0.00%) =A0 =A038.0=
0 (35.71%) =A0 =A034.00 (21.43%) =A0 =A030.00 ( 7.14%)
> Files create/transact per second: =A0 =A0 =A0 8.00 ( 0.00%) =A0 =A010.00 =
(25.00%) =A0 =A0 9.00 (12.50%) =A0 =A0 8.00 ( 0.00%)
> Files deleted alone per second: =A0 =A0 =A0 556.00 ( 0.00%) =A01224.00 (1=
20.14%) =A03062.00 (450.72%) =A06124.00 (1001.44%)
> Files delete/transact per second: =A0 =A0 =A0 8.00 ( 0.00%) =A0 =A010.00 =
(25.00%) =A0 =A0 9.00 (12.50%) =A0 =A0 8.00 ( 0.00%)
>
> MMTests Statistics: duration
> Sys Time Running Test (seconds) =A0 =A0 =A0 =A0 =A0 =A0 113.34 =A0 =A0107=
.99 =A0 =A0109.73 =A0 =A0108.72
> User+Sys Time Running Test (seconds) =A0 =A0 =A0 =A0145.51 =A0 =A0139.81 =
=A0 =A0143.32 =A0 =A0143.55
> Total Elapsed Time (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 1159.16 =A0 =A08=
99.23 =A0 =A0980.17 =A0 1062.27
>
> MMTests Statistics: vmstat
> Page Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A013710192 =A0 =A013729032 =A0 =A013727944 =A0 =A013760136
> Page Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 43071140 =A0 =A042987228 =A0 =A042733684 =A0 =A042931624
> Swap Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Swap Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Direct pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9941=
613 =A0 =A0 9937443 =A0 =A0 9939085 =A0 =A0 9929154
> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 994092=
6 =A0 =A0 9936751 =A0 =A0 9938397 =A0 =A0 9928465
> Direct pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Kswapd efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A099% =A0 =A0 =A0 =A0 99% =A0 =A0 =A0 =A0 99% =A0 =A0 =A0 =A0 99%
> Kswapd velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8=
576.567 =A0 11051.058 =A0 10140.164 =A0 =A09347.109
> Direct efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 100% =A0 =A0 =A0 =A0100% =A0 =A0 =A0 =A0100% =A0 =A0 =A0 =A0100%
> Direct velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A00.000 =A0 =A0 =A0 0.000 =A0 =A0 =A0 0.000 =A0 =A0 =A0 0.000
>
> It looks like here that the full series regresses performance but as ftra=
ce
> showed no usage of wait_iff_congested() or sync reclaim I am assuming it'=
s
> a disruption due to monitoring. Other data such as memory usage, page IO,
> swap IO all looked similar.
>
> Running a benchmark with a plain DD showed nothing very interesting. The
> full series stalled in wait_iff_congested() slightly less but stall times
> on vanilla kernels were marginal.
>
> Running a benchmark that hammered on file-backed mappings showed stalls
> due to congestion but not in sync writebacks
>
> MICRO
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3=
.3.0-vanilla =A0 =A0 =A0 rc2-vanilla =A0lumpyremove-v2r3 =A0 =A0 =A0 nosync=
-v2r3
> MMTests Statistics: duration
> Sys Time Running Test (seconds) =A0 =A0 =A0 =A0 =A0 =A0 308.13 =A0 =A0294=
.50 =A0 =A0298.75 =A0 =A0299.53
> User+Sys Time Running Test (seconds) =A0 =A0 =A0 =A0330.45 =A0 =A0316.28 =
=A0 =A0318.93 =A0 =A0320.79
> Total Elapsed Time (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 1814.90 =A0 1833=
.88 =A0 1821.14 =A0 1832.91
>
> MMTests Statistics: vmstat
> Page Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0108712 =A0 =A0 =A0120708 =A0 =A0 =A0 97224 =A0 =A0 =A0110344
> Page Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0155514576 =A0 156017404 =A0 155813676 =A0 156193256
> Swap Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Swap Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A0 0
> Direct pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2599=
253 =A0 =A0 1550480 =A0 =A0 2512822 =A0 =A0 2414760
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A069742=
364 =A0 =A071150694 =A0 =A068839041 =A0 =A069692533
> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03482448=
8 =A0 =A034773341 =A0 =A034796602 =A0 =A034799396
> Direct pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 53=
693 =A0 =A0 =A0 94750 =A0 =A0 =A0 61792 =A0 =A0 =A0 75205
> Kswapd efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A049% =A0 =A0 =A0 =A0 48% =A0 =A0 =A0 =A0 50% =A0 =A0 =A0 =A0 49%
> Kswapd velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A038=
427.662 =A0 38797.901 =A0 37799.972 =A0 38022.889
> Direct efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 2% =A0 =A0 =A0 =A0 =A06% =A0 =A0 =A0 =A0 =A02% =A0 =A0 =A0 =A0 =A0=
3%
> Direct velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1=
432.174 =A0 =A0 845.464 =A0 =A01379.807 =A0 =A01317.446
> Percentage direct scans =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 3% =A0 =A0 =A0 =A0 =A02% =A0 =A0 =A0 =A0 =A03% =A0 =A0 =A0 =A0 =A03%
> Page writes by reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Page writes file =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =
=A0 0
> Page writes anon =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =
=A0 0
> Page reclaim immediate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A01218
> Page rescued immediate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Slabs scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A015360 =A0 =A0 =A0 16384 =A0 =A0 =A0 13312 =A0 =A0 =A0 16384
> Direct inode steals =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =
=A0 0
> Kswapd inode steals =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 4340 =A0 =A0 =A0 =A04327 =A0 =A0 =A0 =A01630 =A0 =A0 =A0 =A04323
>
> FTrace Reclaim Statistics: congestion_wait
> Direct number congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct time =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 0ms =
=A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms
> Direct full =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct number conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 900 =A0 =A0 =
=A0 =A0870 =A0 =A0 =A0 =A0754 =A0 =A0 =A0 =A0789
> Direct time =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 0ms =A0 =
=A0 =A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 20ms
> Direct full =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =
=A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd number congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A02106 =A0 =
=A0 =A0 2308 =A0 =A0 =A0 2116 =A0 =A0 =A0 1915
> KSwapd time =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0139924ms =A0 15=
7832ms =A0 125652ms =A0 132516ms
> KSwapd full =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A01346 =
=A0 =A0 =A0 1530 =A0 =A0 =A0 1202 =A0 =A0 =A0 1278
> KSwapd number conditional waited =A0 =A0 =A0 =A0 =A0 =A0 12922 =A0 =A0 =
=A016320 =A0 =A0 =A010943 =A0 =A0 =A014670
> KSwapd time =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 0ms =A0 =
=A0 =A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms
> KSwapd full =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =
=A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>
>
> Reclaim statistics are not radically changed. The stall times in kswapd
> are massive but it is clear that it is due to calls to congestion_wait()
> and that is almost certainly the call in balance_pgdat(). Otherwise stall=
s
> due to dirty pages are non-existant.
>
> I ran a benchmark that stressed high-order allocation. This is very
> artifical load but was used in the past to evaluate lumpy reclaim and
> compaction. Generally I look at allocation success rates and latency figu=
res.
>
> STRESS-HIGHALLOC
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3.3.0-vanilla =A0 =A0 =A0 rc2-vanilla =A0=
lumpyremove-v2r3 =A0 =A0 =A0 nosync-v2r3
> Pass 1 =A0 =A0 =A0 =A0 =A081.00 ( 0.00%) =A0 =A028.00 (-53.00%) =A0 =A024=
.00 (-57.00%) =A0 =A028.00 (-53.00%)
> Pass 2 =A0 =A0 =A0 =A0 =A082.00 ( 0.00%) =A0 =A039.00 (-43.00%) =A0 =A038=
.00 (-44.00%) =A0 =A043.00 (-39.00%)
> while Rested =A0 =A088.00 ( 0.00%) =A0 =A087.00 (-1.00%) =A0 =A088.00 ( 0=
.00%) =A0 =A088.00 ( 0.00%)
>
> MMTests Statistics: duration
> Sys Time Running Test (seconds) =A0 =A0 =A0 =A0 =A0 =A0 740.93 =A0 =A0681=
.42 =A0 =A0685.14 =A0 =A0684.87
> User+Sys Time Running Test (seconds) =A0 =A0 =A0 2922.65 =A0 3269.52 =A0 =
3281.35 =A0 3279.44
> Total Elapsed Time (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 1161.73 =A0 1152=
.49 =A0 1159.55 =A0 1161.44
>
> MMTests Statistics: vmstat
> Page Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 4486020 =A0 =A0 2807256 =A0 =A0 2855944 =A0 =A0 2876244
> Page Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A07261600 =A0 =A0 7973688 =A0 =A0 7975320 =A0 =A0 7986120
> Swap Ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 31694 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =
=A0 =A0 0
> Swap Outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A098179 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =
=A0 =A0 0
> Direct pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
53494 =A0 =A0 =A0 57731 =A0 =A0 =A0 34406 =A0 =A0 =A0113015
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6271=
173 =A0 =A0 1287481 =A0 =A0 1278174 =A0 =A0 1219095
> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 202924=
0 =A0 =A0 1281025 =A0 =A0 1260708 =A0 =A0 1201583
> Direct pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A01468 =A0 =A0 =A0 14564 =A0 =A0 =A0 16649 =A0 =A0 =A0 92456
> Kswapd efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A032% =A0 =A0 =A0 =A0 99% =A0 =A0 =A0 =A0 98% =A0 =A0 =A0 =A0 98%
> Kswapd velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 5=
398.133 =A0 =A01117.130 =A0 =A01102.302 =A0 =A01049.641
> Direct efficiency =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 2% =A0 =A0 =A0 =A0 25% =A0 =A0 =A0 =A0 48% =A0 =A0 =A0 =A0 81%
> Direct velocity =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 46.047 =A0 =A0 =A050.092 =A0 =A0 =A029.672 =A0 =A0 =A097.306
> Percentage direct scans =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0% =A0 =A0 =A0 =A0 =A04% =A0 =A0 =A0 =A0 =A02% =A0 =A0 =A0 =A0 =A08%
> Page writes by reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 161604=
9 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Page writes file =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
1517870 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Page writes anon =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 98179 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Page reclaim immediate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0103=
778 =A0 =A0 =A0 27339 =A0 =A0 =A0 =A09796 =A0 =A0 =A0 17831
> Page rescued immediate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0
> Slabs scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A01096704 =A0 =A0 =A0986112 =A0 =A0 =A0980992 =A0 =A0 =A0998400
> Direct inode steals =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0223 =A0 =A0 =A0215040 =A0 =A0 =A0216736 =A0 =A0 =A0247881
> Kswapd inode steals =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1=
75331 =A0 =A0 =A0 61548 =A0 =A0 =A0 68444 =A0 =A0 =A0 63066
> Kswapd skipped wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A021991 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 0
> THP fault alloc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A01 =A0 =A0 =A0 =A0 135 =A0 =A0 =A0 =A0 125 =A0 =A0 =A0 =A0 13=
4
> THP collapse alloc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 393 =A0 =A0 =A0 =A0 311 =A0 =A0 =A0 =A0 228 =A0 =A0 =A0 =A0 236
> THP splits =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A025 =A0 =A0 =A0 =A0 =A013 =A0 =A0 =A0 =A0 =A0 7 =A0 =A0 =
=A0 =A0 =A0 8
> THP fault fallback =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =
=A0 0
> THP collapse fail =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A03 =A0 =A0 =A0 =A0 =A0 5 =A0 =A0 =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =
=A0 7
> Compaction stalls =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0865 =A0 =A0 =A0 =A01270 =A0 =A0 =A0 =A01422 =A0 =A0 =A0 =A01518
> Compaction success =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 370 =A0 =A0 =A0 =A0 401 =A0 =A0 =A0 =A0 353 =A0 =A0 =A0 =A0 383
> Compaction failures =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0495 =A0 =A0 =A0 =A0 869 =A0 =A0 =A0 =A01069 =A0 =A0 =A0 =A01135
> Compaction pages moved =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0870=
155 =A0 =A0 3828868 =A0 =A0 4036106 =A0 =A0 4423626
> Compaction move failure =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A026=
429 =A0 =A0 =A0 23865 =A0 =A0 =A0 29742 =A0 =A0 =A0 27514
>
> Success rates are completely hosed for 3.4-rc2 which is almost certainly
> due to [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled].=
 I
> expected this would happen for kswapd and impair allocation success rates
> (https://lkml.org/lkml/2012/1/25/166) but I did not anticipate this much
> a difference: 80% less scanning, 37% less reclaim by kswapd
>
> In comparison, reclaim/compaction is not aggressive and gives up easily
> which is the intended behaviour. hugetlbfs uses __GFP_REPEAT and would be
> much more aggressive about reclaim/compaction than THP allocations are. T=
he
> stress test above is allocating like neither THP or hugetlbfs but is much
> closer to THP.
>
> Mainline is now impaired in terms of high order allocation under heavy lo=
ad
> although I do not know to what degree as I did not test with __GFP_REPEAT=
.
> Keep this in mind for bugs related to hugepage pool resizing, THP allocat=
ion
> and high order atomic allocation failures from network devices.
>
> In terms of congestion throttling, I see the following for this test
>
> FTrace Reclaim Statistics: congestion_wait
> Direct number congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct time =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 0ms =
=A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms
> Direct full =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct number conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 957 =A0 =A0 =
=A0 =A0512 =A0 =A0 =A0 1081 =A0 =A0 =A0 1075
> Direct time =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 0ms =A0 =
=A0 =A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms
> Direct full =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =
=A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd number congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A036 =
=A0 =A0 =A0 =A0 =A04 =A0 =A0 =A0 =A0 =A03 =A0 =A0 =A0 =A0 =A05
> KSwapd time =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A03148ms =A0 =
=A0 =A0400ms =A0 =A0 =A0300ms =A0 =A0 =A0500ms
> KSwapd full =A0 congest =A0 =A0 waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A030 =
=A0 =A0 =A0 =A0 =A04 =A0 =A0 =A0 =A0 =A03 =A0 =A0 =A0 =A0 =A05
> KSwapd number conditional waited =A0 =A0 =A0 =A0 =A0 =A0 88514 =A0 =A0 =
=A0 =A0197 =A0 =A0 =A0 =A0332 =A0 =A0 =A0 =A0542
> KSwapd time =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A04980ms =A0 =A0 =
=A0 =A00ms =A0 =A0 =A0 =A00ms =A0 =A0 =A0 =A00ms
> KSwapd full =A0 conditional waited =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A049 =A0 =
=A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>
> The "conditional waited" times are the most interesting as this is direct=
ly
> impacted by the number of dirty pages encountered during scan. As lumpy
> reclaim is no longer scanning contiguous ranges, it is finding fewer dirt=
y
> pages. This brings wait times from about 5 seconds to 0. kswapd itself is
> still calling congestion_wait() so it'll still stall but it's a lot less.
>
> In terms of the type of IO we were doing, I see this
>
> FTrace Reclaim Statistics: mm_vmscan_writepage
> Direct writes anon =A0sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct writes anon =A0async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct writes file =A0sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct writes file =A0async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct writes mixed sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct writes mixed async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes anon =A0sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes anon =A0async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A091682 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes file =A0sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes file =A0async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 822629 =
=A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes mixed sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> KSwapd writes mixed async =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>
> In 3.2, kswapd was doing a bunch of async writes of pages but
> reclaim/compaction was never reaching a point where it was doing sync
> IO. This does not guarantee that reclaim/compaction was not calling
> wait_on_page_writeback() but I would consider it unlikely. It indicates
> that merging patches 2 and 3 to stop reclaim/compaction calling
> wait_on_page_writeback() should be safe.
>
> =A0include/trace/events/vmscan.h | =A0 40 ++-----
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0263 ++++---------=
----------------------------
> =A02 files changed, 37 insertions(+), 266 deletions(-)
>
> --
> 1.7.9.2
>

It might be a naive question, what we do w/ users with the following
in the .config file?

# CONFIG_COMPACTION is not set

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
