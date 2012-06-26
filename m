Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 037F36B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:02:32 -0400 (EDT)
Date: Tue, 26 Jun 2012 19:01:56 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120626220155.GA2292@t510.redhat.com>
References: <cover.1340665087.git.aquini@redhat.com>
 <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
 <20120626101729.GF8103@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626101729.GF8103@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org

Mel,

First and foremost, thank you for taking the time to review these bits and
provide such valuable feedback.

On Tue, Jun 26, 2012 at 11:17:29AM +0100, Mel Gorman wrote:
> > +/* return 1 if page is part of a guest's memory balloon, 0 otherwise */
> > +static inline int PageBalloon(struct page *page)
> > +{
> > +	return is_balloon_page(page);
> > +}
> 
> bool
> 
> Why is there both is_balloon_page and PageBalloon? 
> 
> is_ballon_page is so simple it should just be a static inline here
> 
> extern struct address_space *balloon_mapping;
> static inline bool is_balloon_page(page)
> {
> 	return page->mapping == balloon_mapping;
> }
> 	
I was thinking about sustain the same syntax other page tests utilize,
but I rather stick to your suggestion on this one.

 
> >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > @@ -312,6 +313,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >  			continue;
> >  		}
> >  
> > +		/*
> > +		 * For ballooned pages, we need to isolate them before testing
> > +		 * for PageLRU, as well as skip the LRU page isolation steps.
> > +		 */
> 
> This says what, but not why.
> 
> I didn't check the exact mechanics of a balloon page but I expect it's that
> balloon pages are not on the LRU. If they are on the LRU, that's pretty dumb.
> 
> 
> /*
>  * Balloon pages can be migrated but are not on the LRU. Isolate
>  * them before LRU checks.
>  */
> 
> 
> It would be nicer to do this without gotos
> 
> /*
>  * It is possible to migrate LRU pages and balloon pages. Skip
>  * any other type of page
>  */
> if (is_balloon_page(page)) {
> 	if (!isolate_balloon_page(page))
> 		continue;
> } else if (PageLRU(page)) {
> 	....
> }
> 
> You will need to shuffle things around a little to make it work properly
> but if we handle other page types in the future it will be neater
> overall.
>
I'm glad you've put things this way on this one. Despite I was thinking on doing it
the way you suggested, I took the goto approach because I was afraid of doing
otherwise could be considered as an unnecessary radical surgery on established code.
Will do it, certainly.

 	
> > +struct address_space *balloon_mapping;
> > +EXPORT_SYMBOL(balloon_mapping);
> > +
> 
> EXPORT_SYMBOL_GPL?
> 
> I don't mind how it is exported as such. I'm idly curious if there are
> external closed modules that use the driver.
> 
To be honest with you, that was picked with no particular case in mind. And, since
you've raised this question, I'm also curious. However, after giving a thought
on your feedback, I believe EXPORT_SYMBOL_GPL suits far better.


> > +/* ballooned page id check */
> > +int is_balloon_page(struct page *page)
> > +{
> > +	struct address_space *mapping = page->mapping;
> > +	if (mapping == balloon_mapping)
> > +		return 1;
> > +	return 0;
> > +}
> > +
> > +/* __isolate_lru_page() counterpart for a ballooned page */
> > +int isolate_balloon_page(struct page *page)
> > +{
> > +	struct address_space *mapping = page->mapping;
> 
> This is a publicly visible function and while your current usage looks
> correct it would not hurt to do something like this;
> 
> if (WARN_ON(!is_page_ballon(page))
> 	return 0;
>
Excellent point!
 

> > +	if (mapping->a_ops->invalidatepage) {
> > +		/*
> > +		 * We can race against move_to_new_page() and stumble across a
> > +		 * locked 'newpage'. If we succeed on isolating it, the result
> > +		 * tends to be disastrous. So, we sanely skip PageLocked here.
> > +		 */
> > +		if (likely(!PageLocked(page) && get_page_unless_zero(page))) {
> 
> But the page can get locked after this point.
> 
> Would it not be better to do a trylock_page() and unlock the page on
> exit after the isolation completes?
> 
Far better, for sure! thanks (again)


> > @@ -78,7 +78,10 @@ void putback_lru_pages(struct list_head *l)
> >  		list_del(&page->lru);
> >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> >  				page_is_file_cache(page));
> > -		putback_lru_page(page);
> > +		if (unlikely(PageBalloon(page)))
> > +			VM_BUG_ON(!putback_balloon_page(page));
> 
> Why not BUG_ON?
> 
> What shocked me actually is that VM_BUG_ON code is executed on
> !CONFIG_DEBUG_VM builds and has been since 2.6.36 due to commit [4e60c86bd:
> gcc-4.6: mm: fix unused but set warnings]. I thought the whole point of
> VM_BUG_ON was to avoid expensive and usually unnecessary checks. Andi,
> was this deliberate?
> 
> Either way, you always want to call putback_ballon_page() so BUG_ON is
> more appropriate although gracefully recovering from the situation and a
> WARN would be better.
> 
Shame on me!
 I was lazy enough to not carefully read VM_BUG_ON's definition and get its
original purpose. Will change it, for sure.


Once more, thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
