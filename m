Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 597C56B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 05:13:29 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so5365023wjc.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 02:13:29 -0800 (PST)
Received: from mx1.molgen.mpg.de (mx1.molgen.mpg.de. [141.14.17.9])
        by mx.google.com with ESMTPS id du10si33329590wjb.54.2016.12.09.02.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 02:13:27 -0800 (PST)
Subject: Re: [PATCH] mm, vmscan: add cond_resched into shrink_node_memcg
References: <20161202095841.16648-1-mhocko@kernel.org>
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <b9239c93-2dd1-8973-28fd-efc4984fc34a@molgen.mpg.de>
Date: Fri, 9 Dec 2016 11:13:27 +0100
MIME-Version: 1.0
In-Reply-To: <20161202095841.16648-1-mhocko@kernel.org>
Content-Type: multipart/alternative;
 boundary="------------375F8C773005DF889666C889"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Zhmurov <bb@kernelpanic.ru>, "Christopher S. Aker" <caker@theshore.net>, Paul Menzel <pmenzel@molgen.mpg.de>

This is a multi-part message in MIME format.
--------------375F8C773005DF889666C889
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 12/02/16 10:58, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> Boris Zhmurov has reported RCU stalls during the kswapd reclaim:
> 17511.573645] INFO: rcu_sched detected stalls on CPUs/tasks:
> [17511.573699]  23-...: (22 ticks this GP) idle=92f/140000000000000/0 softirq=2638404/2638404 fqs=23
> [17511.573740]  (detected by 4, t=6389 jiffies, g=786259, c=786258, q=42115)
> [17511.573776] Task dump for CPU 23:
> [17511.573777] kswapd1         R  running task        0   148      2 0x00000008
> [17511.573781]  0000000000000000 ffff8efe5f491400 ffff8efe44523e68 ffff8f16a7f49000
> [17511.573782]  0000000000000000 ffffffffafb67482 0000000000000000 0000000000000000
> [17511.573784]  0000000000000000 0000000000000000 ffff8efe44523e58 00000000016dbbee
> [17511.573786] Call Trace:
> [17511.573796]  [<ffffffffafb67482>] ? shrink_node+0xd2/0x2f0
> [17511.573798]  [<ffffffffafb683ab>] ? kswapd+0x2cb/0x6a0
> [17511.573800]  [<ffffffffafb680e0>] ? mem_cgroup_shrink_node+0x160/0x160
> [17511.573806]  [<ffffffffafa8b63d>] ? kthread+0xbd/0xe0
> [17511.573810]  [<ffffffffafa2967a>] ? __switch_to+0x1fa/0x5c0
> [17511.573813]  [<ffffffffaff9095f>] ? ret_from_fork+0x1f/0x40
> [17511.573815]  [<ffffffffafa8b580>] ? kthread_create_on_node+0x180/0x180
>
> a closer code inspection has shown that we might indeed miss all the
> scheduling points in the reclaim path if no pages can be isolated from
> the LRU list. This is a pathological case but other reports from Donald
> Buczek have shown that we might indeed hit such a path:
>          clusterd-989   [009] .... 118023.654491: mm_vmscan_direct_reclaim_end: nr_reclaimed=193
>           kswapd1-86    [001] dN.. 118023.987475: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239830 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118024.320968: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239844 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118024.654375: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239858 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118024.987036: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239872 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118025.319651: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239886 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118025.652248: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239900 nr_taken=0 file=1
>           kswapd1-86    [001] dN.. 118025.984870: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239914 nr_taken=0 file=1
> [...]
>           kswapd1-86    [001] dN.. 118084.274403: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4241133 nr_taken=0 file=1
>
> this is minute long snapshot which didn't take a single page from the
> LRU. It is not entirely clear why only 1303 pages have been scanned
> during that time (maybe there was a heavy IRQ activity interfering).
>
> In any case it looks like we can really hit long periods without
> scheduling on non preemptive kernels so an explicit cond_resched() in
> shrink_node_memcg which is independent on the reclaim operation is due.
>
> Reported-and-tested-by: Boris Zhmurov <bb@kernelpanic.ru>
> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
> Reported-by: "Christopher S. Aker" <caker@theshore.net>
> Reported-by: Paul Menzel <pmenzel@molgen.mpg.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>
> Hi,
> there were multiple reportes of the similar RCU stalls. Only Boris has
> confirmed that this patch helps in his workload. Others might see a
> slightly different issue and that should be investigated if it is the
> case. As pointed out by Paul [1] cond_resched might be not sufficient
> to silence RCU stalls because that would require a real scheduling.
> This is a separate problem, though, and Paul is working with Peter [2]
> to resolve it.
>
> Anyway, I believe that this patch should be a good start because it
> really seems that nr_taken=0 during the LRU isolation can be triggered
> in the real life. All reporters are agreeing to start seeing this issue
> when moving on to 4.8 kernel which might be just a coincidence or a
> different behavior of some subsystem. Well, MM has moved from zone to
> node reclaim but I couldn't have found any direct relation to that
> change.
>
> [1] http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com
> [2] http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com
>
>   mm/vmscan.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c05f00042430..c4abf08861d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2362,6 +2362,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
>   			}
>   		}
>   
> +		cond_resched();
> +
>   		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
>   			continue;
>   

