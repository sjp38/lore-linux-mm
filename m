Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 714386B009B
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 05:27:26 -0500 (EST)
Date: Thu, 16 Dec 2010 10:26:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: PROBLEM: __offline_isolated_pages may offline too many pages
Message-ID: <20101216102641.GK13914@csn.ul.ie>
References: <4D0786D3.7070007@akana.de> <20101215092134.e2c8849f.kamezawa.hiroyu@jp.fujitsu.com> <4D08899F.4050502@akana.de> <20101216090657.9d3aaa4c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101216090657.9d3aaa4c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ingo Korb <ingo@akana.de>, linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org, yinghai@kernel.org, andi.kleen@intel.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 09:06:57AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Dec 2010 10:25:51 +0100
> Ingo Korb <ingo@akana.de> wrote:
> 
> > On 15.12.2010 01:21, KAMEZAWA Hiroyuki wrote:
> > 
> > > It's designed for offline memory section>  MAX_ORDER. pageblock_nr_pages
> > > is tend to be smaller than that.
> > >
> > > Do you see the problem with _exsisting_ user interface of memory hotplug ?
> > > I think we have no control other than memory section.
> > 
> > The existing, exported interface (remove_memory() - the check itself is 
> > in offline_pages()) only checks if both start and end of the 
> > to-be-removed block are aligned to pageblock_nr_pages. As you noted the 
> > actual size and alignment requirements in __offline_isolated_pages can 
> > be larger that that, so I think the checks in offline_pages() should be 
> > changed (if 1<<MAX_ORDER is always >= pageblock_nr_pages) or extended 
> > (if there can be any relation between the two).
> > 
> 
> Ok, maybe my mistake. This is a fix. Thank you for reporting.
> ==
> 
> offline_pages()'s sanity check of given range is wrong. It should
> be aligned to MAX_ORDER. Current exsiting caller uses SECTION_SIZE
> alignment, so this change has no influence to exsisting callers.
> 
> Reported-by: Ingo Korb <ingo@akana.de>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Other than the spelling mistakes in the changelog and the lack of a
subject;

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/memory_hotplug.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.37-rc5/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.37-rc5.orig/mm/memory_hotplug.c
> +++ linux-2.6.37-rc5/mm/memory_hotplug.c
> @@ -798,10 +798,14 @@ static int offline_pages(unsigned long s
>  	struct memory_notify arg;
>  
>  	BUG_ON(start_pfn >= end_pfn);
> -	/* at least, alignment against pageblock is necessary */
> -	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
> +	/*
> +	 * Considering buddy allocator which joins nearby pages, the range
> +	 * in offline should be aligned to MAX_ORDER. If not, isolated
> +	 * page will be joined to other (not isolated) pages.
> +	 */
> +	if (!IS_ALIGNED(start_pfn, MAX_ORDER_NR_PAGES))
>  		return -EINVAL;
> -	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
> +	if (!IS_ALIGNED(end_pfn, MAX_ORDER_NR_PAGES))
>  		return -EINVAL;
>  	/* This makes hotplug much easier...and readable.
>  	   we assume this for now. .*/
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
