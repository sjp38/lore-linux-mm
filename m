Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 861F26B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 17:47:33 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7VLlSpg009836
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:47:29 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq13.eem.corp.google.com with ESMTP id o7VLlQe7021643
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:47:27 -0700
Received: by qyk36 with SMTP id 36so1371545qyk.5
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:47:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100831075323.GA13677@csn.ul.ie>
References: <AANLkTikW74dzq9v1EF1n8SD+T9d8d-EfNgC5m3aXyfL1@mail.gmail.com>
	<20100831075323.GA13677@csn.ul.ie>
Date: Tue, 31 Aug 2010 14:47:24 -0700
Message-ID: <AANLkTi=5RuVtZ=25qy4SW195h3nKcPgJmBVGRY7SMkkB@mail.gmail.com>
Subject: Re: Question of backporting the trace-vmscan-postprocess.pl
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 12:53 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Aug 30, 2010 at 04:10:05PM -0700, Ying Han wrote:
>> Hi Mel:
>>
>> I've been looking into the vmscan:tracing you added for 2.6.36_rc1. I
>> also backported into 2.6.34 which is the kernel we are currently
>> working on. However, I seems can not get it fully functional. Are you
>> aware of any changes on the kernel tracing ABI which could cause that
>> ?
>>
>
> Nothing springs to mind but ...
>
>> Here is how I reproduce it and I also attached the
>> postprocess/trace-vmscan-postprocess.pl I patched.
>>
>> # mount -t debugfs nodev /sys/kernel/debug/
>>
>> # for i in `find /sys/kernel/debug/tracing/events -name "enable" |
>> grep mm_`; do echo 1 > $i; done
>>
>> run a process with pid=3D=3D30196
>>
>> # echo 'common_pid =3D=3D 30196' > /sys/kernel/debug/tracing/events/vmsc=
an/filter
>>
>> # cat /sys/kernel/debug/tracing/events/vmscan/filter
>> common_pid =3D=3D 30196
>>
>> # ./trace-vmscan-postprocess.pl < /sys/kernel/debug/tracing/trace_pipe
>> WARNING: Event vmscan/mm_vmscan_lru_shrink_inactive format string not fo=
und
>> WARNING: Event vmscan/mm_vmscan_lru_shrink_active format string not foun=
d
>> ^CSIGINT received, report pending. Hit ctrl-c again to exit
>>
>
> I didn't test the script for live processing. I was logging
> /sys/kernel/debug/tracing/trace_pipe to a file and post-processing it
> after a test. I suggest you do the same and check if any events for pid
> 30196 were recorded.

Ok. I tried the logging and it works better this time. Both pagealloc
and vmscan give me some data
with the filtering works ok. thanks for your replay :)

--Ying

>> Reclaim latencies expressed as order-latency_in_ms
>>
>> Process =A0 =A0 =A0 =A0 =A0Direct =A0 =A0 Wokeup =A0 =A0 =A0Pages =A0 =
=A0 =A0Pages =A0 =A0Pages
>> Time
>> details =A0 =A0 =A0 =A0 =A0 Rclms =A0 =A0 Kswapd =A0 =A0Scanned =A0 =A0S=
ync-IO ASync-IO
>> Stalled
>>
>> Kswapd =A0 =A0 =A0 =A0 =A0 Kswapd =A0 =A0 =A0Order =A0 =A0 =A0Pages =A0 =
=A0 =A0Pages =A0 =A0Pages
>> Instance =A0 =A0 =A0 =A0Wakeups =A0Re-wakeup =A0 =A0Scanned =A0 =A0Sync-=
IO ASync-IO
>>
>> Summary
>> Direct reclaims:
>> Direct reclaim pages scanned:
>> Direct reclaim write file sync I/O:
>> Direct reclaim write anon sync I/O:
>> Direct reclaim write file async I/O:
>> Direct reclaim write anon async I/O:
>> Wake kswapd requests:
>> Time stalled direct reclaim: =A0 =A0 =A0 =A0 =A00.00 seconds
>>
>> Kswapd wakeups:
>> Kswapd pages scanned:
>> Kswapd reclaim write file sync I/O:
>> Kswapd reclaim write anon sync I/O:
>> Kswapd reclaim write file async I/O:
>> Kswapd reclaim write anon async I/O:
>> Time kswapd awake: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00.00 seconds
>>
>> So it didn't give me any output. However, if I turn off the filter for
>> vmscan, it did give me some data but with random processes on the
>> system.
>>
>
> Did one of them processes include 30196 that you were filtering for?
>
>> The same set of tests works for trace-pagealloc-postprocess.pl though
>>
>> # cat /sys/kernel/debug/tracing/events/kmem/filter
>> common_pid =3D=3D 30196
>>
>> # ./trace-pagealloc-postprocess.pl < /sys/kernel/debug/tracing/trace_pip=
e
>>
>> Process =A0 =A0 =A0 =A0 =A0 Pages =A0 =A0 =A0Pages =A0 =A0 =A0Pages =A0 =
=A0Pages =A0 =A0 =A0 PCPU
>> PCPU =A0 =A0 PCPU =A0 Fragment Fragment =A0MigType Fragment Fragment =A0=
Unknown
>> details =A0 =A0 =A0 =A0 =A0allocd =A0 =A0 allocd =A0 =A0 =A0freed =A0 =
=A0freed =A0 =A0 =A0pages
>> drains =A0refills =A0 Fallback =A0Causing =A0Changed =A0 Severe Moderate
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 under lock =A0 =A0 direc=
t =A0pagevec =A0 =A0 =A0drain
>> -30196 =A0 =A0 =A0 =A0 =A0 =A0 2871 =A0 =A0 =A0 2917 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> =A0 0 =A0 =A0 =A0439 =A0 =A0 =A0 =A0 32 =A0 =A0 =A0 32 =A0 =A0 =A0 =A00 =
=A0 =A0 =A0 32 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A00
>> ddtest-30196 =A0 =A0 =A0 4560 =A0 =A0 =A0 4328 =A0 =A0 =A0 =A0 =A00 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> =A0 0 =A0 =A0 =A0639 =A0 =A0 =A0 =A0 26 =A0 =A0 =A0 26 =A0 =A0 =A0 =A01 =
=A0 =A0 =A0 25 =A0 =A0 =A0 =A01 =A0 =A0 =A0 =A00
>>
>
> Maybe there were page allocator events and not vmscan events?
>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
