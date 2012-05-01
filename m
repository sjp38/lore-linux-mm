Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id AEC346B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:14:19 -0400 (EDT)
Date: Tue, 1 May 2012 14:14:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() ->
 hugetlb_cow()
Message-ID: <20120501131413.GA11435@suse.de>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
 <alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 30, 2012 at 01:19:27PM -0700, Hugh Dickins wrote:
> On Sun, 29 Apr 2012, Chris Metcalf wrote:
> 
> > Commit 66aebce747eaf added code to avoid a race condition by
> > elevating the page refcount in hugetlb_fault() while calling
> > hugetlb_cow().  However, one code path in hugetlb_cow() includes
> > an assertion that the page count is 1, whereas it may now also
> > have the value 2 in this path.
> > 
> > Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> > ---
> > We discovered this while testing the original path; one particular
> > application triggered this due to the specific number of huge pages
> > it started with.
> 
> Well done finding that.

Agreed.

> But I think it would be better to remove the
> BUG_ON() than complicate it, and then no need to add a comment there.
> 
> IIRC it's unsafe to make any assertions about what a page_count() may
> be, beyond whether it's 0 or non-0: because of speculative accesses to
> the page from elsewhere (perhaps it used to be visible in a radix_tree,
> perhaps __isolate_lru_pages is having a go at it).
> 

There are relatively few cases where this type of hugetlbfs page can be
found and the count elevated. The pages are not on the LRU for example and
as it is privately mapped there are fewer cases where speculative accesses
elevate the count.

> I'd say that BUG_ON() has outlived its usefulness, and should just be
> eliminated now: but git "blames" Mel for it, so let's see if he agrees.
> 

The reason it was added in the first place was to rattle out any bugs
related to unmap_ref_private(). As that was 4 years ago, I agree with High
and the BUG_ON can go as it has done its job.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
