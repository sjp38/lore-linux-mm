Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 5583A6B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:14:39 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2202129eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:14:37 -0800 (PST)
Date: Fri, 16 Nov 2012 19:14:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/8] sched, numa, mm: Add adaptive NUMA affinity support
Message-ID: <20121116181433.GA4763@gmail.com>
References: <20121112160451.189715188@chello.nl>
 <20121112161215.782018877@chello.nl>
 <50A68096.1050208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A68096.1050208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


* Rik van Riel <riel@redhat.com> wrote:

> On 11/12/2012 11:04 AM, Peter Zijlstra wrote:
> 
> >We change the load-balancer to prefer moving tasks in order of:
> >
> >   1) !numa tasks and numa tasks in the direction of more faults
> >   2) allow !ideal tasks getting worse in the direction of faults
> >   3) allow private tasks to get worse
> >   4) allow shared tasks to get worse
> >
> >This order ensures we prefer increasing memory locality but when
> >we do have to make hard decisions we prefer spreading private
> >over shared, because spreading shared tasks significantly
> >increases the interconnect bandwidth since not all memory can
> >follow.
> 
> Combined with the fact that we only turn a certain amount of 
> memory into NUMA ptes each second, could this result in a 
> program being classified as a private task one second, and a 
> shared task a few seconds later?

It's a statistical method, like most of scheduling.

It's as prone to oscillation as tasks are already prone to being 
moved spuriously by the load balancer today, due to the per CPU 
load average being statistical and them being slightly above or 
below a critical load average value.
 
Higher freq oscillation should not happen normally though, we 
dampen these metrics and have per CPU hysteresis.

( We can also add explicit hysteresis if anyone demonstrates 
  real oscillation with a real workload - wanted to keep it 
  simple first and change it only as-needed. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
