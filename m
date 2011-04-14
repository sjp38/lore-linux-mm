Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D514A900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:59:53 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p3ELxlNm018313
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:59:48 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by wpaz29.hot.corp.google.com with ESMTP id p3ELwVJe022329
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:59:46 -0700
Received: by qwb7 with SMTP id 7so1848546qwb.26
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:59:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik9p=hUuc+Bm06e2j5=Nn099tXWrg@mail.gmail.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<20110413164747.0d4076d1.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTik2QFp_6_c6eoO1VY4Wgq-TDW9d5Q@mail.gmail.com>
	<20110414091435.0fc6f74c.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTik9p=hUuc+Bm06e2j5=Nn099tXWrg@mail.gmail.com>
Date: Thu, 14 Apr 2011 14:59:46 -0700
Message-ID: <BANLkTikyPSiqKLwGcHPYvEweo0DiycXFrw@mail.gmail.com>
Subject: Re: [PATCH V3 0/7] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0023544706741d68a904a0e80b07
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--0023544706741d68a904a0e80b07
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 10:38 AM, Ying Han <yinghan@google.com> wrote:

>
>
> On Wed, Apr 13, 2011 at 5:14 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Wed, 13 Apr 2011 10:53:19 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > On Wed, Apr 13, 2011 at 12:47 AM, KAMEZAWA Hiroyuki <
>> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > > On Wed, 13 Apr 2011 00:03:00 -0700
>> > > Ying Han <yinghan@google.com> wrote:
>> > >
>> > > > The current implementation of memcg supports targeting reclaim when
>> the
>> > > > cgroup is reaching its hard_limit and we do direct reclaim per
>> cgroup.
>> > > > Per cgroup background reclaim is needed which helps to spread out
>> memory
>> > > > pressure over longer period of time and smoothes out the cgroup
>> > > performance.
>> > > >
>> > > > If the cgroup is configured to use per cgroup background reclaim, a
>> > > kswapd
>> > > > thread is created which only scans the per-memcg LRU list. Two
>> watermarks
>> > > > ("high_wmark", "low_wmark") are added to trigger the background
>> reclaim
>> > > and
>> > > > stop it. The watermarks are calculated based on the cgroup's
>> > > limit_in_bytes.
>> > > >
>> > > > I run through dd test on large file and then cat the file. Then I
>> > > compared
>> > > > the reclaim related stats in memory.stat.
>> > > >
>> > > > Step1: Create a cgroup with 500M memory_limit.
>> > > > $ mkdir /dev/cgroup/memory/A
>> > > > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
>> > > > $ echo $$ >/dev/cgroup/memory/A/tasks
>> > > >
>> > > > Step2: Test and set the wmarks.
>> > > > $ cat /dev/cgroup/memory/A/memory.wmark_ratio
>> > > > 0
>> > > >
>> > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
>> > > > low_wmark 524288000
>> > > > high_wmark 524288000
>> > > >
>> > > > $ echo 90 >/dev/cgroup/memory/A/memory.wmark_ratio
>> > > >
>> > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
>> > > > low_wmark 471859200
>> > > > high_wmark 470016000
>> > > >
>> > > > $ ps -ef | grep memcg
>> > > > root     18126     2  0 22:43 ?        00:00:00 [memcg_3]
>> > > > root     18129  7999  0 22:44 pts/1    00:00:00 grep memcg
>> > > >
>> > > > Step3: Dirty the pages by creating a 20g file on hard drive.
>> > > > $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
>> > > >
>> > > > Here are the memory.stat with vs without the per-memcg reclaim. It
>> used
>> > > to be
>> > > > all the pages are reclaimed from direct reclaim, and now some of the
>> > > pages are
>> > > > also being reclaimed at background.
>> > > >
>> > > > Only direct reclaim                       With background reclaim:
>> > > >
>> > > > pgpgin 5248668                            pgpgin 5248347
>> > > > pgpgout 5120678                           pgpgout 5133505
>> > > > kswapd_steal 0                            kswapd_steal 1476614
>> > > > pg_pgsteal 5120578                        pg_pgsteal 3656868
>> > > > kswapd_pgscan 0                           kswapd_pgscan 3137098
>> > > > pg_scan 10861956                          pg_scan 6848006
>> > > > pgrefill 271174                           pgrefill 290441
>> > > > pgoutrun 0                                pgoutrun 18047
>> > > > allocstall 131689                         allocstall 100179
>> > > >
>> > > > real    7m42.702s                         real 7m42.323s
>> > > > user    0m0.763s                          user 0m0.748s
>> > > > sys     0m58.785s                         sys  0m52.123s
>> > > >
>> > > > throughput is 44.33 MB/sec                throughput is 44.23 MB/sec
>> > > >
>> > > > Step 4: Cleanup
>> > > > $ echo $$ >/dev/cgroup/memory/tasks
>> > > > $ echo 1 > /dev/cgroup/memory/A/memory.force_empty
>> > > > $ rmdir /dev/cgroup/memory/A
>> > > > $ echo 3 >/proc/sys/vm/drop_caches
>> > > >
>> > > > Step 5: Create the same cgroup and read the 20g file into pagecache.
>> > > > $ cat /export/hdc3/dd/tf0 > /dev/zero
>> > > >
>> > > > All the pages are reclaimed from background instead of direct
>> reclaim
>> > > with
>> > > > the per cgroup reclaim.
>> > > >
>> > > > Only direct reclaim                       With background reclaim:
>> > > > pgpgin 5248668                            pgpgin 5248114
>> > > > pgpgout 5120678                           pgpgout 5133480
>> > > > kswapd_steal 0                            kswapd_steal 5133397
>> > > > pg_pgsteal 5120578                        pg_pgsteal 0
>> > > > kswapd_pgscan 0                           kswapd_pgscan 5133400
>> > > > pg_scan 10861956                          pg_scan 0
>> > > > pgrefill 271174                           pgrefill 0
>> > > > pgoutrun 0                                pgoutrun 40535
>> > > > allocstall 131689                         allocstall 0
>> > > >
>> > > > real    7m42.702s                         real 6m20.439s
>> > > > user    0m0.763s                          user 0m0.169s
>> > > > sys     0m58.785s                         sys  0m26.574s
>> > > >
>> > > > Note:
>> > > > This is the first effort of enhancing the target reclaim into memcg.
>> Here
>> > > are
>> > > > the existing known issues and our plan:
>> > > >
>> > > > 1. there are one kswapd thread per cgroup. the thread is created
>> when the
>> > > > cgroup changes its limit_in_bytes and is deleted when the cgroup is
>> being
>> > > > removed. In some enviroment when thousand of cgroups are being
>> configured
>> > > on
>> > > > a single host, we will have thousand of kswapd threads. The memory
>> > > consumption
>> > > > would be 8k*100 = 8M. We don't see a big issue for now if the host
>> can
>> > > host
>> > > > that many of cgroups.
>> > > >
>> > >
>> > > What's bad with using workqueue ?
>> > >
>> > > Pros.
>> > >  - we don't have to keep our own thread pool.
>> > >  - we don't have to see 'ps -elf' is filled by kswapd...
>> > > Cons.
>> > >  - because threads are shared, we can't put kthread to cpu cgroup.
>> > >
>> >
>> > I did some study on workqueue after posting V2. There was a comment
>> suggesting
>> > workqueue instead of per-memcg kswapd thread, since it will cut the
>> number
>> > of kernel threads being created in host with lots of cgroups. Each
>> kernel
>> > thread allocates about 8K of stack and 8M in total w/ thousand of
>> cgroups.
>> >
>> > The current workqueue model merged in 2.6.36 kernel is called
>> "concurrency
>> > managed workqueu(cmwq)", which is intended to provide flexible
>> concurrency
>> > without wasting resources. I studied a bit and here it is:
>> >
>> > 1. The workqueue is complicated and we need to be very careful of work
>> items
>> > in the workqueue. We've experienced in one workitem stucks and the rest
>> of
>> > the work item won't proceed. For example in dirty page writeback,  one
>> > heavily writer cgroup could starve the other cgroups from flushing dirty
>> > pages to the same disk. In the kswapd case, I can image we might have
>> > similar scenario.
>> >
>> > 2. How to prioritize the workitems is another problem. The order of
>> adding
>> > the workitems in the queue reflects the order of cgroups being
>> reclaimed. We
>> > don't have that restriction currently but relying on the cpu scheduler
>> to
>> > put kswapd on the right cpu-core to run. We "might" introduce priority
>> later
>> > for reclaim and how are we gonna deal with that.
>> >
>> > 3. Based on what i observed, not many callers has migrated to the cmwq
>> and I
>> > don't have much data of how good it is.
>> >
>> >
>> > Regardless of workqueue, can't we have moderate numbers of threads ?
>> > >
>> > > I really don't like to have too much threads and thinks
>> > > one-thread-per-memcg
>> > > is big enough to cause lock contension problem.
>> > >
>> >
>> > Back to the current model, on machine with thousands of cgroups which it
>> > will take 8M total for thousand of kswapd threads (8K stack for each
>> > thread).  We are running system with fakenuma which each numa node has a
>> > kswapd. So far we haven't noticed issue caused by "lots of" kswapd
>> threads.
>> > Also, there shouldn't be any performance overhead for kernel thread if
>> it is
>> > not running.
>> >
>> > Based on the complexity of workqueue and the benefit it provides, I
>> would
>> > like to stick to the current model first. After we get the basic stuff
>> in
>> > and other targeting reclaim improvement, we can come back to this. What
>> do
>> > you think?
>> >
>>
>> Okay, fair enough. kthread_run() will win.
>>
>> Then, I have another request. I'd like to kswapd-for-memcg to some cpu
>> cgroup to limit cpu usage.
>>
>> - Could you show thread ID somewhere ?
>
> I added a patch which exports per-memcg-kswapd pid. This is necessary to
later link the kswapd thread to the memcg owner from userspace.

