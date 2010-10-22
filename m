Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ED7FB6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 08:30:04 -0400 (EDT)
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o9MCTsUo028316
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:29:54 GMT
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9MCTtT82637870
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 13:29:55 +0100
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9MCTqG6018976
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 06:29:53 -0600
Message-ID: <4CC183C0.80007@linux.vnet.ibm.com>
Date: Fri, 22 Oct 2010 14:29:52 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Reduce latencies and improve overall reclaim efficiency
 v2
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <4CB721A1.4010508@linux.vnet.ibm.com> <20101018135535.GC30667@csn.ul.ie>
In-Reply-To: <20101018135535.GC30667@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>



On 10/18/2010 03:55 PM, Mel Gorman wrote:
> On Thu, Oct 14, 2010 at 05:28:33PM +0200, Christian Ehrhardt wrote:
[...]
>>
>> So much from the case that I used when I reported the issue earlier this year.
>> The short summary is that the patch series from Mel helps a lot for my test case.
>>
> 
> This is good to hear. We're going in the right direction at least.
> 
>> So I guess Mel you now want some traces of the last two cases right?
>> Could you give me some minimal advice what/how you would exactly need.
>>
> 
> Yes please. Please do something like the following before the test
> 
> mount -t debugfs none /sys/kernel/debug
> echo 1>  /sys/kernel/debug/tracing/events/vmscan/enable
> echo 1>  /sys/kernel/debug/tracing/events/writeback/writeback_congestion_wait/enable
> echo 1>  /sys/kernel/debug/tracing/events/writeback/writeback_wait_iff_congested/enable
> cat /sys/kernel/debug/tracing/trace_pipe>  trace.log&
> 
> rerun the test, gzip trace.log and drop it on some publicly accessible
> webserver. I can rerun the analysis scripts and see if something odd
> falls out.
> 

I ran my sequential read load with triple sync, 3 > drop caches and
some sleeps in advance. Therefore I hope you can see/find some rampup
towards the problem in the log, as all we know from the past suggests
that it isn't a problem as long as there are free or easy-to-free
things around.

The "writeback_wait_iff_congested" trace comes in with one of the
later patches so you can only find it in the log for the -fix kernel.
To be sure I activated all events of writeback (they don't seem to
add too much events - vmscan causes the majority).

I only traced the 16 thread case and raw performance when taking the
logs was still roughly as it appeared without tracing (ftp access as
user "anonymous" - no pw - should ):
                                 TP          Log-size     ftp-access
2.6.36-rc4-trace           179 mb/s             892mb     ftp://testcase.boulder.ibm.com/fromibm/linux/iozone-seq-16thr-2.6.36-trace.log.bz2
2.6.36-rc4-fix            1630 mb/s             229mb     ftp://testcase.boulder.ibm.com/fromibm/linux/iozone-seq-16thr-2.6.36-fix.log.bz2

You can find the bzipped full log files at:
2.6.36-rc4-trace          ftp://testcase.boulder.ibm.com/fromibm/linux/iozone-seq-16thr-2.6.36-trace.log.bz2
2.6.36-rc4-fix            ftp://testcase.boulder.ibm.com/fromibm/linux/iozone-seq-16thr-2.6.36-fix.log.bz2

I used the post-processing script that was patched within your
series, this should easily give everyone a good overview (the
differences are huge). But I don't know if my scripts are really
up-to-date - so it is up to you to decide if the following is
really valid (I also found nothing about the *iff* stuff in the
script, so you might want the full log anyway):

## WITHOUT-FIXES 2.6.36-rc4-trace ##
Process             Direct     Wokeup      Pages    Pages     Pages    Pages     Time
details              Rclms     Kswapd    Scanned   Rclmed   Sync-IO ASync-IO  Stalled
iozone-28292         13654     459886     844139   453638         0       20  159.156      direct-0=13654        wakeup-0=459884 wakeup-1=2
iozone-28300         13071     436052     818191   434998         0        6  159.932      direct-0=13071        wakeup-0=436051 wakeup-1=1
iozone-28303         13813     464730     858740   459634         0        6  159.152      direct-0=13813        wakeup-0=464730
iozone-28295         12824     428748     826281   427246         0       25  159.488      direct-0=12824        wakeup-0=428748
iozone-28301         13482     452617     849624   448212         0       32  159.240      direct-0=13482        wakeup-0=452614 wakeup-1=3
iozone-28304         13131     443473     833093   437755         0       17  159.409      direct-0=13131        wakeup-0=443472 wakeup-1=1
iozone-28305         13628     458115     852889   453645         0        0  159.700      direct-0=13628        wakeup-0=458113 wakeup-1=2
iozone-28291         13625     460635     847770   453657         0        0  159.553      direct-0=13625        wakeup-0=460634 wakeup-1=1
iozone-28297         13103     439959     847125   436743         0       44  159.698      direct-0=13103        wakeup-0=439959
iozone-28302         11991     399591     797354   400234         0        0  160.685      direct-0=11991        wakeup-0=399590 wakeup-1=1
iozone-28296         13085     437466     821684   436628         0        7  159.446      direct-0=13085        wakeup-0=437466
iozone-28294         14028     471795     858038   466738         0        8  159.403      direct-0=14028        wakeup-0=471793 wakeup-1=2
iozone-28298         14216     477065     860224   473428         0        9  158.943      direct-0=14216        wakeup-0=477060 wakeup-1=5
iozone-28299         13354     449048     858721   445392         0        4  159.905      direct-0=13354        wakeup-0=449048
iozone-28293         13554     456445     855633   451410         0       31  159.418      direct-0=13554        wakeup-0=456441 wakeup-1=4
iozone-28290         14664     488925     893139   488442         0        5  158.800      direct-0=14664        wakeup-0=488921 wakeup-1=4
rpcbind-605             45        542       5009     1464         0        0    1.056      direct-0=45           wakeup-0=542
crond-774               11        138        636      414         0        0    0.203      direct-0=11           wakeup-0=138
kthreadd-2               2          2         64       64         0        0    0.000      direct-1=1 direct-2=1 wakeup-1=1 wakeup-2=1
cat-28278             1117       5046     220362    39158         0        0   67.623      direct-0=1117         wakeup-0=5046
sendmail-758           211       6665      33016     7353         0        0    9.436      direct-0=211          wakeup-0=6665
netcat-28279           145       1709      39559     5288         0        0   11.772      direct-0=145          wakeup-0=1709

