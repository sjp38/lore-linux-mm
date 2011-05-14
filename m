Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55C796B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:25:51 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p4E0PgAW015082
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:25:44 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe15.cbf.corp.google.com with ESMTP id p4E0PaSW009107
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:25:36 -0700
Received: by qyg14 with SMTP id 14so1981322qyg.5
        for <linux-mm@kvack.org>; Fri, 13 May 2011 17:25:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinFesh5cpdk16dWygoWJeH8QU0hTw@mail.gmail.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511205110.354fa05e.akpm@linux-foundation.org>
	<20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110512171725.d367980f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110513120318.63ff7d0e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinFesh5cpdk16dWygoWJeH8QU0hTw@mail.gmail.com>
Date: Fri, 13 May 2011 17:25:35 -0700
Message-ID: <BANLkTi=pzdnMj7ie6kZG8qRe32DhOx6Bsw@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc0b9cb704a3317693
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>

--000e0ce008bc0b9cb704a3317693
Content-Type: text/plain; charset=ISO-8859-1

Here I ran some tests and the result.

On a 32G machine, I created a memcg with 4G hard_limit (limit_in_bytes)
and and ran cat on a 20g file. Then I use getdelays to measure the
ttfp "delay average" under RECLAIM. When the workload is reaching its
hard_limit and
without background reclaim, each ttfp is triggered by a pagefault. I would
like to demostrate the average delay average for ttfp (thus page fault
latency) on the streaming read/write workload and compare it w/ per-memcg bg
reclaim enabled.

Note:
1. I applied a patch on getdelays.c from fengguang which shows
average CPU/IO/SWAP/RECLAIM delays in ns.

2. I used my latest version of per-memcg-per-kswapd patch for the
following test. The patch could have been improved since then and I can run
the same test when Kame has his patch ready.

Configuration:
$ cat /proc/meminfo
MemTotal:       33045832 kB

$ cat /dev/cgroup/memory/A/memory.limit_in_bytes
4294967296

$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
low_wmark 4137680896
high_wmark 4085252096

Test:
$ echo $$ >/dev/cgroup/memory/A/tasks
$ cat /export/hdc3/dd_A/tf0 > /dev/zero

Without per-memcg background reclaim:

CPU             count     real total  virtual total    delay total  delay
average
               176589    17248377848    27344548685     1093693318
6193.440ns
IO              count    delay total  delay average
               160704   242072632962        1506326ns
SWAP            count    delay total  delay average
                    0              0              0ns
RECLAIM         count    delay total  delay average
                15944     3512140153         220279ns
cat: read=20947877888, write=0, cancelled_write=0

real>---4m26.912s
user>---0m0.227s
sys>----0m27.823s

With per-memcg background reclaim:

$ ps -ef | grep memcg
root      5803     2  2 13:56 ?        00:04:20 [memcg_4]

CPU             count     real total  virtual total    delay total  delay
average
               161085    13185995424    23863858944       72902585
 452.572ns
IO              count    delay total  delay average
               160915   246145533109        1529661ns
SWAP            count    delay total  delay average
                    0              0              0ns
RECLAIM         count    delay total  delay average
                    0              0              0ns
cat: read=20974891008, write=0, cancelled_write=0

real>---4m26.572s
user>---0m0.246s
sys>----0m24.192s

memcg_4 cputime: 2.86sec

Observation:
1. Without the background reclaim, the cat hit ttfp heavely and the "delay
average" goes above 220 microsec.

2. With background reclaim, the ttfp delay average is always 0. Since the
ttfp happens synchronously and that implies the latency of the application
overtime.

3. The real time goes slighly better w/ bg reclaim and the sys time is
about the same ( adding the memcg_4 time on top of sys time of cat). But i
don't expect big cpu benefit. The async reclaim uses spare cputime to
proactivly reclaim pages on the side which gurantees less latency variation
of application over time.

--Ying

On Thu, May 12, 2011 at 10:10 PM, Ying Han <yinghan@google.com> wrote:

