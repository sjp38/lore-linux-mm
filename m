Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DF8B2900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 13:53:32 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p3DHrPvg018597
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 10:53:27 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by wpaz1.hot.corp.google.com with ESMTP id p3DHpjbl011091
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 10:53:24 -0700
Received: by qwb7 with SMTP id 7so560670qwb.12
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 10:53:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110413164747.0d4076d1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<20110413164747.0d4076d1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 10:53:19 -0700
Message-ID: <BANLkTik2QFp_6_c6eoO1VY4Wgq-TDW9d5Q@mail.gmail.com>
Subject: Re: [PATCH V3 0/7] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee0f04adb04a0d07be7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cd68ee0f04adb04a0d07be7
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 12:47 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Apr 2011 00:03:00 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The current implementation of memcg supports targeting reclaim when the
> > cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> > Per cgroup background reclaim is needed which helps to spread out memory
> > pressure over longer period of time and smoothes out the cgroup
> performance.
> >
> > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > thread is created which only scans the per-memcg LRU list. Two watermarks
> > ("high_wmark", "low_wmark") are added to trigger the background reclaim
> and
> > stop it. The watermarks are calculated based on the cgroup's
> limit_in_bytes.
> >
> > I run through dd test on large file and then cat the file. Then I
> compared
> > the reclaim related stats in memory.stat.
> >
> > Step1: Create a cgroup with 500M memory_limit.
> > $ mkdir /dev/cgroup/memory/A
> > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > $ echo $$ >/dev/cgroup/memory/A/tasks
> >
> > Step2: Test and set the wmarks.
> > $ cat /dev/cgroup/memory/A/memory.wmark_ratio
> > 0
> >
> > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > low_wmark 524288000
> > high_wmark 524288000
> >
> > $ echo 90 >/dev/cgroup/memory/A/memory.wmark_ratio
> >
> > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > low_wmark 471859200
> > high_wmark 470016000
> >
> > $ ps -ef | grep memcg
> > root     18126     2  0 22:43 ?        00:00:00 [memcg_3]
> > root     18129  7999  0 22:44 pts/1    00:00:00 grep memcg
> >
> > Step3: Dirty the pages by creating a 20g file on hard drive.
> > $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
> >
> > Here are the memory.stat with vs without the per-memcg reclaim. It used
> to be
> > all the pages are reclaimed from direct reclaim, and now some of the
> pages are
> > also being reclaimed at background.
> >
> > Only direct reclaim                       With background reclaim:
> >
> > pgpgin 5248668                            pgpgin 5248347
> > pgpgout 5120678                           pgpgout 5133505
> > kswapd_steal 0                            kswapd_steal 1476614
> > pg_pgsteal 5120578                        pg_pgsteal 3656868
> > kswapd_pgscan 0                           kswapd_pgscan 3137098
> > pg_scan 10861956                          pg_scan 6848006
> > pgrefill 271174                           pgrefill 290441
> > pgoutrun 0                                pgoutrun 18047
> > allocstall 131689                         allocstall 100179
> >
> > real    7m42.702s                         real 7m42.323s
> > user    0m0.763s                          user 0m0.748s
> > sys     0m58.785s                         sys  0m52.123s
> >
> > throughput is 44.33 MB/sec                throughput is 44.23 MB/sec
> >
> > Step 4: Cleanup
> > $ echo $$ >/dev/cgroup/memory/tasks
> > $ echo 1 > /dev/cgroup/memory/A/memory.force_empty
> > $ rmdir /dev/cgroup/memory/A
> > $ echo 3 >/proc/sys/vm/drop_caches
> >
> > Step 5: Create the same cgroup and read the 20g file into pagecache.
> > $ cat /export/hdc3/dd/tf0 > /dev/zero
> >
> > All the pages are reclaimed from background instead of direct reclaim
> with
> > the per cgroup reclaim.
> >
> > Only direct reclaim                       With background reclaim:
> > pgpgin 5248668                            pgpgin 5248114
> > pgpgout 5120678                           pgpgout 5133480
> > kswapd_steal 0                            kswapd_steal 5133397
> > pg_pgsteal 5120578                        pg_pgsteal 0
> > kswapd_pgscan 0                           kswapd_pgscan 5133400
> > pg_scan 10861956                          pg_scan 0
> > pgrefill 271174                           pgrefill 0
> > pgoutrun 0                                pgoutrun 40535
> > allocstall 131689                         allocstall 0
> >
> > real    7m42.702s                         real 6m20.439s
> > user    0m0.763s                          user 0m0.169s
> > sys     0m58.785s                         sys  0m26.574s
> >
> > Note:
> > This is the first effort of enhancing the target reclaim into memcg. Here
> are
> > the existing known issues and our plan:
> >
> > 1. there are one kswapd thread per cgroup. the thread is created when the
> > cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> > removed. In some enviroment when thousand of cgroups are being configured
> on
> > a single host, we will have thousand of kswapd threads. The memory
> consumption
> > would be 8k*100 = 8M. We don't see a big issue for now if the host can
> host
> > that many of cgroups.
> >
>
> What's bad with using workqueue ?
>
> Pros.
>  - we don't have to keep our own thread pool.
>  - we don't have to see 'ps -elf' is filled by kswapd...
> Cons.
>  - because threads are shared, we can't put kthread to cpu cgroup.
>

