Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 826776B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 07:02:53 -0500 (EST)
Date: Tue, 13 Nov 2012 12:02:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/19] mm: mempolicy: Add MPOL_MF_LAZY
Message-ID: <20121113120248.GA8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-15-git-send-email-mgorman@suse.de>
 <20121113102555.GE21522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113102555.GE21522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 11:25:55AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> > NOTE: Once again there is a lot of patch stealing and the end result
> > 	is sufficiently different that I had to drop the signed-offs.
> > 	Will re-add if the original authors are ok with that.
> > 
> > This patch adds another mbind() flag to request "lazy migration".  The
> > flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
> > pages are marked PROT_NONE. The pages will be migrated in the fault
> > path on "first touch", if the policy dictates at that time.
> > 
> > <SNIP>
> 
> Here you are paying a heavy price for the earlier design 
> mistake, for forking into per arch approach - the NUMA version 
> of change_protection() had to be open-coded:
> 

I considered this when looking at the two trees.

At the time I also had the option of making change_prot_numa() to be a
wrapper around change_protection() and if pte_numa is made generic, that
becomes more attractive.

One of the reasons I went with this version from Andrea's tree is simply
because it does less work than change_protect() but what should be
sufficient for _PAGE_NUMA. I avoid the TLB flush if there are no PTE
updates for example but could shuffle change_protection() and get the
same thing.

> >  include/linux/mm.h             |    3 +
> >  include/uapi/linux/mempolicy.h |   13 ++-
> >  mm/mempolicy.c                 |  176 ++++++++++++++++++++++++++++++++++++----
> >  3 files changed, 174 insertions(+), 18 deletions(-)
> 
> Compare it to the generic version that Peter used:
> 
>  include/uapi/linux/mempolicy.h | 13 ++++++++---
>  mm/mempolicy.c                 | 49 +++++++++++++++++++++++++++---------------
>  2 files changed, 42 insertions(+), 20 deletions(-)
> 
> and the cleanliness and maintainability advantages are obvious.
> 
> So without some really good arguments in favor of your approach 
> NAK on that complex approach really.
> 

I will reimplement around change_protection() and see what effect, if any,
it has on overhead.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
