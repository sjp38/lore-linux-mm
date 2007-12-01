Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB19oWkk016460
	for <linux-mm@kvack.org>; Sat, 1 Dec 2007 04:50:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB19oWsO125660
	for <linux-mm@kvack.org>; Sat, 1 Dec 2007 02:50:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB19oV8L007505
	for <linux-mm@kvack.org>; Sat, 1 Dec 2007 02:50:32 -0700
Message-ID: <47512E65.9030803@linux.vnet.ibm.com>
Date: Sat, 01 Dec 2007 15:20:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: What can we do to get ready for memory controller merge in 2.6.25
References: <474ED005.7060300@linux.vnet.ibm.com> <200711301311.48291.nickpiggin@yahoo.com.au> <6599ad830711302339v1f92af40v85e89484a8a6575e@mail.gmail.com>
In-Reply-To: <6599ad830711302339v1f92af40v85e89484a8a6575e@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Nov 29, 2007 6:11 PM, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>> And also some
>> results or even anecdotes of where this is going to be used would be
>> interesting...
> 
> We want to be able to run multiple isolated jobs on the same machine.
> So being able to limit how much memory each job can consume, in terms
> of anonymous memory and page cache, are useful. I've not had much time
> to look at the patches in great detail, but they seem to provide a
> sensible way to assign and enforce static limits on a bunch of jobs.
> 
> Some of our requirements are a bit beyond this, though:
> 
> In our experience, users are not good at figuring out how much memory
> they really need. In general they tend to massively over-estimate
> their requirements. So we want some way to determine how much of its
> allocated memory a job is actively using, and how much could be thrown
> away or swapped out without bothering the job too much.
> 

One would prefer the kernel provides the mechanism and user space
provides the policy. The algorithms to assign limits can exist in user
space and be supported by a good set of statistics.

> Of course, the definition of "actve use" is tricky - one possibility
> that we're looking at is "has been accessed within the last N
> seconds", where N can be configured appropriately for different jobs
> depending on the job's latency requirements. Active use should also be
> reported for pages that can't be easily freed quickly, e.g. mlocked or
> dirty pages, or anon pages on a swapless system. Inactive pages should
> be easily freeable, and be the first ones to go in the event of memory
> pressure. (From a scheduling point of view we can treat them as free
> memory, and schedule more jobs on the machine)
> 

This definition of active comes from the mainline kernel, which in-turn
is derived from our understanding of the working set.

> The existing active/inactive distinction doesn't really capture this,
> since it's relative rather than absolute.
> 

Not sure I understand why we need absolute use and not relative use.

> We want to be able to overcommit a machine, so the sums of the cgroup
> memory limits can add up to more than the total machine memory. So we
> need control over what happens when there's global memory pressure,
> and a way to ensure that the low-latency jobs don't get bogged down in
> reclaim (or OOM) due to the activity of batch jobs.
> 

I agree, well said. We need Job Isolation.

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
