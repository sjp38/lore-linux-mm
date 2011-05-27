Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 465FF6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 14:46:36 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p4RIkPJa013339
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:46:25 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq11.eem.corp.google.com with ESMTP id p4RIjR54030882
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:46:24 -0700
Received: by qwc9 with SMTP id 9so1706121qwc.27
        for <linux-mm@kvack.org>; Fri, 27 May 2011 11:46:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527173331.087c6615.kamezawa.hiroyu@jp.fujitsu.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
	<20110527093142.d3733053.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimSXrqPudRZ=af9N7k+Z=p5V+nxHQ@mail.gmail.com>
	<20110527111102.f5bd5ff1.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTik_zV38MGittCrWfwnkLVuVCvdjBg@mail.gmail.com>
	<20110527173331.087c6615.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 May 2011 11:46:23 -0700
Message-ID: <BANLkTim96thMbFoN+wOWESm4bpUxXX_wFA@mail.gmail.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, May 27, 2011 at 1:33 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 26 May 2011 21:45:28 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Thu, May 26, 2011 at 7:11 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, 26 May 2011 18:40:44 -0700
>> > Ying Han <yinghan@google.com> wrote:
>> >
>> >> On Thu, May 26, 2011 at 5:31 PM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > On Thu, 26 May 2011 17:23:20 -0700
>> >> > Ying Han <yinghan@google.com> wrote:
>> >> >
>> >> >> On Thu, May 26, 2011 at 5:05 PM, KAMEZAWA Hiroyuki <
>> >> >> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> >>
>> >> >> > On Thu, 26 May 2011 14:07:49 -0700
>> >> >> > Ying Han <yinghan@google.com> wrote:
>> >> >> >
>> >> >> > > This adds histogram to capture pagefault latencies on per-memc=
g basis. I
>> >> >> > used
>> >> >> > > this patch on the memcg background reclaim test, and figured t=
here could
>> >> >> > be more
>> >> >> > > usecases to monitor/debug application performance.
>> >> >> > >
>> >> >> > > The histogram is composed 8 bucket in ns unit. The last one is=
 infinite
>> >> >> > (inf)
>> >> >> > > which is everything beyond the last one. To be more flexible, =
the buckets
>> >> >> > can
>> >> >> > > be reset and also each bucket is configurable at runtime.
>> >> >> > >
>> >> >> > > memory.pgfault_histogram: exports the histogram on per-memcg b=
asis and
>> >> >> > also can
>> >> >> > > be reset by echoing "reset". Meantime, all the buckets are wri=
table by
>> >> >> > echoing
>> >> >> > > the range into the API. see the example below.
>> >> >> > >
>> >> >> > > /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be=
 used to
