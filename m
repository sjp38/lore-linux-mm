Date: Thu, 31 May 2007 21:26:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] KAMEZAWA Hiroyuki - migration by kernel
Message-Id: <20070531212606.c5acd10c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705302021040.7044@blonde.wat.veritas.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
	<20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
	<20070530114243.e3c3c75e.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705302021040.7044@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007 20:57:38 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> I've taken a look at last.  It looks like a good fix to a real problem,
> but may I suggest a simpler version?  The anon_vma isn't usually held
> by a refcount, but by having a vma on its linked list: why not just
> put a dummy vma into that linked list?  No need to add a refcount.
> 
> The NUMA shmem_alloc_page already uses a dummy vma on its stack,
Oh, I didn't notice that. If dummy-vma works well now, I'll use it.
thank you.

>
> >  static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> > -			struct page *page, int force)
> > +			struct page *page, int force, int nocontext)
> >  {
> 
> An "int context" would be a lot better than the negative "int nocontext";
> even better would be "int holds_mmap_sem".  Or even skip the additional
> argument completely, use the anon_vma_hold method always without relying
> on whether or not mmap_sem is held.  I don't know how significant it is
> to avoid extra locking here: on the one hand we like to avoid unnecessary
> locking; on the other hand there's probably a thousand commoner places in
> the kernel where we could pass down an arg to say, actually you won't
> need to lock in such and such a case.
Hmm, ok. I'd like to try make things simpler.

> 
> >  	int rc = 0;
> >  	int *result = NULL;
> >  	struct page *newpage = get_new_page(page, private, &result);
> > +	struct anon_vma *anon_vma = NULL;
> >  
> >  	if (!newpage)
> >  		return -ENOMEM;
> > @@ -632,17 +633,23 @@ static int unmap_and_move(new_page_t get
> >  			goto unlock;
> >  		wait_on_page_writeback(page);
> >  	}
> > -
> > +	/* hold this anon_vma until page migration ends */
> > +	if (nocontext && PageAnon(page) && page_mapped(page))
> > +		anon_vma = anon_vma_hold(page);
> >  	/*
> >  	 * Establish migration ptes or remove ptes
> >  	 */
> > -	try_to_unmap(page, 1);
> > +	if (page_mapped(page))
> > +		try_to_unmap(page, 1);
> > +
> 
> All these preliminary tests: yes, I suppose they avoid unnecessary
> locking, so I guess they're good; but it should work without them.
> 
> >  	if (!page_mapped(page))
> >  		rc = move_to_new_page(newpage, page);
> >  
> >  	if (rc)
> >  		remove_migration_ptes(page, page);
> >  
> > +	anon_vma_release(anon_vma);
> > +
> >  unlock:
> >  	unlock_page(page);
> >  
> > @@ -686,8 +693,8 @@ move_newpage:
> >   *
> >   * Return: Number of pages not migrated or error code.
> >   */
> > -int migrate_pages(struct list_head *from,
> > -		new_page_t get_new_page, unsigned long private)
> > +int __migrate_pages(struct list_head *from,
> > +		new_page_t get_new_page, unsigned long private, int nocontext)
> >  {
> 
> Remarks on nocontext as above: mmm, I think keep the patch small
> and don't add that extra argument at all.
> 
> >  	int retry = 1;
> >  	int nr_failed = 0;
> > @@ -707,7 +714,7 @@ int migrate_pages(struct list_head *from
> >  			cond_resched();
> >  
> >  			rc = unmap_and_move(get_new_page, private,
> > -						page, pass > 2);
> > +						page, pass > 2, nocontext);
> >  
> >  			switch(rc) {
> >  			case -ENOMEM:
> > @@ -737,6 +744,22 @@ out:
> >  	return nr_failed + retry;
> >  }
> >  
> > +int migrate_pages(struct list_head *from,
> > +	new_page_t get_new_page, unsigned long private)
> > +{
> > +	return __migrate_pages(from, get_new_page, private, 0);
> > +}
> > +
> > +/*
> > + * When page migration is issued by the kernel itself without page mapper's
> > + * mm->sem, we have to be more careful to do page migration.
> > + */
> > +int migrate_pages_nocontext(struct list_head *from,
> > +	new_page_t get_new_page, unsigned long private)
> > +{
> > +	return __migrate_pages(from, get_new_page, private, 1);
> > +}
> > +
> >  #ifdef CONFIG_NUMA
> >  /*
> >   * Move a list of individual pages
> > Index: linux-2.6.22-rc2-mm1/include/linux/rmap.h
> > ===================================================================
> > --- linux-2.6.22-rc2-mm1.orig/include/linux/rmap.h
> > +++ linux-2.6.22-rc2-mm1/include/linux/rmap.h
> > @@ -26,6 +26,9 @@
> >  struct anon_vma {
> >  	spinlock_t lock;	/* Serialize access to vma list */
> >  	struct list_head head;	/* List of private "related" vmas */
> > +#ifdef CONFIG_MIGRATION
> > +	int	ref;	/* special refcnt for migration */
> > +#endif
> >  };
> >  
> >  #ifdef CONFIG_MMU
> > @@ -42,6 +45,14 @@ static inline void anon_vma_free(struct 
> >  	kmem_cache_free(anon_vma_cachep, anon_vma);
> >  }
> >  
> > +#ifdef  CONFIG_MIGRATION
> > +extern struct anon_vma *anon_vma_hold(struct page *page);
> > +extern void anon_vma_release(struct anon_vma *anon_vma);
> > +#else
> > +#define anon_vma_hold(page)     do{}while(0)
> > +#define anon_vma_release(anon)  do{}while(0)
> 
> Rather than change those to "do {} while (0)", to which others
> will ask for static inlines, just delete them, can't you -
> they're simply not needed in the !CONFIG_MIGRATION case, right?
> 
Ok. they are not necessary if !CONFIG_MIGRATION. I'll delete.

Maybe I was confused at deleting CONFIG_MIGRATON_BY_KERNEL...which needed ifdef.
 
Thank you!.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
