Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 361206B00FB
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 20:10:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5FEB83EE0AE
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:09:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49EC345DE69
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:09:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33F5C45DE4D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:09:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2316E1DB803C
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:09:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF32C1DB802C
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:09:58 +0900 (JST)
Date: Tue, 21 Jun 2011 09:02:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] memcg: add reclaim pgfault latency histograms
Message-Id: <20110621090250.97c5abe2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=fj8xaThqSVFtzX1WGuzykkqSwpQ@mail.gmail.com>
References: <1308354828-30670-1-git-send-email-yinghan@google.com>
	<20110620084537.24b28e53.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=fj8xaThqSVFtzX1WGuzykkqSwpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 19 Jun 2011 23:08:52 -0700
Ying Han <yinghan@google.com> wrote:

> On Sunday, June 19, 2011, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 17 Jun 2011 16:53:48 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> This adds histogram to capture pagefault latencies on per-memcg basis. I used
> >> this patch on the memcg background reclaim test, and figured there could be more
> >> usecases to monitor/debug application performance.
> >>
> >> The histogram is composed 8 bucket in us unit. The last one is "rest" which is
> >> everything beyond the last one. To be more flexible, the buckets can be reset
> >> and also each bucket is configurable at runtime.
> >>
> >> memory.pgfault_histogram: exports the histogram on per-memcg basis and also can
> >> be reset by echoing "-1". Meantime, all the buckets are writable by echoing
> >> the range into the API. see the example below.
> >>
> >> change v3..v2:
> >> no change except rebasing the patch to 3.0-rc3 and retested.
> >>
> >> change v2..v1:
> >> 1. record the page fault involving reclaim only and changing the unit to us.
> >> 2. rename the "inf" to "rest".
> >> 3. removed the global tunable to turn on/off the recording. this is ok since
> >> there is no overhead measured by collecting the data.
> >> 4. changed reseting the history by echoing "-1".
> >>
> >> Functional Test:
> >> $ cat /dev/cgroup/memory/D/memory.pgfault_histogram
> >> page reclaim latency histogram (us):
> >> < 150 A  A  A  A  A  A 22
> >> < 200 A  A  A  A  A  A 17434
> >> < 250 A  A  A  A  A  A 69135
> >> < 300 A  A  A  A  A  A 17182
> >> < 350 A  A  A  A  A  A 4180
> >> < 400 A  A  A  A  A  A 3179
> >> < 450 A  A  A  A  A  A 2644
> >> < rest A  A  A  A  A  29840
> >>
> >> $ echo -1 >/dev/cgroup/memory/D/memory.pgfault_histogram
> >> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> >> page reclaim latency histogram (us):
> >> < 150 A  A  A  A  A  A 0
> >> < 200 A  A  A  A  A  A 0
> >> < 250 A  A  A  A  A  A 0
> >> < 300 A  A  A  A  A  A 0
> >> < 350 A  A  A  A  A  A 0
> >> < 400 A  A  A  A  A  A 0
> >> < 450 A  A  A  A  A  A 0
> >> < rest A  A  A  A  A  0
> >>
> >> $ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/D/memory.pgfault_histogram
> >> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> >> page reclaim latency histogram (us):
> >> < 500 A  A  A  A  A  A 0
> >> < 520 A  A  A  A  A  A 0
> >> < 540 A  A  A  A  A  A 0
> >> < 580 A  A  A  A  A  A 0
> >> < 600 A  A  A  A  A  A 0
> >> < 1000 A  A  A  A  A  0
> >> < 5000 A  A  A  A  A  0
> >> < rest A  A  A  A  A  0
> >>
> >> Performance Test:
> >> I ran through the PageFaultTest (pft) benchmark to measure the overhead of
> >> recording the histogram. There is no overhead observed on both "flt/cpu/s"
> >> and "fault/wsec".
> >>
> >> $ mkdir /dev/cgroup/memory/A
> >> $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
> >> $ echo $$ >/dev/cgroup/memory/A/tasks
> >> $ ./pft -m 15g -t 8 -T a
> >>
> >> Result:
> >> $ ./ministat no_histogram histogram
> >>
> >> "fault/wsec"
> >> x fault_wsec/no_histogram
> >> + fault_wsec/histogram
> >> +-------------------------------------------------------------------------+
> >> A  A  N A  A  A  A  A  Min A  A  A  A  A  Max A  A  A  A Median A  A  A  A  A  Avg A  A  A  A Stddev
> >> x A  5 A  A  864432.44 A  A  880840.81 A  A  879707.95 A  A  874606.51 A  A  7687.9841
> >> + A  5 A  A  861986.57 A  A  877867.25 A  A  A 870823.9 A  A  870901.38 A  A  6413.8821
> >> No difference proven at 95.0% confidence
> >>
> >> "flt/cpu/s"
> >> x flt_cpu_s/no_histogram
> >> + flt_cpu_s/histogram
> >> +-------------------------------------------------------------------------+
> >> A  A  I'll never ack this.
> 
> The patch is created as part of effort testing per-memcg bg reclaim
> patch. I don't have strong opinion that we indeed need to merge it,
> but found it is a useful testing and monitoring tool.
> 
> Meantime, can you help to clarify your concern? In case I missed
> something here.
> 

I want to see the numbers via 'perf' because of its flexibility.
For this kind of things, I like dumping "raw" data and parse it by
tools. Because we can change our view with a single data without
taking mulitple-data-by-multiple-experiments.

I like your idea of histgram. So, I'd like to try to write a
perf stuff when my memory.vmscan_stat is merged (it's good trace
point I think) and see what we can get.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
