Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 30DD06B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 20:38:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B61223EE0C1
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:38:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9695045DE6C
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:38:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B5745DE4E
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:38:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62E7CE18004
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:38:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AA691DB8038
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:38:36 +0900 (JST)
Date: Fri, 27 May 2011 09:31:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
Message-Id: <20110527093142.d3733053.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 26 May 2011 17:23:20 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 26, 2011 at 5:05 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 26 May 2011 14:07:49 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > This adds histogram to capture pagefault latencies on per-memcg basis. I
> > used
> > > this patch on the memcg background reclaim test, and figured there could
> > be more
> > > usecases to monitor/debug application performance.
> > >
> > > The histogram is composed 8 bucket in ns unit. The last one is infinite
> > (inf)
> > > which is everything beyond the last one. To be more flexible, the buckets
> > can
> > > be reset and also each bucket is configurable at runtime.
> > >
> > > memory.pgfault_histogram: exports the histogram on per-memcg basis and
> > also can
> > > be reset by echoing "reset". Meantime, all the buckets are writable by
> > echoing
> > > the range into the API. see the example below.
> > >
> > > /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to
> > turn
> > > on/off recording the histogram.
> > >
> > > Functional Test:
> > > Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
> > > Measure the anon page allocation latency.
> > >
> > > $ mkdir /dev/cgroup/memory/B
> > > $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
> > > $ echo $$ >/dev/cgroup/memory/B/tasks
> > > $ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
> > > $ allocate 8g anon pages
> > >
> > > $ echo 1 >/proc/sys/vm/pgfault_histogram
> > >
> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > > pgfault latency histogram (ns):
> > > < 600            2051273
> > > < 1200           40859
> > > < 2400           4004
> > > < 4800           1605
> > > < 9600           170
> > > < 19200          82
> > > < 38400          6
> > > < inf            0
> > >
> > > $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > > pgfault latency histogram (ns):
> > > < 600            0
> > > < 1200           0
> > > < 2400           0
> > > < 4800           0
> > > < 9600           0
> > > < 19200          0
> > > < 38400          0
> > > < inf            0
> > >
> > > $ echo 500 520 540 580 600 1000 5000
> > >/dev/cgroup/memory/B/memory.pgfault_histogram
> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > > pgfault latency histogram (ns):
> > > < 500            50
> > > < 520            151
> > > < 540            3715
> > > < 580            1859812
> > > < 600            202241
> > > < 1000           25394
> > > < 5000           5875
> > > < inf            186
> > >
> > > Performance Test:
> > > I ran through the PageFaultTest (pft) benchmark to measure the overhead
> > of
> > > recording the histogram. There is no overhead observed on both
> > "flt/cpu/s"
> > > and "fault/wsec".
> > >
> > > $ mkdir /dev/cgroup/memory/A
> > > $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
> > > $ echo $$ >/dev/cgroup/memory/A/tasks
> > > $ ./pft -m 15g -t 8 -T a
> > >
> > > Result:
> > > "fault/wsec"
> > >
> > > $ ./ministat no_histogram histogram
> > > x no_histogram
> > > + histogram
> > >
> > +--------------------------------------------------------------------------+
> > >    N           Min           Max        Median           Avg
> >  Stddev
> > > x   5     813404.51     824574.98      821661.3     820470.83
> > 4202.0758
> > > +   5     821228.91     825894.66     822874.65     823374.15
> > 1787.9355
> > >
> > > "flt/cpu/s"
> > >
> > > $ ./ministat no_histogram histogram
> > > x no_histogram
> > > + histogram
> > >
> > +--------------------------------------------------------------------------+
> > >    N           Min           Max        Median           Avg
> >  Stddev
> > > x   5     104951.93     106173.13     105142.73      105349.2
> > 513.78158
> > > +   5     104697.67      105416.1     104943.52     104973.77
> > 269.24781
> > > No difference proven at 95.0% confidence
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > Hmm, interesting....but isn't it very very very complicated interface ?
> > Could you make this for 'perf' ? Then, everyone (including someone who
> > don't use memcg)
> > will be happy.
> >
> 
> Thank you for looking at it.
> 
> There is only one per-memcg API added which is basically exporting the
> histogram. The "reset" and reconfiguring the bucket is not "must" but make
> it more flexible. Also, the sysfs API can be reduced if necessary since
> there is no over-head observed by always turning it on anyway.
> 
> I am not familiar w/ perf, any suggestions how it is supposed to be look
> like?
> 
> Thanks
> 

IIUC, you can record "all" latency information by perf record. Then, latency
information can be dumped out to some file.

You can add a python? script for perf as

  # perf report memory-reclaim-latency-histgram -f perf.data
                -o 500,1000,1500,2000.....
   ...show histgram in text.. or report the histgram in graphic.

Good point is
  - you can reuse perf.data and show histgram from another point of view.

  - you can show another cut of view, for example, I think you can write a
    parser to show "changes in hisgram by time", easily.
    You may able to generate a movie ;)
    
  - Now, perf cgroup is supported. Then,
    - you can see per task histgram
    - you can see per cgroup histgram
    - you can see per system-wide histgram
      (If you record latency of usual kswapd/alloc_pages)

  - If you record latency within shrink_zone(), you can show per-zone
    reclaim latency histgram. record parsers can gather them and
    show histgram. This will be benefical to cpuset users.


I'm sorry if I miss something.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
