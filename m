Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 460016B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:48:11 -0400 (EDT)
Date: Thu, 22 Aug 2013 10:45:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 8/9] mm: thrash detection-based file cache sizing
Message-ID: <20130822084559.GB26749@cmpxchg.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
 <1376767883-4411-9-git-send-email-hannes@cmpxchg.org>
 <20130820135920.b8b7ea0eb2471dfa0034b175@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130820135920.b8b7ea0eb2471dfa0034b175@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 20, 2013 at 01:59:20PM -0700, Andrew Morton wrote:
> On Sat, 17 Aug 2013 15:31:22 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > The VM maintains cached filesystem pages on two types of lists.  One
> > list holds the pages recently faulted into the cache, the other list
> > holds pages that have been referenced repeatedly on that first list.
> > The idea is to prefer reclaiming young pages over those that have
> > shown to benefit from caching in the past.  We call the recently used
> > list "inactive list" and the frequently used list "active list".
> > 
> > The tricky part of this model is finding the right balance between
> > them.  A big inactive list may not leave enough room for the active
> > list to protect all the frequently used pages.  A big active list may
> > not leave enough room for the inactive list for a new set of
> > frequently used pages, "working set", to establish itself because the
> > young pages get pushed out of memory before having a chance to get
> > promoted.
> > 
> > Historically, every reclaim scan of the inactive list also took a
> > smaller number of pages from the tail of the active list and moved
> > them to the head of the inactive list.  This model gave established
> > working sets more gracetime in the face of temporary use once streams,
> > but was not satisfactory when use once streaming persisted over longer
> > periods of time and the established working set was temporarily
> > suspended, like a nightly backup evicting all the interactive user
> > program data.
> > 
> > Subsequently, the rules were changed to only age active pages when
> > they exceeded the amount of inactive pages, i.e. leave the working set
> > alone as long as the other half of memory is easy to reclaim use once
> > pages.  This works well until working set transitions exceed the size
> > of half of memory and the average access distance between the pages of
> > the new working set is bigger than the inactive list.  The VM will
> > mistake the thrashing new working set for use once streaming, while
> > the unused old working set pages are stuck on the active list.
> > 
> > This patch solves this problem by maintaining a history of recently
> > evicted file pages, which in turn allows the VM to tell used-once page
> > streams from thrashing file cache.
> > 
> > To accomplish this, a per-zone counter is increased every time a page
> > is evicted and a snapshot of that counter is stored as shadow entry in
> > the page's now empty page cache radix tree slot.  Upon refault of that
> > page, the difference between the current value of that counter and the
> > shadow entry value is called the refault distance.  It tells how many
> > pages have been evicted from the zone since that page's eviction,
> > which is how many page slots at most are missing from the zone's
> > inactive list for this page to get accessed twice while in memory.  If
> > the number of missing slots is less than or equal to the number of
> > active pages, increasing the inactive list at the cost of the active
> > list would give this thrashing set a chance to establish itself:
> > 
> > eviction counter = 4
> >                         evicted      inactive           active
> >  Page cache data:       [ a b c d ]  [ e f g h i j k ]  [ l m n ]
> >   Shadow entries:         0 1 2 3
> > Refault distance:         4 3 2 1
> > 
> > When c is faulted back into memory, it is noted that at most two more
> > page slots on the inactive list could have prevented the refault (it
> > could be less if c is used out of order).  Thus, the active list needs
> > to be challenged as it is possible that c is used more frequently than
> > l, m, n.  However, there is no access frequency information available
> > on active pages so the pages have to be put in direct competition with
> > each other before deciding which one to keep.  Thus, 1) pages can not
> > be directly reclaimed from the tail of the active list and b)
> > refaulting pages can not be directly activated.  Instead, active pages
> > are moved from the tail of the active list to the head of the inactive
> > list and placed directly next to the refaulting pages.  This way, they
> > both have the same time on the inactive list to prove which page is
> > actually used more frequently without incurring unnecessary major
> > faults or diluting the active page set in case the previously active
> > page is in fact the more frequently used one.
> > 
> > Also, since the refault of c could have been due to a spurious access,
> > only one active page per qualifying refault is challenged.  This will
> > keep the impact of outliers low but still detect if bigger groups of
> > pages are refaulting.
> > 
> > ...
> >
> > +/*
> > + *		Double CLOCK lists
> > + *
> > + * Per zone, two clock lists are maintained for file pages: the
> > + * inactive and the active list.  Freshly faulted pages start out at
> > + * the head of the inactive list and page reclaim scans pages from the
> > + * tail.  Pages that are accessed multiple times on the inactive list
> > + * are promoted to the active list, to protect them from reclaim,
> > + * whereas active pages are demoted to the inactive list when the
> > + * inactive list requires more space to detect repeatedly accessed
> > + * pages in the current workload and prevent them from thrashing:
> > + *
> > + *   fault -----------------------+
> > + *                                |
> > + *              +-------------+   |            +-------------+
> > + *   reclaim <- | inactive    | <-+-- demotion | active      | <--+
> > + *              +-------------+                +-------------+    |
> > + *                       |                                        |
> > + *                       +----------- promotion ------------------+
> > + *
> > + *
> > + *		Access frequency and refault distance
> > + *
> > + * A workload is thrashing when the distances between the first and
> > + * second access of pages that are frequently used is bigger than the
> > + * current inactive clock list size, as the pages get reclaimed before
> > + * the second access would have promoted them instead:
> > + *
> > + *    Access #: 1 2 3 4 5 6 7 8 9
> > + *     Page ID: x y b c d e f x y
> > + *                  | inactive  |
> > + *
> > + * To prevent this workload from thrashing, a bigger inactive list is
> > + * required.  And the only way the inactive list can grow on a full
> > + * zone is by taking away space from the corresponding active list.
> > + *
> > + *      +-inactive--+-active------+
> > + *  x y | b c d e f | G H I J K L |
> > + *      +-----------+-------------+
> > + *
> > + * Not every refault should lead to growing the inactive list at the
> > + * cost of the active list, however: if the access distances are
> > + * bigger than available memory overall, there is little point in
> > + * challenging the protected pages on the active list, as those
> > + * refaulting pages will not fit completely into memory.
> > + *
> > + * It is prohibitively expensive to track the access frequency of
> > + * in-core pages, but it is possible to track their refault distance,
> > + * which is the number of page slots shrunk from the inactive list
> > + * between a page's eviction and subsequent refault.  This indicates
> > + * how many page slots are missing on the inactive list in order to
> > + * prevent future thrashing of that page.  Thus, instead of comparing
> > + * access frequency to total available memory, one can compare the
> > + * refault distance to the inactive list's potential for growth: the
> > + * size of the active list.
> > + *
> > + *
> > + *		Rebalancing the lists
> > + *
> > + * Shrinking the active list has to be done carefully because the
> > + * pages on it may have vastly different access frequencies compared
> > + * to the pages on the inactive list.  Thus, pages are not reclaimed
> > + * directly from the tail of the active list, but instead moved to the
> > + * head of the inactive list.  This way, they are competing directly
> > + * with the pages that challenged their protected status.  If they are
> > + * unused, they will eventually be reclaimed, but if they are indeed
> > + * used more frequently than the challenging inactive pages, they will
> > + * be reactivated.  This allows the existing protected set to be
> > + * challenged without incurring major faults in case of a mistake.
> > + */
> 
> The consequences of a 32-bit wraparound of the refault distance still
> concern me.  It's a rare occurrence and it is difficult to determine
> what will happen.  An explicit design-level description here would be
> useful.

