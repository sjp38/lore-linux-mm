Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C2B346B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 16:03:37 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p0BL3XCr014476
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 13:03:33 -0800
Received: from iwn3 (iwn3.prod.google.com [10.241.68.67])
	by hpaq6.eem.corp.google.com with ESMTP id p0BL1iWg022320
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 13:03:32 -0800
Received: by iwn3 with SMTP id 3so21030089iwn.12
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 13:03:32 -0800 (PST)
Date: Tue, 11 Jan 2011 13:03:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mmotm hangs on compaction lock_page
In-Reply-To: <20110111124551.f8d0522c.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1101111256060.26435@sister.anvils>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie> <20110110172609.GA11932@csn.ul.ie> <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com> <20110111114521.GD11932@csn.ul.ie>
 <20110111124551.f8d0522c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, Andrew Morton wrote:
> On Tue, 11 Jan 2011 11:45:21 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1809,12 +1809,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  	bool sync_migration)
> >  {
> >  	struct page *page;
> > +	struct task_struct *p = current;
> >  
> >  	if (!order || compaction_deferred(preferred_zone))
> >  		return NULL;
> >  
> > +	p->flags |= PF_MEMALLOC;
> >  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
> >  						nodemask, sync_migration);
> > +	p->flags &= ~PF_MEMALLOC;
> 
> Thus accidentally wiping out PF_MEMALLOC if it was already set.
> 
> It's risky, and general bad practice.  The default operation here
> should be to push the old value and to later restore it.
> 
> If it is safe to micro-optimise that operation then we need to make
> sure that it's really really safe and that there is no risk of
> accidentally breaking things later on as code evolves.
> 
> One way of doing that would be to add a WARN_ON(p->flags & PF_MEMALLOC)
> on entry.

True.  Though one of the nice things about Mel's patch is that it is
precisely copying in __alloc_pages_direct_compact what is already
done in __alloc_pages_direct_reclaim (both being called from
__alloc_pages_slowpath after it checked for PF_MEMALLOC).

> 
> Oh, and since when did we use `p' to identify task_structs?

Tsk, tsk: we've been using `p' for task_structs for years and years!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