>> >> >> > turn
>> >> >> > > on/off recording the histogram.
>> >> >> > >
>> >> >> > > Functional Test:
>> >> >> > > Create a memcg with 10g hard_limit, running dd & allocate 8g a=
non page.
>> >> >> > > Measure the anon page allocation latency.
>> >> >> > >
>> >> >> > > $ mkdir /dev/cgroup/memory/B
>> >> >> > > $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
>> >> >> > > $ echo $$ >/dev/cgroup/memory/B/tasks
>> >> >> > > $ dd if=3D/dev/zero of=3D/export/hdc3/dd/tf0 bs=3D1024 count=
=3D20971520 &
>> >> >> > > $ allocate 8g anon pages
>> >> >> > >
>> >> >> > > $ echo 1 >/proc/sys/vm/pgfault_histogram
>> >> >> > >
>> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> >> >> > > pgfault latency histogram (ns):
>> >> >> > > < 600 =A0 =A0 =A0 =A0 =A0 =A02051273
>> >> >> > > < 1200 =A0 =A0 =A0 =A0 =A0 40859
>> >> >> > > < 2400 =A0 =A0 =A0 =A0 =A0 4004
>> >> >> > > < 4800 =A0 =A0 =A0 =A0 =A0 1605
>> >> >> > > < 9600 =A0 =A0 =A0 =A0 =A0 170
>> >> >> > > < 19200 =A0 =A0 =A0 =A0 =A082
>> >> >> > > < 38400 =A0 =A0 =A0 =A0 =A06
>> >> >> > > < inf =A0 =A0 =A0 =A0 =A0 =A00
>> >> >> > >
>> >> >> > > $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
>> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> >> >> > > pgfault latency histogram (ns):
>> >> >> > > < 600 =A0 =A0 =A0 =A0 =A0 =A00
>> >> >> > > < 1200 =A0 =A0 =A0 =A0 =A0 0
>> >> >> > > < 2400 =A0 =A0 =A0 =A0 =A0 0
>> >> >> > > < 4800 =A0 =A0 =A0 =A0 =A0 0
>> >> >> > > < 9600 =A0 =A0 =A0 =A0 =A0 0
>> >> >> > > < 19200 =A0 =A0 =A0 =A0 =A00
>> >> >> > > < 38400 =A0 =A0 =A0 =A0 =A00
>> >> >> > > < inf =A0 =A0 =A0 =A0 =A0 =A00
>> >> >> > >
>> >> >> > > $ echo 500 520 540 580 600 1000 5000
>> >> >> > >/dev/cgroup/memory/B/memory.pgfault_histogram
>> >> >> > > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> >> >> > > pgfault latency histogram (ns):
>> >> >> > > < 500 =A0 =A0 =A0 =A0 =A0 =A050
>> >> >> > > < 520 =A0 =A0 =A0 =A0 =A0 =A0151
>> >> >> > > < 540 =A0 =A0 =A0 =A0 =A0 =A03715
>> >> >> > > < 580 =A0 =A0 =A0 =A0 =A0 =A01859812
>> >> >> > > < 600 =A0 =A0 =A0 =A0 =A0 =A0202241
>> >> >> > > < 1000 =A0 =A0 =A0 =A0 =A0 25394
>> >> >> > > < 5000 =A0 =A0 =A0 =A0 =A0 5875
>> >> >> > > < inf =A0 =A0 =A0 =A0 =A0 =A0186
>> >> >> > >
>> >> >> > > Performance Test:
>> >> >> > > I ran through the PageFaultTest (pft) benchmark to measure the=
 overhead
