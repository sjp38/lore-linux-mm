Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id BD4D46B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:25:15 -0400 (EDT)
Date: Wed, 31 Jul 2013 12:25:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, numa: Sanitize task_numa_fault() callsites
Message-ID: <20130731112510.GS2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725103845.GN27075@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130725103845.GN27075@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 25, 2013 at 12:38:45PM +0200, Peter Zijlstra wrote:
> 
> Subject: mm, numa: Sanitize task_numa_fault() callsites
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Mon Jul 22 10:42:38 CEST 2013
> 
> There are three callers of task_numa_fault():
> 
>  - do_huge_pmd_numa_page():
>      Accounts against the current node, not the node where the
>      page resides, unless we migrated, in which case it accounts
>      against the node we migrated to.
> 
>  - do_numa_page():
>      Accounts against the current node, not the node where the
>      page resides, unless we migrated, in which case it accounts
>      against the node we migrated to.
> 
>  - do_pmd_numa_page():
>      Accounts not at all when the page isn't migrated, otherwise
>      accounts against the node we migrated towards.
> 
> This seems wrong to me; all three sites should have the same
> sementaics, furthermore we should accounts against where the page
> really is, we already know where the task is.
> 

Agreed. To allow the scheduler parts to still be evaluated in proper
isolation I moved this patch to much earlier in the series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
