Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 589E16B006E
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 11:40:40 -0400 (EDT)
Date: Mon, 16 Sep 2013 16:40:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/50] sched: Set the scan rate proportional to the
 memory usage of the task being scanned
Message-ID: <20130916154035.GE22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-15-git-send-email-mgorman@suse.de>
 <20130916151822.GE9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130916151822.GE9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 05:18:22PM +0200, Peter Zijlstra wrote:
> On Tue, Sep 10, 2013 at 10:31:54AM +0100, Mel Gorman wrote:
> > @@ -860,9 +908,14 @@ void task_numa_fault(int node, int pages, bool migrated)
> >  	 * If pages are properly placed (did not migrate) then scan slower.
> >  	 * This is reset periodically in case of phase changes
> >  	 */
> > -        if (!migrated)
> > -		p->numa_scan_period = min(sysctl_numa_balancing_scan_period_max,
> > +        if (!migrated) {
> > +		/* Initialise if necessary */
> > +		if (!p->numa_scan_period_max)
> > +			p->numa_scan_period_max = task_scan_max(p);
> > +
> > +		p->numa_scan_period = min(p->numa_scan_period_max,
> >  			p->numa_scan_period + jiffies_to_msecs(10));
> 
> So the next patch changes the jiffies_to_msec() thing.. is that really
> worth a whole separate patch?
> 

No, I can collapse them.

> Also, I really don't believe any of that is 'right', increasing the scan
> period by a fixed amount for every !migrated page is just wrong.
> 

At the moment Rik and I are both looking at adapting the scan rate based
on whether the faults trapped since the last scan window were local or
remote faults. It should be able to sensibly adapt the scan rate
independently of the RSS of the process.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
