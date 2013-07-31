Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8761D6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:36:53 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 13:36:52 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8299AC90043
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:36:47 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6VHakki186852
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:36:47 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6VHZYLl031479
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:35:34 -0600
Date: Wed, 31 Jul 2013 23:05:13 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130731173513.GA12770@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
 <20130730091542.GA28656@linux.vnet.ibm.com>
 <20130730093321.GO3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130730093321.GO3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2013-07-30 11:33:21]:

> On Tue, Jul 30, 2013 at 02:45:43PM +0530, Srikar Dronamraju wrote:
> 
> > Can you please suggest workloads that I could try which might showcase
> > why you hate pure process based approach?
> 
> 2 processes, 1 sysvshm segment. I know there's multi-process MPI
> libraries out there.
> 
> Something like: perf bench numa mem -p 2 -G 4096 -0 -z --no-data_rand_walk -Z
> 

The above dumped core; Looks like -T is a must with -G.

I tried "perf bench numa mem -p 2 -T 32 -G 4096 -0 -z --no-data_rand_walk -Z"
It still didn't seem to do anything on my 4 node box (almost 2 hours
and nothing happened).

Finally I ran "perf bench numa mem -a"
(both with ht disabled and enabled)

Convergence wise my patchset did really well.

bw looks like a mixed bag. Though there are improvements, we see
degradations. I am not sure how to quantify which was the best among the
three. nx1 tests were the ones where this patchset had a -ve; but +ve
for all others.

Is this what you were looking for? Or was it something else?

(Lower is better)
testcase		3.9.0		Mels v5		this_patchset 	Units
------------------------------------------------------------------------------
1x3-convergence		0.320		100.060		100.204		secs
1x4-convergence		100.139		100.162		100.155		secs
1x6-convergence		100.455		100.179		1.078		secs
2x3-convergence		100.261		100.339		9.743		secs
3x3-convergence		100.213		100.168		10.073		secs
4x4-convergence		100.307		100.201		19.686		secs
4x4-convergence-NOTHP	100.229		100.221		3.189		secs
4x6-convergence		101.441		100.632		6.204		secs
4x8-convergence		100.680		100.588		5.275		secs
8x4-convergence		100.335		100.365		34.069		secs
8x4-convergence-NOTHP	100.331		100.412		100.478		secs
3x1-convergence		1.227		1.536		0.576		secs
4x1-convergence		1.224		1.063		1.390		secs
8x1-convergence		1.713		2.437		1.704		secs
16x1-convergence	2.750		2.677		1.856		secs
32x1-convergence	1.985		1.795		1.391		secs


(Higher is better)
testcase		3.9.0		Mels v5		this_patchset 	Units
------------------------------------------------------------------------------
RAM-bw-local		3.341		3.340		3.325		GB/sec
RAM-bw-local-NOTHP	3.308		3.307		3.290		GB/sec
RAM-bw-remote		1.815		1.815		1.815		GB/sec
RAM-bw-local-2x		6.410		6.413		6.412		GB/sec
RAM-bw-remote-2x	3.020		3.041		3.027		GB/sec
RAM-bw-cross		4.397		3.425		4.374		GB/sec
2x1-bw-process		3.481		3.442		3.492		GB/sec
3x1-bw-process		5.423		7.547		5.445		GB/sec
4x1-bw-process		5.108		11.009		5.118		GB/sec
8x1-bw-process		8.929		10.935		8.825		GB/sec
8x1-bw-process-NOTHP	12.754		11.442		22.889		GB/sec
16x1-bw-process		12.886		12.685		13.546		GB/sec
4x1-bw-thread		19.147		17.964		9.622		GB/sec
8x1-bw-thread		26.342		30.171		14.679		GB/sec
16x1-bw-thread		41.527		36.363		40.070		GB/sec
32x1-bw-thread		45.005		40.950		49.846		GB/sec
2x3-bw-thread		9.493		14.444		8.145		GB/sec
4x4-bw-thread		18.309		16.382		45.384		GB/sec
4x6-bw-thread		14.524		18.502		17.058		GB/sec
4x8-bw-thread		13.315		16.852		33.693		GB/sec
4x8-bw-thread-NOTHP	12.273		12.226		24.887		GB/sec
3x3-bw-thread		17.614		11.960		16.119		GB/sec
5x5-bw-thread		13.415		17.585		24.251		GB/sec
2x16-bw-thread		11.718		11.174		17.971		GB/sec
1x32-bw-thread		11.360		10.902		14.330		GB/sec
numa02-bw		48.999		44.173		54.795		GB/sec
numa02-bw-NOTHP		47.655		42.600		53.445		GB/sec
numa01-bw-thread	36.983		39.692		45.254		GB/sec
numa01-bw-thread-NOTHP	38.486		35.208		44.118		GB/sec