>
>
> On Thu, May 12, 2011 at 8:03 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Thu, 12 May 2011 17:17:25 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > On Thu, 12 May 2011 13:22:37 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > I'll check what codes in vmscan.c or /mm affects memcg and post a
>> > required fix in step by step. I think I found some..
>> >
>>
>> After some tests, I doubt that 'automatic' one is unnecessary until
>> memcg's dirty_ratio is supported. And as Andrew pointed out,
>> total cpu consumption is unchanged and I don't have workloads which
>> shows me meaningful speed up.
>>
>
> The total cpu consumption is one way to measure the background reclaim,
> another thing I would like to measure is a histogram of page fault latency
> for a heavy page allocation application. I would expect with background
> reclaim, we will get less variation on the page fault latency than w/o it.
>
> Sorry i haven't got chance to run some tests to back it up. I will try to
> get some data.
>
>
>> But I guess...with dirty_ratio, amount of dirty pages in memcg is
>> limited and background reclaim can work enough without noise of
>> write_page() while applications are throttled by dirty_ratio.
>>
>
> Definitely. I have run into the issue while debugging the soft_limit
> reclaim. The background reclaim became very inefficient if we have dirty
> pages greater than the soft_limit. Talking w/ Greg about it regarding his
> per-memcg dirty page limit effort, we should consider setting the dirty
> ratio which not allowing the dirty pages greater the reclaim watermarks
> (here is the soft_limit).
>
> --Ying
>
>
>> Hmm, I'll study for a while but it seems better to start active soft
>> limit,
>> (or some threshold users can set) first.
>>
>> Anyway, this work makes me to see vmscan.c carefully and I think I can
>> post some patches for fix, tunes.
>>
>> Thanks,
>> -Kame
>>
>>
>

--000e0ce008bc0b9cb704a3317693
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Here I ran some tests and the result.=A0<div><br></div><div><div>On a 32G m=
achine, I created a memcg with 4G hard_limit (limit_in_bytes) and=A0and ran=
 cat on a 20g file. Then I use getdelays to measure the ttfp=A0&quot;delay =
average&quot; under RECLAIM. When the workload is reaching its hard_limit a=
nd</div>
<div>without background reclaim, each ttfp is triggered by a pagefault. I w=
ould like=A0to demostrate the average delay average for ttfp (thus page fau=
lt latency) on=A0the streaming read/write workload and compare it w/ per-me=
mcg bg reclaim enabled.</div>
<div><br></div><div>Note:</div><div>1. I applied a patch on getdelays.c fro=
m fengguang which shows average=A0CPU/IO/SWAP/RECLAIM delays in ns.</div><d=
iv><br></div><div>2. I used my latest version of per-memcg-per-kswapd patch=
 for the following=A0test. The patch could have been improved since then an=
d I can run the same test=A0when Kame has his patch ready.</div>
<div><br></div><div>Configuration:</div><div>$ cat /proc/meminfo</div><div>=
MemTotal: =A0 =A0 =A0 33045832 kB</div><div><br></div><div>$ cat /dev/cgrou=
p/memory/A/memory.limit_in_bytes</div><div>4294967296</div><div><br></div><=
div>
$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks</div><div>low_wmark 413768=
0896</div><div>high_wmark 4085252096</div><div><br></div><div>Test:</div><d=
iv>$ echo $$ &gt;/dev/cgroup/memory/A/tasks</div><div>$ cat /export/hdc3/dd=
_A/tf0 &gt; /dev/zero</div>
<div><br></div><div>Without per-memcg background reclaim:</div><div><br></d=
iv><div>CPU =A0 =A0 =A0 =A0 =A0 =A0 count =A0 =A0 real total =A0virtual tot=
al =A0 =A0delay total =A0delay average</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0176589 =A0 =A017248377848 =A0 =A027344548685 =A0 =A0 1093693318 =A0 =
=A0 =A0 6193.440ns</div>
<div>IO =A0 =A0 =A0 =A0 =A0 =A0 =A0count =A0 =A0delay total =A0delay averag=
e</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0160704 =A0 242072632962 =A0 =A0 =
=A0 =A01506326ns</div><div>SWAP =A0 =A0 =A0 =A0 =A0 =A0count =A0 =A0delay t=
otal =A0delay average</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0 =A00ns</div>
<div>RECLAIM =A0 =A0 =A0 =A0 count =A0 =A0delay total =A0delay average</div=
><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 15944 =A0 =A0 3512140153 =A0 =A0 =A0 =
=A0 220279ns</div><div>cat: read=3D20947877888, write=3D0, cancelled_write=
=3D0</div><div><br></div><div>real&gt;---4m26.912s</div>
<div>user&gt;---0m0.227s</div><div>sys&gt;----0m27.823s</div><div><br></div=
><div>With per-memcg background reclaim:</div><div><br></div><div>$ ps -ef =
| grep memcg</div><div>root =A0 =A0 =A05803 =A0 =A0 2 =A02 13:56 ? =A0 =A0 =
=A0 =A000:04:20 [memcg_4]</div>
<div><br></div><div>CPU =A0 =A0 =A0 =A0 =A0 =A0 count =A0 =A0 real total =
=A0virtual total =A0 =A0delay total =A0delay average</div><div>=A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0161085 =A0 =A013185995424 =A0 =A023863858944 =A0 =A0 =A0=
 72902585 =A0 =A0 =A0 =A0452.572ns</div><div>IO =A0 =A0 =A0 =A0 =A0 =A0 =A0=
