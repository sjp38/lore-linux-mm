Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9591C6B01FB
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 04:53:13 -0400 (EDT)
Date: Fri, 2 Apr 2010 09:52:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100402085251.GD621@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie> <1269940489-5776-15-git-send-email-mel@csn.ul.ie> <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com> <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com> <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com> <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com> <20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com> <w2i28c262361004010351r605c897dzd2bdccac149dcc6b@mail.gmail.com> <20100401173640.GB621@csn.ul.ie> <20100402092150.dc4b54a0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100402092150.dc4b54a0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 09:21:50AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 1 Apr 2010 18:36:41 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > > ==
> > > >        skip_remap = 0;
> > > >        if (PageAnon(page)) {
> > > >                rcu_read_lock();
> > > >                if (!page_mapped(page)) {
> > > >                        if (!PageSwapCache(page))
> > > >                                goto rcu_unlock;
> > > >                        /*
> > > >                         * We can't convice this anon_vma is valid or not because
> > > >                         * !page_mapped(page). Then, we do migration(radix-tree replacement)
> > > >                         * but don't remap it which touches anon_vma in page->mapping.
> > > >                         */
> > > >                        skip_remap = 1;
> > > >                        goto skip_unmap;
> > > >                } else {
> > > >                        anon_vma = page_anon_vma(page);
> > > >                        atomic_inc(&anon_vma->external_refcount);
> > > >                }
> > > >        }
> > > >        .....copy page, radix-tree replacement,....
> > > >
> > > 
> > > It's not enough.
> > > we uses remove_migration_ptes in  move_to_new_page, too.
> > > We have to prevent it.
> > > We can check PageSwapCache(page) in move_to_new_page and then
> > > skip remove_migration_ptes.
> > > 
> > > ex)
> > > static int move_to_new_page(....)
> > > {
> > >      int swapcache = PageSwapCache(page);
> > >      ...
> > >      if (!swapcache)
> > >          if(!rc)
> > >              remove_migration_ptes
> > >          else
> > >              newpage->mapping = NULL;
> > > }
> > > 
> > 
> > This I agree with.
> > 
> me, too.
> 
> 
> > I am not sure this race exists because the page is locked but a key
> > observation has been made - A page that is unmapped can be migrated if
> > it's PageSwapCache but it may not have a valid anon_vma. Hence, in the
> > !page_mapped case, the key is to not use anon_vma. How about the
> > following patch?
> > 
> 
> Seems good to me. But (see below)
> 
> 
> > ==== CUT HERE ====
> > 
> > mm,migration: Allow the migration of PageSwapCache pages
> > 
> > PageAnon pages that are unmapped may or may not have an anon_vma so are
> > not currently migrated. However, a swap cache page can be migrated and
> > fits this description. This patch identifies page swap caches and allows
> > them to be migrated but ensures that no attempt to made to remap the pages
> > would would potentially try to access an already freed anon_vma.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 35aad2a..5d0218b 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -484,7 +484,8 @@ static int fallback_migrate_page(struct address_space *mapping,
> >   *   < 0 - error code
> >   *  == 0 - success
> >   */
> > -static int move_to_new_page(struct page *newpage, struct page *page)
> > +static int move_to_new_page(struct page *newpage, struct page *page,
> > +						int safe_to_remap)
> >  {
> >  	struct address_space *mapping;
> >  	int rc;
> > @@ -519,10 +520,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
> >  	else
> >  		rc = fallback_migrate_page(mapping, newpage, page);
> >  
> > -	if (!rc)
> > -		remove_migration_ptes(page, newpage);
> > -	else
> > -		newpage->mapping = NULL;
> > +	if (safe_to_remap) {
> > +		if (!rc)
> > +			remove_migration_ptes(page, newpage);
> > +		else
> > +			newpage->mapping = NULL;
> > +	}
> >  
> 	if (rc)
> 		newpage->mapping = NULL;
> 	else if (safe_to_remap)
> 		remove_migrateion_ptes(page, newpage);
> 
> Is better. Old code cleared newpage->mapping if rc!=0.
> 

True, done.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
