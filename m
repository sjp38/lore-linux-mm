Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9346A6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 20:23:27 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4R0NNah011482
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:23:23 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz9.hot.corp.google.com with ESMTP id p4R0MoID026591
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:23:21 -0700
Received: by qwj9 with SMTP id 9so920708qwj.21
        for <linux-mm@kvack.org>; Thu, 26 May 2011 17:23:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 17:23:20 -0700
Message-ID: <BANLkTiknNVZNC=CfYyr8W3EaD1=kTe940w@mail.gmail.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bceea27804a436f13a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--000e0ce008bceea27804a436f13a
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 26, 2011 at 5:05 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 26 May 2011 14:07:49 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This adds histogram to capture pagefault latencies on per-memcg basis. I
> used
> > this patch on the memcg background reclaim test, and figured there could
> be more
> > usecases to monitor/debug application performance.
> >
> > The histogram is composed 8 bucket in ns unit. The last one is infinite
> (inf)
> > which is everything beyond the last one. To be more flexible, the buckets
> can
> > be reset and also each bucket is configurable at runtime.
> >
> > memory.pgfault_histogram: exports the histogram on per-memcg basis and
> also can
> > be reset by echoing "reset". Meantime, all the buckets are writable by
> echoing
> > the range into the API. see the example below.
> >
> > /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to
> turn
> > on/off recording the histogram.
> >
> > Functional Test:
> > Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
> > Measure the anon page allocation latency.
> >
> > $ mkdir /dev/cgroup/memory/B
> > $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
> > $ echo $$ >/dev/cgroup/memory/B/tasks
> > $ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
> > $ allocate 8g anon pages
> >
> > $ echo 1 >/proc/sys/vm/pgfault_histogram
> >
> > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > pgfault latency histogram (ns):
> > < 600            2051273
> > < 1200           40859
> > < 2400           4004
> > < 4800           1605
> > < 9600           170
> > < 19200          82
> > < 38400          6
> > < inf            0
> >
> > $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
> > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > pgfault latency histogram (ns):
> > < 600            0
> > < 1200           0
> > < 2400           0
> > < 4800           0
> > < 9600           0
> > < 19200          0
> > < 38400          0
> > < inf            0
> >
> > $ echo 500 520 540 580 600 1000 5000
> >/dev/cgroup/memory/B/memory.pgfault_histogram
> > $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> > pgfault latency histogram (ns):
> > < 500            50
> > < 520            151
> > < 540            3715
> > < 580            1859812
> > < 600            202241
> > < 1000           25394
> > < 5000           5875
> > < inf            186
> >
> > Performance Test:
> > I ran through the PageFaultTest (pft) benchmark to measure the overhead
> of
> > recording the histogram. There is no overhead observed on both
> "flt/cpu/s"
> > and "fault/wsec".
> >
> > $ mkdir /dev/cgroup/memory/A
> > $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
> > $ echo $$ >/dev/cgroup/memory/A/tasks
> > $ ./pft -m 15g -t 8 -T a
> >
> > Result:
> > "fault/wsec"
> >
> > $ ./ministat no_histogram histogram
> > x no_histogram
> > + histogram
> >
> +--------------------------------------------------------------------------+
> >    N           Min           Max        Median           Avg
>  Stddev
> > x   5     813404.51     824574.98      821661.3     820470.83
> 4202.0758
> > +   5     821228.91     825894.66     822874.65     823374.15
> 1787.9355
> >
> > "flt/cpu/s"
> >
> > $ ./ministat no_histogram histogram
> > x no_histogram
> > + histogram
> >
> +--------------------------------------------------------------------------+
> >    N           Min           Max        Median           Avg
>  Stddev
> > x   5     104951.93     106173.13     105142.73      105349.2
> 513.78158
> > +   5     104697.67      105416.1     104943.52     104973.77
> 269.24781
> > No difference proven at 95.0% confidence
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Hmm, interesting....but isn't it very very very complicated interface ?
> Could you make this for 'perf' ? Then, everyone (including someone who
> don't use memcg)
> will be happy.
>

Thank you for looking at it.

There is only one per-memcg API added which is basically exporting the
histogram. The "reset" and reconfiguring the bucket is not "must" but make
it more flexible. Also, the sysfs API can be reduced if necessary since
there is no over-head observed by always turning it on anyway.

I am not familiar w/ perf, any suggestions how it is supposed to be look
like?

Thanks

--Ying


> Thanks,
> -Kame
>
>
>

--000e0ce008bceea27804a436f13a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 26, 2011 at 5:05 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, 26 May 2011 14:07:49 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This adds histogram to capture pagefault latencies on per-memcg basis.=
 I used<br>
&gt; this patch on the memcg background reclaim test, and figured there cou=
ld be more<br>
&gt; usecases to monitor/debug application performance.<br>
&gt;<br>
&gt; The histogram is composed 8 bucket in ns unit. The last one is infinit=
e (inf)<br>
&gt; which is everything beyond the last one. To be more flexible, the buck=
ets can<br>
&gt; be reset and also each bucket is configurable at runtime.<br>
&gt;<br>
&gt; memory.pgfault_histogram: exports the histogram on per-memcg basis and=
 also can<br>
&gt; be reset by echoing &quot;reset&quot;. Meantime, all the buckets are w=
ritable by echoing<br>
&gt; the range into the API. see the example below.<br>
&gt;<br>
&gt; /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to=
 turn<br>
&gt; on/off recording the histogram.<br>
&gt;<br>
&gt; Functional Test:<br>
&gt; Create a memcg with 10g hard_limit, running dd &amp; allocate 8g anon =
page.<br>
&gt; Measure the anon page allocation latency.<br>
&gt;<br>
&gt; $ mkdir /dev/cgroup/memory/B<br>
&gt; $ echo 10g &gt;/dev/cgroup/memory/B/memory.limit_in_bytes<br>
&gt; $ echo $$ &gt;/dev/cgroup/memory/B/tasks<br>
&gt; $ dd if=3D/dev/zero of=3D/export/hdc3/dd/tf0 bs=3D1024 count=3D2097152=
0 &amp;<br>
&gt; $ allocate 8g anon pages<br>
&gt;<br>
&gt; $ echo 1 &gt;/proc/sys/vm/pgfault_histogram<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/B/memory.pgfault_histogram<br>
&gt; pgfault latency histogram (ns):<br>
&gt; &lt; 600 =A0 =A0 =A0 =A0 =A0 =A02051273<br>
&gt; &lt; 1200 =A0 =A0 =A0 =A0 =A0 40859<br>
&gt; &lt; 2400 =A0 =A0 =A0 =A0 =A0 4004<br>
&gt; &lt; 4800 =A0 =A0 =A0 =A0 =A0 1605<br>
&gt; &lt; 9600 =A0 =A0 =A0 =A0 =A0 170<br>
&gt; &lt; 19200 =A0 =A0 =A0 =A0 =A082<br>
&gt; &lt; 38400 =A0 =A0 =A0 =A0 =A06<br>
&gt; &lt; inf =A0 =A0 =A0 =A0 =A0 =A00<br>
&gt;<br>
&gt; $ echo reset &gt;/dev/cgroup/memory/B/memory.pgfault_histogram<br>
&gt; $ cat /dev/cgroup/memory/B/memory.pgfault_histogram<br>
&gt; pgfault latency histogram (ns):<br>
&gt; &lt; 600 =A0 =A0 =A0 =A0 =A0 =A00<br>
&gt; &lt; 1200 =A0 =A0 =A0 =A0 =A0 0<br>
&gt; &lt; 2400 =A0 =A0 =A0 =A0 =A0 0<br>
&gt; &lt; 4800 =A0 =A0 =A0 =A0 =A0 0<br>
&gt; &lt; 9600 =A0 =A0 =A0 =A0 =A0 0<br>
&gt; &lt; 19200 =A0 =A0 =A0 =A0 =A00<br>
&gt; &lt; 38400 =A0 =A0 =A0 =A0 =A00<br>
&gt; &lt; inf =A0 =A0 =A0 =A0 =A0 =A00<br>
&gt;<br>
&gt; $ echo 500 520 540 580 600 1000 5000 &gt;/dev/cgroup/memory/B/memory.p=
gfault_histogram<br>
&gt; $ cat /dev/cgroup/memory/B/memory.pgfault_histogram<br>
&gt; pgfault latency histogram (ns):<br>
&gt; &lt; 500 =A0 =A0 =A0 =A0 =A0 =A050<br>
&gt; &lt; 520 =A0 =A0 =A0 =A0 =A0 =A0151<br>
&gt; &lt; 540 =A0 =A0 =A0 =A0 =A0 =A03715<br>
&gt; &lt; 580 =A0 =A0 =A0 =A0 =A0 =A01859812<br>
&gt; &lt; 600 =A0 =A0 =A0 =A0 =A0 =A0202241<br>
&gt; &lt; 1000 =A0 =A0 =A0 =A0 =A0 25394<br>
&gt; &lt; 5000 =A0 =A0 =A0 =A0 =A0 5875<br>
&gt; &lt; inf =A0 =A0 =A0 =A0 =A0 =A0186<br>
&gt;<br>
&gt; Performance Test:<br>
&gt; I ran through the PageFaultTest (pft) benchmark to measure the overhea=
d of<br>
&gt; recording the histogram. There is no overhead observed on both &quot;f=
lt/cpu/s&quot;<br>
&gt; and &quot;fault/wsec&quot;.<br>
&gt;<br>
&gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; $ echo 16g &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<br>
&gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt; $ ./pft -m 15g -t 8 -T a<br>
&gt;<br>
&gt; Result:<br>
&gt; &quot;fault/wsec&quot;<br>
&gt;<br>
&gt; $ ./ministat no_histogram histogram<br>
&gt; x no_histogram<br>
&gt; + histogram<br>
&gt; +---------------------------------------------------------------------=
-----+<br>
&gt; =A0 =A0N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =
=A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev<br>
&gt; x =A0 5 =A0 =A0 813404.51 =A0 =A0 824574.98 =A0 =A0 =A0821661.3 =A0 =
=A0 820470.83 =A0 =A0 4202.0758<br>
&gt; + =A0 5 =A0 =A0 821228.91 =A0 =A0 825894.66 =A0 =A0 822874.65 =A0 =A0 =
823374.15 =A0 =A0 1787.9355<br>
&gt;<br>
&gt; &quot;flt/cpu/s&quot;<br>
&gt;<br>
&gt; $ ./ministat no_histogram histogram<br>
&gt; x no_histogram<br>
&gt; + histogram<br>
&gt; +---------------------------------------------------------------------=
-----+<br>
&gt; =A0 =A0N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =
=A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev<br>
&gt; x =A0 5 =A0 =A0 104951.93 =A0 =A0 106173.13 =A0 =A0 105142.73 =A0 =A0 =
=A0105349.2 =A0 =A0 513.78158<br>
&gt; + =A0 5 =A0 =A0 104697.67 =A0 =A0 =A0105416.1 =A0 =A0 104943.52 =A0 =
=A0 104973.77 =A0 =A0 269.24781<br>
&gt; No difference proven at 95.0% confidence<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div></div>Hmm, interesting....but isn&#39;t it very very very complicated=
 interface ?<br>
Could you make this for &#39;perf&#39; ? Then, everyone (including someone =
who don&#39;t use memcg)<br>
will be happy.<br></blockquote><div><br></div><div>Thank you for looking at=
 it.=A0</div><div><br></div><div>There is only one per-memcg API added whic=
h is basically exporting the histogram. The &quot;reset&quot; and reconfigu=
ring the bucket is not &quot;must&quot; but make it more flexible. Also, th=
e sysfs API can be reduced if necessary since there is no over-head=A0obser=
ved=A0by always turning it on anyway. =A0</div>
<div><br></div><div>I am not=A0familiar w/ perf, any suggestions how it is =
supposed to be look like?</div><div><br></div><div>Thanks</div><div><br></d=
iv><div>--Ying=A0</div><div>=A0</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--000e0ce008bceea27804a436f13a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
