Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 13C546001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:34:11 -0500 (EST)
Date: Thu, 28 Jan 2010 15:33:57 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
Message-ID: <20100128153357.GC7139@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <948638099c17d3da3d6f.1264513919@v2.random> <20100126183706.GI16468@csn.ul.ie> <20100127194504.GA13766@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100127194504.GA13766@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 08:45:04PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 06:37:07PM +0000, Mel Gorman wrote:
> > I'm not fully getting from the changelog why the second round through
> > __get_user_pages_fast() is necessary or why the write parameter is
> > unconditionally 1.
> 
> The write parameter is unconditionally to 1 because the first gup_fast
> already existing had it unconditionally set to 1, it's not relevant
> with this change.
> 

hmm, really? I was seeing rw == VERIFY_WRITE rather than an
unconditional. I'll double check the kernel version I'm reading against
when I read the next review.

> > Is the second round necessary just so compound_head() is called with
> > interrupts disabled? Is that sufficient?
> 
> Correct. It's necessary and sufficient, because if it returns == 1, it
> means the huge pmd is established and cannot go away from under
> us. pmdp_splitting_flush_notify in __split_huge_page_splitting will
> have to wait for local_irq_enable before the IPI delivery can
> return. This means __split_huge_page_refcount can't be running from
> under us, and in turn when we run compound_head(page) we're not
> reading a dangling pointer from tailpage->first_page. Then after we
> get to stable head page, we are always safe to call compound_lock and
> after taking the compound lock on head page we can finally re-check if
> the page returned by gup-fast is still a tail page. in which case
> we're set and we didn't need to split the hugepage in order to take a
> futex on it.
> 
> I'll add above to changelog.
> 

Do please. That explanation helps a lot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
