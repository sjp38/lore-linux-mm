Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 65FFC6B009B
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 14:29:21 -0400 (EDT)
Date: Mon, 1 Oct 2012 20:29:09 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] hugetlb: do not use vma_hugecache_offset for
 vma_prio_tree_foreach
Message-ID: <20121001182909.GE29854@cmpxchg.org>
References: <1344866141-27906-1-git-send-email-mhocko@suse.cz>
 <20120926205617.GA2667@cmpxchg.org>
 <20121001162226.GA24860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121001162226.GA24860@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Mon, Oct 01, 2012 at 06:22:26PM +0200, Michal Hocko wrote:
> On Wed 26-09-12 16:56:17, Johannes Weiner wrote:
> > On Mon, Aug 13, 2012 at 03:55:41PM +0200, Michal Hocko wrote:
> > > 0c176d5 (mm: hugetlb: fix pgoff computation when unmapping page
> > > from vma) fixed pgoff calculation but it has replaced it by
> > > vma_hugecache_offset which is not approapriate for offsets used for
> > > vma_prio_tree_foreach because that one expects index in page units
> > > rather than in huge_page_shift.
> > > Using vma_hugecache_offset is not incorrect because the pgoff will fit
> > > into the same vmas but it is confusing so the standard PAGE_SHIFT based
> > > index calculation is used instead.
> > 
> > I do think it's incorrect.  The resulting index may not be too big,
> > but it can be too small: assume hpage size of 2M and the address to
> > unmap to be 0x200000.  This is regular page index 512 and hpage index
> > 1.  If you have a VMA that maps the file only starting at the second
> > huge page, that VMAs vm_pgoff will be 512 but you ask for offset 1 and
> > miss it even though it does map the page of interest.  hugetlb_cow()
> > will try to unmap, miss the vma, and retry the cow until the
> > allocation succeeds or the skipped vma(s) go away.
> > 
> > Unless I missed something, this should not be deferred as a cleanup.
> 
> You are right and I have totally missed this because I focused on the
> other boundary too much :/ This vma_hugecache_offset is really
> confusing.
> Andrew has already updated the changelog so we will not get even more
> confusion into the Linus tree.
> Thanks for spotting this Johannes!

Just saw the update on ozlabs, thanks guys.  Andrew, could you please
also add:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
