Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB8A66B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:53:42 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4R1nS6M021368
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:49:29 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by kpbe14.cbf.corp.google.com with ESMTP id p4R1nRqh015657
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:49:27 -0700
Received: by qwa26 with SMTP id 26so921837qwa.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 18:49:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 18:49:26 -0700
Message-ID: <BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 0/10] memcg async reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, May 25, 2011 at 10:10 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> It's now merge window...I just dump my patch queue to hear other's idea.
> I wonder I should wait until dirty_ratio for memcg is queued to mmotm...
> I'll be busy with LinuxCon Japan etc...in the next week.
>
> This patch is onto mmotm-May-11 + some patches queued in mmotm, as numa_s=
tat.
>
> This is a patch for memcg to keep margin to the limit in background.
> By keeping some margin to the limit in background, application can
> avoid foreground memory reclaim at charge() and this will help latency.
>
> Main changes from v2 is.
> =A0- use SCHED_IDLE.
> =A0- removed most of heuristic codes. Now, code is very simple.
>
> By using SCHED_IDLE, async memory reclaim can only consume 0.3%? of cpu
> if the system is truely busy but can use much CPU if the cpu is idle.
> Because my purpose is for reducing latency without affecting other runnin=
g
> applications, SCHED_IDLE fits this work.
>
> If application need to stop by some I/O or event, background memory recla=
im
> will cull memory while the system is idle.
>
> Perforemce:
> =A0Running an httpd (apache) under 300M limit. And access 600MB working s=
et
> =A0with normalized distribution access by apatch-bench.
> =A0apatch bench's concurrency was 4 and did 40960 accesses.
>
> Without async reclaim:
> Connection Times (ms)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0min =A0mean[+/-sd] median =A0 max
> Connect: =A0 =A0 =A0 =A00 =A0 =A00 =A0 0.0 =A0 =A0 =A00 =A0 =A0 =A0 2
> Processing: =A0 =A030 =A0 37 =A028.3 =A0 =A0 32 =A0 =A01793
> Waiting: =A0 =A0 =A0 28 =A0 35 =A025.5 =A0 =A0 31 =A0 =A01792
> Total: =A0 =A0 =A0 =A0 30 =A0 37 =A028.4 =A0 =A0 32 =A0 =A01793
>
> Percentage of the requests served within a certain time (ms)
> =A050% =A0 =A0 32
> =A066% =A0 =A0 32
> =A075% =A0 =A0 33
> =A080% =A0 =A0 34
> =A090% =A0 =A0 39
> =A095% =A0 =A0 60
> =A098% =A0 =A0100
> =A099% =A0 =A0133
> =A0100% =A0 1793 (longest request)
>
> With async reclaim:
> Connection Times (ms)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0min =A0mean[+/-sd] median =A0 max
> Connect: =A0 =A0 =A0 =A00 =A0 =A00 =A0 0.0 =A0 =A0 =A00 =A0 =A0 =A0 2
> Processing: =A0 =A030 =A0 35 =A012.3 =A0 =A0 32 =A0 =A0 678
> Waiting: =A0 =A0 =A0 28 =A0 34 =A012.0 =A0 =A0 31 =A0 =A0 658
> Total: =A0 =A0 =A0 =A0 30 =A0 35 =A012.3 =A0 =A0 32 =A0 =A0 678
>
> Percentage of the requests served within a certain time (ms)
> =A050% =A0 =A0 32
> =A066% =A0 =A0 32
> =A075% =A0 =A0 33
> =A080% =A0 =A0 34
> =A090% =A0 =A0 39
> =A095% =A0 =A0 49
> =A098% =A0 =A0 71
> =A099% =A0 =A0 86
> =A0100% =A0 =A0678 (longest request)
>
>
> It seems latency is stabilized by hiding memory reclaim.
>
> The score for memory reclaim was following.
> See patch 10 for meaning of each member.
>
> =3D=3D without async reclaim =3D=3D
> recent_scan_success_ratio 44
> limit_scan_pages 388463
> limit_freed_pages 162238
> limit_elapsed_ns 13852159231
> soft_scan_pages 0
> soft_freed_pages 0
> soft_elapsed_ns 0
> margin_scan_pages 0
> margin_freed_pages 0
> margin_elapsed_ns 0
>
> =3D=3D with async reclaim =3D=3D
> recent_scan_success_ratio 6
> limit_scan_pages 0
> limit_freed_pages 0
> limit_elapsed_ns 0
> soft_scan_pages 0
> soft_freed_pages 0
> soft_elapsed_ns 0
> margin_scan_pages 1295556
> margin_freed_pages 122450
> margin_elapsed_ns 644881521
>
>
> For this case, SCHED_IDLE workqueue can reclaim enough memory to the http=
d.
>
> I may need to dig why scan_success_ratio is far different in the both cas=
e.
> I guess the difference of epalsed_ns is because several threads enter
> memory reclaim when async reclaim doesn't run. But may not...
>


Hmm.. I noticed a very strange behavior on a simple test w/ the patch set.