With HT ON

(Lower is better)
testcase		3.9.0		Mels v5		this_patchset 	Units
------------------------------------------------------------------------------
1x3-convergence		100.114		100.138		100.084		secs
1x4-convergence		0.468		100.227		100.153		secs
1x6-convergence		100.278		100.400		100.197		secs
2x3-convergence		100.186		1.833		13.132		secs
3x3-convergence		100.302		100.457		2.087		secs
4x4-convergence		100.237		100.178		2.466		secs
4x4-convergence-NOTHP	100.148		100.251		2.985		secs
4x6-convergence		100.931		3.632		9.184		secs
4x8-convergence		100.398		100.456		4.801		secs
8x4-convergence		100.649		100.458		4.179		secs
8x4-convergence-NOTHP	100.391		100.428		9.758		secs
3x1-convergence		1.472		1.501		0.727		secs
4x1-convergence		1.478		1.489		1.408		secs
8x1-convergence		2.380		2.385		2.432		secs
16x1-convergence	3.260		3.399		2.219		secs
32x1-convergence	2.622		2.067		1.951		secs



(Higher is better)
testcase		3.9.0		Mels v5		this_patchset 	Units
------------------------------------------------------------------------------
RAM-bw-local		3.333		3.342		3.345		GB/sec
RAM-bw-local-NOTHP	3.305		3.306		3.307		GB/sec
RAM-bw-remote		1.814		1.814		1.816		GB/sec
RAM-bw-local-2x		7.896		6.400		6.538		GB/sec
RAM-bw-remote-2x	2.982		3.038		3.034		GB/sec
RAM-bw-cross		4.313		3.427		4.372		GB/sec
2x1-bw-process		3.473		4.708		3.784		GB/sec
3x1-bw-process		5.397		4.983		5.399		GB/sec
4x1-bw-process		5.040		8.775		5.098		GB/sec
8x1-bw-process		8.989		6.862		13.745		GB/sec
8x1-bw-process-NOTHP	8.457		19.094		8.118		GB/sec
16x1-bw-process		13.482		23.067		15.138		GB/sec
4x1-bw-thread		14.904		18.258		9.713		GB/sec
8x1-bw-thread		24.160		29.153		12.495		GB/sec
16x1-bw-thread		41.283		36.642		32.140		GB/sec
32x1-bw-thread		46.983		43.068		48.153		GB/sec
2x3-bw-thread		9.718		15.344		10.846		GB/sec
4x4-bw-thread		12.602		15.758		13.148		GB/sec
4x6-bw-thread		13.807		11.278		18.540		GB/sec
4x8-bw-thread		13.316		11.677		22.795		GB/sec
4x8-bw-thread-NOTHP	12.548		21.797		30.807		GB/sec
3x3-bw-thread		13.500		18.758		18.569		GB/sec
5x5-bw-thread		14.575		14.199		36.521		GB/sec
2x16-bw-thread		11.345		11.434		19.569		GB/sec
1x32-bw-thread		14.123		10.586		14.587		GB/sec
numa02-bw		50.963		44.092		53.419		GB/sec
numa02-bw-NOTHP		50.553		42.724		51.106		GB/sec
numa01-bw-thread	33.724		33.050		37.801		GB/sec
numa01-bw-thread-NOTHP	39.064		35.139		43.314		GB/sec


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
