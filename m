Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A06096B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:51:24 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p4VGpKbC002277
	for <linux-mm@kvack.org>; Tue, 31 May 2011 09:51:20 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe20.cbf.corp.google.com with ESMTP id p4VGpIk9029129
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 May 2011 09:51:18 -0700
Received: by qyk7 with SMTP id 7so2841871qyk.17
        for <linux-mm@kvack.org>; Tue, 31 May 2011 09:51:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110528101745.GA15692@elte.hu>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
	<20110527093142.d3733053.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimSXrqPudRZ=af9N7k+Z=p5V+nxHQ@mail.gmail.com>
	<20110528101745.GA15692@elte.hu>
Date: Tue, 31 May 2011 09:51:15 -0700
Message-ID: <BANLkTin3v=ib+Zc7HVqLj_ROCDLFndGAZokcseSxzzWej26xoA@mail.gmail.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>

On Sat, May 28, 2011 at 3:17 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Ying Han <yinghan@google.com> wrote:
>
>> After study a bit on perf, it is not feasible in this casecase. The
>> cpu & memory overhead of perf is overwhelming.... Each page fault
>> will generate a record in the buffer and how many data we can
>> record in the buffer, and how many data will be processed later..
>> Most of the data that is recorded by the general perf framework is
>> not needed here.
>>
>>
>> On the other hand, the memory consumption is very little in this
>> patch. We only need to keep a counter of each bucket and the
>> recording can go on as long as the machine is up. As also measured,
>> there is no overhead of the data collection :)
>>
>> So, the perf is not an option for this purpose.
>
> It's not a fundamental limitation in perf though.
>
> The way i always thought perf could be extended to support heavy-duty
> profiling such as your patch does would be along the following lines:
>
> Right now perf supports three output methods:
>
> =A0 =A0 =A0 =A0 =A0 'full detail': per sample records, recorded in the ri=
ng-buffer
> =A0'filtered full detail': per sample records filtered, recorded in the r=
ing-buffer
> =A0 =A0 =A0 =A0 =A0'full summary': the count of all samples (simple count=
er), no recording
>
> What i think would make sense is to introduce a fourth variant, which
> is a natural intermediate of the above output methods:
>
> =A0 =A0 =A0 'partial summary': partially summarized samples, record in an
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0array in the ring-buff=
er - an extended
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0multi-dimensional 'cou=
nt'.
>
> A histogram like yours would be one (small) sub-case of this new
> model.
>
> Now, to keep things maximally flexible we really do not want to hard
> code histogram summary functions: i.e. we do not want to hardcode
> ourselves to 'latency histograms' or 'frequency histograms'.
>
> To achieve that flexibility we could define the histogram function as
> a simple extension to filters: filters that evaluate to an integer
> value.
>
> For example, if we defined the following tracepoint in
> arch/x86/mm/fault.c:
>
> TRACE_EVENT(mm_pagefault,
>
> =A0 =A0 =A0 TP_PROTO(u64 time_start, u64 time_end, unsigned long address,=
 int error_code, unsigned long ip),
>
> =A0 =A0 =A0 TP_ARGS(time_start, time_end, address, error_code, ip),
>
> =A0 =A0 =A0 TP_STRUCT__entry(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(u64, =A0 =A0 =A0 =A0 =A0 time_start)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(u64, =A0 =A0 =A0 =A0 =A0 time_end)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, address)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, error_code)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, ip)
> =A0 =A0 =A0 ),
>
> =A0 =A0 =A0 TP_fast_assign(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->time_start =A0 =A0 =3D time_start;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->time_end =A0 =A0 =A0 =3D time_end;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->address =A0 =A0 =A0 =A0=3D address;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->error_code =A0 =A0 =3D error_code;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ip =A0 =A0 =A0 =A0 =A0 =A0 =3D ip;
> =A0 =A0 =A0 ),
>
> =A0 =A0 =A0 TP_printk("time_start=3D%uL time_end=3D%uL address=3D%lx, err=
or code=3D%lx, ip=3D%lx",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->time_start, __entry->time_end,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->address, __entry->error_code, __entr=
y->ip)
>
>
> Then the following filter expressions could be used to calculate the
> histogram index and value:
>
> =A0 =A0 =A0 =A0 =A0 index: "(time_end - time_start)/1000"
> =A0 =A0 =A0 =A0iterator: "curr + 1"
>
> The /1000 index filter expression means that there is one separate
> bucket per microsecond of delay.
>
> The "curr + 1" iterator filter expression would represent that for
> every bucket an event means we add +1 to the current bucket value.
>
> Today our filter expressions evaluate to a small subset of integer
> numbers: 0 or 1 :-)
>
> Extending them to integer calculations is possible and would be
> desirable for other purposes as well, not just histograms. Adding
> integer operators in addition to the logical and bitwise operators
> the filter engine supports today would be useful as well. (See
> kernel/trace/trace_events_filter.c for the current filter engine.)
>
> This way we would have the equivalent functionality and performance
> of your histogram patch - and it would also open up many, *many*
> other nice possibilities as well:
>
> =A0- this could be used with any event, anywhere - could even be used
> =A0 with hardware events. We could sample with an NMI every 100 usecs
> =A0 and profile with relatively small profiling overhead.
>
> =A0- arbitrarily large histograms could be created: need a 10 GB
> =A0 histogram on a really large system? No problem, create such
> =A0 a big ring-buffer.
>
> =A0- many different types of summaries are possible as well:
>
> =A0 =A0- we could create a histogram over *which* code pagefaults, via
> =A0 =A0 =A0using the "ip" (faulting instruction) address and a
> =A0 =A0 =A0sufficiently large ring-buffer.
>
> =A0 =A0- histogram over the address space (which vmas are the hottest one=
s),
> =A0 =A0 =A0by changing the first filter to "address/1000000" to have per
> =A0 =A0 =A0megabyte buckets.
>
> =A0 =A0- weighted histograms: for example if the histogram iteration
> =A0 =A0 =A0function is "curr + (time_end-time_start)/1000" and the
> =A0 =A0 =A0histogram index is "address/1000000", then we get an
> =A0 =A0 =A0address-indexed histogram weighted by length of latency: the
> =A0 =A0 =A0higher latencies a given area of memory causes, the hotter the
> =A0 =A0 =A0bucket.
>
> =A0- the existing event filter code can be used to filter the incoming
> =A0 events to begin with: for example an "error_code =3D 1" filter would
> =A0 limit the histogram to write faults (page dirtying).
>
> So instead of adding just one hardcoded histogram type, it would be
> really nice to work on a more generic solution!
>
> Thanks,
>
> =A0 =A0 =A0 =A0Ingo

Hi Ingo,

Thank you for the detailed information.

This patch is used to evaluating the memcg reclaim patch and I have
got some interesting results.  I will post the next version of the
patch which made couple of improvement based on the comments from the
thread. Meantime, I will need to study more on your suggestion :)

Thanks

--Ying
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
