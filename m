Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9C4F66B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 21:35:02 -0400 (EDT)
Date: Fri, 29 Jun 2012 22:34:48 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120630013447.GA1545@x61.redhat.com>
References: <cover.1340916058.git.aquini@redhat.com>
 <d0f33a6492501a0d420abbf184f9b956cff3e3fc.1340916058.git.aquini@redhat.com>
 <4FED3DDB.1000903@kernel.org>
 <20120629173653.GA1774@t510.redhat.com>
 <20120629220333.GA2079@barrios>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120629220333.GA2079@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

Howdy Minchan,

On Sat, Jun 30, 2012 at 07:03:33AM +0900, Minchan Kim wrote:
> > > > +static inline bool is_balloon_page(struct page *page)
> > > > +{
> > > > +        return (page->mapping == balloon_mapping) ? true : false;
> > > > +}
> > > 
> > > 
> > > What lock should it protect?
> > > 
> > I'm afraid I didn't quite get what you meant by that question. If you were
> > referring to lock protection to the address_space balloon_mapping, we don't need
> > it. balloon_mapping, once initialized lives forever (as long as driver is
> > loaded, actually) as a static reference that just helps us on identifying pages 
> > that are enlisted in a memory balloon as well as it keeps the callback pointers 
> > to functions that will make those pages mobility magic happens.
> 
> Thanks. That's what I want to know.
> If anyone(like me don't know of ballooning in detail) see this, it would be very helpful.
> 
Good point! I'll make sure this explanation gets properly registered either at commit log or
at a comment along with balloon_mapping declaration, then.



> > > > +		if (likely(PageLRU(page))) {
> > > 
> > > 
> > > We can't make sure it is likely because there might be so many pages for kernel.
> > > 
> > I thought that by that far in codepath that would be the likelihood since most
> > pages of an ordinary workload will be at LRU lists. Following that idea, it
> > sounded neat to hint the compiler to not branch for that block. But, if in the
> > end that is just a "bad hint", I'll get rid of it right away.
> 
> Yeb. I hope you remove this.
> If you want really, it should be separated patch because it's not related to your
> series.
> 
That will be removed, then.



> > > > +/* __isolate_lru_page() counterpart for a ballooned page */
> > > > +bool isolate_balloon_page(struct page *page)
> > > > +{
> > > > +	if (WARN_ON(!is_balloon_page(page)))
> > > > +		return false;
> > > > +
> > > > +	if (likely(get_page_unless_zero(page))) {
> > > > +		/*
> > > > +		 * We can race against move_to_new_page() & __unmap_and_move().
> > > > +		 * If we stumble across a locked balloon page and succeed on
> > > > +		 * isolating it, the result tends to be disastrous.
> > > > +		 */
> > > > +		if (likely(trylock_page(page))) {
> > > > +			/*
> > > > +			 * A ballooned page, by default, has just one refcount.
> > > > +			 * Prevent concurrent compaction threads from isolating
> > > > +			 * an already isolated balloon page.
> > > > +			 */
> > > > +			if (is_balloon_page(page) && (page_count(page) == 2)) {
> > > > +				page->mapping->a_ops->invalidatepage(page, 0);
> > > 
> > > 
> > > Could you add more meaningful name wrapping raw invalidatepage?
> > > But I don't know what is proper name. ;)
> > > 
> > If I understood you correctely, your suggestion is to add two extra callback
> > pointers to struct address_space_operations, instead of re-using those which are
> > already there, and are suitable for the mission. Is this really necessary? It
> > seems just like unecessary bloat to struct address_space_operations, IMHO.
> 
> I meant this. :)
> 
> void isolate_page_from_balloonlist(struct page* page)
> {
> 	page->mapping->a_ops->invalidatepage(page, 0);
> }
> 
> 	if (is_balloon_page(page) && (page_count(page) == 2)) {
> 		isolate_page_from_balloonlist(page);
> 	}
> 
Humm, my feelings on your approach here: just an unecessary indirection that
doesn't bring the desired code readability improvement.
If the header comment statement on balloon_mapping->a_ops is not clear enough 
on those methods usage for ballooned pages:

..... 
/*
 * Balloon pages special page->mapping.
 * users must properly allocate and initialize an instance of balloon_mapping,
 * and set it as the page->mapping for balloon enlisted page instances.
 *
 * address_space_operations necessary methods for ballooned pages:
 *   .migratepage    - used to perform balloon's page migration (as is)
 *   .invalidatepage - used to isolate a page from balloon's page list
 *   .freepage       - used to reinsert an isolated page to balloon's page list
 */
struct address_space *balloon_mapping;
EXPORT_SYMBOL_GPL(balloon_mapping);
.....

I can add an extra commentary, to recollect folks about that usage, next to the
points where those callbacks are used at isolate_balloon_page() &
putback_balloon_page(). What do you think?


> Thanks!
> 
Thank you for such attention and valuable feedback! Have a nice weekend!

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