Our two backup servers which had rcu stall warnings since 4.8 are 
running with this patch on top of v4.8.12 for 3 1/2 days now and didn't 
log any rcu stalls since then. So this patch might be fixing it for our 
environment, too.

The previous times between boots and first occurrences of rcu stall 
warnings were:

Server A ("void"): 1d14h 5h 1d4h 2d2h 21h 3d21h
Server B ("null"): 3d12h 2d3h 5d4h 4h 12h

(Yes, this contradicts a previous mail from me, where I wrongly stated 
"37,0.2,1,2,0.8 hours" for the first server, because I messed up the 
units. Its "37 hours,  0.2 days, 1 day, 2 days, 0.8 days" which fits the 
first 5 numbers in the above list. Sorry.)

We should wait a few days longer for a better p-value but there is 
reason for hope.

Donald

-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433


--------------375F8C773005DF889666C889
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 12/02/16 10:58, Michal Hocko wrote:<br>
    </div>
    <blockquote cite="mid:20161202095841.16648-1-mhocko@kernel.org"
      type="cite">
      <pre wrap="">From: Michal Hocko <a class="moz-txt-link-rfc2396E" href="mailto:mhocko@suse.com">&lt;mhocko@suse.com&gt;</a>

Boris Zhmurov has reported RCU stalls during the kswapd reclaim:
17511.573645] INFO: rcu_sched detected stalls on CPUs/tasks:
[17511.573699]  23-...: (22 ticks this GP) idle=92f/140000000000000/0 softirq=2638404/2638404 fqs=23
[17511.573740]  (detected by 4, t=6389 jiffies, g=786259, c=786258, q=42115)
[17511.573776] Task dump for CPU 23:
[17511.573777] kswapd1         R  running task        0   148      2 0x00000008
[17511.573781]  0000000000000000 ffff8efe5f491400 ffff8efe44523e68 ffff8f16a7f49000
[17511.573782]  0000000000000000 ffffffffafb67482 0000000000000000 0000000000000000
[17511.573784]  0000000000000000 0000000000000000 ffff8efe44523e58 00000000016dbbee
[17511.573786] Call Trace:
[17511.573796]  [&lt;ffffffffafb67482&gt;] ? shrink_node+0xd2/0x2f0
[17511.573798]  [&lt;ffffffffafb683ab&gt;] ? kswapd+0x2cb/0x6a0
[17511.573800]  [&lt;ffffffffafb680e0&gt;] ? mem_cgroup_shrink_node+0x160/0x160
[17511.573806]  [&lt;ffffffffafa8b63d&gt;] ? kthread+0xbd/0xe0
[17511.573810]  [&lt;ffffffffafa2967a&gt;] ? __switch_to+0x1fa/0x5c0
[17511.573813]  [&lt;ffffffffaff9095f&gt;] ? ret_from_fork+0x1f/0x40
[17511.573815]  [&lt;ffffffffafa8b580&gt;] ? kthread_create_on_node+0x180/0x180

a closer code inspection has shown that we might indeed miss all the
scheduling points in the reclaim path if no pages can be isolated from
the LRU list. This is a pathological case but other reports from Donald
Buczek have shown that we might indeed hit such a path:
        clusterd-989   [009] .... 118023.654491: mm_vmscan_direct_reclaim_end: nr_reclaimed=193
         kswapd1-86    [001] dN.. 118023.987475: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239830 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118024.320968: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239844 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118024.654375: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239858 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118024.987036: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239872 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118025.319651: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239886 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118025.652248: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239900 nr_taken=0 file=1
         kswapd1-86    [001] dN.. 118025.984870: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4239914 nr_taken=0 file=1
