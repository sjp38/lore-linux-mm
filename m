Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E7BB6B0089
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 20:04:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0714Iv0013279
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 10:04:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0320E45DE52
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:04:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D527045DE50
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:04:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADEF31DB8048
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:04:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41F801DB8042
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:04:17 +0900 (JST)
Date: Thu, 7 Jan 2010 10:00:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100107100054.e56b709a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001060119010.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
	<20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
	<20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
	<20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
	<20100106160614.ff756f82.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001060119010.3630@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 2010 01:39:17 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
> >
> >      9.08%  multi-fault-all  [kernel]                  [k] down_read_trylock
<snip>
> That way, it will do the cmpxchg first, and if it wasn't unlocked and had 
> other readers active, it will end up doing an extra cmpxchg, but still 
> hopefully avoid the extra bus cycles.
> 
> So it might be worth testing this trivial patch on top of my other one.
> 
Test: on 8-core/2-socket x86-64
  while () {
	touch memory
	barrier
	madvice DONTNEED all range by cpu 0
	barrier
  }

<Before> (cut from my post)
> [root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8
> 
>  Performance counter stats for './multi-fault-all 8' (5 runs):
> 
>        33029186  page-faults                ( +-   0.146% )
>       348698659  cache-misses               ( +-   0.149% )
> 
>    60.002876268  seconds time elapsed   ( +-   0.001% )
>     41.51%  multi-fault-all  [kernel]                  [k] clear_page_c
>      9.08%  multi-fault-all  [kernel]                  [k] down_read_trylock
>      6.23%  multi-fault-all  [kernel]                  [k] up_read
>      6.17%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_charg


<After>
[root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8

 Performance counter stats for './multi-fault-all 8' (5 runs):

       33782787  page-faults                ( +-   2.650% )
      332753197  cache-misses               ( +-   0.477% )

   60.003984337  seconds time elapsed   ( +-   0.004% )

# Samples: 1014408915089
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    44.42%  multi-fault-all  [kernel]                  [k] clear_page_c
     7.73%  multi-fault-all  [kernel]                  [k] down_read_trylock
     6.65%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_char
     6.15%  multi-fault-all  [kernel]                  [k] up_read
     4.87%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     3.70%  multi-fault-all  [kernel]                  [k] __rmqueue
     3.69%  multi-fault-all  [kernel]                  [k] __mem_cgroup_commit_c
     2.35%  multi-fault-all  [kernel]                  [k] bad_range


yes, it seems slightly improved, at least on this test.
but page-fault-throughput test score is within error range.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
