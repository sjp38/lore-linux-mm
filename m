Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2BD326B003B
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 10:54:51 -0400 (EDT)
Date: Mon, 16 Sep 2013 16:54:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/50] mm: Account for a THP NUMA hinting update as one
 PTE update
Message-ID: <20130916145438.GT21832@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-8-git-send-email-mgorman@suse.de>
 <20130916123645.GD9326@twins.programming.kicks-ass.net>
 <52370A2F.90006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52370A2F.90006@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 09:39:59AM -0400, Rik van Riel wrote:
> On 09/16/2013 08:36 AM, Peter Zijlstra wrote:
> > On Tue, Sep 10, 2013 at 10:31:47AM +0100, Mel Gorman wrote:
> >> A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
> >> large difference when estimating the cost of automatic NUMA balancing and
> >> can be misleading when comparing results that had collapsed versus split
> >> THP. This patch addresses the accounting issue.
> >>
> >> Signed-off-by: Mel Gorman <mgorman@suse.de>
> >> ---
> >>  mm/mprotect.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/mprotect.c b/mm/mprotect.c
> >> index 94722a4..2bbb648 100644
> >> --- a/mm/mprotect.c
> >> +++ b/mm/mprotect.c
> >> @@ -145,7 +145,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
> >>  				split_huge_page_pmd(vma, addr, pmd);
> >>  			else if (change_huge_pmd(vma, pmd, addr, newprot,
> >>  						 prot_numa)) {
> >> -				pages += HPAGE_PMD_NR;
> >> +				pages++;
> > 
> > But now you're not counting pages anymore..
> 
> The migrate statistics still count pages. That makes sense, since the
> amount of work scales with the amount of memory moved.

Right.

> It is just the "number of faults" counters that actually count the
> number of faults again, instead of the number of pages represented
> by each fault.

So you're suggesting s/pages/faults/ or somesuch?

> IMHO this change makes sense.

I never said the change didn't make sense as such. Just that we're no
longer counting pages in change_*_range().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
