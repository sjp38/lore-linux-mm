Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B174D6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:48:34 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so614875wgh.16
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 09:48:34 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n18si7384327wij.19.2014.01.22.09.48.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 09:48:33 -0800 (PST)
Date: Wed, 22 Jan 2014 12:47:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/9] mm + fs: prepare for non-page entries in page cache
 radix trees
Message-ID: <20140122174744.GC4407@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
 <20140113020132.GO1992@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140113020132.GO1992@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 13, 2014 at 11:01:32AM +0900, Minchan Kim wrote:
> On Fri, Jan 10, 2014 at 01:10:39PM -0500, Johannes Weiner wrote:
> > shmem mappings already contain exceptional entries where swap slot
> > information is remembered.
> > 
> > To be able to store eviction information for regular page cache,
> > prepare every site dealing with the radix trees directly to handle
> > entries other than pages.
> > 
> > The common lookup functions will filter out non-page entries and
> > return NULL for page cache holes, just as before.  But provide a raw
> > version of the API which returns non-page entries as well, and switch
> > shmem over to use it.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks, Minchan!

> > @@ -890,6 +973,73 @@ repeat:
> >  EXPORT_SYMBOL(find_or_create_page);
> >  
> >  /**
> > + * __find_get_pages - gang pagecache lookup
> > + * @mapping:	The address_space to search
> > + * @start:	The starting page index
> > + * @nr_pages:	The maximum number of pages
> > + * @pages:	Where the resulting pages are placed
> 
> where is @indices?

Fixed :)

> > @@ -894,6 +894,53 @@ EXPORT_SYMBOL(__pagevec_lru_add);
> >  
> >  /**
> >   * pagevec_lookup - gang pagecache lookup
> 
>       __pagevec_lookup?
> 
> > + * @pvec:	Where the resulting entries are placed
> > + * @mapping:	The address_space to search
> > + * @start:	The starting entry index
> > + * @nr_pages:	The maximum number of entries
> 
>       missing @indices?
> 
> > + *
> > + * pagevec_lookup() will search for and return a group of up to
> > + * @nr_pages pages and shadow entries in the mapping.  All entries are
> > + * placed in @pvec.  pagevec_lookup() takes a reference against actual
> > + * pages in @pvec.
> > + *
> > + * The search returns a group of mapping-contiguous entries with
> > + * ascending indexes.  There may be holes in the indices due to
> > + * not-present entries.
> > + *
> > + * pagevec_lookup() returns the number of entries which were found.
> 
>       __pagevec_lookup

Yikes, all three fixed.

> > @@ -22,6 +22,22 @@
> >  #include <linux/cleancache.h>
> >  #include "internal.h"
> >  
> > +static void clear_exceptional_entry(struct address_space *mapping,
> > +				    pgoff_t index, void *entry)
> > +{
> > +	/* Handled by shmem itself */
> > +	if (shmem_mapping(mapping))
> > +		return;
> > +
> > +	spin_lock_irq(&mapping->tree_lock);
> > +	/*
> > +	 * Regular page slots are stabilized by the page lock even
> > +	 * without the tree itself locked.  These unlocked entries
> > +	 * need verification under the tree lock.
> > +	 */
> 
> Could you explain why repeated spin_lock with irq disabled isn't problem
> in truncation path?

To modify the cache tree, we have to take the IRQ-safe tree_lock, this
is no different than removing a page (see truncate_complete_page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