I replied to a previous question about the wraparound issue, was that
useful at all?  Quote:

"The distance between two time stamps is an unsigned subtraction, so
 it's accurate even when the counter has wrapped between them.

 The per-zone counter lapping shadow entries is possible but not very
 likely because the shadow pages are reclaimed when more than
 2*global_dirtyable_memory() of them exist.  And usually they are
 refaulted or reclaimed along with the inode before that happens.

 There is an unlikely case where some shadow entries make it into an
 inode and then that same inode is evicting and refaulting pages in
 another area, which increases the counter while not producing an
 excess of shadow entries.  Should the counter lap these inactive
 shadow entries, the worst case is that a refault will incorrectly
 interpret them as recently evicted and deactivate a page for every
 such entry.  Which would at worst be a "regression" to how the code
 was for a long time, where every reclaim run also always deactivated
 some pages."

I'll expand the documentation on this either way, I just want to gauge
if this addresses your concerns.

> > +static void *pack_shadow(unsigned long time, struct zone *zone)
> > +{
> > +	time = (time << NODES_SHIFT) | zone_to_nid(zone);
> > +	time = (time << ZONES_SHIFT) | zone_idx(zone);
> > +	time = (time << RADIX_TREE_EXCEPTIONAL_SHIFT);
> > +
> > +	return (void *)(time | RADIX_TREE_EXCEPTIONAL_ENTRY);
> > +}
> 
> "time" is normally in jiffies ;)
> 
> Some description of the underlying units of workingset_time would be
> helpful.