I did some study on workqueue after posting V2. There was a comment suggesting
workqueue instead of per-memcg kswapd thread, since it will cut the number
of kernel threads being created in host with lots of cgroups. Each kernel
thread allocates about 8K of stack and 8M in total w/ thousand of cgroups.

The current workqueue model merged in 2.6.36 kernel is called "concurrency
managed workqueu(cmwq)", which is intended to provide flexible concurrency
without wasting resources. I studied a bit and here it is:

1. The workqueue is complicated and we need to be very careful of work items
in the workqueue. We've experienced in one workitem stucks and the rest of
the work item won't proceed. For example in dirty page writeback,  one
heavily writer cgroup could starve the other cgroups from flushing dirty
pages to the same disk. In the kswapd case, I can image we might have
similar scenario.

2. How to prioritize the workitems is another problem. The order of adding
the workitems in the queue reflects the order of cgroups being reclaimed. We
don't have that restriction currently but relying on the cpu scheduler to
put kswapd on the right cpu-core to run. We "might" introduce priority later
for reclaim and how are we gonna deal with that.

3. Based on what i observed, not many callers has migrated to the cmwq and I
don't have much data of how good it is.


Regardless of workqueue, can't we have moderate numbers of threads ?
>
> I really don't like to have too much threads and thinks
> one-thread-per-memcg
> is big enough to cause lock contension problem.
>

Back to the current model, on machine with thousands of cgroups which it
will take 8M total for thousand of kswapd threads (8K stack for each
thread).  We are running system with fakenuma which each numa node has a
kswapd. So far we haven't noticed issue caused by "lots of" kswapd threads.
Also, there shouldn't be any performance overhead for kernel thread if it is
not running.

Based on the complexity of workqueue and the benefit it provides, I would
like to stick to the current model first. After we get the basic stuff in
and other targeting reclaim improvement, we can come back to this. What do
you think?

--Ying

>
> Anyway, thank you for your patches. I'll review.
>

Thank you for your review~

>
> Thanks,
> -Kame
>
>
>

