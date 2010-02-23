Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AC506B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:48:30 -0500 (EST)
Received: by bwz19 with SMTP id 19so3014687bwz.6
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 06:48:25 -0800 (PST)
Subject: Re: [patch 2/3] vmscan: drop page_mapping_inuse()
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100223143259.GB29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
	 <1266868150-25984-3-git-send-email-hannes@cmpxchg.org>
	 <1266933800.2723.24.camel@barrios-desktop>
	 <20100223143259.GB29762@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Feb 2010 23:48:12 +0900
Message-ID: <1266936492.2723.36.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-02-23 at 15:32 +0100, Johannes Weiner wrote:
> Hello Minchan,
> 
> On Tue, Feb 23, 2010 at 11:03:20PM +0900, Minchan Kim wrote:
> > On Mon, 2010-02-22 at 20:49 +0100, Johannes Weiner wrote:
> > > Protecting file pages that are not by themselves mapped but are part
> > > of a mapped file is also a historic leftover for short-lived things
> > 
> > I have been a question in the part.
> > You seem to solve my long question. :)
> > But I want to make sure it by any log.
> > Could you tell me where I find the discussion mail thread or git log at
> > that time?
> 
> I dug up this change in history.git, but unfortunately it was merged
> undocumented in a large changeset.  So there does not seem to be any
> written reason for why this was merged initially.    What I wrote is
> based on what Rik told me on IRC.
> 
> > >  	/* Reclaim if clean, defer dirty pages to writeback */
> > > @@ -1378,7 +1357,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > >  		}
> > >  
> > >  		/* page_referenced clears PageReferenced */
> > > -		if (page_mapping_inuse(page) &&
> > > +		if (page_mapped(page) &&
> > >  		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> > >  			nr_rotated++;
> > >  			/*
> > 
> > It's good to me.
> > But page_referenced already have been checked page_mapped. 
> > How about folding alone page_mapped check into page_referenced's inner?
> 
> The next patch essentially does that.  page_referenced() will no longer
> clear PG_referenced on the page and if page_referenced() is true, it
> means that young ptes were found and the page must thus be mapped.
> 
> So #3 removes the page_mapped() from this conditional.

Thanks! 
I should have reviewed your [3/3] before nitpick. 

> 
> 	Hannes


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
