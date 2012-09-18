Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8F1916B00DF
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 12:24:43 -0400 (EDT)
Date: Tue, 18 Sep 2012 13:24:21 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v10 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120918162420.GB1645@optiplex.redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
 <89c9f4096bbad072e155445fcdf1805d47ddf48e.1347897793.git.aquini@redhat.com>
 <20120917151543.fd523040.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120917151543.fd523040.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Sep 17, 2012 at 03:15:43PM -0700, Andrew Morton wrote:
> > +/* return code to identify when a ballooned page has been migrated */
> > +#define BALLOON_MIGRATION_RETURN	0xba1100
> 
> I didn't really spend enough time to work out why this was done this
> way, but I know a hack when I see one!
>
Yes, I'm afraid it's a hack, but, unfortunately, it's a necessary one (IMHO).

This 'distinct' return code is used to flag a sucessful balloon page migration
at the following unmap_and_move() snippet (patch 2).
If by any reason we fail to identify a sucessfull balloon page migration, we
will cause a page leak, as the old 'page' won't be properly released.
.....
        rc = __unmap_and_move(page, newpage, force, offlining, mode);
+
+        if (unlikely(rc == BALLOON_MIGRATION_RETURN)) {
+                /*
+                 * A ballooned page has been migrated already.
+                 * Now, it's the time to remove the old page from the isolated
+                 * pageset list and handle it back to Buddy, wrap-up counters
+                 * and return.
+                 */
......

By reaching that point in code, we cannot rely on testing page->mapping flags
anymore for both 'page' and 'newpage' because:
a) migration has already finished and 'page'->mapping is wiped out;
b) balloon might have started to deflate, and 'newpage' might be released
   already;

If the return code approach is unnaceptable, we might defer the 'page'->mapping
wipe-out step to that point in code for the balloon page case.
That, however, tends to be a little bit heavier, IMHO, as it will require us to
acquire the page lock once more to proceed the mapping wipe out, thus
potentially introducing overhead by lock contention (specially when several
parallel compaction threads are scanning pages for isolation)

 
> We forgot to document the a_ops.migratepage() return value.  Perhaps
> it's time to work out what it should be.
> 
> > +#ifdef CONFIG_BALLOON_COMPACTION
> > +#define count_balloon_event(e)		count_vm_event(e)
> > +#define free_balloon_mapping(m)		kfree(m)
> 
> It would be better to write these in C please.  That way we get
> typechecking, even when CONFIG_BALLOON_COMPACTION=n.
> 

Consider it done, sir.


> > +extern bool isolate_balloon_page(struct page *);
> > +extern void putback_balloon_page(struct page *);
> > +extern int migrate_balloon_page(struct page *newpage,
> > +				struct page *page, enum migrate_mode mode);
> > +extern struct address_space *alloc_balloon_mapping(void *balloon_device,
> > +				const struct address_space_operations *a_ops);
> 
> There's a useful convention that interface identifiers are prefixed by
> their interface's name.  IOW, everything in this file would start with
> "balloon_".  balloon_page_isolate, balloon_page_putback, etc.  I think
> we could follow that convention here?
> 

Consider it done, sir.


> > +static inline void assign_balloon_mapping(struct page *page,
> > +					  struct address_space *mapping)
> > +{
> > +	page->mapping = mapping;
> > +	smp_wmb();
> > +}
> > +
> > +static inline void clear_balloon_mapping(struct page *page)
> > +{
> > +	page->mapping = NULL;
> > +	smp_wmb();
> > +}
> > +
> > +static inline gfp_t balloon_mapping_gfp_mask(void)
> > +{
> > +	return GFP_HIGHUSER_MOVABLE;
> > +}
> > +
> > +static inline bool __is_movable_balloon_page(struct page *page)
> > +{
> > +	struct address_space *mapping = ACCESS_ONCE(page->mapping);
> > +	smp_read_barrier_depends();
> > +	return mapping_balloon(mapping);
> > +}
> 
> hm.  Are these barrier tricks copied from somewhere else, or home-made?
>

They were introduced by a reviewer request to assure the proper ordering when
inserting or deleting pages to/from a balloon device, so a given page won't get
elected as being a balloon page before it gets inserted into the balloon's page
list, just as it will only be deleted from the balloon's page list after it is
decomissioned of its balloon page status (page->mapping wipe-out). 