>> >> >> > of
>> >> >> > > recording the histogram. There is no overhead observed on both
>> >> >> > "flt/cpu/s"
>> >> >> > > and "fault/wsec".
>> >> >> > >
>> >> >> > > $ mkdir /dev/cgroup/memory/A
>> >> >> > > $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
>> >> >> > > $ echo $$ >/dev/cgroup/memory/A/tasks
>> >> >> > > $ ./pft -m 15g -t 8 -T a
>> >> >> > >
>> >> >> > > Result:
>> >> >> > > "fault/wsec"
>> >> >> > >
>> >> >> > > $ ./ministat no_histogram histogram
>> >> >> > > x no_histogram
>> >> >> > > + histogram
>> >> >> > >
>> >> >> > +---------------------------------------------------------------=
-----------+
>> >> >> > > =A0 =A0N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =
=A0 =A0 =A0Median =A0 =A0 =A0 =A0 =A0 Avg
>> >> >> > =A0Stddev
>> >> >> > > x =A0 5 =A0 =A0 813404.51 =A0 =A0 824574.98 =A0 =A0 =A0821661.=
3 =A0 =A0 820470.83
>> >> >> > 4202.0758
>> >> >> > > + =A0 5 =A0 =A0 821228.91 =A0 =A0 825894.66 =A0 =A0 822874.65 =
=A0 =A0 823374.15
>> >> >> > 1787.9355
>> >> >> > >
>> >> >> > > "flt/cpu/s"
>> >> >> > >
>> >> >> > > $ ./ministat no_histogram histogram
>> >> >> > > x no_histogram
>> >> >> > > + histogram
>> >> >> > >
>> >> >> > +---------------------------------------------------------------=
-----------+
>> >> >> > > =A0 =A0N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =
=A0 =A0 =A0Median =A0 =A0 =A0 =A0 =A0 Avg
>> >> >> > =A0Stddev
>> >> >> > > x =A0 5 =A0 =A0 104951.93 =A0 =A0 106173.13 =A0 =A0 105142.73 =
=A0 =A0 =A0105349.2
>> >> >> > 513.78158
>> >> >> > > + =A0 5 =A0 =A0 104697.67 =A0 =A0 =A0105416.1 =A0 =A0 104943.5=
2 =A0 =A0 104973.77
>> >> >> > 269.24781
>> >> >> > > No difference proven at 95.0% confidence
>> >> >> > >
>> >> >> > > Signed-off-by: Ying Han <yinghan@google.com>
>> >> >> >
>> >> >> > Hmm, interesting....but isn't it very very very complicated inte=
rface ?
>> >> >> > Could you make this for 'perf' ? Then, everyone (including someo=
ne who
>> >> >> > don't use memcg)
>> >> >> > will be happy.
>> >> >> >
>> >> >>
>> >> >> Thank you for looking at it.
>> >> >>
>> >> >> There is only one per-memcg API added which is basically exporting=
 the
>> >> >> histogram. The "reset" and reconfiguring the bucket is not "must" =
but make
>> >> >> it more flexible. Also, the sysfs API can be reduced if necessary =
since
>> >> >> there is no over-head observed by always turning it on anyway.
>> >> >>
>> >> >> I am not familiar w/ perf, any suggestions how it is supposed to b=
e look
>> >> >> like?
>> >> >>
>> >> >> Thanks
>> >> >>
>> >> >
>> >> > IIUC, you can record "all" latency information by perf record. Then=
, latency
>> >> > information can be dumped out to some file.
>> >> >
>> >> > You can add a python? script for perf as
>> >> >
>> >> > =A0# perf report memory-reclaim-latency-histgram -f perf.data
>> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-o 500,1000,1500,2000.....
>> >> > =A0 ...show histgram in text.. or report the histgram in graphic.
>> >> >
>> >> > Good point is
>> >> > =A0- you can reuse perf.data and show histgram from another point o=
f view.
>> >> >
>> >> > =A0- you can show another cut of view, for example, I think you can=
 write a
>> >> > =A0 =A0parser to show "changes in hisgram by time", easily.
>> >> > =A0 =A0You may able to generate a movie ;)
>> >> >
>> >> > =A0- Now, perf cgroup is supported. Then,
>> >> > =A0 =A0- you can see per task histgram
>> >> > =A0 =A0- you can see per cgroup histgram
>> >> > =A0 =A0- you can see per system-wide histgram
>> >> > =A0 =A0 =A0(If you record latency of usual kswapd/alloc_pages)
>> >> >
>> >> > =A0- If you record latency within shrink_zone(), you can show per-z=
one
>> >> > =A0 =A0reclaim latency histgram. record parsers can gather them and
>> >> > =A0 =A0show histgram. This will be benefical to cpuset users.
>> >> >
>> >> >
>> >> > I'm sorry if I miss something.
>> >>
>> >> After study a bit on perf, it is not feasible in this casecase. The
>> >> cpu & memory overhead of perf is overwhelming.... Each page fault wil=
l
>> >> generate a record in the buffer and how many data we can record in th=
e
>> >> buffer, and how many data will be processed later.. Most of the data
>> >> that is recorded by the general perf framework is not needed here.
>> >>
>> >
>> > I disagree. "each page fault" is not correct. "every lru scan" is corr=
ect.
>> > Then, record to buffer will be at most memory.failcnt times.
>>
>> Hmm. Sorry I might miss something here... :(
>>
>> The page fault histogram recorded is per page-fault, only the ones
>> trigger reclaim. The background reclaim testing is just one usecase of
>> it, and we need this information for more
>> general usage to monitor application performance. So i recorded the
>> latency for each single page fault.
>>
>
> BTW, why page-fault only ? For some applications, file cache is more impo=
ratant.
> I think usual page fault's usual cost is not in interest.
> you can get PGPGIN statistics from other source.
>
> Anyway, I think it's better for record reclaim latency.

Sounds reasonable. I will add that in the next post.

Thanks for reviewing

--Ying

>
>
> Thanks,
> -Kame
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