Kswapd              Kswapd      Order      Pages      Pages    Pages    Pages     
Instance           Wakeups  Re-wakeup    Scanned     Rclmed  Sync-IO ASync-IO
kswapd0-40              31     267142    9687398  1017640         0     2173      wake-0=30 wake-2=1       rewake-0=267128 rewake-1=13 rewake-2=1

Summary
Direct reclaims:                        216754
Direct reclaim pages scanned:           13821291
Direct reclaim pages reclaimed:         7221541
Direct reclaim write file sync I/O:     0
Direct reclaim write anon sync I/O:     0
Direct reclaim write file async I/O:    0
Direct reclaim write anon async I/O:    214
Wake kswapd requests:                   7238652
Time stalled direct reclaim:            2642.02 seconds

Kswapd wakeups:                         31
Kswapd pages scanned:                   9687398
Kswapd pages reclaimed:                 1017640
Kswapd reclaim write file sync I/O:     0
Kswapd reclaim write anon sync I/O:     0
Kswapd reclaim write file async I/O:    0
Kswapd reclaim write anon async I/O:    2173
Time kswapd awake:                      170.15 seconds

## WITH-FIXES 2.6.36-rc4-fix ##
Process             Direct     Wokeup      Pages    Pages     Pages    Pages     Time
details              Rclms     Kswapd    Scanned   Rclmed   Sync-IO ASync-IO  Stalled
iozone-28116          2948      93766     277563    99026         0       41    2.622      direct-0=2948         wakeup-0=93766
iozone-28122          2852      90519     263432    95304         0       15    2.487      direct-0=2852         wakeup-0=90519
iozone-28126          3082     101045     276212   103204         0        7    2.191      direct-0=3082         wakeup-0=101045
iozone-28114          2875      92733     271584    96677         0        5    3.031      direct-0=2875         wakeup-0=92733
iozone-28118          2715      88316     255099    90875         0        2    2.247      direct-0=2715         wakeup-0=88316
iozone-28111          2967      95493     273437    98998         0        0    2.363      direct-0=2967         wakeup-0=95493
iozone-28123          3153     101812     255698   105400         0       25    2.865      direct-0=3153         wakeup-0=101812
iozone-28112          3062     100341     283059   102653         0        4    2.560      direct-0=3062         wakeup-0=100341
iozone-28115          2738      88916     255389    91634         0       14    3.106      direct-0=2738         wakeup-0=88916
iozone-28121          3201     103626     276337   107378         0        0    3.265      direct-0=3201         wakeup-0=103626
iozone-28119          3147     102094     307378   105165         0        0    3.159      direct-0=3147         wakeup-0=102094
iozone-28125          3032      98644     282571   101666         0       12    2.257      direct-0=3032         wakeup-0=98644
iozone-28124          3075     100182     292561   103107         0       12    2.419      direct-0=3075         wakeup-0=100182
iozone-28120          2809      90570     273207    94067         0        7    2.565      direct-0=2809         wakeup-0=90570
iozone-28117          2813      89807     252515    93916         0        0    2.884      direct-0=2813         wakeup-0=89807
iozone-28113          2711      87677     253710    90648         0       18    2.537      direct-0=2711         wakeup-0=87677
sendmail-758            13        442       1915      499         0        0    0.011      direct-0=13           wakeup-0=442
netcat-28100            44        331       4554     1549         0        0    0.507      direct-0=44           wakeup-0=331
cat-28099              141        513      35986     5085         0       39    0.702      direct-0=141          wakeup-0=513
bash-816                 1        173         32       32         0        0    0.000      direct-0=1            wakeup-0=173

Kswapd              Kswapd      Order      Pages      Pages    Pages    Pages
Instance           Wakeups  Re-wakeup    Scanned     Rclmed  Sync-IO ASync-IO
kswapd0-45               2     617968      33692     8905         0        3      wake-0=2       rewake-0=617968

Summary
Direct reclaims:                        47379
Direct reclaim pages scanned:           4392239
Direct reclaim pages reclaimed:         1586883
Direct reclaim write file sync I/O:     0
Direct reclaim write anon sync I/O:     0
Direct reclaim write file async I/O:    0
Direct reclaim write anon async I/O:    201
Wake kswapd requests:                   1527000
Time stalled direct reclaim:            43.78 seconds

Kswapd wakeups:                         2
Kswapd pages scanned:                   33692
Kswapd pages reclaimed:                 8905
Kswapd reclaim write file sync I/O:     0
Kswapd reclaim write anon sync I/O:     0
Kswapd reclaim write file async I/O:    0
Kswapd reclaim write anon async I/O:    3
Time kswapd awake:                      22.35 seconds

[...]
>>
> 
> The log might help me further in figuring out how and why we are losing
> time. When/if the patches move from -mm to mainline, it'd also be worth
> retesting as there is some churn in this area and we need to know whether
> we are heading in the right direction or not. If all goes according to plan,
> kernel 2.6.37-rc1 will be of interest. Thanks again.
> 

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