--000e0cd68ee0f04adb04a0d07be7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 12:47 AM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, 13 Apr 2011 00:03:00 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; The current implementation of memcg supports targeting reclaim when th=
e<br>
&gt; cgroup is reaching its hard_limit and we do direct reclaim per cgroup.=
<br>
&gt; Per cgroup background reclaim is needed which helps to spread out memo=
ry<br>
&gt; pressure over longer period of time and smoothes out the cgroup perfor=
mance.<br>
&gt;<br>
&gt; If the cgroup is configured to use per cgroup background reclaim, a ks=
wapd<br>
&gt; thread is created which only scans the per-memcg LRU list. Two waterma=
rks<br>
&gt; (&quot;high_wmark&quot;, &quot;low_wmark&quot;) are added to trigger t=
he background reclaim and<br>
&gt; stop it. The watermarks are calculated based on the cgroup&#39;s limit=
_in_bytes.<br>
&gt;<br>
&gt; I run through dd test on large file and then cat the file. Then I comp=
ared<br>
&gt; the reclaim related stats in memory.stat.<br>
&gt;<br>
&gt; Step1: Create a cgroup with 500M memory_limit.<br>
&gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<br>
&gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt;<br>
&gt; Step2: Test and set the wmarks.<br>
&gt; $ cat /dev/cgroup/memory/A/memory.wmark_ratio<br>
&gt; 0<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; low_wmark 524288000<br>
&gt; high_wmark 524288000<br>
&gt;<br>
&gt; $ echo 90 &gt;/dev/cgroup/memory/A/memory.wmark_ratio<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; low_wmark 471859200<br>
&gt; high_wmark 470016000<br>
&gt;<br>
&gt; $ ps -ef | grep memcg<br>
&gt; root =A0 =A0 18126 =A0 =A0 2 =A00 22:43 ? =A0 =A0 =A0 =A000:00:00 [mem=
cg_3]<br>
&gt; root =A0 =A0 18129 =A07999 =A00 22:44 pts/1 =A0 =A000:00:00 grep memcg=
<br>
&gt;<br>
&gt; Step3: Dirty the pages by creating a 20g file on hard drive.<br>
&gt; $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1<br>
&gt;<br>
&gt; Here are the memory.stat with vs without the per-memcg reclaim. It use=
d to be<br>
&gt; all the pages are reclaimed from direct reclaim, and now some of the p=
ages are<br>
&gt; also being reclaimed at background.<br>
&gt;<br>
&gt; Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 With b=
ackground reclaim:<br>
&gt;<br>
&gt; pgpgin 5248668 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
pgpgin 5248347<br>
&gt; pgpgout 5120678 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg=
pgout 5133505<br>
&gt; kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
kswapd_steal 1476614<br>
&gt; pg_pgsteal 5120578 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pg_p=
gsteal 3656868<br>
&gt; kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ks=
wapd_pgscan 3137098<br>
&gt; pg_scan 10861956 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pg=
_scan 6848006<br>
&gt; pgrefill 271174 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg=
refill 290441<br>
&gt; pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0pgoutrun 18047<br>
&gt; allocstall 131689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 allo=
cstall 100179<br>
&gt;<br>
&gt; real =A0 =A07m42.702s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
real 7m42.323s<br>
&gt; user =A0 =A00m0.763s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0user 0m0.748s<br>
&gt; sys =A0 =A0 0m58.785s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
sys =A00m52.123s<br>
&gt;<br>
&gt; throughput is 44.33 MB/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0throughput i=
s 44.23 MB/sec<br>
&gt;<br>
&gt; Step 4: Cleanup<br>
&gt; $ echo $$ &gt;/dev/cgroup/memory/tasks<br>
&gt; $ echo 1 &gt; /dev/cgroup/memory/A/memory.force_empty<br>
&gt; $ rmdir /dev/cgroup/memory/A<br>
&gt; $ echo 3 &gt;/proc/sys/vm/drop_caches<br>
&gt;<br>
&gt; Step 5: Create the same cgroup and read the 20g file into pagecache.<b=
r>
&gt; $ cat /export/hdc3/dd/tf0 &gt; /dev/zero<br>
&gt;<br>
&gt; All the pages are reclaimed from background instead of direct reclaim =
with<br>
&gt; the per cgroup reclaim.<br>
&gt;<br>
&gt; Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 With b=
ackground reclaim:<br>
&gt; pgpgin 5248668 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
pgpgin 5248114<br>
&gt; pgpgout 5120678 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg=
pgout 5133480<br>
&gt; kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
kswapd_steal 5133397<br>
&gt; pg_pgsteal 5120578 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pg_p=
gsteal 0<br>
&gt; kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ks=
wapd_pgscan 5133400<br>
&gt; pg_scan 10861956 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pg=
_scan 0<br>
&gt; pgrefill 271174 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg=
refill 0<br>
&gt; pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0pgoutrun 40535<br>
&gt; allocstall 131689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 allo=
cstall 0<br>
&gt;<br>
&gt; real =A0 =A07m42.702s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
real 6m20.439s<br>
&gt; user =A0 =A00m0.763s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0user 0m0.169s<br>
&gt; sys =A0 =A0 0m58.785s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
sys =A00m26.574s<br>
&gt;<br>
&gt; Note:<br>
&gt; This is the first effort of enhancing the target reclaim into memcg. H=
ere are<br>
&gt; the existing known issues and our plan:<br>
&gt;<br>
&gt; 1. there are one kswapd thread per cgroup. the thread is created when =
the<br>
&gt; cgroup changes its limit_in_bytes and is deleted when the cgroup is be=
ing<br>
&gt; removed. In some enviroment when thousand of cgroups are being configu=
red on<br>
&gt; a single host, we will have thousand of kswapd threads. The memory con=
sumption<br>
&gt; would be 8k*100 =3D 8M. We don&#39;t see a big issue for now if the ho=
st can host<br>
&gt; that many of cgroups.<br>
&gt;<br>
<br>
</div></div>What&#39;s bad with using workqueue ?<br>
<br>
Pros.<br>
 =A0- we don&#39;t have to keep our own thread pool.<br>
 =A0- we don&#39;t have to see &#39;ps -elf&#39; is filled by kswapd...<br>
