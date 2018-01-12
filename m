Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC4F6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 23:20:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p1so3913927pfp.13
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 20:20:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ay1si8567626plb.2.2018.01.11.20.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 20:20:51 -0800 (PST)
Date: Thu, 11 Jan 2018 23:20:46 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111232046.778b447f@gandalf.local.home>
In-Reply-To: <20180111215547.2f66a23a@gandalf.local.home>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180111203057.5b1a8f8f@gandalf.local.home>
	<20180111215547.2f66a23a@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 21:55:47 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> I ran this on a box with 4 CPUs and a serial console (so it has a slow
> console). Again, all I have is each CPU doing exactly ONE printk()!
> then sleeping for a full millisecond! It will cause a lot of output,
> and perhaps slow the system down. But it should not lock up the system.
> But without my patch, it does!

I decided to see how this works without a slow serial console. So I
rebooted the box and enabled hyper-threading (doubling the number of
CPUs to 8), and then ran this module, with serial disabled.

As expected, it did not lock up. That's because there was only a single
console (VGA) and it is fast enough to keep up. Especially, since I
have a 1 millisecond sleep between printks.

But I ran the function_graph tracer to see what was happening. Here's
the unpatched case. It didn't take long to see a single CPU suffering
(and this is with a fast console!)

     kworker/1:2-309   [001]    78.677770: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    78.677772: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    78.677772: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    78.677778: funcgraph_exit:         4.528 us   |  }
     kworker/3:1-72    [003]    78.677779: funcgraph_exit:         5.875 us   |  }
     kworker/0:0-3     [000]    78.678745: funcgraph_entry:                   |  printk() {
     kworker/5:1-78    [005]    78.678749: funcgraph_entry:                   |  printk() {
     kworker/4:1-73    [004]    78.678751: funcgraph_entry:                   |  printk() {
     kworker/0:0-3     [000]    78.678752: funcgraph_exit:         4.893 us   |  }
     kworker/5:1-78    [005]    78.678754: funcgraph_exit:         4.287 us   |  }
     kworker/4:1-73    [004]    78.678756: funcgraph_exit:         3.964 us   |  }
     kworker/6:1-147   [006]    78.679751: funcgraph_entry:                   |  printk() {
     kworker/2:3-1295  [002]    78.679753: funcgraph_entry:                   |  printk() {
     kworker/6:1-147   [006]    78.679767: funcgraph_exit:       + 13.735 us  |  }
     kworker/2:3-1295  [002]    78.679768: funcgraph_exit:       + 14.318 us  |  }
     kworker/7:1-176   [007]    78.680751: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    78.680753: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    78.680756: funcgraph_exit:         3.981 us   |  }
     kworker/3:1-72    [003]    78.680757: funcgraph_exit:         3.499 us   |  }
     kworker/5:1-78    [005]    78.681734: funcgraph_entry:        3.388 us   |  printk();
     kworker/4:1-73    [004]    78.681752: funcgraph_entry:                   |  printk() {
     kworker/0:0-3     [000]    78.681753: funcgraph_entry:                   |  printk() {
     kworker/4:1-73    [004]    78.681756: funcgraph_exit:         3.009 us   |  }
     kworker/0:0-3     [000]    78.681757: funcgraph_exit:         3.708 us   |  }
     kworker/2:3-1295  [002]    78.682742: funcgraph_entry:                   |  printk() {
     kworker/6:1-147   [006]    78.682746: funcgraph_entry:                   |  printk() {
     kworker/2:3-1295  [002]    78.682749: funcgraph_exit:         4.548 us   |  }
     kworker/6:1-147   [006]    78.682750: funcgraph_exit:         3.001 us   |  }
     kworker/3:1-72    [003]    78.683751: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    78.683753: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    78.683756: funcgraph_exit:         3.869 us   |  }
     kworker/7:1-176   [007]    78.683757: funcgraph_exit:         4.300 us   |  }
     kworker/5:1-78    [005]    78.684736: funcgraph_entry:        2.074 us   |  printk();
     kworker/4:1-73    [004]    78.684755: funcgraph_entry:                   |  printk() {
     kworker/0:0-3     [000]    78.684755: funcgraph_entry:        3.065 us   |  printk();
     kworker/4:1-73    [004]    78.684760: funcgraph_exit:         4.091 us   |  }
     kworker/6:1-147   [006]    78.685744: funcgraph_entry:                   |  printk() {
     kworker/2:3-1295  [002]    78.685744: funcgraph_entry:        4.616 us   |  printk();
     kworker/6:1-147   [006]    78.685752: funcgraph_exit:         5.943 us   |  }
     kworker/7:1-176   [007]    78.686763: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    78.686767: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    78.686770: funcgraph_exit:         4.570 us   |  }
     kworker/3:1-72    [003]    78.686771: funcgraph_exit:         3.262 us   |  }
     kworker/1:2-309   [001]    78.687626: funcgraph_exit:       # 9854.982 us |  }


