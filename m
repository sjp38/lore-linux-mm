Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A11E26B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 22:12:39 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 3so322296eyh.18
        for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:12:37 -0700 (PDT)
Date: Fri, 16 Oct 2009 11:10:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20091016111041.6ffc59c9.minchan.kim@barrios-desktop>
In-Reply-To: <alpine.DEB.2.00.0910151507260.2882@kernalhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
	<20090903140602.e0169ffc.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca>
	<20090903154704.da62dd76.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca>
	<20090904165305.c19429ce.akpm@linux-foundation.org>
	<20090908132100.GA17446@csn.ul.ie>
	<alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca>
	<20090909082759.7144aaa5.minchan.kim@barrios-desktop>
	<alpine.DEB.2.00.0910151507260.2882@kernalhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <root@brc.ubc.ca>
Cc: Minchan Kim <minchan.kim@gmail.com>, Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Vicent. 
First of all, Thanks for your effort. :)

On Thu, 15 Oct 2009 15:47:07 -0700 (PDT)
Vincent Li <root@brc.ubc.ca> wrote:

> 
> 
> On Wed, 9 Sep 2009, Minchan Kim wrote:
> 
> >
> > You're right. the experiment said so.
> > But hackbench performs fork-bomb test
> > so that it makes corner case, I think.
> > Such a case shows the your patch is good.
> > But that case is rare.
> >
> > The thing remained is to test your patch
> > in normal case. so you need to test hackbench with
> > smaller parameters to make for the number of task
> > to fit your memory size but does happen reclaim.
> >
> 
> Hi Kim,
> 
> I finally got some time to rerun the perf test and press Alt + SysRq 
> + M the same time  on a freshly start computer.

Your sysrq would catch mem info at random time during hackbench execution.
So, it wouldn't have a consistency. but Your data said somethings. 

> 
> I run the perf with repeat only 1 instead of 5, so run hackbench 
> with number 100 does not cause my system stall, the system  is still quite 
> responsive during the test, I assume that is normal situation, not fork 
> bomb case?

Hackbench make many process in short time so kernel allocates many anon pages
for processes. So we call it 'fork bomb'. 

> 
> In general, it seems nr_taken_zero does happen in normal page reclaim 
> situation, but it is also true that nr_taken_zero does not happen from 
> time to time.
> 
> ###1 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 80
> Running with 80*40 (== 3200) tasks.
> Time: 4.912
> 
>   Performance counter stats for 'hackbench 80':
> 
>                0  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>                0  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>      5.286915156  seconds time elapsed
> 
> 
> [   45.290044] SysRq : Show Memory
> [   45.291132] active_anon:3283 inactive_anon:0 isolated_anon:0
> [   45.291133]  active_file:2538 inactive_file:7964 isolated_file:0
> 
> ###2 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 90
> Running with 90*40 (== 3600) tasks.
> Time: 12.548
> 
>   Performance counter stats for 'hackbench 90':
> 
>               76  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>              361  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     12.980680642  seconds time elapsed
> 
> [  324.098169] SysRq : Show Memory
> [  324.099261] active_anon:3793 inactive_anon:1635 isolated_anon:590
> [  324.099262]  active_file:1334 inactive_file:4262 isolated_file:0

isolated_anon said us there are many processes which need reclaim 
in anon list in your system. So it would be a situation as fork bomb. 
But, it's not heavy. 

> ###3 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 100
> Running with 100*40 (== 4000) tasks.
> Time: 47.296
> 
>   Performance counter stats for 'hackbench 100':
> 
>                0  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>             1064  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     47.765099490  seconds time elapsed
> 
> [  454.130625] SysRq : Show Memory
> [  454.131718] active_anon:8375 inactive_anon:10350 isolated_anon:10285
> [  454.131720]  active_file:1675 inactive_file:7148 isolated_file:30

It's so heavy. isolated anon is bigger than active_anon. 
Nontheless, nr_taken_zero count is zero. 
perhaps, VM would select good pages in anon list.
It's good. 

