Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F39B16B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:08:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so37531769wme.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:08:19 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s76si13784826wmb.46.2016.10.24.12.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 12:08:18 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id d199so11220351wmd.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:08:18 -0700 (PDT)
Date: Mon, 24 Oct 2016 21:08:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Stable 4.4 - NEEDS REVIEW - 2/3] mm: filemap: don't plant
 shadow entries without radix tree node
Message-ID: <20161024190816.GE13148@dhcp22.suse.cz>
References: <20161024152605.11707-1-mhocko@kernel.org>
 <20161024152605.11707-3-mhocko@kernel.org>
 <20161024185600.GB28326@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024185600.GB28326@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>

On Mon 24-10-16 14:56:00, Johannes Weiner wrote:
> Hi Michal,
> 
> On Mon, Oct 24, 2016 at 05:26:04PM +0200, Michal Hocko wrote:
> > @@ -155,44 +155,27 @@ static void page_cache_tree_delete(struct address_space *mapping,
> >  				   struct page *page, void *shadow)
> >  {
> >  	struct radix_tree_node *node;
> > -	unsigned long index;
> > -	unsigned int offset;
> > -	unsigned int tag;
> >  	void **slot;
> >  
> >  	VM_BUG_ON(!PageLocked(page));
> >  
> >  	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
> >  
> > -	if (shadow) {
> > -		mapping->nrshadows++;
> > -		/*
> > -		 * Make sure the nrshadows update is committed before
> > -		 * the nrpages update so that final truncate racing
> > -		 * with reclaim does not see both counters 0 at the
> > -		 * same time and miss a shadow entry.
> > -		 */
> > -		smp_wmb();
> > -	}
> > -	mapping->nrpages--;
> > +	radix_tree_clear_tags(&mapping->page_tree, node, slot);
> >  
> >  	if (!node) {
> > -		/* Clear direct pointer tags in root node */
> > -		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> > -		radix_tree_replace_slot(slot, shadow);
> > -		return;
> > -	}
> 
> There is no need to include the refactoring of the tag clearing in the
> stable backport. I already sent a simpler backport of this patch for
> 4.4 to Greg, attached here for reference:

I do not see this in 4.4 so maybe it's fallen through cracks. Yours
definitely looks easier and I will use it. I will post all 4 patches for
inclusion for stable tomorrow unless something else pops out.

Thanks for the review again!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