$ cat /dev/cgroup/memory/A/memory.kswapd_pid
memcg_3 6727



> and confirm we can put it to some cpu cgroup ?
>>
>
I tested it by echoing the memcg kswapd thread into a cpu group w/ some
cpu-share.


>  (creating a auto cpu cgroup for memcg kswapd is a choice, I think.)
>>
>>  BTW, when kthread_run() creates a kthread, which cgroup it will be under
>> ?
>>
>
By default, it is running under root. If there is a need to put the kswapd
thread into a cpu cgroup, userspace can make that change by reading the pid
from the new API and echo-ing.


>  If it will be under a cgroup who calls kthread_run(), per-memcg kswapd
>> will
>>  go under cgroup where the user sets hi/low wmark, implicitly.
>>  I don't think this is very bad. But it's better to mention the behavior
>>  somewhere because memcg is tend to be used with cpu cgroup.
>>  Could you check and add some doc ?
>>
>
It make senses to constrain the cpu usage of per-memcg kswapd thread as part
of the memcg. However, i see more problems of doing it than the benefits.

pros:
1. it is good for isolation which prevent one cgroup heavy reclaiming
behavior stealing cpu cycles from other cgroups.

cons:
1. constraining background reclaim will add more pressure into direct
reclaim. it is bad for the process performance, especially on machines with
spare cpu cycles most of time.
2. we have danger of priority inversion to preempt kswapd thread. In no
preemption kernel, we should be ok. In preemptive kernel, we might get
priority inversion by preempting kswapd holding mutex.
3. when user configure the cpu cgroup and memcg cgroup, they need to make
the reservation of cpu be proportional to memcg size.