[...]
         kswapd1-86    [001] dN.. 118084.274403: mm_vmscan_lru_isolate: isolate_mode=0 classzone=0 order=0 nr_requested=32 nr_scanned=4241133 nr_taken=0 file=1

this is minute long snapshot which didn't take a single page from the
LRU. It is not entirely clear why only 1303 pages have been scanned
during that time (maybe there was a heavy IRQ activity interfering).

In any case it looks like we can really hit long periods without
scheduling on non preemptive kernels so an explicit cond_resched() in
shrink_node_memcg which is independent on the reclaim operation is due.

Reported-and-tested-by: Boris Zhmurov <a class="moz-txt-link-rfc2396E" href="mailto:bb@kernelpanic.ru">&lt;bb@kernelpanic.ru&gt;</a>
Reported-by: Donald Buczek <a class="moz-txt-link-rfc2396E" href="mailto:buczek@molgen.mpg.de">&lt;buczek@molgen.mpg.de&gt;</a>
Reported-by: "Christopher S. Aker" <a class="moz-txt-link-rfc2396E" href="mailto:caker@theshore.net">&lt;caker@theshore.net&gt;</a>
Reported-by: Paul Menzel <a class="moz-txt-link-rfc2396E" href="mailto:pmenzel@molgen.mpg.de">&lt;pmenzel@molgen.mpg.de&gt;</a>
Signed-off-by: Michal Hocko <a class="moz-txt-link-rfc2396E" href="mailto:mhocko@suse.com">&lt;mhocko@suse.com&gt;</a>
---

Hi,
there were multiple reportes of the similar RCU stalls. Only Boris has
confirmed that this patch helps in his workload. Others might see a
slightly different issue and that should be investigated if it is the
case. As pointed out by Paul [1] cond_resched might be not sufficient
to silence RCU stalls because that would require a real scheduling.
This is a separate problem, though, and Paul is working with Peter [2]
to resolve it.

Anyway, I believe that this patch should be a good start because it
really seems that nr_taken=0 during the LRU isolation can be triggered
in the real life. All reporters are agreeing to start seeing this issue
when moving on to 4.8 kernel which might be just a coincidence or a
different behavior of some subsystem. Well, MM has moved from zone to
node reclaim but I couldn't have found any direct relation to that
change.

[1] <a class="moz-txt-link-freetext" href="http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com">http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com</a>
[2] <a class="moz-txt-link-freetext" href="http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com">http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com</a>

 mm/vmscan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c05f00042430..c4abf08861d2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2362,6 +2362,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 			}
 		}
 
+		cond_resched();
+
 		if (nr_reclaimed &lt; nr_to_reclaim || scan_adjusted)
 			continue;
 
</pre>
    </blockquote>
    <br>
    Our two backup servers which had rcu stall warnings since 4.8 are
    running with this patch on top of v4.8.12 for 3 1/2 days now and
    didn't log any rcu stalls since then. So this patch might be fixing
    it for our environment, too. <br>
    <br>
    The previous times between boots and first occurrences of rcu stall
    warnings were:<br>
    <br>
    Server A ("void"): <span
      class="author-a-kpnz69zalnz65zz66zz72zaz89z1iz88z3">1d14h 5h 1d4h
      2d2h 21h 3d21h</span><br>
    Server B ("null"): 3d12h 2d3h 5d4h 4h 12h<br>
    <br>
    (Yes, this contradicts a previous mail from me, where I wrongly
    stated "37,0.2,1,2,0.8 hours" for the first server, because I messed
    up the units. Its "37 hours,  0.2 days, 1 day, 2 days, 0.8 days"
    which fits the first 5 numbers in the above list. Sorry.)<br>
    <br>
    We should wait a few days longer for a better p-value but there is
    reason for hope.<br>
    <br>
    Donald<br>
    <br>
    <pre class="moz-signature" cols="72">-- 
Donald Buczek
<a class="moz-txt-link-abbreviated" href="mailto:buczek@molgen.mpg.de">buczek@molgen.mpg.de</a>
Tel: +49 30 8413 1433
</pre>
  </body>
</html>

--------------375F8C773005DF889666C889--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