Cons.<br>
 =A0- because threads are shared, we can&#39;t put kthread to cpu cgroup.<b=
r></blockquote><div><br></div><div>I did some study on workqueue after post=
ing V2. There was a comment <span class=3D"Apple-style-span" style=3D"borde=
r-collapse: collapse; font-family: arial, sans-serif; font-size: 13px; -web=
kit-border-horizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px; "=
>suggesting workqueue instead of per-memcg kswapd thread, since it will cut=
 the number of kernel threads being created in host with lots of cgroups. E=
ach kernel thread allocates about 8K of stack and 8M in total w/ thousand o=
f cgroups.</span></div>
<br><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-ho=
rizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px;">The current w=
orkqueue model merged in 2.6.36 kernel is called &quot;concurrency managed =
workqueu(cmwq)&quot;, which is intended to provide flexible concurrency wit=
hout wasting resources. I studied a bit and here it is:</span></font><br>
<br><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-ho=
rizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px;">1. The workqu=
eue is complicated and we need to be very careful of work items in the work=
queue. We&#39;ve experienced in one workitem stucks and the rest of the wor=
k item won&#39;t proceed. For example in dirty page writeback, =A0one heavi=
ly writer cgroup could starve the other cgroups from flushing dirty pages t=
o the same disk. In the kswapd case, I can image we might have similar scen=
ario.</span></font><br>
<br><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-ho=
rizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px;">2. How to pri=
oritize the workitems is another problem. The order of adding the workitems=
 in the queue reflects the order of cgroups being reclaimed. We don&#39;t h=
ave that restriction currently but relying on the cpu scheduler to put kswa=
pd on the right cpu-core to run. We &quot;might&quot; introduce priority la=
ter for reclaim and how are we gonna deal with that.</span></font><br>
<br><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-ho=
rizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px;">3. Based on w=
hat i observed, not many callers has migrated to the cmwq and I don&#39;t h=
ave much data of how good it is.</span></font><font class=3D"Apple-style-sp=
an" face=3D"arial, sans-serif"><span class=3D"Apple-style-span" style=3D"bo=
rder-collapse: collapse; -webkit-border-horizontal-spacing: 2px; -webkit-bo=
rder-vertical-spacing: 2px;"><br>
</span></font><br><div><font class=3D"Apple-style-span" face=3D"arial, sans=
-serif"><span class=3D"Apple-style-span" style=3D"border-collapse: collapse=
; -webkit-border-horizontal-spacing: 2px; -webkit-border-vertical-spacing: =
2px;"><br>
</span></font></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;">Regardless of workqueue=
, can&#39;t we have moderate numbers of threads ?<br>
<br>
I really don&#39;t like to have too much threads and thinks one-thread-per-=
memcg<br>
is big enough to cause lock contension problem.<br></blockquote><div><br></=
div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8=
"><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span class=
=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-ho=
rizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px; ">Back to the =
current model, on machine with thousands of cgroups which it will take 8M t=
otal for thousand of kswapd threads (8K stack for each thread). =A0We are r=
unning system with fakenuma which each numa node has a kswapd. So far we ha=
ven&#39;t noticed issue caused by &quot;lots of&quot;=A0kswapd threads. Als=
o, there shouldn&#39;t be any performance overhead for kernel thread if it =
is not running.</span></font><br>
<br><div><span class=3D"Apple-style-span" style=3D"border-collapse: collaps=
e; font-family: arial, sans-serif; -webkit-border-horizontal-spacing: 2px; =
-webkit-border-vertical-spacing: 2px; ">Based on the complexity of workqueu=
e and the benefit it provides, I would like to stick to the current model f=
irst. After we get the basic stuff in and other=A0targeting=A0reclaim impro=
vement, we can come back to this. What do you think?</span></div>
<div><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; f=
ont-family: arial, sans-serif; -webkit-border-horizontal-spacing: 2px; -web=
kit-border-vertical-spacing: 2px; "><br></span></div><div><span class=3D"Ap=
ple-style-span" style=3D"border-collapse: collapse; font-family: arial, san=
s-serif; -webkit-border-horizontal-spacing: 2px; -webkit-border-vertical-sp=
acing: 2px; ">--Ying</span></div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
Anyway, thank you for your patches. I&#39;ll review.<br></blockquote><div><=
br></div><div>Thank you for your review~=A0</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">

<br>
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--000e0cd68ee0f04adb04a0d07be7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