Despite the mentioned operations only take place under proper locking, I thought
it wouldn't hurt enforcing such order, thus I kept the barrier stuff. Btw,
considering the aforementioned usage case, I just realized the
assign_balloon_mapping() barrier is misplaced. I'll fix that and introduce
comments on those function's usage.
 

> > +/*
> > + * movable_balloon_page - test page->mapping->flags to identify balloon pages
> > + *			  that can be moved by compaction/migration.
> > + *
> > + * This function is used at core compaction's page isolation scheme and so it's
> > + * exposed to several system pages which may, or may not, be part of a memory
> > + * balloon, and thus we cannot afford to hold a page locked to perform tests.
> 
> I don't understand this.  What is a "system page"?  If I knew that, I
> migth perhaps understand why we cannot lock such a page.
> 

I've attempted to mean compaction threads scan through all memory pages in the
system to check whether a page can be isolated or not, thus we cannot held the
page locked to perform the mapping->flags test as it can cause undesired effects
on other subsystems where the weA?e about to test here page is on use.

I'll try to re-arrange the comment to make it clear.


> > + * Therefore, as we might return false positives in the case a balloon page
> > + * is just released under us, the page->mapping->flags need to be retested
> > + * with the proper page lock held, on the functions that will cope with the
> > + * balloon page later.
> > + */
> > +static inline bool movable_balloon_page(struct page *page)
> > +{
> > +	/*
> > +	 * Before dereferencing and testing mapping->flags, lets make sure
> > +	 * this is not a page that uses ->mapping in a different way
> > +	 */
> > +	if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
> > +	    !page_mapped(page))
> > +		return __is_movable_balloon_page(page);
> > +
> > +	return false;
> > +}
> > +
> > +/*
> > + * __page_balloon_device - get the balloon device that owns the given page.
> > + *
> > + * This shall only be used at driver callbacks under proper page lock,
> > + * to get access to the balloon device which @page belongs.
> > + */
> > +static inline void *__page_balloon_device(struct page *page)
> > +{
> > +	struct address_space *mapping = page->mapping;
> > +	if (mapping)
> > +		mapping = mapping->assoc_mapping;
> > +
> > +	return mapping;
> > +}
> 
> So you've repurposed address_space.assoc_mapping in new and unexpected
> ways.
> 
> I don't immediately see a problem with doing this, but we should do it
> properly.  Something like:
> 
> - rename address_space.assoc_mapping to private_data
> - it has type void*
> - document its ownership rules
> - convert fs/buffer.c
> 
> all done as a standalone preparatory patch.
>

I'll do it as you requested/suggested.

 
> Also, your usage of ->private_data should minimise its use of void* -
> use more specific types wherever possible.  So this function should
> return a "struct virtio_balloon *".
> 

I believe we can keep it returning the opaque type, as it will allow us to expand 
its usage to other balloon drivers which might have different balloon descriptors
in the future. I didn't looked at all balloon drivers, but in a glance seems that
vmware's balloon is using a fairly similar scheme to virtio's and it could
leverage all this interfaces, as well.


> It is unobvious why this interface function is prefixed with __.
> 
> > +/*
> > + * DEFINE_BALLOON_MAPPING_AOPS - declare and instantiate a callback descriptor
> > + *				 to be used as balloon page->mapping->a_ops.
> > + *
> > + * @label     : declaration identifier (var name)
> > + * @isolatepg : callback symbol name for performing the page isolation step
> > + * @migratepg : callback symbol name for performing the page migration step
> > + * @putbackpg : callback symbol name for performing the page putback step
> > + *
> > + * address_space_operations utilized methods for ballooned pages:
> > + *   .migratepage    - used to perform balloon's page migration (as is)
> > + *   .invalidatepage - used to isolate a page from balloon's page list
> > + *   .freepage       - used to reinsert an isolated page to balloon's page list
> > + */
> > +#define DEFINE_BALLOON_MAPPING_AOPS(label, isolatepg, migratepg, putbackpg) \
> > +	const struct address_space_operations (label) = {		    \
> > +		.migratepage    = (migratepg),				    \
> > +		.invalidatepage = (isolatepg),				    \
> > +		.freepage       = (putbackpg),				    \
> > +	}
> 
> erp.  Can we avoid doing this?  afaict it would be pretty simple to
> avoid instantiating virtio_balloon_aops at all if
> CONFIG_BALLOON_COMPACTION=n?
>

