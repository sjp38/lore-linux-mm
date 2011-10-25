Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A63516B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 07:23:11 -0400 (EDT)
Date: Tue, 25 Oct 2011 13:23:00 +0200
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111025112300.GB10797@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
 <20111025090956.GA10797@suse.de>
 <CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 02:26:56AM -0700, Colin Cross wrote:
> On Tue, Oct 25, 2011 at 2:09 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Mon, Oct 24, 2011 at 11:39:49PM -0700, Colin Cross wrote:
> >> Under the following conditions, __alloc_pages_slowpath can loop
> >> forever:
> >> gfp_mask & __GFP_WAIT is true
> >> gfp_mask & __GFP_FS is false
> >> reclaim and compaction make no progress
> >> order <= PAGE_ALLOC_COSTLY_ORDER
> >>
> >> These conditions happen very often during suspend and resume,
> >> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> >> allocations into __GFP_WAIT.
> > b>
> >> The oom killer is not run because gfp_mask & __GFP_FS is false,
> >> but should_alloc_retry will always return true when order is less
> >> than PAGE_ALLOC_COSTLY_ORDER.
> >>
> >> Fix __alloc_pages_slowpath to skip retrying when oom killer is
> >> not allowed by the GFP flags, the same way it would skip if the
> >> oom killer was allowed but disabled.
> >>
> >> Signed-off-by: Colin Cross <ccross@android.com>
> >
> > Hi Colin,
> >
> > Your patch functionally seems fine. I see the problem and we certainly
> > do not want to have the OOM killer firing during suspend. I would prefer
> > that the IO devices would not be suspended until reclaim was completed
> > but I imagine that would be a lot harder.
> >
> > That said, it will be difficult to remember why checking __GFP_NOFAIL in
> > this case is necessary and someone might "optimitise" it away later. It
> > would be preferable if it was self-documenting. Maybe something like
> > this? (This is totally untested)
> 
> This issue is not limited to suspend, any GFP_NOIO allocation could
> end up in the same loop.  Suspend is the most likely case, because it
> effectively converts all GFP_KERNEL allocations into GFP_NOIO.
> 

I see what you mean with GFP_NOIO but there is an important difference
between GFP_NOIO and suspend.  A GFP_NOIO low-order allocation currently
implies __GFP_NOFAIL as commented on in should_alloc_retry(). If no progress
is made, we call wait_iff_congested() and sleep for a bit. As the system
is running, kswapd and other process activity will proceed and eventually
reclaim enough pages for the GFP_NOIO allocation to succeed. In a running
system, GFP_NOIO can stall for a period of time but your patch will cause
the allocation to fail. While I expect callers return ENOMEM or handle
the situation properly with a wait-and-retry loop, there will be
operations that fail that used to succeed. This is why I'd prefer it was
a suspend-specific fix unless we know there is a case where a machine
livelocks due to a GFP_NOIO allocation looping forever and even then I'd
wonder why kswapd was not helping.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