count =A0 =A0delay total =A0delay average</div>
<div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0160915 =A0 246145533109 =A0 =A0 =A0 =A0=
1529661ns</div><div>SWAP =A0 =A0 =A0 =A0 =A0 =A0count =A0 =A0delay total =
=A0delay average</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0 =A00ns</div><div>RECLAIM =
=A0 =A0 =A0 =A0 count =A0 =A0delay total =A0delay average</div>
<div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A0 =A0 =A00ns</div><div>cat: read=3D20974891008, write=3D=
0, cancelled_write=3D0</div><div><br></div><div>real&gt;---4m26.572s</div><=
div>user&gt;---0m0.246s</div><div>sys&gt;----0m24.192s</div>
<div><br></div><div>memcg_4 cputime: 2.86sec</div><div><br></div><div><meta=
 http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><div>Ob=
servation:</div><div>1. Without the background reclaim, the cat hit ttfp he=
avely and the &quot;delay average&quot;=A0goes above 220 microsec.</div>
<div><br></div><div>2. With background reclaim, the ttfp delay average is a=
lways 0. Since the ttfp=A0happens synchronously and that implies the latenc=
y of the application overtime.</div><div><br></div><div>3. The real time go=
es slighly better w/ bg reclaim and the sys time is about=A0the same ( addi=
ng the memcg_4 time on top of sys time of cat). But i don&#39;t=A0expect bi=
g cpu benefit. The async reclaim uses spare cputime to proactivly=A0reclaim=
 pages on the side which gurantees less latency variation of application=A0=
over time.</div>
</div><div><br></div><div>--Ying</div><div><br></div><div class=3D"gmail_qu=
ote">On Thu, May 12, 2011 at 10:10 PM, Ying Han <span dir=3D"ltr">&lt;<a hr=
ef=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt;</span> wrote:<b=
r>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><br><br><div class=3D"gmail_quote"><div cla=
ss=3D"im">On Thu, May 12, 2011 at 8:03 PM, KAMEZAWA Hiroyuki <span dir=3D"l=
tr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blank"=
>kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Thu, 12 May 2011 17:17:25 +0900<br>
<div>KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com=
" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, 12 May 2011 13:22:37 +0900<br>
&gt; KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com=
" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
</div><div>&gt; I&#39;ll check what codes in vmscan.c or /mm affects memcg =
and post a<br>
&gt; required fix in step by step. I think I found some..<br>
&gt;<br>
<br>
</div>After some tests, I doubt that &#39;automatic&#39; one is unnecessary=
 until<br>
memcg&#39;s dirty_ratio is supported. And as Andrew pointed out,<br>
total cpu consumption is unchanged and I don&#39;t have workloads which<br>
shows me meaningful speed up.<br></blockquote><div><br></div></div><div>The=
 total cpu consumption is one way to measure the background reclaim, anothe=
r thing I would like to measure is a histogram of page fault latency</div>
<div>
for a heavy page allocation application. I would expect with background rec=
laim, we will get less variation on the page fault latency than w/o it.=A0<=
/div><div><br></div><div>Sorry i haven&#39;t got chance to run some tests t=
o back it up. I will try to get some data.</div>
<div class=3D"im">
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">
But I guess...with dirty_ratio, amount of dirty pages in memcg is<br>
limited and background reclaim can work enough without noise of<br>
write_page() while applications are throttled by dirty_ratio.<br></blockquo=
te><div><br></div></div><div>Definitely. I have run into the issue while de=
bugging the soft_limit reclaim. The background reclaim became very ineffici=
ent if we have dirty pages greater than the soft_limit. Talking w/ Greg abo=
ut it regarding his per-memcg dirty page limit effort, we should consider s=
etting the dirty ratio which not allowing the dirty pages greater the recla=
im watermarks (here is the soft_limit).</div>

<div><br></div><font color=3D"#888888"><div>--Ying</div></font><div class=
=3D"im"><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Hmm, I&#39;ll study for a while but it seems better to start active soft li=
mit,<br>
(or some threshold users can set) first.<br>
<br>
Anyway, this work makes me to see vmscan.c carefully and I think I can<br>
post some patches for fix, tunes.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div></div><br>
</blockquote></div><br></div>

--000e0ce008bc0b9cb704a3317693--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