Test:
I created a 4g memcg and start doing cat. Then the memcg being OOM
killed as soon as it reaches its hard_limit. We shouldn't hit OOM even
w/o async-reclaim.

Again, I will read through the patch. But like to post the test result firs=
t.

$ echo $$ >/dev/cgroup/memory/A/tasks
$ cat /dev/cgroup/memory/A/memory.limit_in_bytes
4294967296

$ time cat /export/hdc3/dd_A/tf0 > /dev/zero
Killed

real	0m53.565s
user	0m0.061s
sys	0m4.814s

Here is the OOM log:

May 26 18:43:00  kernel: [  963.489112] cat invoked oom-killer:
gfp_mask=3D0xd0, order=3D0, oom_adj=3D0, oom_score_adj=3D0
May 26 18:43:00  kernel: [  963.489121] Pid: 9425, comm: cat Tainted:
G        W   2.6.39-mcg-DEV #131
May 26 18:43:00  kernel: [  963.489123] Call Trace:
May 26 18:43:00  kernel: [  963.489134]  [<ffffffff810e3512>]
dump_header+0x82/0x1af
May 26 18:43:00  kernel: [  963.489137]  [<ffffffff810e33ca>] ?
spin_lock+0xe/0x10
May 26 18:43:00  kernel: [  963.489140]  [<ffffffff810e33f9>] ?
find_lock_task_mm+0x2d/0x67
May 26 18:43:00  kernel: [  963.489143]  [<ffffffff810e38dd>]
oom_kill_process+0x50/0x27b
May 26 18:43:00  kernel: [  963.489155]  [<ffffffff810e3dc6>]
mem_cgroup_out_of_memory+0x9a/0xe4
May 26 18:43:00  kernel: [  963.489160]  [<ffffffff811153aa>]
mem_cgroup_handle_oom+0x134/0x1fe
May 26 18:43:00  kernel: [  963.489163]  [<ffffffff81114a72>] ?
__mem_cgroup_insert_exceeded+0x83/0x83
May 26 18:43:00  kernel: [  963.489176]  [<ffffffff811166e9>]
__mem_cgroup_try_charge.clone.3+0x368/0x43a
May 26 18:43:00  kernel: [  963.489179]  [<ffffffff81117586>]
mem_cgroup_cache_charge+0x95/0x123
May 26 18:43:00  kernel: [  963.489183]  [<ffffffff810e16d8>]
add_to_page_cache_locked+0x42/0x114
May 26 18:43:00  kernel: [  963.489185]  [<ffffffff810e17db>]
add_to_page_cache_lru+0x31/0x5f
May 26 18:43:00  kernel: [  963.489189]  [<ffffffff81145636>]
mpage_readpages+0xb6/0x132
May 26 18:43:00  kernel: [  963.489194]  [<ffffffff8119992f>] ?
noalloc_get_block_write+0x24/0x24
May 26 18:43:00  kernel: [  963.489197]  [<ffffffff8119992f>] ?
noalloc_get_block_write+0x24/0x24
May 26 18:43:00  kernel: [  963.489201]  [<ffffffff81036742>] ?
__switch_to+0x160/0x212
May 26 18:43:00  kernel: [  963.489205]  [<ffffffff811978b2>]
ext4_readpages+0x1d/0x1f
May 26 18:43:00  kernel: [  963.489209]  [<ffffffff810e8d4b>]
__do_page_cache_readahead+0x144/0x1e3
May 26 18:43:00  kernel: [  963.489212]  [<ffffffff810e8e0b>]
ra_submit+0x21/0x25
May 26 18:43:00  kernel: [  963.489215]  [<ffffffff810e9075>]
ondemand_readahead+0x18c/0x19f
May 26 18:43:00  kernel: [  963.489218]  [<ffffffff810e9105>]
page_cache_async_readahead+0x7d/0x86
May 26 18:43:00  kernel: [  963.489221]  [<ffffffff810e2b7e>]
generic_file_aio_read+0x2d8/0x5fe
May 26 18:43:00  kernel: [  963.489225]  [<ffffffff81119626>]
do_sync_read+0xcb/0x108
May 26 18:43:00  kernel: [  963.489230]  [<ffffffff811f168a>] ?
fsnotify_perm+0x66/0x72
May 26 18:43:00  kernel: [  963.489233]  [<ffffffff811f16f7>] ?
security_file_permission+0x2e/0x33
May 26 18:43:00  kernel: [  963.489236]  [<ffffffff8111a0c8>]
vfs_read+0xab/0x107
May 26 18:43:00  kernel: [  963.489239]  [<ffffffff8111a1e4>] sys_read+0x4a=
/0x6e
May 26 18:43:00  kernel: [  963.489244]  [<ffffffff8140f469>]
sysenter_dispatch+0x7/0x27
May 26 18:43:00  kernel: [  963.489248] Task in /A killed as a result
of limit of /A
May 26 18:43:00  kernel: [  963.489251] memory: usage 4194304kB, limit
4194304kB, failcnt 26
May 26 18:43:00  kernel: [  963.489253] memory+swap: usage 0kB, limit
9007199254740991kB, failcnt 0

--Ying

>
> Thanks,
> -Kame
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
