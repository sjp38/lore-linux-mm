Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DFCBE6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 22:55:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 76A5B3EE0C1
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:55:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B9CA45DF8A
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:55:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC6A45DF87
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:55:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 181291DB8037
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:55:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA9171DB803E
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:55:23 +0900 (JST)
Date: Fri, 27 May 2011 11:48:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 0/10] memcg async reclaim
Message-Id: <20110527114837.8fae7f00.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 26 May 2011 18:49:26 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, May 25, 2011 at 10:10 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > It's now merge window...I just dump my patch queue to hear other's idea.
> > I wonder I should wait until dirty_ratio for memcg is queued to mmotm...
> > I'll be busy with LinuxCon Japan etc...in the next week.
> >
> > This patch is onto mmotm-May-11 + some patches queued in mmotm, as numa_stat.
> >
> > This is a patch for memcg to keep margin to the limit in background.
> > By keeping some margin to the limit in background, application can
> > avoid foreground memory reclaim at charge() and this will help latency.
> >
> > Main changes from v2 is.
> > A - use SCHED_IDLE.
> > A - removed most of heuristic codes. Now, code is very simple.
> >
> > By using SCHED_IDLE, async memory reclaim can only consume 0.3%? of cpu
> > if the system is truely busy but can use much CPU if the cpu is idle.
> > Because my purpose is for reducing latency without affecting other running
> > applications, SCHED_IDLE fits this work.
> >
> > If application need to stop by some I/O or event, background memory reclaim
> > will cull memory while the system is idle.
> >
> > Perforemce:
> > A Running an httpd (apache) under 300M limit. And access 600MB working set
> > A with normalized distribution access by apatch-bench.
> > A apatch bench's concurrency was 4 and did 40960 accesses.
> >
> > Without async reclaim:
> > Connection Times (ms)
> > A  A  A  A  A  A  A min A mean[+/-sd] median A  max
> > Connect: A  A  A  A 0 A  A 0 A  0.0 A  A  A 0 A  A  A  2
> > Processing: A  A 30 A  37 A 28.3 A  A  32 A  A 1793
> > Waiting: A  A  A  28 A  35 A 25.5 A  A  31 A  A 1792
> > Total: A  A  A  A  30 A  37 A 28.4 A  A  32 A  A 1793
> >
> > Percentage of the requests served within a certain time (ms)
> > A 50% A  A  32
> > A 66% A  A  32
> > A 75% A  A  33
> > A 80% A  A  34
> > A 90% A  A  39
> > A 95% A  A  60
> > A 98% A  A 100
> > A 99% A  A 133
> > A 100% A  1793 (longest request)
> >
> > With async reclaim:
> > Connection Times (ms)
> > A  A  A  A  A  A  A min A mean[+/-sd] median A  max
> > Connect: A  A  A  A 0 A  A 0 A  0.0 A  A  A 0 A  A  A  2
> > Processing: A  A 30 A  35 A 12.3 A  A  32 A  A  678
> > Waiting: A  A  A  28 A  34 A 12.0 A  A  31 A  A  658
> > Total: A  A  A  A  30 A  35 A 12.3 A  A  32 A  A  678
> >
> > Percentage of the requests served within a certain time (ms)
> > A 50% A  A  32
> > A 66% A  A  32
> > A 75% A  A  33
> > A 80% A  A  34
> > A 90% A  A  39
> > A 95% A  A  49
> > A 98% A  A  71
> > A 99% A  A  86
> > A 100% A  A 678 (longest request)
> >
> >
> > It seems latency is stabilized by hiding memory reclaim.
> >
> > The score for memory reclaim was following.
> > See patch 10 for meaning of each member.
> >
> > == without async reclaim ==
> > recent_scan_success_ratio 44
> > limit_scan_pages 388463
> > limit_freed_pages 162238
> > limit_elapsed_ns 13852159231
> > soft_scan_pages 0
> > soft_freed_pages 0
> > soft_elapsed_ns 0
> > margin_scan_pages 0
> > margin_freed_pages 0
> > margin_elapsed_ns 0
> >
> > == with async reclaim ==
> > recent_scan_success_ratio 6
> > limit_scan_pages 0
> > limit_freed_pages 0
> > limit_elapsed_ns 0
> > soft_scan_pages 0
> > soft_freed_pages 0
> > soft_elapsed_ns 0
> > margin_scan_pages 1295556
> > margin_freed_pages 122450
> > margin_elapsed_ns 644881521
> >
> >
> > For this case, SCHED_IDLE workqueue can reclaim enough memory to the httpd.
> >
> > I may need to dig why scan_success_ratio is far different in the both case.
> > I guess the difference of epalsed_ns is because several threads enter
> > memory reclaim when async reclaim doesn't run. But may not...
> >
> 
> 
> Hmm.. I noticed a very strange behavior on a simple test w/ the patch set.
> 
> Test:
> I created a 4g memcg and start doing cat. Then the memcg being OOM
> killed as soon as it reaches its hard_limit. We shouldn't hit OOM even
> w/o async-reclaim.
> 
> Again, I will read through the patch. But like to post the test result first.
> 
> $ echo $$ >/dev/cgroup/memory/A/tasks
> $ cat /dev/cgroup/memory/A/memory.limit_in_bytes
> 4294967296
> 
> $ time cat /export/hdc3/dd_A/tf0 > /dev/zero
> Killed
> 
> real	0m53.565s
> user	0m0.061s
> sys	0m4.814s
> 

Hmm, what I see is
==
root@bluextal kamezawa]# ls -l test/1G
-rw-rw-r--. 1 kamezawa kamezawa 1053261824 May 13 13:58 test/1G
[root@bluextal kamezawa]# mkdir /cgroup/memory/A
[root@bluextal kamezawa]# echo 0 > /cgroup/memory/A/tasks
[root@bluextal kamezawa]# echo 300M > /cgroup/memory/A/memory.limit_in_bytes
[root@bluextal kamezawa]# echo 1 > /cgroup/memory/A/memory.async_control
[root@bluextal kamezawa]# cat test/1G > /dev/null
[root@bluextal kamezawa]# cat /cgroup/memory/A/memory.reclaim_stat
recent_scan_success_ratio 83
limit_scan_pages 82
limit_freed_pages 49
limit_elapsed_ns 242507
soft_scan_pages 0
soft_freed_pages 0
soft_elapsed_ns 0
margin_scan_pages 218630
margin_freed_pages 181598
margin_elapsed_ns 117466604
[root@bluextal kamezawa]#
==

I'll turn off swapaccount and try again.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