--Ying


>
>> And
>> - Could you drop PF_MEMALLOC ? (for now.) (in patch 4)
>>
> Hmm, do you mean to drop it for per-memcg kswapd?
>

Ok, I dropped the flag for per-memcg kswapd and also made the comment.

>
>
>> - Could you check PF_KSWAPD doesn't do anything bad ?
>>
>
>  There are eight places where the current_is_kswapd() is called. Five of
> them are called to update counter. And the rest looks good to me.
>
> 1. too_many_isolated()
>     returns false if kswapd
>
> 2. should_reclaim_stall()
>     returns false if kswapd
>
> 3.  nfs_commit_inode()
>    may_wait = NULL if kswapd
>
> --Ying
>
>
>>
>> Thanks,
>> -Kame
>>
>>
>>
>>
>>
>

--0023544706741d68a904a0e80b07
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 10:38 AM, Ying H=
an <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br><br><div class=3D"gmail_quote"><div><div></div><div class=3D"h5">On Wed=
, Apr 13, 2011 at 5:14 PM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=
=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blank">kamezawa.hiroy=
u@jp.fujitsu.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Wed, 13 Apr 2011 10:53:19 -0700<br>
<div><div></div><div>Ying Han &lt;<a href=3D"mailto:yinghan@google.com" tar=
get=3D"_blank">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; On Wed, Apr 13, 2011 at 12:47 AM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blank">ka=
mezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed, 13 Apr 2011 00:03:00 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com" target=3D"_bla=
nk">yinghan@google.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; The current implementation of memcg supports targeting recla=
im when the<br>
&gt; &gt; &gt; cgroup is reaching its hard_limit and we do direct reclaim p=
er cgroup.<br>
&gt; &gt; &gt; Per cgroup background reclaim is needed which helps to sprea=
d out memory<br>
&gt; &gt; &gt; pressure over longer period of time and smoothes out the cgr=
oup<br>
&gt; &gt; performance.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; If the cgroup is configured to use per cgroup background rec=
laim, a<br>
&gt; &gt; kswapd<br>
&gt; &gt; &gt; thread is created which only scans the per-memcg LRU list. T=
wo watermarks<br>
&gt; &gt; &gt; (&quot;high_wmark&quot;, &quot;low_wmark&quot;) are added to=
 trigger the background reclaim<br>
