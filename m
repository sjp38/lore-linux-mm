Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 00A306B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 20:30:37 -0500 (EST)
Date: Wed, 25 Jan 2012 17:30:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 -mm] make swapin readahead skip over holes
Message-Id: <20120125173036.ec0d3bac.akpm@linux-foundation.org>
In-Reply-To: <4F20ABDF.8020604@redhat.com>
References: <20120124131351.05309a2a@annuminas.surriel.com>
	<20120124141400.6d33b7c4@annuminas.surriel.com>
	<20120125172319.edbbde73.akpm@linux-foundation.org>
	<4F20ABDF.8020604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Adrian Drzewieki <z@drze.net>

On Wed, 25 Jan 2012 20:26:55 -0500
Rik van Riel <riel@redhat.com> wrote:

> On 01/25/2012 08:23 PM, Andrew Morton wrote:
> 
> > Just to show that I'm paying attention...
> >
> >> --- a/mm/swap_state.c
> >> +++ b/mm/swap_state.c
> >> @@ -382,25 +382,23 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> >>   struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >>   			struct vm_area_struct *vma, unsigned long addr)
> >>   {
> >> -	int nr_pages;
> >>   	struct page *page;
> >> -	unsigned long offset;
> >> -	unsigned long end_offset;
> >> +	unsigned long offset = swp_offset(entry);
> >> +	unsigned long start_offset, end_offset;
> >> +	unsigned long mask = (1<<  page_cluster) - 1;
> >
> > This is broken for page_cluster>  31.  Fix:
> 
> I don't know who would want to do their swapins in chunks
> of 8GB or large at a time,

Linux MM developers ;)

> but still a good catch.
> 
> Want me to send in a v5, or do you prefer to merge a -fix
> patch in your tree?

I already queued the fix, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
