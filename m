Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ED2F86B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:34:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7YHm3025058
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:34:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5573345DE53
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2532E45DE51
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E2DAD1DB805B
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B1CA1DB8040
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:16 +0900 (JST)
Date: Thu, 10 Dec 2009 16:31:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC mm][PATCH 0/5] per mm counter updates
Message-Id: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

For better OOM handling and statistics per process, I'd like to add new
counters in mm_struct, counter for swap entries and lowmem usage.

But, simply adding new counter makes page fault path fat and adds more cache
misses. So, before going further, it's better to modify per-mm counter itself.

This is an updated version of percpu cached mm counter.

Main changes from previous one is:
  - If no page faults, no sync at scheduler.
  - removed synchronization at tick.
  - added SWAPENTS counter.
  - added lowmem_rss counter.

(I added Ingo to CC: because this patch has hooks for schedule(), tell me
 if you finds concern in patch [2/5]...)

In general, maintaining a shared counter without frequent atomic_ops can be done
in following ways.
 (1) use simple percpu counter. and calculates sum of it at read.
 (2) use cached percpu counter and make some invalidation/synchronization points.

because read cost of this per mm counter is important, this set uses (2).
And synchronziation points is in schedule().

Scheule() is a good point for synchronize per-process per-cpu cached information.
I wanted to avoid adds hooks to schedule() but 
  - Hadnling all per-cpu cache handling requires complicated refcnt handling.
  - taskacct requires full-synchronization of cached counter information.
    IPI at each task exit()? it's silly.

Follwoing is the cost of this patches. On 2 socket x86-64 hosts.
Measured the number of pagefaults caused by 2 threads in 60secs.
One thread per one socket. (test program will follow this mail.)
This patch set is only for SPLIT_PTLOCK=y case.

[Before] (mmotom-2.6.32-Dec8)
 Performance counter stats for './multi-fault 2' (5 runs):

       45122351  page-faults                ( +-   1.125% )
      989608571  cache-references           ( +-   1.198% )
      205308558  cache-misses               ( +-   0.159% )
 29263096648639268  bus-cycles                 ( +-   0.004% )

   60.003427500  seconds time elapsed   ( +-   0.003% )

4.55 miss/faults

[After patch 2/5] (percpu cached counter)
Performance counter stats for './multi-fault 2' (5 runs):

       46997471  page-faults                ( +-   0.720% )
     1004100076  cache-references           ( +-   0.734% )
      180959964  cache-misses               ( +-   0.374% )
 29263437363580464  bus-cycles                 ( +-   0.002% )

   60.003315683  seconds time elapsed   ( +-   0.004% )

3.85 miss/faults

[After patch 5/5] (adds 2 more coutners..swapents and lowmem)
 Performance counter stats for './multi-fault 2' (5 runs):

       45976947  page-faults                ( +-   0.405% )
      992296954  cache-references           ( +-   0.860% )
      183961537  cache-misses               ( +-   0.473% )
 29261902069414016  bus-cycles                 ( +-   0.002% )

   60.001403261  seconds time elapsed   ( +-   0.000% )

4.0 miss/faults.


Just for curious, this is the result when SPLIT_PTLOCKS is not enabled.

Performance counter stats for './multi-fault 2' (5 runs):

       20329544  page-faults                ( +-   0.795% )
     1041624126  cache-references           ( +-   1.153% )
      160983634  cache-misses               ( +-   3.188% )
 29217349673892936  bus-cycles                 ( +-   0.035% )

   60.004098210  seconds time elapsed   ( +-   0.003% )

Too bad ;(

(Off topic) Why SPLIT_PTLOCKS is disabled if DEBUG_SPINLOCK=y ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
