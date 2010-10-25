Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57FA68D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:10:33 -0400 (EDT)
Date: Mon, 25 Oct 2010 15:10:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH] fix is_mem_section_removable() page_order
 BUG_ON check.
Message-ID: <20101025131025.GA18570@tiehlicka.suse.cz>
References: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025074933.GB5452@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025074933.GB5452@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon 25-10-10 15:49:33, Wu Fengguang wrote:
> On Mon, Oct 25, 2010 at 02:37:26PM +0800, KAMEZAWA Hiroyuki wrote:
> > I wonder this should be for stable tree...but want to hear opinions before.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > page_order() is called by memory hotplug's user interface to check 
> > the section is removable or not. (is_mem_section_removable())
> > 
> > It calls page_order() withoug holding zone->lock.
> > So, even if the caller does
> > 
> > 	if (PageBuddy(page))
> > 		ret = page_order(page) ...
> > The caller may hit BUG_ON().
> > 
> > For fixing this, there are 2 choices.
> >   1. add zone->lock.
> >   2. remove BUG_ON().
> 
> One more alternative might be to introduce a private
> maybe_page_order() for is_mem_section_removable(). Not a big deal. 

I guess this is not necessary as all page_order callers check PageBuddy
anyway AFAICS.

>  
> > is_mem_section_removable() is used for some "advice" and doesn't need
> > to be 100% accurate. This is_removable() can be called via user program..
> > We don't want to take this important lock for long by user's request.
> > So, this patch removes BUG_ON().
> 
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Yes, the change looks good.

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