CPU 1 was stuck for 9 milliseconds doing nothing but handling printk.
And this is without a serial or slow console.

With a patched kernel:

     kworker/7:1-176   [007]    85.937411: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    85.937416: funcgraph_exit:         3.357 us   |  }
     kworker/7:1-176   [007]    85.937416: funcgraph_exit:         4.388 us   |  }
     kworker/2:2-315   [002]    85.937793: funcgraph_exit:       # 1391.842 us |  }
     kworker/1:2-592   [001]    85.938391: funcgraph_entry:                   |  printk() {
     kworker/4:2-529   [004]    85.938396: funcgraph_entry:        3.267 us   |  printk();
     kworker/6:1-150   [006]    85.938555: funcgraph_exit:       # 1159.354 us |  }
     kworker/0:2-127   [000]    85.939393: funcgraph_entry:                   |  printk() {
     kworker/5:2-352   [005]    85.939394: funcgraph_entry:      + 13.403 us  |  printk();
     kworker/1:2-592   [001]    85.939718: funcgraph_exit:       # 1325.211 us |  }
     kworker/0:2-127   [000]    85.940345: funcgraph_exit:       ! 951.361 us |  }
     kworker/7:1-176   [007]    85.940390: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    85.940390: funcgraph_entry:                   |  printk() {
     kworker/2:2-315   [002]    85.940391: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    85.940396: funcgraph_exit:         4.144 us   |  }
     kworker/2:2-315   [002]    85.940397: funcgraph_exit:         5.687 us   |  }
     kworker/4:2-529   [004]    85.941403: funcgraph_entry:                   |  printk() {
     kworker/6:1-150   [006]    85.941407: funcgraph_entry:        3.167 us   |  printk();
     kworker/3:1-72    [003]    85.941545: funcgraph_exit:       # 1153.899 us |  }
     kworker/4:2-529   [004]    85.942371: funcgraph_exit:       ! 966.322 us |  }
     kworker/1:2-592   [001]    85.942411: funcgraph_entry:                   |  printk() {
     kworker/5:2-352   [005]    85.942411: funcgraph_entry:                   |  printk() {
     kworker/1:2-592   [001]    85.942416: funcgraph_exit:         4.099 us   |  }
     kworker/0:2-127   [000]    85.942553: funcgraph_entry:                   |  printk() {
     kworker/5:2-352   [005]    85.942739: funcgraph_exit:       ! 326.853 us |  }
     kworker/0:2-127   [000]    85.943358: funcgraph_exit:       ! 804.095 us |  }
     kworker/2:2-315   [002]    85.943388: funcgraph_entry:                   |  printk() {
     kworker/7:1-176   [007]    85.943391: funcgraph_entry:                   |  printk() {
     kworker/2:2-315   [002]    85.943754: funcgraph_exit:       ! 364.921 us |  }
     kworker/7:1-176   [007]    85.944127: funcgraph_exit:       ! 734.864 us |  }
     kworker/6:1-150   [006]    85.944408: funcgraph_entry:                   |  printk() {
     kworker/3:1-72    [003]    85.944408: funcgraph_entry:        4.911 us   |  printk();
     kworker/6:1-150   [006]    85.945235: funcgraph_exit:       ! 826.596 us |  }
     kworker/0:2-127   [000]    85.945398: funcgraph_entry:                   |  printk() {
     kworker/5:2-352   [005]    85.945399: funcgraph_entry:                   |  printk() {
     kworker/4:2-529   [004]    85.945400: funcgraph_entry:                   |  printk() {
     kworker/1:2-592   [001]    85.945412: funcgraph_entry:                   |  printk() {
     kworker/5:2-352   [005]    85.945415: funcgraph_exit:       + 14.537 us  |  }
     kworker/4:2-529   [004]    85.945416: funcgraph_exit:         5.494 us   |  }
     kworker/0:2-127   [000]    85.945736: funcgraph_exit:       ! 337.000 us |  }
     kworker/7:1-176   [007]    85.946403: funcgraph_entry:                   |  printk() {
     kworker/2:2-315   [002]    85.946409: funcgraph_entry:        3.275 us   |  printk();
     kworker/1:2-592   [001]    85.946546: funcgraph_exit:       # 1133.155 us |  }

The load is spread out much better. No one CPU is stuck too badly.

As the function_graph tracer annotates functions that take over a
millisecond with a '#', I can grep and see how many take that long, and
for how long.

 $ trace-cmd report trace-printk-nopatch-8cpus.dat |grep '#'
     kworker/4:1-73    [004]    78.658973: funcgraph_exit:       # 1247.220 us |  }
     kworker/2:3-1295  [002]    78.662340: funcgraph_exit:       # 2616.456 us |  }
     kworker/7:1-176   [007]    78.671727: funcgraph_exit:       # 1996.234 us |  }
     kworker/4:1-73    [004]    78.676696: funcgraph_exit:       # 2954.230 us |  }
     kworker/1:2-309   [001]    78.687626: funcgraph_exit:       # 9854.982 us |  }
     kworker/5:1-78    [005]    78.692652: funcgraph_exit:       # 4920.607 us |  }
     kworker/5:1-78    [005]    78.696737: funcgraph_exit:       # 1983.090 us |  }
     kworker/5:1-78    [005]    78.701426: funcgraph_exit:       # 1686.832 us |  }
     kworker/2:3-1295  [002]    78.710736: funcgraph_exit:       # 6975.033 us |  }
     kworker/1:2-309   [001]    78.712455: funcgraph_exit:       # 1711.895 us |  }
     kworker/7:1-176   [007]    78.721588: funcgraph_exit:       # 7835.767 us |  }
     kworker/1:2-309   [001]    78.729626: funcgraph_exit:       # 5879.358 us |  }
     kworker/3:1-72    [003]    78.744426: funcgraph_exit:       # 12678.256 us |  }
     kworker/1:2-309   [001]    78.754549: funcgraph_exit:       # 7816.182 us |  }
     kworker/7:1-176   [007]    78.758612: funcgraph_exit:       # 1874.185 us |  }
     kworker/5:1-78    [005]    78.762615: funcgraph_exit:       # 1878.463 us |  }
     kworker/2:3-1295  [002]    78.771593: funcgraph_exit:       # 6849.619 us |  }
     kworker/3:1-72    [003]    78.776616: funcgraph_exit:       # 2868.446 us |  }
     kworker/1:2-309   [001]    78.780585: funcgraph_exit:       # 2843.085 us |  }
     kworker/7:1-176   [007]    78.785701: funcgraph_exit:       # 3949.963 us |  }
     kworker/1:2-309   [001]    78.787192: funcgraph_exit:       # 1452.146 us |  }
     kworker/2:3-1295  [002]    78.791554: funcgraph_exit:       # 2821.999 us |  }
     kworker/5:1-78    [005]    78.793686: funcgraph_exit:       # 1934.499 us |  }
     kworker/2:3-1295  [002]    78.795377: funcgraph_exit:       # 1641.652 us |  }
     kworker/6:1-147   [006]    78.815413: funcgraph_exit:       # 2669.295 us |  }
     kworker/5:1-78    [005]    78.821529: funcgraph_exit:       # 1782.758 us |  }
     kworker/5:1-78    [005]    78.826732: funcgraph_exit:       # 2993.772 us |  }
     kworker/6:1-147   [006]    78.829676: funcgraph_exit:       # 1920.164 us |  }
     kworker/5:1-78    [005]    78.831464: funcgraph_exit:       # 1728.834 us |  }
     kworker/1:2-309   [001]    78.833674: funcgraph_exit:       # 1939.356 us |  }
     kworker/1:2-309   [001]    78.839663: funcgraph_exit:       # 3908.825 us |  }
     kworker/5:1-78    [005]    78.841376: funcgraph_exit:       # 1624.089 us |  }
     kworker/1:2-309   [001]    78.843474: funcgraph_exit:       # 1725.975 us |  }
     kworker/5:1-78    [005]    78.845490: funcgraph_exit:       # 1753.258 us |  }
     kworker/5:1-78    [005]    78.850592: funcgraph_exit:       # 2839.801 us |  }
     kworker/2:3-1295  [002]    78.855668: funcgraph_exit:       # 3925.402 us |  }
     kworker/6:1-147   [006]    78.866346: funcgraph_exit:       # 10603.155 us |  }


CPUs can be stuck for over 10 milliseconds doing just printk!

With my patch:

     kworker/0:2-127   [000]    85.902486: funcgraph_exit:       # 1092.105 us |  }
     kworker/2:2-315   [002]    85.904458: funcgraph_exit:       # 1070.174 us |  }
     kworker/4:2-529   [004]    85.907523: funcgraph_exit:       # 1131.189 us |  }
     kworker/6:1-150   [006]    85.909187: funcgraph_exit:       # 1802.074 us |  }
     kworker/7:1-176   [007]    85.910534: funcgraph_exit:       # 1138.249 us |  }
     kworker/1:2-592   [001]    85.911586: funcgraph_exit:       # 1207.807 us |  }
     kworker/2:2-315   [002]    85.914585: funcgraph_exit:       # 1183.669 us |  }
     kworker/6:1-150   [006]    85.915426: funcgraph_exit:       # 1019.587 us |  }
     kworker/5:2-352   [005]    85.916516: funcgraph_exit:       # 1120.144 us |  }
     kworker/3:1-72    [003]    85.922472: funcgraph_exit:       # 1071.437 us |  }
     kworker/4:2-529   [004]    85.923685: funcgraph_exit:       # 1296.953 us |  }
     kworker/1:2-592   [001]    85.924481: funcgraph_exit:       # 1051.758 us |  }
     kworker/5:2-352   [005]    85.926536: funcgraph_exit:       # 1126.423 us |  }
     kworker/2:2-315   [002]    85.927403: funcgraph_exit:       # 1020.366 us |  }
     kworker/1:2-592   [001]    85.928493: funcgraph_exit:       # 1094.864 us |  }
     kworker/6:1-150   [006]    85.931457: funcgraph_exit:       # 1052.531 us |  }
     kworker/1:2-592   [001]    85.932779: funcgraph_exit:       # 1371.806 us |  }
     kworker/5:2-352   [005]    85.933536: funcgraph_exit:       # 1128.199 us |  }
     kworker/2:2-315   [002]    85.937793: funcgraph_exit:       # 1391.842 us |  }
     kworker/6:1-150   [006]    85.938555: funcgraph_exit:       # 1159.354 us |  }
     kworker/1:2-592   [001]    85.939718: funcgraph_exit:       # 1325.211 us |  }
     kworker/3:1-72    [003]    85.941545: funcgraph_exit:       # 1153.899 us |  }
     kworker/1:2-592   [001]    85.946546: funcgraph_exit:       # 1133.155 us |  }
     kworker/7:1-176   [007]    85.947730: funcgraph_exit:       # 1325.744 us |  }
     kworker/3:1-72    [003]    85.948588: funcgraph_exit:       # 1192.876 us |  }
     kworker/4:2-529   [004]    85.950647: funcgraph_exit:       # 2248.783 us |  }
     kworker/6:1-150   [006]    85.951463: funcgraph_exit:       # 1045.498 us |  }
     kworker/0:2-127   [000]    85.952576: funcgraph_exit:       # 1171.645 us |  }
     kworker/1:2-592   [001]    85.953393: funcgraph_exit:       # 1001.659 us |  }
     kworker/5:2-352   [005]    85.955542: funcgraph_exit:       # 1130.396 us |  }

It spreads the load out much nicer, and seldom goes over 2 milliseconds.

My trace was only for a few seconds (no events lost), and I can see the
max with:

 $ trace-cmd report trace-printk-nopatch-8cpus.dat | grep '#' | cut -d'#' -f1 | sort -n | tail -20
 13510.063 us |  }
 13531.914 us |  }
 13533.591 us |  }
 13574.488 us |  }
 13584.322 us |  }
 13611.234 us |  }
 13668.255 us |  }
 13710.294 us |  }
 13722.017 us |  }
 13725.000 us |  }
 13728.883 us |  }
 13740.601 us |  }
 13744.194 us |  }
 13770.512 us |  }
 13776.246 us |  }
 13809.729 us |  }
 13812.279 us |  }
 13830.563 us |  }
 13907.382 us |  }
 14498.937 us |  }

We had a printk take up to 14 millisecond with a VGA console on 8 CPUs,
where each CPU was doing a single printk once per millisecond.

With my patch:

 $ trace-cmd report trace-printk-patch-8cpus.dat |grep '#' | cut -d'#' -f 2 |sort -n | tail -20
 2477.627 us |  }
 2482.012 us |  }
 2482.077 us |  }
 2488.672 us |  }
 2490.253 us |  }
 2502.381 us |  }
 2503.990 us |  }
 2505.448 us |  }
 2509.389 us |  }
 2510.868 us |  }
 2511.597 us |  }
 2512.108 us |  }
 2538.886 us |  }
 3095.917 us |  }
 3137.604 us |  }
 3223.213 us |  }
 3324.967 us |  }
 3331.018 us |  }
 3331.518 us |  }
 3348.263 us |  }

We got up to just over 3 milliseconds for a single printk.

I think that's a damn good improvement.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
