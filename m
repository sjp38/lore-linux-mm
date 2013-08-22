Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E29946B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 03:22:47 -0400 (EDT)
Date: Thu, 22 Aug 2013 09:20:41 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/9] mm + fs: prepare for non-page entries in page cache
 radix trees
Message-ID: <20130822072041.GA26749@cmpxchg.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
 <1376767883-4411-5-git-send-email-hannes@cmpxchg.org>
 <20130820135910.6e6da048131bc841404906be@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820135910.6e6da048131bc841404906be@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 20, 2013 at 01:59:10PM -0700, Andrew Morton wrote:
> On Sat, 17 Aug 2013 15:31:18 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
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
> >
> > ...
> >
> > -/**
> > - * find_get_page - find and get a page reference
> > - * @mapping: the address_space to search
> > - * @offset: the page index
> > - *
> > - * Is there a pagecache struct page at the given (mapping, offset) tuple?
> > - * If yes, increment its refcount and return it; if no, return NULL.
> > - */
> > -struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
> > +struct page *__find_get_page(struct address_space *mapping, pgoff_t offset)
> >  {
> >  	void **pagep;
> >  	struct page *page;
> > @@ -812,24 +828,31 @@ out:
> >  
> >  	return page;
> >  }
> > -EXPORT_SYMBOL(find_get_page);
> > +EXPORT_SYMBOL(__find_get_page);
> 
> Deleting the interface documentation for a global, exported-to-modules
> function was a bit rude.
> 
> And it does need documentation, to tell people that it can return the
> non-pages.

I didn't really delete documentation as much as moving it to the new
find_get_page() definition (the above is a rename).  But yeah, I
should probably add some documentation to the new function as well.

> Does it have the same handling of non-pages as __find_get_pages()?  It
> had better, given the naming!

Yes, the only difference is single vs. multi lookup.  The underscore
versions may return non-pages, the traditional interface filters them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
