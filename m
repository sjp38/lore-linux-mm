Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id AE9516B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:36:55 -0400 (EDT)
Date: Fri, 28 Jun 2013 11:36:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628093625.GF29209@dyad.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130628070027.GD17195@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628070027.GD17195@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 12:30:27PM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:06]:
> 
> > Ideally it would be possible to distinguish between NUMA hinting faults
> > that are private to a task and those that are shared. This would require
> > that the last task that accessed a page for a hinting fault would be
> > recorded which would increase the size of struct page. Instead this patch
> > approximates private pages by assuming that faults that pass the two-stage
> > filter are private pages and all others are shared. The preferred NUMA
> > node is then selected based on where the maximum number of approximately
> > private faults were measured.
> 
> Should we consider only private faults for preferred node?

I don't think so; its optimal for the task to be nearest most of its pages;
irrespective of whether they be private or shared.

> I would think if tasks have shared pages then moving all tasks that share
> the same pages to a node where the share pages are around would be
> preferred. No? 

Well no; not if there's only 5 shared pages but 1024 private pages.

> If yes, how does the preferred node logic help to achieve
> the above?

There's no packing logic yet...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
