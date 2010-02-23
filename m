Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 998416B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:33:23 -0500 (EST)
Date: Tue, 23 Feb 2010 15:32:59 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] vmscan: drop page_mapping_inuse()
Message-ID: <20100223143259.GB29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-3-git-send-email-hannes@cmpxchg.org> <1266933800.2723.24.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266933800.2723.24.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Minchan,

On Tue, Feb 23, 2010 at 11:03:20PM +0900, Minchan Kim wrote:
> On Mon, 2010-02-22 at 20:49 +0100, Johannes Weiner wrote:
> > Protecting file pages that are not by themselves mapped but are part
> > of a mapped file is also a historic leftover for short-lived things
> 
> I have been a question in the part.
> You seem to solve my long question. :)
> But I want to make sure it by any log.
> Could you tell me where I find the discussion mail thread or git log at
> that time?

I dug up this change in history.git, but unfortunately it was merged
undocumented in a large changeset.  So there does not seem to be any
written reason for why this was merged initially.    What I wrote is
based on what Rik told me on IRC.

> >  	/* Reclaim if clean, defer dirty pages to writeback */
> > @@ -1378,7 +1357,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  		}
> >  
> >  		/* page_referenced clears PageReferenced */
> > -		if (page_mapping_inuse(page) &&
> > +		if (page_mapped(page) &&
> >  		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> >  			nr_rotated++;
> >  			/*
> 
> It's good to me.
> But page_referenced already have been checked page_mapped. 
> How about folding alone page_mapped check into page_referenced's inner?

The next patch essentially does that.  page_referenced() will no longer
clear PG_referenced on the page and if page_referenced() is true, it
means that young ptes were found and the page must thus be mapped.

So #3 removes the page_mapped() from this conditional.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
