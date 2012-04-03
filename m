Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 705756B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 16:35:37 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <vatsa@linux.vnet.ibm.com>;
	Wed, 4 Apr 2012 02:05:33 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q33KZGui4300962
	for <linux-mm@kvack.org>; Wed, 4 Apr 2012 02:05:17 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3425qMW007501
	for <linux-mm@kvack.org>; Wed, 4 Apr 2012 12:05:53 +1000
Date: Wed, 4 Apr 2012 02:05:00 +0530
From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/39] [RFC] AutoNUMA alpha10
Message-ID: <20120403203500.GA14386@linux.vnet.ibm.com>
Reply-To: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

* Andrea Arcangeli <aarcange@redhat.com> [2012-03-26 19:45:47]:

> This is the result of the first round of cleanups of the AutoNUMA patch.

I happened to test numasched and autonuma against a Java benchmark and
here are some results (higher scores are better).

Base            : 1 (std. dev : 91%)
Numa sched      : 2.17 (std. dev : 15%)
Autonuma        : 2.56 (std. dev : 10.7%)

Numa sched is ~200% better compared to "base" case. Autonuma is ~18% better 
compared to numasched. Note the high standard deviation in base case.

Also given the differences in base kernel versions for both, this is
admittedly not a apple-2-apple comparison. Getting both patches onto
common code base would help do that type of comparison!

Details:

Base = tip (ee415e2) + numasched patches posted on 3/16.
       qemu-kvm 0.12.1

Numa sched = tip (ee415e2) + numasched patches posted on 3/16.
             Modified version of qemu-kvm 1.0.50 that creates memsched groups

Autonuma = Autonuma alpha10 (SHA1 4596315). qemu-kvm 0.12.1

Machine with 2 Quad-core (w/ HT) Intel Nehalem CPUs. Two NUMA nodes each with
8GB memory.

3 VMs are created:
	VM1 and VM2, each with 4vcpus, 3GB memory and 1024 cpu.shares.
        Each of them runs memory hogs to consume total of 2.5 GB total
	memory (2.5GB memory first written to and then continuously read in a
	loop)

        VM3 of 8vcpus, 4GB memory and 2048 cpu.shares. Runs
	SPECJbb2000 benchmark w/ 8 warehouses (and consuming 2GB heap)

Benchmark was repeated 5 times. Each run consisted of launching VM1 first, 
waiting for it to initialize (wrt memory footprint), launching VM2 next, waiting
for it to initialize before launching VM3 and the benchmark inside VM3. At the 
end of benchmark, all VMs are destroyed and process repeated.

- vatsa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
