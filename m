Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5269A6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 19:59:56 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o0S0xvhS001120
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:59:57 -0800
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz37.hot.corp.google.com with ESMTP id o0S0xtZx011421
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:59:56 -0800
Received: by pwj10 with SMTP id 10so116549pwj.26
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:59:55 -0800 (PST)
Date: Wed, 27 Jan 2010 16:59:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1001271652270.17513@chino.kir.corp.google.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com> <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com> <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com> <20100126151202.75bd9347.akpm@linux-foundation.org>
 <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com> <20100126161952.ee267d1c.akpm@linux-foundation.org> <20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com> <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010, Alan Cox wrote:

> > Now, /proc/<pid>/oom_score and /proc/<pid>/oom_adj are used by servers.
> 
> And embedded, and some desktops (including some neat experimental hacks
> where windows slowly get to be bigger bigger oom targes the longer
> they've been non-focussed)
> 

Right, oom_adj is used much more widely than described.

> I can't help feeling this is the wrong approach. IFF we are running out
> of low memory pages then killing stuff for that reason is wrong to begin
> with except in extreme cases and those extreme cases are probably also
> cases the kill won't help.
> 
> If we have a movable user page (even an mlocked one) then if there is
> space in other parts of memory (ie the OOM is due to a single zone
> problem) we should *never* be killing in the first place, we should be
> moving the page. The mlock case is a bit hairy but the non mlock case is
> exactly the same sequence of operations as a page out and page in
> somewhere else skipping the widdling on the disk bit in the middle.
> 

Mel Gorman's memory compaction patchset will preempt direct reclaim and 
the oom killer if it can defragment zones by page migration such that a 
higher order allocation would now succeed.

In this specific context, both compaction and direct reclaim will have 
failed so the oom killer is the only alternative.  For __GFP_NOFAIL, 
that's required.  However, there has been some long-standing debate (and 
not only for lowmem, but for all oom conditions) about when the page 
allocator should simply return NULL.  We've always killed something on 
blocking allocations to favor current at the expense of other memory hogs, 
but that may be changed soon: it may make sense to defer oom killing 
completely unless the badness() score reaches a certain threshold such 
that memory leakers really can be dealt with accordingly.

In the lowmem case, it certainly seems plausible to use the same behavior 
that we currently do for mempolicy-constrained ooms: kill current.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