&gt; &gt; and<br>
&gt; &gt; &gt; stop it. The watermarks are calculated based on the cgroup&#=
39;s<br>
&gt; &gt; limit_in_bytes.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I run through dd test on large file and then cat the file. T=
hen I<br>
&gt; &gt; compared<br>
&gt; &gt; &gt; the reclaim related stats in memory.stat.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step1: Create a cgroup with 500M memory_limit.<br>
&gt; &gt; &gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; &gt; &gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<b=
r>
&gt; &gt; &gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step2: Test and set the wmarks.<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.wmark_ratio<br>
&gt; &gt; &gt; 0<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; &gt; &gt; low_wmark 524288000<br>
&gt; &gt; &gt; high_wmark 524288000<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ echo 90 &gt;/dev/cgroup/memory/A/memory.wmark_ratio<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; &gt; &gt; low_wmark 471859200<br>
&gt; &gt; &gt; high_wmark 470016000<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ ps -ef | grep memcg<br>
&gt; &gt; &gt; root =A0 =A0 18126 =A0 =A0 2 =A00 22:43 ? =A0 =A0 =A0 =A000:=
00:00 [memcg_3]<br>
&gt; &gt; &gt; root =A0 =A0 18129 =A07999 =A00 22:44 pts/1 =A0 =A000:00:00 =
grep memcg<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step3: Dirty the pages by creating a 20g file on hard drive.=
<br>
&gt; &gt; &gt; $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Here are the memory.stat with vs without the per-memcg recla=
im. It used<br>
&gt; &gt; to be<br>
&gt; &gt; &gt; all the pages are reclaimed from direct reclaim, and now som=
e of the<br>
&gt; &gt; pages are<br>
&gt; &gt; &gt; also being reclaimed at background.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 With background reclaim:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; pgpgin 5248668 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0pgpgin 5248347<br>
&gt; &gt; &gt; pgpgout 5120678 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 pgpgout 5133505<br>
&gt; &gt; &gt; kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0kswapd_steal 1476614<br>
&gt; &gt; &gt; pg_pgsteal 5120578 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0pg_pgsteal 3656868<br>
&gt; &gt; &gt; kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 kswapd_pgscan 3137098<br>
&gt; &gt; &gt; pg_scan 10861956 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0pg_scan 6848006<br>
&gt; &gt; &gt; pgrefill 271174 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 pgrefill 290441<br>
&gt; &gt; &gt; pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0pgoutrun 18047<br>
&gt; &gt; &gt; allocstall 131689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 allocstall 100179<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; real =A0 =A07m42.702s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 real 7m42.323s<br>
&gt; &gt; &gt; user =A0 =A00m0.763s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0user 0m0.748s<br>
&gt; &gt; &gt; sys =A0 =A0 0m58.785s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 sys =A00m52.123s<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; throughput is 44.33 MB/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0th=
roughput is 44.23 MB/sec<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step 4: Cleanup<br>
&gt; &gt; &gt; $ echo $$ &gt;/dev/cgroup/memory/tasks<br>
&gt; &gt; &gt; $ echo 1 &gt; /dev/cgroup/memory/A/memory.force_empty<br>
&gt; &gt; &gt; $ rmdir /dev/cgroup/memory/A<br>
&gt; &gt; &gt; $ echo 3 &gt;/proc/sys/vm/drop_caches<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step 5: Create the same cgroup and read the 20g file into pa=
gecache.<br>
&gt; &gt; &gt; $ cat /export/hdc3/dd/tf0 &gt; /dev/zero<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; All the pages are reclaimed from background instead of direc=
t reclaim<br>
&gt; &gt; with<br>
&gt; &gt; &gt; the per cgroup reclaim.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 With background reclaim:<br>
&gt; &gt; &gt; pgpgin 5248668 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0pgpgin 5248114<br>
&gt; &gt; &gt; pgpgout 5120678 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 pgpgout 5133480<br>
&gt; &gt; &gt; kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0kswapd_steal 5133397<br>
&gt; &gt; &gt; pg_pgsteal 5120578 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0pg_pgsteal 0<br>
&gt; &gt; &gt; kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 kswapd_pgscan 5133400<br>
&gt; &gt; &gt; pg_scan 10861956 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0pg_scan 0<br>
&gt; &gt; &gt; pgrefill 271174 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 pgrefill 0<br>
&gt; &gt; &gt; pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0pgoutrun 40535<br>
&gt; &gt; &gt; allocstall 131689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 allocstall 0<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; real =A0 =A07m42.702s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 real 6m20.439s<br>
&gt; &gt; &gt; user =A0 =A00m0.763s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0user 0m0.169s<br>
&gt; &gt; &gt; sys =A0 =A0 0m58.785s =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 sys =A00m26.574s<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Note:<br>
&gt; &gt; &gt; This is the first effort of enhancing the target reclaim int=
o memcg. Here<br>
&gt; &gt; are<br>
&gt; &gt; &gt; the existing known issues and our plan:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; 1. there are one kswapd thread per cgroup. the thread is cre=
ated when the<br>
&gt; &gt; &gt; cgroup changes its limit_in_bytes and is deleted when the cg=
roup is being<br>
&gt; &gt; &gt; removed. In some enviroment when thousand of cgroups are bei=
ng configured<br>
&gt; &gt; on<br>
&gt; &gt; &gt; a single host, we will have thousand of kswapd threads. The =
memory<br>
&gt; &gt; consumption<br>
&gt; &gt; &gt; would be 8k*100 =3D 8M. We don&#39;t see a big issue for now=
 if the host can<br>
