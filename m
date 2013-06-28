Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 34B796B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:33:11 -0400 (EDT)
Date: Fri, 28 Jun 2013 12:33:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628103304.GF28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130628070027.GD17195@linux.vnet.ibm.com>
 <20130628093625.GF29209@dyad.programming.kicks-ass.net>
 <20130628101245.GD8362@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628101245.GD8362@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 03:42:45PM +0530, Srikar Dronamraju wrote:
> > > 
> > > > Ideally it would be possible to distinguish between NUMA hinting faults
> > > > that are private to a task and those that are shared. This would require
> > > > that the last task that accessed a page for a hinting fault would be
> > > > recorded which would increase the size of struct page. Instead this patch
> > > > approximates private pages by assuming that faults that pass the two-stage
> > > > filter are private pages and all others are shared. The preferred NUMA
> > > > node is then selected based on where the maximum number of approximately
> > > > private faults were measured.
> > > 
> > > Should we consider only private faults for preferred node?
> > 
> > I don't think so; its optimal for the task to be nearest most of its pages;
> > irrespective of whether they be private or shared.
> 
> Then the preferred node should have been chosen based on both the
> private and shared faults and not just private faults.

Oh duh indeed. I totally missed it did that. Changelog also isn't giving
rationale for this. Mel?

> > 
> > > I would think if tasks have shared pages then moving all tasks that share
> > > the same pages to a node where the share pages are around would be
> > > preferred. No? 
> > 
> > Well no; not if there's only 5 shared pages but 1024 private pages.
> 
> Yes, agree, but should we try to give the shared pages some additional weightage?

Yes because you'll get 1/n amount of this on shared pages for threads --
other threads will contend for the same PTE fault. And no because for
inter process shared memory they'll each have their own PTE. And maybe
because even for the threaded case its hard to tell how many threads
will actually contend for that one PTE.

Confused enough? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
