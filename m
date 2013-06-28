Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4ABA66B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:13:26 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 04:13:25 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4DC1E6E8039
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:13:17 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SACpTY314110
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:12:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SACnmr004659
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 07:12:51 -0300
Date: Fri, 28 Jun 2013 15:42:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/8] sched: Split accounting of NUMA hinting faults that
 pass two-stage filter
Message-ID: <20130628101245.GD8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-8-git-send-email-mgorman@suse.de>
 <20130628070027.GD17195@linux.vnet.ibm.com>
 <20130628093625.GF29209@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628093625.GF29209@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > 
> > > Ideally it would be possible to distinguish between NUMA hinting faults
> > > that are private to a task and those that are shared. This would require
> > > that the last task that accessed a page for a hinting fault would be
> > > recorded which would increase the size of struct page. Instead this patch
> > > approximates private pages by assuming that faults that pass the two-stage
> > > filter are private pages and all others are shared. The preferred NUMA
> > > node is then selected based on where the maximum number of approximately
> > > private faults were measured.
> > 
> > Should we consider only private faults for preferred node?
> 
> I don't think so; its optimal for the task to be nearest most of its pages;
> irrespective of whether they be private or shared.

Then the preferred node should have been chosen based on both the
private and shared faults and not just private faults.

> 
> > I would think if tasks have shared pages then moving all tasks that share
> > the same pages to a node where the share pages are around would be
> > preferred. No? 
> 
> Well no; not if there's only 5 shared pages but 1024 private pages.

Yes, agree, but should we try to give the shared pages some additional weightage?

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
