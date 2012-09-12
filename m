Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AFF8F6B00FD
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 17:28:31 -0400 (EDT)
Date: Wed, 12 Sep 2012 14:28:29 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: steering allocations to particular parts of memory
Message-ID: <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
 <20120911093407.GH11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911093407.GH11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Larry Bassel <lbassel@codeaurora.org>, dan.magenheimer@oracle.com, linux-mm@kvack.org

On 11 Sep 12 10:34, Mel Gorman wrote:
> On Fri, Sep 07, 2012 at 11:27:15AM -0700, Larry Bassel wrote:
> > I am looking for a way to steer allocations (these may be
> > by either userspace or the kernel) to or away from particular
> > ranges of memory. The reason for this is that some parts of
> > memory are different from others (i.e. some memory may be
> > faster/slower). For instance there may be 500M of "fast"
> > memory and 1500M of "slower" memory on a 2G platform.
> > 
> 
> Hi Larry,
> 
> > At the memory mini-summit last week, it was mentioned
> > that the Super-H architecture was using NUMA for this
> > purpose, which was considered to be an very bad thing
> > to do -- we have ported NUMA to ARM here (as an experiment)
> > and agree that NUMA doesn't work well for solving this problem.
> > 
> 
> Yes, I remember the discussion and regret it had to be cut short.
> 
> NUMA is almost always considered to be the first solution to this type
> of problem but as you say it's considered to be a "very bad thing to do".
> It's convenient in one sense because you get data structures that track all
> the pages for you and create the management structures. It's bad because
> page allocation uses these slow nodes when the fast nodes are full which
> is a very poor placement policy. Similarly pages from the slow node are
> reclaimed based on memory pressure. It comes down to luck whether the
> optimal pages are in the slow node or not. You can try wedging your own
> placement policy on the side but it won't be pretty.

It appears that I was too vague about this. Both userspace and
kernel (drivers mostly) need to be able to specify either explicitly
or implicitly (using defaults if no explicit memory type is mentioned)
what sort of memory is desired and what to do if this type is not
available (either due to actual lack of such memory or because
a low watermark would be violated, etc.) such as fall back to
another type of memory or get an out-of-memory error
(More sophisticated alternatives would be to trigger
some sort of migration or even eviction in these cases).
This seems similar to a simplified version of memory policies,
unless I'm missing something.

Admittedly, most drivers and user processes will not explicitly ask
for a certain type of memory.

We also would like to be able to create lowmem or highmem
from any type of memory.

The above makes me wonder if something that keeps nodes and zones
and some sort of simple memory policy and throws out the rest of NUMA such
as bindings of memory to CPUs, cpusets, etc. might be useful
(though after the memory mini-summit I have doubts about this as well)
as node-aware allocators already exist.

[snip]

> Hope this clarifies my position a little but people like Dan who have
> focused on this problem in the past may have a much better idea.

Thanks.

> 
> -- 
> Mel Gorman
> SUSE Labs

Larry

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
