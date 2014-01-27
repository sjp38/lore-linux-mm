Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 52A716B0036
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:29:44 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so5139057pdj.18
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 18:29:43 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qx4si9348914pbc.345.2014.01.26.18.29.41
        for <linux-mm@kvack.org>;
        Sun, 26 Jan 2014 18:29:42 -0800 (PST)
Date: Mon, 27 Jan 2014 11:31:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140127023112.GF14369@bbox>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140113073947.GR1992@bbox>
 <20140122184217.GD4407@cmpxchg.org>
 <20140123052014.GC28732@bbox>
 <20140123192212.GW6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123192212.GW6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jan 23, 2014 at 02:22:12PM -0500, Johannes Weiner wrote:
> On Thu, Jan 23, 2014 at 02:20:14PM +0900, Minchan Kim wrote:
> > On Wed, Jan 22, 2014 at 01:42:17PM -0500, Johannes Weiner wrote:
> > > On Mon, Jan 13, 2014 at 04:39:47PM +0900, Minchan Kim wrote:
> > > > On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > > > > @@ -123,9 +129,39 @@ static void page_cache_tree_delete(struct address_space *mapping,
> > > > >  		 * same time and miss a shadow entry.
> > > > >  		 */
> > > > >  		smp_wmb();
> > > > > -	} else
> > > > > -		radix_tree_delete(&mapping->page_tree, page->index);
> > > > > +	}
> > > > >  	mapping->nrpages--;
> > > > > +
> > > > > +	if (!node) {
> > > > > +		/* Clear direct pointer tags in root node */
> > > > > +		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> > > > > +		radix_tree_replace_slot(slot, shadow);
> > > > > +		return;
> > > > > +	}
> > > > > +
> > > > > +	/* Clear tree tags for the removed page */
> > > > > +	index = page->index;
> > > > > +	offset = index & RADIX_TREE_MAP_MASK;
> > > > > +	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> > > > > +		if (test_bit(offset, node->tags[tag]))
> > > > > +			radix_tree_tag_clear(&mapping->page_tree, index, tag);
> > > > > +	}
> > > > > +
> > > > > +	/* Delete page, swap shadow entry */
> > > > > +	radix_tree_replace_slot(slot, shadow);
> > > > > +	node->count--;
> > > > > +	if (shadow)
> > > > > +		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> > > > 
> > > > Nitpick2:
> > > > It should be a function of workingset.c rather than exposing
> > > > RADIX_TREE_COUNT_SHIFT?
> > > > 
> > > > IMO, It would be better to provide some accessor functions here, too.
> > > 
> > > The shadow maintenance and node lifetime management are pretty
> > > interwoven to share branches and reduce instructions as these are
> > > common paths.  I don't see how this could result in cleaner code while
> > > keeping these advantages.
> > 
> > What I want is just put a inline accessor in somewhere like workingset.h
> > 
> > static inline void inc_shadow_entry(struct radix_tree_node *node)
> > {
> >     node->count += 1U << RADIX_TREE_COUNT_MASK;
> > }
> > 
> > So, anyone don't need to know that node->count upper bits present
> > count of shadow entry.
> 
> Okay, but then you have to cover lower bits as well, without explicit
> higher bit access it would be confusing to use the mask for lower
> bits.
> 
> Something like the following?

LGTM.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
