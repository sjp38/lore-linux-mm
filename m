Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AF48C6B0134
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 20:33:27 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p5L0XMJh031566
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 17:33:25 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq1.eem.corp.google.com with ESMTP id p5L0WRIN008031
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 17:33:21 -0700
Received: by qwc9 with SMTP id 9so1954915qwc.27
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 17:33:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110621090250.97c5abe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1308354828-30670-1-git-send-email-yinghan@google.com>
	<20110620084537.24b28e53.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=fj8xaThqSVFtzX1WGuzykkqSwpQ@mail.gmail.com>
	<20110621090250.97c5abe2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 17:33:20 -0700
Message-ID: <BANLkTim2LNVmDwJvUncwhcNeGGgk-D28tOLabwFCO703Ebov5Q@mail.gmail.com>
Subject: Re: [PATCH V3] memcg: add reclaim pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 20, 2011 at 5:02 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sun, 19 Jun 2011 23:08:52 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Sunday, June 19, 2011, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Fri, 17 Jun 2011 16:53:48 -0700
>> > Ying Han <yinghan@google.com> wrote:
>> >
>> >> This adds histogram to capture pagefault latencies on per-memcg basis=
. I used
>> >> this patch on the memcg background reclaim test, and figured there co=
uld be more
>> >> usecases to monitor/debug application performance.
>> >>
>> >> The histogram is composed 8 bucket in us unit. The last one is "rest"=
 which is
>> >> everything beyond the last one. To be more flexible, the buckets can =
be reset
>> >> and also each bucket is configurable at runtime.
>> >>
>> >> memory.pgfault_histogram: exports the histogram on per-memcg basis an=
d also can
>> >> be reset by echoing "-1". Meantime, all the buckets are writable by e=
choing
>> >> the range into the API. see the example below.
>> >>
>> >> change v3..v2:
>> >> no change except rebasing the patch to 3.0-rc3 and retested.
>> >>
>> >> change v2..v1:
>> >> 1. record the page fault involving reclaim only and changing the unit=
 to us.
>> >> 2. rename the "inf" to "rest".
>> >> 3. removed the global tunable to turn on/off the recording. this is o=
k since
>> >> there is no overhead measured by collecting the data.
>> >> 4. changed reseting the history by echoing "-1".
>> >>
>> >> Functional Test:
>> >> $ cat /dev/cgroup/memory/D/memory.pgfault_histogram
>> >> page reclaim latency histogram (us):
>> >> < 150 =A0 =A0 =A0 =A0 =A0 =A022
>> >> < 200 =A0 =A0 =A0 =A0 =A0 =A017434
>> >> < 250 =A0 =A0 =A0 =A0 =A0 =A069135
>> >> < 300 =A0 =A0 =A0 =A0 =A0 =A017182
>> >> < 350 =A0 =A0 =A0 =A0 =A0 =A04180
>> >> < 400 =A0 =A0 =A0 =A0 =A0 =A03179
>> >> < 450 =A0 =A0 =A0 =A0 =A0 =A02644
>> >> < rest =A0 =A0 =A0 =A0 =A0 29840
>> >>
>> >> $ echo -1 >/dev/cgroup/memory/D/memory.pgfault_histogram
>> >> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> >> page reclaim latency histogram (us):
>> >> < 150 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 200 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 250 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 300 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 350 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 400 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 450 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < rest =A0 =A0 =A0 =A0 =A0 0
>> >>
>> >> $ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/D/memory.pgf=
ault_histogram
>> >> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> >> page reclaim latency histogram (us):
>> >> < 500 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 520 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 540 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 580 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 600 =A0 =A0 =A0 =A0 =A0 =A00
>> >> < 1000 =A0 =A0 =A0 =A0 =A0 0
>> >> < 5000 =A0 =A0 =A0 =A0 =A0 0
>> >> < rest =A0 =A0 =A0 =A0 =A0 0
>> >>
>> >> Performance Test:
>> >> I ran through the PageFaultTest (pft) benchmark to measure the overhe=
ad of
>> >> recording the histogram. There is no overhead observed on both "flt/c=
pu/s"
>> >> and "fault/wsec".
>> >>
>> >> $ mkdir /dev/cgroup/memory/A
>> >> $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
>> >> $ echo $$ >/dev/cgroup/memory/A/tasks
>> >> $ ./pft -m 15g -t 8 -T a
>> >>
>> >> Result:
>> >> $ ./ministat no_histogram histogram
>> >>
>> >> "fault/wsec"
>> >> x fault_wsec/no_histogram
>> >> + fault_wsec/histogram
>> >> +--------------------------------------------------------------------=
-----+
>> >> =A0 =A0 N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0=
 =A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev
>> >> x =A0 5 =A0 =A0 864432.44 =A0 =A0 880840.81 =A0 =A0 879707.95 =A0 =A0=
 874606.51 =A0 =A0 7687.9841
>> >> + =A0 5 =A0 =A0 861986.57 =A0 =A0 877867.25 =A0 =A0 =A0870823.9 =A0 =
=A0 870901.38 =A0 =A0 6413.8821
>> >> No difference proven at 95.0% confidence
>> >>
>> >> "flt/cpu/s"
>> >> x flt_cpu_s/no_histogram
>> >> + flt_cpu_s/histogram
>> >> +--------------------------------------------------------------------=
-----+
>> >> =A0 =A0 I'll never ack this.
>>
>> The patch is created as part of effort testing per-memcg bg reclaim
>> patch. I don't have strong opinion that we indeed need to merge it,
>> but found it is a useful testing and monitoring tool.
>>
>> Meantime, can you help to clarify your concern? In case I missed
>> something here.
>>
>
> I want to see the numbers via 'perf' because of its flexibility.
> For this kind of things, I like dumping "raw" data and parse it by
> tools. Because we can change our view with a single data without
> taking mulitple-data-by-multiple-experiments.
>
> I like your idea of histgram. So, I'd like to try to write a
> perf stuff when my memory.vmscan_stat is merged (it's good trace
> point I think) and see what we can get.

Thank you for the clarification. I have no strong objection of doing
it in perf except it might take some space and cpu-time to collecting
the information, which at the end we just need to increment a counter
:)

Thanks

--Ying

>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
