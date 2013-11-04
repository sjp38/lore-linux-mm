Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 498B96B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 17:36:43 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so7346102pdj.33
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 14:36:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id z1si878202pbn.211.2013.11.04.14.36.41
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 14:36:42 -0800 (PST)
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1381948114.11046.194.camel@schen9-DESK>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
	 <1380753493.11046.82.camel@schen9-DESK> <20131003073212.GC5775@gmail.com>
	 <1381186674.11046.105.camel@schen9-DESK> <20131009061551.GD7664@gmail.com>
	 <1381336441.11046.128.camel@schen9-DESK> <20131010075444.GD17990@gmail.com>
	 <1381882156.11046.178.camel@schen9-DESK> <20131016065526.GB22509@gmail.com>
	 <1381948114.11046.194.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 04 Nov 2013 14:36:25 -0800
Message-ID: <1383604585.11046.258.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, YuanhanLiu <yuanhan.liu@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Ingo,

Sorry for the late response.  My old 4 socket Westmere
test machine went down and I have to find a new one, 
which is a 4 socket Ivybridge machine with 15 cores per socket.

I've updated the workload as a perf benchmark (see patch)
attached.  The workload will mmap, then access memory
in the mmaped area and then unmap, doing so repeatedly
for a specified time.  Each thread is pinned to a
particular core, with the threads distributed evenly between
the sockets. The throughput is reported with standard deviation
info.

First some baseline comparing the workload with serialized mmap vs
without serialized mmap running under vanilla kernel.

Threads		Throughput	std dev(%)
		serail vs non serial
		mmap(%)
1		0.10		0.16
2		0.78		0.09
3		-5.00		0.12
4		-3.27		0.08
5		-0.11		0.09
10		5.32		0.10
20		-2.05		0.05
40		-9.75		0.15
60		11.69		0.05


Here's the data for complete rwsem patch vs the plain vanilla kernel
case.  Overall there's improvement except for the 3 thread case.

Threads		Throughput	std dev(%)
		vs vanilla(%)
1		0.62		0.11
2		3.86		0.10
3		-7.02		0.19
4		-0.01		0.13
5		2.74		0.06
10		5.66		0.03
20		1.44		0.09
40		5.54		0.09
60		15.63		0.13

Now testing with both patched kernel and vanilla kernel
running serialized mmap with mutex acquisition in user space.

Threads		Throughput	std dev(%)
		vs vanilla(%)
1		0.60		0.02
2		6.40		0.11
3		14.13		0.07
4		-2.41		0.07
5		1.05		0.08
10		4.15		0.05
20		-0.26		0.06
40		-3.45		0.13
60		-4.33		0.07

Here's another run with the rwsem patchset without
optimistic spinning

Threads		Throughput	std dev(%)
		vs vanilla(%)
1		0.81		0.04
2		2.85		0.17
3		-4.09		0.05
4		-8.31		0.07
5		-3.19		0.03
10		1.02		0.05
20		-4.77		0.04
40		-3.11		0.10
60		2.06		0.10

No-optspin comparing serialized mmaped workload under
patched kernel vs vanilla kernel

Threads		Throughput	std dev(%)
		vs vanilla(%)
1		0.57		0.03
2		2.13		0.17
3		14.78		0.33
4		-1.23		0.11
5		2.99		0.08
10		-0.43		0.10
20		0.01		0.03
40		3.03		0.10
60		-1.74		0.09


The data is a bit of a mixed bag.  I'll spin off
the MCS cleanup patch separately so we can merge that first
for Waiman's qrwlock work.

Tim

---