&gt; &gt; host<br>
&gt; &gt; &gt; that many of cgroups.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; What&#39;s bad with using workqueue ?<br>
&gt; &gt;<br>
&gt; &gt; Pros.<br>
&gt; &gt; =A0- we don&#39;t have to keep our own thread pool.<br>
&gt; &gt; =A0- we don&#39;t have to see &#39;ps -elf&#39; is filled by kswa=
pd...<br>
&gt; &gt; Cons.<br>
&gt; &gt; =A0- because threads are shared, we can&#39;t put kthread to cpu =
cgroup.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I did some study on workqueue after posting V2. There was a comment su=
ggesting<br>
&gt; workqueue instead of per-memcg kswapd thread, since it will cut the nu=
mber<br>
&gt; of kernel threads being created in host with lots of cgroups. Each ker=
nel<br>
&gt; thread allocates about 8K of stack and 8M in total w/ thousand of cgro=
ups.<br>
&gt;<br>
&gt; The current workqueue model merged in 2.6.36 kernel is called &quot;co=
ncurrency<br>
&gt; managed workqueu(cmwq)&quot;, which is intended to provide flexible co=
ncurrency<br>
&gt; without wasting resources. I studied a bit and here it is:<br>
&gt;<br>
&gt; 1. The workqueue is complicated and we need to be very careful of work=
 items<br>
