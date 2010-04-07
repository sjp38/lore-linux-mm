Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3056B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 12:50:14 -0400 (EDT)
Date: Wed, 7 Apr 2010 17:49:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100407164951.GW17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-15-git-send-email-mel@csn.ul.ie> <20100406170623.50631eb8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170623.50631eb8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:06:23PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:48 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > PageAnon pages that are unmapped may or may not have an anon_vma so are
> > not currently migrated. However, a swap cache page can be migrated and
> > fits this description. This patch identifies page swap caches and allows
> > them to be migrated but ensures that no attempt to made to remap the pages
> > would would potentially try to access an already freed anon_vma.
> > 
> > ...
> >
> > @@ -484,7 +484,8 @@ static int fallback_migrate_page(struct address_space *mapping,
> >   *   < 0 - error code
> >   *  == 0 - success
> >   */
> > -static int move_to_new_page(struct page *newpage, struct page *page)
> > +static int move_to_new_page(struct page *newpage, struct page *page,
> > +						int remap_swapcache)
> 
> You're not a fan of `bool'.
> 

This function existed before compaction and returns an error code rather
than a true/false value.

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
> > +	if (rc) {
> >  		newpage->mapping = NULL;
> > +	} else {
> > +		if (remap_swapcache) 
> > +			remove_migration_ptes(page, newpage);
> > +	}
> >  
> >  	unlock_page(newpage);
> >  
> > @@ -539,6 +542,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	int rc = 0;
> >  	int *result = NULL;
> >  	struct page *newpage = get_new_page(page, private, &result);
> > +	int remap_swapcache = 1;
> >  	int rcu_locked = 0;
> >  	int charge = 0;
> >  	struct mem_cgroup *mem = NULL;
> > @@ -600,18 +604,27 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  		rcu_read_lock();
> >  		rcu_locked = 1;
> >  
> > -		/*
> > -		 * If the page has no mappings any more, just bail. An
> > -		 * unmapped anon page is likely to be freed soon but worse,
> > -		 * it's possible its anon_vma disappeared between when
> > -		 * the page was isolated and when we reached here while
> > -		 * the RCU lock was not held
> > -		 */
> > -		if (!page_mapped(page))
> > -			goto rcu_unlock;
> > +		/* Determine how to safely use anon_vma */
> > +		if (!page_mapped(page)) {
> > +			if (!PageSwapCache(page))
> > +				goto rcu_unlock;
> >  
> > -		anon_vma = page_anon_vma(page);
> > -		atomic_inc(&anon_vma->external_refcount);
> > +			/*
> > +			 * We cannot be sure that the anon_vma of an unmapped
> > +			 * swapcache page is safe to use.
> 
> Why not?  A full explanation here would be nice.

Patch below.

> 
> > 			   In this case, the
> > +			 * swapcache page gets migrated but the pages are not
> > +			 * remapped
> > +			 */
> > +			remap_swapcache = 0;
> > +		} else { 
> > +			/*
> > +			 * Take a reference count on the anon_vma if the
> > +			 * page is mapped so that it is guaranteed to
> > +			 * exist when the page is remapped later
> > +			 */
> > +			anon_vma = page_anon_vma(page);
> > +			atomic_inc(&anon_vma->external_refcount);
> > +		}
> >  	}
> >  
> >  	/*
> > @@ -646,9 +659,9 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
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
> 

Patch that updates the comment if you prefer it is as follows

==== CUT HERE ====
mm,compaction: Expand comment on unmapped page swap cache

The comment on the handling of anon_vma for unmapped pages is a bit
sparse. Expand it.

This is a fix to the patch "mm,migration: Allow the migration of
PageSwapCache pages"

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/migrate.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 0356e64..281a239 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -611,9 +611,15 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 
 			/*
 			 * We cannot be sure that the anon_vma of an unmapped
-			 * swapcache page is safe to use. In this case, the
-			 * swapcache page gets migrated but the pages are not
-			 * remapped
+			 * swapcache page is safe to use because we don't
+			 * know in advance if the VMA that this page belonged
+			 * to still exists. If the VMA and others sharing the
+			 * data have been freed, then the anon_vma could
+			 * already be invalid.
+			 *
+			 * To avoid this possibility, swapcache pages get
+			 * migrated but are not remapped when migration
+			 * completes
 			 */
 			remap_swapcache = 0;
 		} else { 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