Humm, yes, "time" might be misleading.

The unit is pages and the clock is advanced every time the inactive
list shrinks (eviction or activation).

The refault distance (a delta of workingset time) describes the
inactive list space deficit, which increases as the inactive list
shrinks.

I'll try to expand on this better in the documentation.

> > +/**
> > + * workingset_eviction - note the eviction of a page from memory
> > + * @mapping: address space the page was backing
> > + * @page: the page being evicted
> > + *
> > + * Returns a shadow entry to be stored in @mapping->page_tree in place
> > + * of the evicted @page so that a later refault can be detected.  Or
> > + * %NULL when the eviction should not be remembered.
> > + */
> 
> Describe the locking requirements here.  It's part of the interface. 
> And it's the part the compiler can't check, so extra care is needed.
> 
> > +void *workingset_eviction(struct address_space *mapping, struct page *page)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +	unsigned long time;
> > +
> > +	time = atomic_long_inc_return(&zone->workingset_time);
> > +
> > +	/*
> > +	 * Don't store shadows in an inode that is being reclaimed.
> > +	 * This is not just an optizimation, inode reclaim needs to
> > +	 * empty out the radix tree or the nodes are lost, so don't
> > +	 * plant shadows behind its back.
> > +	 */
> > +	if (mapping_exiting(mapping))
> > +		return NULL;

This needs to be ordered against inode eviction such that reclaim
never sneaks a shadow entry into the tree after eviction does the
final truncate.

  mapping_set_exiting(mapping)
  truncate_inode_pages(mapping)

  vs.

  mapping_exiting(mapping)
  page_cache_insert(mapping, shadow)

You already mentioned that the tree lock around mapping_set_exiting()
might be pointless.

I'll give this another pass when I'm less jetlagged and then either
document the locking requirements (tree lock) or remove it entirely.

> > +
> > +	return pack_shadow(time, zone);
> > +}
> > +
> > +/**
> > + * workingset_refault - note the refault of a previously evicted page
> > + * @shadow: shadow entry of the evicted page
> > + *
> > + * Calculates and evaluates the refault distance of the previously
> > + * evicted page in the context of the zone it was allocated in.
> > + *
> > + * This primes page reclaim to rebalance the zone's file lists if
> > + * necessary, so it must be called before a page frame for the
> > + * refaulting page is allocated.
> > + */
> > +void workingset_refault(void *shadow)
> > +{
> > +	unsigned long refault_distance;
> 
> Is the "refault distance" described somewhere?  What relationship (if
> any) does it have with workingset_time?

Ok, I definitely need to extend the documentation on this ;)

It says

"[...] it is possible to track their refault distance, which is the
 number of page slots shrunk from the inactive list between a page's
 eviction and subsequent refault."

So we take a snapshot of the workingset time on eviction.  The clock
advances as the inactive list shrinks.  On refault of a page, the
delta between its eviction timestamp and the current time is the
refault distance.  It describes the deficit in page slots available to
the inactive list that lead to the page being evicted between
accesses.

If the deficit is smaller than the active list, it can be closed by
stealing slots from there and giving them to the inactive list.

> > +	struct zone *zone;
> > +
> > +	unpack_shadow(shadow, &zone, &refault_distance);
> > +
> > +	inc_zone_state(zone, WORKINGSET_REFAULT);
> > +
> > +	/*
> > +	 * Protected pages should be challenged when the refault
> > +	 * distance indicates that thrashing could be stopped by
> > +	 * increasing the inactive list at the cost of the active
> > +	 * list.
> > +	 */
> > +	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
> > +		inc_zone_state(zone, WORKINGSET_STALE);
> > +		zone->shrink_active++;
> > +	}
> > +}
> > +EXPORT_SYMBOL(workingset_refault);
> > +
> > +/**
> > + * workingset_activation - note a page activation
> > + * @page: page that is being activated
> > + */
> > +void workingset_activation(struct page *page)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +
> > +	/*
> > +	 * The lists are rebalanced when the inactive list is observed
> > +	 * to be too small for activations.  An activation means that
> > +	 * the inactive list is now big enough again for at least one
> > +	 * page, so back off further deactivation.
> > +	 */
> > +	atomic_long_inc(&zone->workingset_time);
> > +	if (zone->shrink_active > 0)
> > +		zone->shrink_active--;
> > +}
> 
> Strange mixture of exports and non-exports.  I assume you went with
> "enough to make it build".

All these callbacks should be internal to the core VM but
page_cache_alloc(), which calls workingset_refault(), can be an inline
function used by modular filesystem code.

I should probably just make it a real function and remove the export.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