> 
> ###4 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 80
> Running with 80*40 (== 3200) tasks.
> Time: 4.790
> 
>   Performance counter stats for 'hackbench 80':
> 
>                0  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>                0  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>      5.210933885  seconds time elapsed
> 
> [  599.514166] SysRq : Show Memory
> [  599.515263] active_anon:27830 inactive_anon:114 isolated_anon:0
> [  599.515264]  active_file:1195 inactive_file:3284 isolated_file:0
> 
> ###5 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 90
> Running with 90*40 (== 3600) tasks.
> Time: 5.836
> 
>   Performance counter stats for 'hackbench 90':
> 
>                0  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>                0  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>      6.258902896  seconds time elapsed
> 
> [  753.201247] SysRq : Show Memory
> [  753.202346] active_anon:37091 inactive_anon:114 isolated_anon:0
> [  753.202348]  active_file:1211 inactive_file:3314 isolated_file:0
> 
> ###6 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 100
> Running with 100*40 (== 4000) tasks.
> Time: 6.445
> 
>   Performance counter stats for 'hackbench 100':
> 
>                0  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>                0  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>      6.920834955  seconds time elapsed
> 
> [  836.228395] SysRq : Show Memory
> [  836.229487] active_anon:30157 inactive_anon:114 isolated_anon:0
> [  836.229488]  active_file:1217 inactive_file:3338 isolated_file:0
> 
> ###7 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 120
> Running with 120*40 (== 4800) tasks.
> Time: 66.182
> 
>   Performance counter stats for 'hackbench 120':
> 
>             3307  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>             1218  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     66.767057051  seconds time elapsed
> 
> [  927.855061] SysRq : Show Memory
> [  927.856156] active_anon:11320 inactive_anon:11962 isolated_anon:11879
> [  927.856157]  active_file:1220 inactive_file:3253 isolated_file:0

It's so heavy, too. This case is good for proving your concept. 
But as your data said, it's rare case. 

> 
> ###8 run
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 110
> Running with 110*40 (== 4400) tasks.
> Time: 47.128
> 
>   Performance counter stats for 'hackbench 110':
> 
>                6  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>              934  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     47.657109224  seconds time elapsed
> 
> [ 1058.031490] SysRq : Show Memory
> [ 1058.032573] active_anon:15351 inactive_anon:245 isolated_anon:23350
> [ 1058.032574]  active_file:2112 inactive_file:5036 isolated_file:0
> 
> ###9 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 100
> Running with 100*40 (== 4000) tasks.
> Time: 14.223
> 
>   Performance counter stats for 'hackbench 100':
> 
>                9  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>              382  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     14.773145947  seconds time elapsed
> 
> [ 1242.620748] SysRq : Show Memory
> [ 1242.621843] active_anon:5926 inactive_anon:3066 isolated_anon:788
> [ 1242.621844]  active_file:1297 inactive_file:3145 isolated_file:0
> 
> ###10 run
> 
> root@kernalhack:~# perf stat --repeat 1 -e kmem:mm_vmscan_nr_taken_zero -e 
> kmem:mm_vmscan_nr_taken_nonzero hackbench 110
> Running with 110*40 (== 4400) tasks.
> Time: 39.346
> 
>   Performance counter stats for 'hackbench 110':
> 
>              367  kmem:mm_vmscan_nr_taken_zero #      0.000 M/sec
>              810  kmem:mm_vmscan_nr_taken_nonzero #      0.000 M/sec
> 
>     39.880113992  seconds time elapsed
> 
> [ 1346.694702] SysRq : Show Memory
> [ 1346.695797] active_anon:12729 inactive_anon:6726 isolated_anon:3804
> [ 1346.695798]  active_file:1311 inactive_file:3141 isolated_file:0
> 
> Thanks,
> 
> Vincent

But as your data said, on usual case, nr_taken_zero count is much less 
than non_zero. so we could lost benefit in normal case due to compare
insturction although it's trivial. 

I have no objection in this patch since overhead is not so big.
But I am not sure what other guys think about it. 

How about adding unlikely following as ?

+
+       if (unlikely(nr_taken == 0))
+               goto done;

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
