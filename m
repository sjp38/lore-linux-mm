Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECBEA6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:27:31 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4RGRTxR016896
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:27:29 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz9.hot.corp.google.com with ESMTP id p4RGRQeQ004541
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:27:28 -0700
Received: by qwk3 with SMTP id 3so933554qwk.19
        for <linux-mm@kvack.org>; Fri, 27 May 2011 09:27:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527080417.GG3440@balbir.in.ibm.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
	<20110527080417.GG3440@balbir.in.ibm.com>
Date: Fri, 27 May 2011 09:27:25 -0700
Message-ID: <BANLkTin4ccq5Q0HbwwUS3VBwk-czWEFxog@mail.gmail.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8c1bebc04a444696d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--002354470aa8c1bebc04a444696d
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 27, 2011 at 1:04 AM, Balbir Singh <balbir@linux.vnet.ibm.com>wrote:

> * Ying Han <yinghan@google.com> [2011-05-26 14:07:49]:
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
>
> inf is a bit confusing for page faults -- no? Why not call it "rest"
> or something line "> 38400".


ok, i can change that to "rest".


> BTW, why was 600 used as base?
>

well, that is based some of my experiments. I am doing anon page allocation
and most of the page fault falls into the bucket of 580 ns - 600 ns. So I
just leave it as default.

However, the bucket is configurable and user can change it based on their
workload and platform.




>
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
>
> Why not make this per memcg?
>

That can be done.

>
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
>
> Can't we use something like "-1" to mean reset?
>

sounds good to me.

Thank you for reviewing.

--Ying

>
> --
>        Three Cheers,
>        Balbir
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--002354470aa8c1bebc04a444696d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, May 27, 2011 at 1:04 AM, Balbir =
Singh <span dir=3D"ltr">&lt;<a href=3D"mailto:balbir@linux.vnet.ibm.com">ba=
lbir@linux.vnet.ibm.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
* Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>=
&gt; [2011-05-26 14:07:49]:<br>
<div class=3D"im"><br>
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
<br>
</div>inf is a bit confusing for page faults -- no? Why not call it &quot;r=
est&quot;<br>
or something line &quot;&gt; 38400&quot;.</blockquote><div>=A0</div><div>ok=
, i can change that to &quot;rest&quot;.</div><div>=A0</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex;">
BTW, why was 600 used as base?<br></blockquote><div><br></div><div>well, th=
at is based some of my experiments. I am doing anon page allocation and mos=
t of the page fault falls into the bucket of 580 ns - 600 ns. So I just lea=
ve it as default.=A0</div>
<div><br></div><div>However, the bucket is configurable and user can change=
 it based on their workload and platform.</div><div><br></div><div><br></di=
v><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
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
<br>
</div>Why not make this per memcg?<br></blockquote><div><br></div><div>That=
 can be done.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
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
<br>
</div>Can&#39;t we use something like &quot;-1&quot; to mean reset?<br></bl=
ockquote><div><br></div><div>sounds good to me.</div><div><br></div><div>Th=
ank you for reviewing.</div><div><br></div><div>--Ying=A0</div><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">

<br>
--<br>
 =A0 =A0 =A0 =A0Three Cheers,<br>
 =A0 =A0 =A0 =A0Balbir<br>
<font color=3D"#888888"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></blockquote></div><br>

--002354470aa8c1bebc04a444696d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
