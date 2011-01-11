Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D57A6B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 15:46:39 -0500 (EST)
Date: Tue, 11 Jan 2011 12:45:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm hangs on compaction lock_page
Message-Id: <20110111124551.f8d0522c.akpm@linux-foundation.org>
In-Reply-To: <20110111114521.GD11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils>
	<20110107145259.GK29257@csn.ul.ie>
	<20110107175705.GL29257@csn.ul.ie>
	<20110110172609.GA11932@csn.ul.ie>
	<alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
	<20110111114521.GD11932@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011 11:45:21 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1809,12 +1809,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	bool sync_migration)
>  {
>  	struct page *page;
> +	struct task_struct *p = current;
>  
>  	if (!order || compaction_deferred(preferred_zone))
>  		return NULL;
>  
> +	p->flags |= PF_MEMALLOC;
>  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
>  						nodemask, sync_migration);
> +	p->flags &= ~PF_MEMALLOC;

Thus accidentally wiping out PF_MEMALLOC if it was already set.

It's risky, and general bad practice.  The default operation here
should be to push the old value and to later restore it.

If it is safe to micro-optimise that operation then we need to make
sure that it's really really safe and that there is no risk of
accidentally breaking things later on as code evolves.

One way of doing that would be to add a WARN_ON(p->flags & PF_MEMALLOC)
on entry.

Oh, and since when did we use `p' to identify task_structs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