That was being instantiated at driver's level directly, 
and driver folks have requested this change.

I'll look a way around of it, though. (Just to make sure we're on the same page
here: Are you against the preprocessor macro, or just the way it's being used?)

 
> > +#else
> > +#define assign_balloon_mapping(p, m)	do { } while (0)
> > +#define clear_balloon_mapping(p)	do { } while (0)
> > +#define free_balloon_mapping(m)		do { } while (0)
> > +#define count_balloon_event(e)		do { } while (0)
> 
> Written in C with proper types if possible, please.
> 

Consider it done, sir.


> > +#define DEFINE_BALLOON_MAPPING_AOPS(label, isolatepg, migratepg, putbackpg) \
> > +	const struct {} (label) = {}
> > +
> > +static inline bool movable_balloon_page(struct page *page) { return false; }
> > +static inline bool isolate_balloon_page(struct page *page) { return false; }
> > +static inline void putback_balloon_page(struct page *page) { return; }
> > +
> > +static inline int migrate_balloon_page(struct page *newpage,
> > +				struct page *page, enum migrate_mode mode)
> > +{
> > +	return 0;
> > +}
> > +
> >
> > ...
> >
> > @@ -53,6 +54,23 @@ static inline int mapping_unevictable(struct address_space *mapping)
> >  	return !!mapping;
> >  }
> >  
> > +static inline void mapping_set_balloon(struct address_space *mapping)
> > +{
> > +	set_bit(AS_BALLOON_MAP, &mapping->flags);
> > +}
> > +
> > +static inline void mapping_clear_balloon(struct address_space *mapping)
> > +{
> > +	clear_bit(AS_BALLOON_MAP, &mapping->flags);
> > +}
> > +
> > +static inline int mapping_balloon(struct address_space *mapping)
> > +{
> > +	if (mapping)
> > +		return test_bit(AS_BALLOON_MAP, &mapping->flags);
> > +	return !!mapping;
> 
> Why not "return 0"?
> 
> Or
> 
> 	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);

Consider it done, sir.


> 
> > +}
> > +
> >
> > ...
> >
> > +struct address_space *alloc_balloon_mapping(void *balloon_device,
> > +				const struct address_space_operations *a_ops)
> > +{
> > +	struct address_space *mapping;
> > +
> > +	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
> > +	if (!mapping)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	/*
> > +	 * Give a clean 'zeroed' status to all elements of this special
> > +	 * balloon page->mapping struct address_space instance.
> > +	 */
> > +	address_space_init_once(mapping);
> > +
> > +	/*
> > +	 * Set mapping->flags appropriately, to allow balloon ->mapping
> > +	 * identification, as well as give a proper hint to the balloon
> > +	 * driver on what GFP allocation mask shall be used.
> > +	 */
> > +	mapping_set_balloon(mapping);
> > +	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
> > +
> > +	/* balloon's page->mapping->a_ops callback descriptor */
> > +	mapping->a_ops = a_ops;
> > +
> > +	/*
> > +	 * balloon special page->mapping overloads ->assoc_mapping
> > +	 * to held a reference back to the balloon device wich 'owns'
> > +	 * a given page. This is the way we can cope with multiple
> > +	 * balloon devices without losing reference of several
> > +	 * ballooned pagesets.
> 
> I don't really understand the final part of this comment.  Can you
> expand more fully on the problem which this code is solving?
> 

I was trying to state we can have several virtio_balloon devices instantiated
for a single guest (virtio folks have told me that's a quite easy scenario), and
the only way we can safely get the right balloon page lists to isolate pages
from, or put pages back in, is maintaining a pointer back to the device descriptor
at every balloon's page->mapping instance.

I'll try to reprhase the commentary, to make it clearer.


> > +	 */
> > +	mapping->assoc_mapping = balloon_device;
> > +
> > +	return mapping;
> > +}
> > +EXPORT_SYMBOL_GPL(alloc_balloon_mapping);
> 
> balloon_mapping_alloc() :)

Consider it done, sir.


> 
> > +static inline void __isolate_balloon_page(struct page *page)
> > +{
> > +	page->mapping->a_ops->invalidatepage(page, 0);
> > +}
> > +
> >
> > ...
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
