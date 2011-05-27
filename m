Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E140E6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 04:40:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3B4763EE0C5
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:40:26 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 19E1745DF86
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:40:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0150E45DF85
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:40:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8B241DB8045
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:40:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C134EE78003
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:40:24 +0900 (JST)
Date: Fri, 27 May 2011 17:33:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
Message-Id: <20110527173331.087c6615.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTik_zV38MGittCrWfwnkLVuVCvdjBg@mail.gmail.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
	<20110527093142.d3733053.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimSXrqPudRZ=af9N7k+Z=p5V+nxHQ@mail.gmail.com>
	<20110527111102.f5bd5ff1.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTik_zV38MGittCrWfwnkLVuVCvdjBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 26 May 2011 21:45:28 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 26, 2011 at 7:11 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 26 May 2011 18:40:44 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Thu, May 26, 2011 at 5:31 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Thu, 26 May 2011 17:23:20 -0700
> >> > Ying Han <yinghan@google.com> wrote:
> >> >
> >> >> On Thu, May 26, 2011 at 5:05 PM, KAMEZAWA Hiroyuki <
> >> >> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >>
> >> >> > On Thu, 26 May 2011 14:07:49 -0700
> >> >> > Ying Han <yinghan@google.com> wrote:
> >> >> >
> >> >> > > This adds histogram to capture pagefault latencies on per-memcg basis. I
> >> >> > used
> >> >> > > this patch on the memcg background reclaim test, and figured there could
> >> >> > be more
> >> >> > > usecases to monitor/debug application performance.
> >> >> > >
> >> >> > > The histogram is composed 8 bucket in ns unit. The last one is infinite
> >> >> > (inf)
> >> >> > > which is everything beyond the last one. To be more flexible, the buckets
> >> >> > can
> >> >> > > be reset and also each bucket is configurable at runtime.
> >> >> > >
> >> >> > > memory.pgfault_histogram: exports the histogram on per-memcg basis and
> >> >> > also can
> >> >> > > be reset by echoing "reset". Meantime, all the buckets are writable by
> >> >> > echoing
> >> >> > > the range into the API. see the example below.
> >> >> > >
> >> >> > > /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to
> >> >> > turn
> >> >> > > on/off recording the histogram.
> >> >> > >
> >> >> > > Functional Test:
> >> >> > > Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
> >> >> > > Measure the anon page allocation latency.
> >> >> > >
> >> >> > > $ mkdir /dev/cgroup/memory/B
> >> >> > > $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
> >> >> > > $ echo $$ >/dev/cgroup/memory/B/tasks
> >> >> > > $ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
> >> >> > > $ allocate 8g anon pages
> >> >> > >
> >> >> > > $ echo 1 >/proc/sys/vm/pgfault_histogram
> >> >> > >
> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> >> >> > > pgfault latency histogram (ns):
> >> >> > > < 600 A  A  A  A  A  A 2051273
> >> >> > > < 1200 A  A  A  A  A  40859
> >> >> > > < 2400 A  A  A  A  A  4004
> >> >> > > < 4800 A  A  A  A  A  1605
> >> >> > > < 9600 A  A  A  A  A  170
> >> >> > > < 19200 A  A  A  A  A 82
> >> >> > > < 38400 A  A  A  A  A 6
> >> >> > > < inf A  A  A  A  A  A 0
> >> >> > >
> >> >> > > $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> >> >> > > pgfault latency histogram (ns):
> >> >> > > < 600 A  A  A  A  A  A 0
> >> >> > > < 1200 A  A  A  A  A  0
> >> >> > > < 2400 A  A  A  A  A  0
> >> >> > > < 4800 A  A  A  A  A  0
> >> >> > > < 9600 A  A  A  A  A  0
> >> >> > > < 19200 A  A  A  A  A 0
> >> >> > > < 38400 A  A  A  A  A 0
> >> >> > > < inf A  A  A  A  A  A 0
> >> >> > >
> >> >> > > $ echo 500 520 540 580 600 1000 5000
> >> >> > >/dev/cgroup/memory/B/memory.pgfault_histogram
> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> >> >> > > pgfault latency histogram (ns):
> >> >> > > < 500 A  A  A  A  A  A 50
> >> >> > > < 520 A  A  A  A  A  A 151
> >> >> > > < 540 A  A  A  A  A  A 3715
> >> >> > > < 580 A  A  A  A  A  A 1859812
> >> >> > > < 600 A  A  A  A  A  A 202241
> >> >> > > < 1000 A  A  A  A  A  25394
> >> >> > > < 5000 A  A  A  A  A  5875
> >> >> > > < inf A  A  A  A  A  A 186
> >> >> > >
> >> >> > > Performance Test:
> >> >> > > I ran through the PageFaultTest (pft) benchmark to measure the overhead
> >> >> > of
> >> >> > > recording the histogram. There is no overhead observed on both
> >> >> > "flt/cpu/s"
> >> >> > > and "fault/wsec".
> >> >> > >
> >> >> > > $ mkdir /dev/cgroup/memory/A
> >> >> > > $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
> >> >> > > $ echo $$ >/dev/cgroup/memory/A/tasks
> >> >> > > $ ./pft -m 15g -t 8 -T a
> >> >> > >
> >> >> > > Result:
> >> >> > > "fault/wsec"
> >> >> > >
> >> >> > > $ ./ministat no_histogram histogram
> >> >> > > x no_histogram
> >> >> > > + histogram
> >> >> > >
> >> >> > +--------------------------------------------------------------------------+
> >> >> > > A  A N A  A  A  A  A  Min A  A  A  A  A  Max A  A  A  A Median A  A  A  A  A  Avg
> >> >> > A Stddev
> >> >> > > x A  5 A  A  813404.51 A  A  824574.98 A  A  A 821661.3 A  A  820470.83
> >> >> > 4202.0758
> >> >> > > + A  5 A  A  821228.91 A  A  825894.66 A  A  822874.65 A  A  823374.15
> >> >> > 1787.9355
> >> >> > >
> >> >> > > "flt/cpu/s"
> >> >> > >
> >> >> > > $ ./ministat no_histogram histogram
> >> >> > > x no_histogram
> >> >> > > + histogram
> >> >> > >
> >> >> > +--------------------------------------------------------------------------+
> >> >> > > A  A N A  A  A  A  A  Min A  A  A  A  A  Max A  A  A  A Median A  A  A  A  A  Avg
> >> >> > A Stddev
> >> >> > > x A  5 A  A  104951.93 A  A  106173.13 A  A  105142.73 A  A  A 105349.2
> >> >> > 513.78158
> >> >> > > + A  5 A  A  104697.67 A  A  A 105416.1 A  A  104943.52 A  A  104973.77
> >> >> > 269.24781
> >> >> > > No difference proven at 95.0% confidence
> >> >> > >
> >> >> > > Signed-off-by: Ying Han <yinghan@google.com>
> >> >> >
> >> >> > Hmm, interesting....but isn't it very very very complicated interface ?
> >> >> > Could you make this for 'perf' ? Then, everyone (including someone who
> >> >> > don't use memcg)
> >> >> > will be happy.
> >> >> >
> >> >>
> >> >> Thank you for looking at it.
> >> >>
> >> >> There is only one per-memcg API added which is basically exporting the
> >> >> histogram. The "reset" and reconfiguring the bucket is not "must" but make
> >> >> it more flexible. Also, the sysfs API can be reduced if necessary since
> >> >> there is no over-head observed by always turning it on anyway.
> >> >>
> >> >> I am not familiar w/ perf, any suggestions how it is supposed to be look
> >> >> like?
> >> >>
> >> >> Thanks
> >> >>
> >> >
> >> > IIUC, you can record "all" latency information by perf record. Then, latency
> >> > information can be dumped out to some file.
> >> >
> >> > You can add a python? script for perf as
> >> >
> >> > A # perf report memory-reclaim-latency-histgram -f perf.data
> >> > A  A  A  A  A  A  A  A -o 500,1000,1500,2000.....
> >> > A  ...show histgram in text.. or report the histgram in graphic.
> >> >
> >> > Good point is
> >> > A - you can reuse perf.data and show histgram from another point of view.
> >> >
> >> > A - you can show another cut of view, for example, I think you can write a
> >> > A  A parser to show "changes in hisgram by time", easily.
> >> > A  A You may able to generate a movie ;)
> >> >
> >> > A - Now, perf cgroup is supported. Then,
> >> > A  A - you can see per task histgram
> >> > A  A - you can see per cgroup histgram
> >> > A  A - you can see per system-wide histgram
> >> > A  A  A (If you record latency of usual kswapd/alloc_pages)
> >> >
> >> > A - If you record latency within shrink_zone(), you can show per-zone
> >> > A  A reclaim latency histgram. record parsers can gather them and
> >> > A  A show histgram. This will be benefical to cpuset users.
> >> >
> >> >
> >> > I'm sorry if I miss something.
> >>
> >> After study a bit on perf, it is not feasible in this casecase. The
> >> cpu & memory overhead of perf is overwhelming.... Each page fault will
> >> generate a record in the buffer and how many data we can record in the
> >> buffer, and how many data will be processed later.. Most of the data
> >> that is recorded by the general perf framework is not needed here.
> >>
> >
> > I disagree. "each page fault" is not correct. "every lru scan" is correct.
> > Then, record to buffer will be at most memory.failcnt times.
> 
> Hmm. Sorry I might miss something here... :(
> 
> The page fault histogram recorded is per page-fault, only the ones
> trigger reclaim. The background reclaim testing is just one usecase of
> it, and we need this information for more
> general usage to monitor application performance. So i recorded the
> latency for each single page fault.
> 

BTW, why page-fault only ? For some applications, file cache is more imporatant.
I think usual page fault's usual cost is not in interest.
you can get PGPGIN statistics from other source.

Anyway, I think it's better for record reclaim latency.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
