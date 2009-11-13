Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 72A1E6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 02:38:29 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD7cQiP001000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 16:38:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EE6FE45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:38:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D200545DE4C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:38:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B6F7B1DB8037
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:38:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44BEC1DB803A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:38:22 +0900 (JST)
Date: Fri, 13 Nov 2009 16:35:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC MM] speculative page fault
Message-Id: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is just a toy patch inspied by on Christoph's mmap_sem works.
Only for my hobby, now.

Not well tested. So please look into only if you have time.

My multi-thread page fault test program shows some improvement.
But I doubt my test ;) Do you have recommended benchmarks for parallel page-faults ?

Counting # of page faults per 60sec. See page-faults. bigger is better.
Test on x86-64 8cpus.

[Before]
  474441.541914  task-clock-msecs         #      7.906 CPUs
          10318  context-switches         #      0.000 M/sec
             10  CPU-migrations           #      0.000 M/sec
       15816787  page-faults              #      0.033 M/sec
  1485219138381  cycles                   #   3130.458 M/sec  (scaled from 69.99%)
   295669524399  instructions             #      0.199 IPC    (scaled from 79.98%)
    57658291915  branches                 #    121.529 M/sec  (scaled from 79.98%)
      798567455  branch-misses            #      1.385 %      (scaled from 79.98%)
     2458780947  cache-references         #      5.182 M/sec  (scaled from 20.02%)
      844605496  cache-misses             #      1.780 M/sec  (scaled from 20.02%)

[After]
471166.582784  task-clock-msecs         #      7.852 CPUs
          10378  context-switches         #      0.000 M/sec
             10  CPU-migrations           #      0.000 M/sec
       37950235  page-faults              #      0.081 M/sec
  1463000664470  cycles                   #   3105.060 M/sec  (scaled from 70.32%)
   346531590054  instructions             #      0.237 IPC    (scaled from 80.20%)
    63309364882  branches                 #    134.367 M/sec  (scaled from 80.19%)
      448256258  branch-misses            #      0.708 %      (scaled from 80.20%)
     2601112130  cache-references         #      5.521 M/sec  (scaled from 19.81%)
      872978619  cache-misses             #      1.853 M/sec  (scaled from 19.80%)


Main concept of this patch is
 - Do page fault without taking mm->mmap_sem until some modification in vma happens.
 - All page fault via get_user_pages() should have to take mmap_sem.
 - find_vma()/rb_tree must be walked under proper locks. For avoiding that, use
   per-thread cache.

It seems I don't have enough time to update this, more.
So, I dump patches here just for share.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