&gt; in the workqueue. We&#39;ve experienced in one workitem stucks and the=
 rest of<br>
&gt; the work item won&#39;t proceed. For example in dirty page writeback, =
=A0one<br>
&gt; heavily writer cgroup could starve the other cgroups from flushing dir=
ty<br>
&gt; pages to the same disk. In the kswapd case, I can image we might have<=
br>
&gt; similar scenario.<br>
&gt;<br>
&gt; 2. How to prioritize the workitems is another problem. The order of ad=
ding<br>
&gt; the workitems in the queue reflects the order of cgroups being reclaim=
ed. We<br>
&gt; don&#39;t have that restriction currently but relying on the cpu sched=
uler to<br>
&gt; put kswapd on the right cpu-core to run. We &quot;might&quot; introduc=
e priority later<br>
&gt; for reclaim and how are we gonna deal with that.<br>
&gt;<br>
&gt; 3. Based on what i observed, not many callers has migrated to the cmwq=
 and I<br>
&gt; don&#39;t have much data of how good it is.<br>
&gt;<br>
&gt;<br>
&gt; Regardless of workqueue, can&#39;t we have moderate numbers of threads=
 ?<br>
&gt; &gt;<br>
&gt; &gt; I really don&#39;t like to have too much threads and thinks<br>
&gt; &gt; one-thread-per-memcg<br>
&gt; &gt; is big enough to cause lock contension problem.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Back to the current model, on machine with thousands of cgroups which =
it<br>
&gt; will take 8M total for thousand of kswapd threads (8K stack for each<b=
r>
&gt; thread). =A0We are running system with fakenuma which each numa node h=
as a<br>
&gt; kswapd. So far we haven&#39;t noticed issue caused by &quot;lots of&qu=
ot; kswapd threads.<br>
&gt; Also, there shouldn&#39;t be any performance overhead for kernel threa=
d if it is<br>
&gt; not running.<br>
&gt;<br>
&gt; Based on the complexity of workqueue and the benefit it provides, I wo=
uld<br>
&gt; like to stick to the current model first. After we get the basic stuff=
 in<br>
