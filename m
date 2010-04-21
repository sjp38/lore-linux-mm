Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2492A6B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:01:03 -0400 (EDT)
Date: Wed, 21 Apr 2010 16:00:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100421150037.GJ30306@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004210927550.4959@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004210927550.4959@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 09:30:20AM -0500, Christoph Lameter wrote:
> On Tue, 20 Apr 2010, Mel Gorman wrote:
> 
> > @@ -520,10 +521,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
> >  	else
> >  		rc = fallback_migrate_page(mapping, newpage, page);
> >
> > -	if (!rc)
> > -		remove_migration_ptes(page, newpage);
> > -	else
> > +	if (rc) {
> >  		newpage->mapping = NULL;
> > +	} else {
> > +		if (remap_swapcache)
> > +			remove_migration_ptes(page, newpage);
> > +	}
> 
> You are going to keep the migration ptes after the page has been unlocked?

Yes, because it's not known if the anon_vma for the unmapped swapcache page
still exists or not.  Now, a bug has been reported where a migration PTE is
found where the page is not locked. I'm trying to determine if it's the same
page or not but the problem takes ages to reproduce.

> Or is remap_swapcache true if its not a swapcache page?
> 
> Maybe you meant
> 
> if (!remap_swapcache)
> 
> ?
> 

No, remap_swapcache could just be called "remap". If it's 0, it's
considered unsafe to remap the page.

> >  	unlock_page(newpage);
> >
> 
> >
> >  skip_unmap:
> >  	if (!page_mapped(page))
> > -		rc = move_to_new_page(newpage, page);
> > +		rc = move_to_new_page(newpage, page, remap_swapcache);
> >
> > -	if (rc)
> > +	if (rc && remap_swapcache)
> >  		remove_migration_ptes(page, page);
> >  rcu_unlock:
> >
> 
> Looks like you meant !remap_swapcache
> 

If remap_swapcache is 1, the anon_vma is valid (or irrelevant because
it's a file) and it's safe to remap the page by removing the migration
PTEs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
