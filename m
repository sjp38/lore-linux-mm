Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 814946B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:27:24 -0500 (EST)
Date: Thu, 12 Jan 2012 09:27:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Fix NULL ptr dereference in __count_immobile_pages
Message-ID: <20120112082722.GB1042@tiehlicka.suse.cz>
References: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.00.1201101326080.10821@chino.kir.corp.google.com>
 <20120111084802.GA16466@tiehlicka.suse.cz>
 <20120112111702.3b7f2fa2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120112111702.3b7f2fa2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

On Thu 12-01-12 11:17:02, KAMEZAWA Hiroyuki wrote:
> On Wed, 11 Jan 2012 09:48:02 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 10-01-12 13:31:08, David Rientjes wrote:
> > > On Tue, 10 Jan 2012, Michal Hocko wrote:
> > [...]
> > > >  mm/page_alloc.c |   11 +++++++++++
> > > >  1 files changed, 11 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 2b8ba3a..485be89 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -5608,6 +5608,17 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
> > > >  bool is_pageblock_removable_nolock(struct page *page)
> > > >  {
> > > >  	struct zone *zone = page_zone(page);
> > > > +	unsigned long pfn = page_to_pfn(page);
> > > > +
> 
> Hmm, I don't like to use page_zone() when we know the page may not be initialized.
> Shouldn't we add
> 
> 	if (!node_online(page_to_nid(page))
> 		return false;
> ?

How is this different? The node won't be initialized in page flags as
well.

> But...hmm. I think we should return 'true' here for removing a section with a hole
> finally....(Now, false will be safe.)

Those pages are reserved (for BIOS I guess) in this particular case so I
do not think it is safe to claim that the block is removable. Or am I
missing something?

[...]
> > > I think this should be handled in is_mem_section_removable() on the pfn 
> > > rather than using the struct page in is_pageblock_removable_nolock() and 
> > > converting back and forth.  We should make sure that any page passed to 
> > > is_pageblock_removable_nolock() is valid.
> > 
> > Yes, I do not like pfn->page->pfn dance as well and in fact I do not
> > have a strong opinion which one is better. I just put it at the place
> > where we care about zone to be more obvious. If others think that I
> > should move the check one level higher I'll do that. I just think this
> > is more obvious.
> > 
> Hmm, mem_section and pageblock is a different chunk...
> And, IIUC, in some IBM machines, section may includes several zones.
> Please taking care of that if you move this to is_mem_section_removable()...

Thanks for pointing this out. 

> 
> Thanks,
> -Kame

Thanks for comments.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
