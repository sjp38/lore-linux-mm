Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A517E6B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:52:03 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so2222385pad.25
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 12:52:02 -0800 (PST)
Date: Fri, 8 Feb 2013 12:52:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 7/11] ksm: make KSM page migration possible
In-Reply-To: <20130205191102.GM21389@suse.de>
Message-ID: <alpine.LNX.2.00.1302081133540.4233@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251802050.29196@eggly.anvils> <20130205191102.GM21389@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Paul, I've added you to the Cc in the hope that you can shed your light
on an smp_read_barrier_depends() question with which Mel taxes me below.
You may ask for more context: linux-next currently has an mm/ksm.c after
this patch is applied, but you may have questions beyond that - thanks!

On Tue, 5 Feb 2013, Mel Gorman wrote:
> On Fri, Jan 25, 2013 at 06:03:31PM -0800, Hugh Dickins wrote:
> > KSM page migration is already supported in the case of memory hotremove,
> > which takes the ksm_thread_mutex across all its migrations to keep life
> > simple.
> > 
> > But the new KSM NUMA merge_across_nodes knob introduces a problem, when
> > it's set to non-default 0: if a KSM page is migrated to a different NUMA
> > node, how do we migrate its stable node to the right tree?  And what if
> > that collides with an existing stable node?
> > 
> > So far there's no provision for that, and this patch does not attempt
> > to deal with it either.  But how will I test a solution, when I don't
> > know how to hotremove memory? 
> 
> Just reach in and yank it straight out with a chisel.

:)

> 
> > The best answer is to enable KSM page
> > migration in all cases now, and test more common cases.  With THP and
> > compaction added since KSM came in, page migration is now mainstream,
> > and it's a shame that a KSM page can frustrate freeing a page block.
> > 
> 
> THP will at least check if migration within a node works. It won't
> necessarily check we can migrate across nodes properly but it's a lot
> better than nothing.

No, I went back and dug out a hack-patch I was using three or four years
ago: occasionally on fault, just migrate every possible page in that mm
for no reason other than to test page migration.

> >  static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
> >  {
> >  	struct page *page;
> >  	void *expected_mapping;
> > +	unsigned long kpfn;
> >  
> > -	page = pfn_to_page(stable_node->kpfn);
> >  	expected_mapping = (void *)stable_node +
> >  				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
> > -	if (page->mapping != expected_mapping)
> > -		goto stale;
> > -	if (!get_page_unless_zero(page))
> > +again:
> > +	kpfn = ACCESS_ONCE(stable_node->kpfn);
> > +	page = pfn_to_page(kpfn);
> > +
> 
> Ok.
> 
> There should be no concern that hot-remove made the kpfn invalid because
> those stable tree entries should have been discarded.

Yes.

> 
> > +	/*
> > +	 * page is computed from kpfn, so on most architectures reading
> > +	 * page->mapping is naturally ordered after reading node->kpfn,
> > +	 * but on Alpha we need to be more careful.
> > +	 */
> > +	smp_read_barrier_depends();
> 
> The value of page is data dependant on pfn_to_page(). Is it really possible
> for that to be re-ordered even on Alpha?

My intuition (to say "understanding" would be an exaggeration) is that
on Alpha a very old value of page->mapping (in the line below) might be
lying around and read from one cache, which has not necessarily been
invalidated by ksm_migrate_page() pointing stable_node->kpfn to this
new page.

And if that happens, we could easily and mistakenly conclude that this
stable node is stale: although there's an smp_rmb() after goto stale,
stable_node->kpfn would still match kpfn, and we wrongly remove the node.

My confidence that I've expressed that clearly in words, is lower than
my confidence that I've coded it right; and if I'm wrong, yes, surely
it's better to remove any cargo-cult smp_read_barrier_depends().

> 
> > +	if (ACCESS_ONCE(page->mapping) != expected_mapping)
> >  		goto stale;
> > -	if (page->mapping != expected_mapping) {
> > +
> > +	/*
> > +	 * We cannot do anything with the page while its refcount is 0.
> > +	 * Usually 0 means free, or tail of a higher-order page: in which
> > +	 * case this node is no longer referenced, and should be freed;
> > +	 * however, it might mean that the page is under page_freeze_refs().
> > +	 * The __remove_mapping() case is easy, again the node is now stale;
> > +	 * but if page is swapcache in migrate_page_move_mapping(), it might
> > +	 * still be our page, in which case it's essential to keep the node.
> > +	 */
> > +	while (!get_page_unless_zero(page)) {
> > +		/*
> > +		 * Another check for page->mapping != expected_mapping would
> > +		 * work here too.  We have chosen the !PageSwapCache test to
> > +		 * optimize the common case, when the page is or is about to
> > +		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
> > +		 * in the freeze_refs section of __remove_mapping(); but Anon
> > +		 * page->mapping reset to NULL later, in free_pages_prepare().
> > +		 */
> > +		if (!PageSwapCache(page))
> > +			goto stale;
> > +		cpu_relax();
> > +	}
> 
> The recheck of stable_node->kpfn check after a barrier distinguishes between
> a free and a completed migration, that's fine. I'm hesitate to ask because
> it must be obvious but where is the guarantee that a KSM page is in the
> swap cache?

Certainly none at all: it's the less common case that a KSM page is in
swap cache.  But if it is not in swap cache, how could its page count be
0 (causing get_page_unless_zero to fail)?  By being free, or well on its
way to being freed (hence stale); or reused as part of a compound page
(hence stale also); or reused for another purpose which arrives at a
page_freeze_refs() (hence stale also); other cases?

It's hard to see from the diff, but in the original version of
get_ksm_page(), !get_page_unless_zero goes straight to stale.

Don't for a moment imagine that this function sprang fully formed
from my mind: it was hard to get it working right (the swap cache
get_page_unless_zero failure during migration really caught me out),
and then to pare it down to its fairly simple final form.

Hugh

> 
> > +
> > +	if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> >  		put_page(page);
> >  		goto stale;
> >  	}
> > +
> >  	if (locked) {
> >  		lock_page(page);
> > -		if (page->mapping != expected_mapping) {
> > +		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> >  			unlock_page(page);
> >  			put_page(page);
> >  			goto stale;
> >  		}
> >  	}
> >  	return page;
> > +
> >  stale:
> > +	/*
> > +	 * We come here from above when page->mapping or !PageSwapCache
> > +	 * suggests that the node is stale; but it might be under migration.
> > +	 * We need smp_rmb(), matching the smp_wmb() in ksm_migrate_page(),
> > +	 * before checking whether node->kpfn has been changed.
> > +	 */
> > +	smp_rmb();
> > +	if (ACCESS_ONCE(stable_node->kpfn) != kpfn)
> > +		goto again;
> >  	remove_node_from_stable_tree(stable_node);
> >  	return NULL;
> >  }
> > @@ -1903,6 +1947,14 @@ void ksm_migrate_page(struct page *newpa
> >  	if (stable_node) {
> >  		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
> >  		stable_node->kpfn = page_to_pfn(newpage);
> > +		/*
> > +		 * newpage->mapping was set in advance; now we need smp_wmb()
> > +		 * to make sure that the new stable_node->kpfn is visible
> > +		 * to get_ksm_page() before it can see that oldpage->mapping
> > +		 * has gone stale (or that PageSwapCache has been cleared).
> > +		 */
> > +		smp_wmb();
> > +		set_page_stable_node(oldpage, NULL);
> >  	}
> >  }
> >  #endif /* CONFIG_MIGRATION */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
