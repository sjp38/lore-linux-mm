Subject: Re: [PATCH 2.6.17-rc1-mm1 3/6] Migrate-on-fault - migrate
	misplaced page
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604111124090.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <1144441424.5198.42.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111124090.878@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 15:51:13 -0400
Message-Id: <1144785073.5160.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-11 at 11:32 -0700, Christoph Lameter wrote:
> On Fri, 7 Apr 2006, Lee Schermerhorn wrote:
> 
> > @@ -184,6 +185,31 @@ int do_migrate_pages(struct mm_struct *m
> >  int mpol_misplaced(struct page *, struct vm_area_struct *,
> >  		unsigned long, int *);
> >  
> > +#if defined(CONFIG_MIGRATION) && defined(_LINUX_MM_H)

I go back and look at it.  I may have to come up with another way to
avoid header dependency hell.  I did it this way because, as I recall,
one place where mempolicy.h is included, I encountered errors because
some of the functions used by the "check_migrate_misplace_page()" are
not available because <linux/mm.h> was not included there.  That seems
like a pretty heavy-weight header to be dragging into a source file to
satisfy a dependency in a static-inline function that the source file
doesn't even care about.  

Maybe check_migrate_misplaced_page() belongs in some other header.
mempolicy.h seemed like the right place.  And I wanted to put it in a
header so that I could turn it into a no-op when migrate-on-fault is not
enabled.  That seems to be the preferred method, when possible, rather
than #ifdefs" in the .c's.  

> 
> Remove the defined(_LINUX_MM_H). This is pretty obscure.
> 
> > Index: linux-2.6.17-rc1-mm1/mm/migrate.c
> > ===================================================================
> > --- linux-2.6.17-rc1-mm1.orig/mm/migrate.c	2006-04-05 10:14:38.000000000 -0400
> > +++ linux-2.6.17-rc1-mm1/mm/migrate.c	2006-04-05 10:14:41.000000000 -0400
> > @@ -59,7 +59,8 @@ int isolate_lru_page(struct page *page, 
> >  				del_page_from_active_list(zone, page);
> >  			else
> >  				del_page_from_inactive_list(zone, page);
> > -			list_add_tail(&page->lru, pagelist);
> > +			if (pagelist)
> > +				list_add_tail(&page->lru, pagelist);
> >  		}
> >  		spin_unlock_irq(&zone->lru_lock);
> >  	}
> 
> isolate lru page can be called without a pagelist now?

I'll take a look.  I thought I still had to do something here to get the
interface that I needed.

> 
> 
> > -int fail_migrate_page(struct page *newpage, struct page *page)
> > +int fail_migrate_page(struct page *newpage, struct page *page, int faulting)
> 
> I do not think the faulting parameter is needed. mapcount == 0 if 
> we are faulting on an unmapped page. try_to_unmap() will do nothing or 
> you can check for mapcount.

I also need to allow another reference count for the fault path.  I much
prefer having the explicit indication and think it less likely to cause
breakage down the line that counting on zero map count here.  

> 
> >  	 *
> >  	 * Note that a real pte entry will allow processes that are not
> >  	 * waiting on the page lock to use the new page via the page tables
> >  	 * before the new page is unlocked.
> >  	 */
> > -	remove_from_swap(newpage);
> > +	if (!faulting)
> > +		remove_from_swap(newpage);
> >  	return 0;
> 
> If we are faulting then there is nothing to remove. remove_from_swap would 
> do nothing.

Not true.  The page is in the swap cache [or migration cache, if we ever
get one].  And, the faulting task may not have the only pte reference to
that page.  I don't remove_from_swap() walking the reverse map and
replacing any other ptes in the fault path of another tasks--as we've
discussed before.

> 
> > +out:
> > +	putback_lru_page(page);		/* drops a page ref */
> 
> We already have a ref from the fault patch and do not need another one 
> in isolate_lru page right?
> 

No, we don't need another one.  I only did the isolate_lru_page() so
that the page being migrated in the fault path is in the same state as
pages being migrated directly--i.e., we hold them isolated from the lru.
Then, they can only be found via the cache.  For anon pages, this means
via faulting tasks' ptes.  For file back and shmem pages [when/if we
hook them up], they could also be found by faulting on the appropriate
file page.  However, in those cases, we'll already have the page locked,
the subsquent faulters will be held off until migration is complete.
Then they'll need to check and do the right thing [as discussed in a
different thread].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
