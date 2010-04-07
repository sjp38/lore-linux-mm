Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D8DB16B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 05:56:57 -0400 (EDT)
Date: Wed, 7 Apr 2010 10:56:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/14] mm,migration: Take a reference to the anon_vma
	before migrating
Message-ID: <20100407095635.GL17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-2-git-send-email-mel@csn.ul.ie> <20100406170520.1e29648c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170520.1e29648c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:20PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:35 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
> > locking an anon_vma and it does not appear to have sufficient locking to
> > ensure the anon_vma does not disappear from under it.
> > 
> > This patch copies an approach used by KSM to take a reference on the
> > anon_vma while pages are being migrated. This should prevent rmap_walk()
> > running into nasty surprises later because anon_vma has been freed.
> > 
> 
> The code didn't exactly bend over backwards making itself easy for
> others to understand...
> 

anon_vma in general is not perfectly straight-forward. I clarify the
situation somewhat in Patch 3/14.

> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index d25bd22..567d43f 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -29,6 +29,9 @@ struct anon_vma {
> >  #ifdef CONFIG_KSM
> >  	atomic_t ksm_refcount;
> >  #endif
> > +#ifdef CONFIG_MIGRATION
> > +	atomic_t migrate_refcount;
> > +#endif
> 
> Some documentation here describing the need for this thing and its
> runtime semantics would be appropriate.
> 

Will come to that in Patch 3.

> >  	/*
> >  	 * NOTE: the LSB of the head.next is set by
> >  	 * mm_take_all_locks() _after_ taking the above lock. So the
> > @@ -81,6 +84,26 @@ static inline int ksm_refcount(struct anon_vma *anon_vma)
> >  	return 0;
> >  }
> >  #endif /* CONFIG_KSM */
> > +#ifdef CONFIG_MIGRATION
> > +static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> > +{
> > +	atomic_set(&anon_vma->migrate_refcount, 0);
> > +}
> > +
> > +static inline int migrate_refcount(struct anon_vma *anon_vma)
> > +{
> > +	return atomic_read(&anon_vma->migrate_refcount);
> > +}
> > +#else
> > +static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> > +{
> > +}
> > +
> > +static inline int migrate_refcount(struct anon_vma *anon_vma)
> > +{
> > +	return 0;
> > +}
> > +#endif /* CONFIG_MIGRATE */
> >  
> >  static inline struct anon_vma *page_anon_vma(struct page *page)
> >  {
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 6903abf..06e6316 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -542,6 +542,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	int rcu_locked = 0;
> >  	int charge = 0;
> >  	struct mem_cgroup *mem = NULL;
> > +	struct anon_vma *anon_vma = NULL;
> >  
> >  	if (!newpage)
> >  		return -ENOMEM;
> > @@ -598,6 +599,8 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	if (PageAnon(page)) {
> >  		rcu_read_lock();
> >  		rcu_locked = 1;
> > +		anon_vma = page_anon_vma(page);
> > +		atomic_inc(&anon_vma->migrate_refcount);
> 
> So no helper function for this.  I guess a grep for `migrate_refcount'
> will find it OK.
> 

It will, again I will expand on this in my response on patch 3.

> Can this count ever have a value > 1?   I guess so..
> 

KSM and migration could both conceivably take a refcount.

> >  	}
> >  
> >  	/*
> > @@ -637,6 +640,15 @@ skip_unmap:
> >  	if (rc)
> >  		remove_migration_ptes(page, page);
> >  rcu_unlock:
> > +
> > +	/* Drop an anon_vma reference if we took one */
> > +	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> > +		int empty = list_empty(&anon_vma->head);
> > +		spin_unlock(&anon_vma->lock);
> > +		if (empty)
> > +			anon_vma_free(anon_vma);
> > +	}
> > +
> 
> So...  Why shouldn't this be testing ksm_refcount() too?
> 

It will in patch 3.

> Can we consolidate ksm_refcount and migrate_refcount into, err, `refcount'?
> 

Will expand on this again in the response to patch 3.

> >  	if (rcu_locked)
> >  		rcu_read_unlock();
> >  uncharge:
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index fcd593c..578d0fe 100644
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