&gt; and other targeting reclaim improvement, we can come back to this. Wha=
t do<br>
&gt; you think?<br>
&gt;<br>
<br>
</div></div>Okay, fair enough. kthread_run() will win.<br>
<br>
Then, I have another request. I&#39;d like to kswapd-for-memcg to some cpu<=
br>
cgroup to limit cpu usage.<br>
<br>
- Could you show thread ID somewhere ? </blockquote></div></div></div></blo=
ckquote><div>I added a patch which exports per-memcg-kswapd pid. This is ne=
cessary to later link the kswapd thread to the memcg owner from userspace.=
=A0</div>
<div><br></div><div>$ cat /dev/cgroup/memory/A/memory.kswapd_pid</div><div>=
memcg_3 6727</div><div><br></div><div>=A0</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x;">
<div class=3D"gmail_quote"><div><div class=3D"h5"><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">and=A0confirm we can put it to some cpu cgroup ?<br></blockquote></di=
v></div>
</div></blockquote><div><br></div><div>I tested it by echoing the memcg ksw=
apd thread into a cpu group w/ some cpu-share.</div><div>=A0</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">
<div class=3D"gmail_quote"><div><div class=3D"h5"><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">
 =A0(creating a auto cpu cgroup for memcg kswapd is a choice, I think.)<br>
<br>
 =A0BTW, when kthread_run() creates a kthread, which cgroup it will be unde=
r ?<br></blockquote></div></div></div></blockquote><div><br></div><div>By d=
efault, it is running under root. If there is a need to put the kswapd thre=
ad into a cpu cgroup, userspace can make that change by reading the pid fro=
m the new API and echo-ing.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;"><div class=3D"gmail_quote"><d=
iv><div class=3D"h5"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

 =A0If it will be under a cgroup who calls kthread_run(), per-memcg kswapd =
will<br>
 =A0go under cgroup where the user sets hi/low wmark, implicitly.<br>
 =A0I don&#39;t think this is very bad. But it&#39;s better to mention the =
behavior<br>
 =A0somewhere because memcg is tend to be used with cpu cgroup.<br>
 =A0Could you check and add some doc ?<br></blockquote></div></div></div></=
blockquote><div><br></div><div>It make senses to constrain the cpu usage of=
 per-memcg kswapd thread as part of the memcg. However, i see more problems=
 of doing it than the benefits.</div>
<div><br></div><div>pros:</div><div>1. it is good for isolation which preve=
nt one cgroup heavy reclaiming behavior stealing cpu cycles from other cgro=
ups.</div><div><br></div><div>cons:</div><div>1. constraining background re=
claim will add more pressure into direct reclaim. it is bad for the process=
 performance,=A0especially=A0on machines with spare cpu cycles most of time=
.</div>
<div>2. we have danger of priority inversion to preempt kswapd thread. In n=
o preemption kernel, we should be ok. In preemptive kernel, we might get pr=
iority inversion by preempting kswapd holding mutex.</div><div>3. when user=
 configure the cpu cgroup and memcg cgroup, they need to make the reservati=
on of cpu be=A0proportional=A0to memcg size.=A0</div>
<div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;"><div class=3D"gmail_quote"><div><div class=3D"h5"><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex">

<br>
And<br>
- Could you drop PF_MEMALLOC ? (for now.) (in patch 4)<br></blockquote></di=
v></div><div>Hmm, do you mean to drop it for per-memcg kswapd?=A0</div></di=
v></blockquote><div><br></div><div>Ok, I dropped the flag for per-memcg ksw=
apd and also made the comment.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div class=3D"gmail_quote"><div class=3D"im=
"><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">

- Could you check PF_KSWAPD doesn&#39;t do anything bad ?<br></blockquote><=
div><br></div></div><div>=A0There are eight places where the current_is_ksw=
apd() is called. Five of them are called to update counter. And the rest lo=
oks good to me.</div>

<div><br></div><div>1. too_many_isolated()=A0</div><div>=A0 =A0 returns fal=
se if kswapd</div><div><br></div><div>2.=A0should_reclaim_stall()</div><div=
>=A0 =A0 returns false if kswapd</div><div><br></div><div>3. =A0nfs_commit_=
inode()</div>

<div>=A0 =A0may_wait =3D NULL if kswapd</div><div><br></div><div>--Ying</di=
v><div>=A0 =A0=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>
</blockquote></div><br>

--0023544706741d68a904a0e80b07--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
