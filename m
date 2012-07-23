Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 6603B6B0068
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:33:17 -0400 (EDT)
Date: Mon, 23 Jul 2012 11:33:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120723023332.GA6832@bbox>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718054824.GA32341@bbox>
 <20120720194858.GA16249@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720194858.GA16249@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Rafael Aquini <aquini@linux.com>

Hi Rafael,

On Fri, Jul 20, 2012 at 04:48:59PM -0300, Rafael Aquini wrote:
> Howdy Minchan,
> 
> Once again, thanks for raising such valuable feedback over here.
> 
> On Wed, Jul 18, 2012 at 02:48:24PM +0900, Minchan Kim wrote:
> > > +/* __isolate_lru_page() counterpart for a ballooned page */
> > > +static bool isolate_balloon_page(struct page *page)
> > > +{
> > > +	if (WARN_ON(!is_balloon_page(page)))
> > > +		return false;
> > 
> > I am not sure we need this because you alreay check it before calling
> > isolate_balloon_page. If you really need it, it would be better to
> > add likely in isolate_balloon_page, too.
> > 
> 
> This check point was set in place because isolate_balloon_page() was a publicly
> visible function and while our current usage looks correct it would not hurt to
> have something like that done -- think of it as an insurance policy, in case
> someone else, in the future, attempts to use it on any other place outside this
> specifc context. 
> Despite not seeing it as a dealbreaker for the patch as is, I do agree, however,
> this snippet can _potentially_ be removed from isolate_balloon_page(), since
> this function has become static to compaction.c.

Yes. It's not static.

> 
> 
> > > +
> > > +	if (likely(get_page_unless_zero(page))) {
> > > +		/*
> > > +		 * We can race against move_to_new_page() & __unmap_and_move().
> > > +		 * If we stumble across a locked balloon page and succeed on
> > > +		 * isolating it, the result tends to be disastrous.
> > > +		 */
> > > +		if (likely(trylock_page(page))) {
> > 
> > Hmm, I can't understand your comment.
> > What does this lock protect? Could you elaborate it with code sequence?
> > 
> 
> As we are coping with a corner case -- balloon pages are not on LRU lists --
> compaction concurrency can lead to a disastrous race which results in
> isolate_balloon_page() re-isolating already isolated balloon pages, or isolating
> a 'newpage' recently promoted to 'balloon page', while these pages are still
> under migration. The only way we have to prevent that from happening is
> attempting to grab the page lock, as pages under migration are already locked.
> I had that comment rephrased to what follows (please, tell me how it sounds to
> you now)
>   	if (likely(get_page_unless_zero(page))) {
>  		/*
> -		 * We can race against move_to_new_page() & __unmap_and_move().
> -		 * If we stumble across a locked balloon page and succeed on
> -		 * isolating it, the result tends to be disastrous.
> +		 * As balloon pages are not isolated from LRU lists, several
> +		 * concurrent compaction threads will potentially race against
> +		 * page migration at move_to_new_page() & __unmap_and_move().
> +		 * In order to avoid having an already isolated balloon page
> +		 * being (wrongly) re-isolated while it is under migration,
> +		 * lets be sure we have the page lock before proceeding with
> +		 * the balloon page isolation steps.

Looks good to me.

>  		 */
>  		if (likely(trylock_page(page))) {
>  			/*
> 
> 
> > > +/* putback_lru_page() counterpart for a ballooned page */
> > > +bool putback_balloon_page(struct page *page)
> > > +{
> > > +	if (WARN_ON(!is_balloon_page(page)))
> > > +		return false;
> > 
> > You already check WARN_ON in putback_lru_pages so we don't need it in here.
> > And you can add likely in here, too.
> >
> 
> This check point is in place by the same reason why it is for
> isolate_balloon_page(). However, I don't think we should drop it here because
> putback_balloon_page() is still a publicly visible symbol. Besides, the check
> that is performed at putback_lru_pages() level has a different meaning, which is
> to warn us when we fail on re-inserting an isolated (but not migrated) page back
> to the balloon page list, thus it does not superceeds nor it's superceeded by
> this checkpoint here.

I'm not against you strongly but IMHO, putback_balloon_page is never generic
function which is likely to be used by many others so I hope not overdesign.

> 
>  
> > > +		} else if (is_balloon_page(page)) {
> > 
> > unlikely?
> 
> This can be done, for sure. Also, it reminds me that I had a
> 'likely(PageLRU(page))' set in place for this vary same patch, on v2 submission.
> Do you recollect you've asked me to get rid of it?. Wouldn't it be better having
> that suggestion of yours reverted, since PageLRU(page) is the likelihood case
> here anyway? What about this?
> 
>    " if (likely(PageLRU(page))) { 
>        ... 
>      } else if (unlikely(is_balloon_page(page))) {
>        ...
>      } else
> 	continue;
>    "

I don't like that.
PageLRU isn't likelihood case in this.

> 
> > 
> > > @@ -78,7 +78,10 @@ void putback_lru_pages(struct list_head *l)
> > >  		list_del(&page->lru);
> > >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> > >  				page_is_file_cache(page));
> > > -		putback_lru_page(page);
> > > +		if (unlikely(is_balloon_page(page)))
> > > +			WARN_ON(!putback_balloon_page(page));
> > > +		else
> > > +			putback_lru_page(page);
> > 
> > Hmm, I don't like this.
> > The function name says we putback *lru* pages, but balloon page isn't.
> > How about this?
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index aad0a16..b07cd67 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -298,6 +298,8 @@ static bool too_many_isolated(struct zone *zone)
> >   * Apart from cc->migratepages and cc->nr_migratetypes this function
> >   * does not modify any cc's fields, in particular it does not modify
> >   * (or read for that matter) cc->migrate_pfn.
> > + * 
> > + * For returning page, you should use putback_pages instead of putback_lru_pages
> >   */
> >  unsigned long
> >  isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > @@ -827,7 +829,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  
> >                 /* Release LRU pages not migrated */
> >                 if (err) {
> > -                       putback_lru_pages(&cc->migratepages);
> > +                       putback_pages(&cc->migratepages);
> >                         cc->nr_migratepages = 0;
> >                         if (err == -ENOMEM) {
> >                                 ret = COMPACT_PARTIAL;
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 9705e70..a96b840 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -86,6 +86,22 @@ void putback_lru_pages(struct list_head *l)
> >         }
> >  }
> > 
> > + /* blah blah .... */ 
> > +void putback_pages(struct list_head *l)
> > +{
> > +       struct page *page;
> > +       struct page *page2;
> > +
> > +       list_for_each_entry_safe(page, page2, l, lru) {
> > +               list_del(&page->lru);
> > +               dec_zone_page_state(page, NR_ISOLATED_ANON +
> > +                               page_is_file_cache(page));
> > +               if (unlikely(is_balloon_page(page)))
> > +                       WARN_ON(!putback_balloon_page(page));
> > +               else
> > +                       putback_lru_page(page);
> > +       }
> > +}
> > +
> >  /*
> >   * Restore a potential migration pte to a working pte entry
> >   */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 32985dd..decb82a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5655,7 +5655,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
> >                                     0, false, MIGRATE_SYNC);
> >         }
> >  
> > -       putback_lru_pages(&cc.migratepages);
> > +       putback_pages(&cc.migratepages);
> >         return ret > 0 ? 0 : ret;
> >  }
> > 
> 
> Despite being a very nice cleanup, this code refactoring has nothing to do with
> this particular patch purpose. For the sake of this implementation, think about
> the balloon page list acting as a particular LRU, so although ballooned pages
> are not enlisted on real LRUs, per se, this doesn't mean we cannot have them
> dealt as a corner case amongst putback_lru_pages() code for the sake of
> simplicity and maintainability ease. OTOH, I do agree with your nice suggestion,
> thus I can submit it as a separate clean-up patch attached to this series (if
> you don't mind).

No problem. But the concern is that I can't agree this patch implementation.
Please see below.

> 
> 
> > >  
> > > +	if (is_balloon_page(page)) {
> > 
> > unlikely?
> >
> 
> Yeah, why not? Will do it.
>  
> > > +	if (is_balloon_page(newpage)) {
> > 
> > unlikely?
> > 
> 
> ditto.
> 
> > > +		/*
> > > +		 * A ballooned page has been migrated already. Now, it is the
> > > +		 * time to wrap-up counters, handle the old page back to Buddy
> > > +		 * and return.
> > > +		 */
> > > +		list_del(&page->lru);
> > > +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> > > +				    page_is_file_cache(page));
> > > +		put_page(page);
> > > +		__free_page(page);
> > 
> > Why do you use __free_page instead of put_page?
> > 
> 
> Do you mean perform an extra put_page() and let putback_lru_page() do the rest?
> Besides looking odd at code level, what other improvement we can potentially gain here?

I mean just do
put_page(page); /* blah blah */
put_page(page); /* It will free the page to buddy */

Yeb it's more fat than __free_page for your case. If so, please comment write out
why you use __free_page instead of put_page.

/*
 * balloon page should be never compund page and not on the LRU so we
 * call __free_page directly instead of put_page.
 */

> 
> 
> > The feeling I look at your code in detail is that it makes compaction/migration
> > code rather complicated because compaction/migration assumes source/target would
> > be LRU pages. 
> > 
> > How often memory ballooning happens? Does it make sense to hook it in generic
> > functions if it's very rare?
> > 
> > Couldn't you implement it like huge page?
> > It doesn't make current code complicated and doesn't affect performance
> > 
> > In compaction,
> > #ifdef CONFIG_VIRTIO_BALLOON
> > static int compact_zone(struct zone *zone, struct compact_control *cc, bool balloon)
> > {
> >         if (balloon) {
> >                 isolate_balloonpages
> > 
> >                 migrate_balloon_pages
> >                         unmap_and_move_balloon_page
> > 
> >                 putback_balloonpages
> >         }
> > }
> > #endif
> > 
> > I'm not sure memory ballooning so it might be dumb question.
> > Can we trigger it once only when ballooning happens?
> 
> I strongly believe, this is the simplest and easiest way to get this task
> accomplished, mostly becasue:
>   i. It does not require any code duplication at all;
>  ii. It requires very few code insertion/surgery to be fully operative;
> iii. It is embeded on already well established and maintained code;
>  iv. The approach makes easier to other balloon drivers leverage compaction
> code;
>   v. It shows no significative impact to the entangled code paths;

But it is adding a few hooks to generic functions which all assume they
are LRU pages. Although it's trivial for performance, we don't need get
such loss due to very infrequent event.

More concern to me that it makes code complicated because we assume
functions related migration/compaction depend on LRU pages.
Let me say a example.
suitable_migration_target in isolate_freepages returns true pageblock
type is MIGRATE_MOVABLE or MIGRATE_CMA which expect pages in that block
is migratable so they should be moved into another location or reclaimed
if we have no space for getting big contiguos space.
All of such code should consider balloon page but balloon page can't be
reclaimed unlike normal LRU page so it makes design more complex.

Look at memory-hotplug, offline_page calls has_unmovable_pages, scan_lru_pages
and do_migrate_range which calls isolate_lru_page. They consider only LRU pages
to migratable ones.

IMHO, better approach is that after we can get complete free pageblocks
by compaction or reclaim, move balloon pages into that pageblocks and make
that blocks to unmovable. It can prevent fragmentation and it makes
current or future code don't need to consider balloon page.

Of course, it needs more code but I think it's valuable.
What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
