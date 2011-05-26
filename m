Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 117D16B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:18:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8895F3EE0AE
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:18:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69A3445DF1D
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:18:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48DFC45DF1F
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:18:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28573E08001
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:18:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E32EF8002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:18:09 +0900 (JST)
Date: Thu, 26 May 2011 14:10:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 0/10] memcg async reclaim
Message-Id: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


It's now merge window...I just dump my patch queue to hear other's idea.
I wonder I should wait until dirty_ratio for memcg is queued to mmotm...
I'll be busy with LinuxCon Japan etc...in the next week.

This patch is onto mmotm-May-11 + some patches queued in mmotm, as numa_stat.

This is a patch for memcg to keep margin to the limit in background.
By keeping some margin to the limit in background, application can
avoid foreground memory reclaim at charge() and this will help latency.

Main changes from v2 is.
  - use SCHED_IDLE.
  - removed most of heuristic codes. Now, code is very simple.

By using SCHED_IDLE, async memory reclaim can only consume 0.3%? of cpu
if the system is truely busy but can use much CPU if the cpu is idle.
Because my purpose is for reducing latency without affecting other running
applications, SCHED_IDLE fits this work.

If application need to stop by some I/O or event, background memory reclaim
will cull memory while the system is idle.

Perforemce:
 Running an httpd (apache) under 300M limit. And access 600MB working set
 with normalized distribution access by apatch-bench.
 apatch bench's concurrency was 4 and did 40960 accesses.

Without async reclaim:
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       2
Processing:    30   37  28.3     32    1793
Waiting:       28   35  25.5     31    1792
Total:         30   37  28.4     32    1793

Percentage of the requests served within a certain time (ms)
  50%     32
  66%     32
  75%     33
  80%     34
  90%     39
  95%     60
  98%    100
  99%    133
 100%   1793 (longest request)

With async reclaim:
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       2
Processing:    30   35  12.3     32     678
Waiting:       28   34  12.0     31     658
Total:         30   35  12.3     32     678

Percentage of the requests served within a certain time (ms)
  50%     32
  66%     32
  75%     33
  80%     34
  90%     39
  95%     49
  98%     71
  99%     86
 100%    678 (longest request)


It seems latency is stabilized by hiding memory reclaim.

The score for memory reclaim was following.
See patch 10 for meaning of each member.

== without async reclaim ==
recent_scan_success_ratio 44
limit_scan_pages 388463
limit_freed_pages 162238
limit_elapsed_ns 13852159231
soft_scan_pages 0
soft_freed_pages 0
soft_elapsed_ns 0
margin_scan_pages 0
margin_freed_pages 0
margin_elapsed_ns 0

== with async reclaim ==
recent_scan_success_ratio 6
limit_scan_pages 0
limit_freed_pages 0
limit_elapsed_ns 0
soft_scan_pages 0
soft_freed_pages 0
soft_elapsed_ns 0
margin_scan_pages 1295556
margin_freed_pages 122450
margin_elapsed_ns 644881521


For this case, SCHED_IDLE workqueue can reclaim enough memory to the httpd.

I may need to dig why scan_success_ratio is far different in the both case.
I guess the difference of epalsed_ns is because several threads enter
memory reclaim when async reclaim doesn't run. But may not...



Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
