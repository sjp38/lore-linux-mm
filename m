Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 0C86D6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:12:11 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:12:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Scheduler
Message-ID: <20120723211206.GZ9222@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Configuration:	global-dhp__scheduler-performance
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__scheduler-performance
Benchmarks:	hackbench-pipes hackbench-sockets pipetest starve lmbench

Summary
=======

This is a mixed bag. The results on an I7 generally look great! There are
some major improvemnets in there and I think this may be due to scheduler
developers working with the latest chips. The other machines did not far
as well. Look at pipetest on hydra for an example of a particularly bad
set of results.

Benchmark notes
===============

starve (http://www.hpl.hp.com/research/linux/kernel/o1-starve.php) was
  chosen because even though it is designed to isolate a bug in the O(1)
  scheduler, it is still interesting to monitor for performance regressions.
  It does not take any special parameters.

hackbench was chosen because it's a general scheduler benchmark that is
  sensitive to regressions in the scheduler fast-path. It is difficult
  to draw conclusions from as it is somewhat sensitive to the starting
  conditions of the machine but trends over time may be observed. It is
  run in both pipe and sockets mode and for each number of clients, it is
  run for 30 iterations.

pipetest is a scheduler ping-pong test that measures context switch latency.
  It runs for 30 iterations.

lmbench is just running the lat_ctx test and is another measure of context
  switch latency.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__scheduler-performance/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Context switch latency is regressing.
===========================================================

starve is looking ok except for 3.0 and 3.1 where System CPU time and elapsed
	time increased. This was fixed in later kernels but worth noting
	for users of -stable.

lmbench showed a small regression in 3.0 where context switch latency was
	increased and this has not been recovered yet. 3.3.6 was particularly
	bad for low numbers of clients.

hackbench-pipes looks ok in comparison to 2.6.32. The "Time ratio" graph
	shows that kernels are below the red line reflecting that most
	kernels are faster. However, it also shows that 2.6.34 was the
	"best" kernel and recent kernels have regressed slightly

hackbench-sockets regressed badly after 2.6.34 until 3.3 which should be
	investigated. Again this is most obvious in the Time Ratio graph

pipetest is showing major regressions in latency since some time between 2.6.34
	and 2.6.39.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__scheduler-performance/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		pipetest is particularly bad.
==========================================================

starve is generally ok although again, 3.0 and 3.1 both regressed on System
	CPU time. This was improved on kernels after that but it's still
	a little worse than 2.6.32 was.

lmbench shows no regression in 3.0 unlike on arnold but later kernels are
	much worse with the latency of 3.4 being generally higher than it
	was in 3.2

hackbench-pipes generally looks ok.

hackbench-sockets is generally bad. 3.1 was particularly bad and while
	3.4 has improved the situation a bit, it is still worse than 2.6.32.

pipetest is showing major regressions. 3.2 regressed particularly badly.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__scheduler-performance/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Generally great.
==========================================================

starve is generally ok. 3.0 regressed in terms of System CPU time but
	recent kernels are very good. This might reflect that a lot
	of people are testing with later Intel processors to the
	detriment of older models.

lmbench is looking superb.

hackbench-pipes looks great.

hackbench-sockets does not look as great but it's still very good.

pipetest is generally looking good in comparison to 2.6.32. However,
	I am concerned that 3.4 is worse than 3.3.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
