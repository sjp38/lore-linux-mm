Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D04DC6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:53:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so3299968wmd.17
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:53:08 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id b13si2800562edi.30.2017.10.12.07.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 07:53:07 -0700 (PDT)
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com [46.22.139.231])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 1F0BD1C209E
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:53:07 +0100 (IST)
Received: from mail.blacknight.com (unknown [81.17.254.26])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id 0C2981C2099
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:53:07 +0100 (IST)
Date: Thu, 12 Oct 2017 15:53:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/8] mm, truncate: Remove all exceptional entries from
 pagevec under one lock
Message-ID: <20171012145306.2lepcjtpdxshua6j@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
 <20171012093103.13412-4-mgorman@techsingularity.net>
 <20171012133323.GB29293@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171012133323.GB29293@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 12, 2017 at 03:33:23PM +0200, Jan Kara wrote:
> >  		return;
> >  
> > -	if (dax_mapping(mapping)) {
> > -		dax_delete_mapping_entry(mapping, index);
> > -		return;
> > +	dax = dax_mapping(mapping);
> > +	if (!dax)
> > +		spin_lock_irq(&mapping->tree_lock);
> > +
> > +	for (i = ei, j = ei; i < pagevec_count(pvec); i++) {
> > +		struct page *page = pvec->pages[i];
> > +		pgoff_t index = indices[i];
> > +
> > +		if (!radix_tree_exceptional_entry(page)) {
> > +			pvec->pages[j++] = page;
> > +			continue;
> > +		}
> > +
> > +		if (unlikely(dax)) {
> > +			dax_delete_mapping_entry(mapping, index);
> > +			continue;
> > +		}
> > +
> > +		__clear_shadow_entry(mapping, index, page);
> >  	}
> > -	clear_shadow_entry(mapping, index, entry);
> > +
> > +	if (!dax)
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +	pvec->nr = j;
> >  }
> 
> When I look at this I think could make things cleaner. I have the following
> observations:
> 
> 1) All truncate_inode_pages(), invalidate_mapping_pages(),
> invalidate_inode_pages2_range() essentially do very similar thing and would
> benefit from a similar kind of batching.
> 

While this is true, the benefit is much more marginal that I didn't feel
the level of churn was justified. Primarily it would help fadvise() and
invalidating when buffered and direct IO is mixed. I didn't think it would
be that much cleaner as a result so I left it.

> 2) As you observed and measured, batching of radix tree operations makes
> sense both when removing pages and shadow entries, I'm very confident it
> would make sense for DAX exceptional entries as well.
> 

True, but I didn't have a suitable setup for testing DAX so I wasn't
comfortable with making the change. dax_delete_mapping_entry can sleep but it
should be as simple as not taking the spinlock in dax_delete_mapping_entry
and always locking in truncate_exceptional_pvec_entries. dax is already
releasing the mapping->tree_lock if it needs to sleep and I didn't spot
any other gotcha but I'd prefer that change was done by someone that can
verify it works properly.

> 3) In all cases (i.e., those three functions and for all entry types) the
> workflow seems to be:
>   * lockless lookup of entries
>   * prepare entry for reclaim (or determine it is not elligible)
>   * lock mapping->tree_lock
>   * verify entry is still elligible for reclaim (otherwise bail)
>   * clear radix tree entry
>   * unlock mapping->tree_lock
>   * final cleanup of the entry
> 
> So I'm wondering whether we cannot somehow refactor stuff so that batching
> of radix tree operations could be shared and we wouldn't have to duplicate
> it in all those cases.
> 
> But it would be rather large overhaul of the code so it may be a bit out of
> scope for these improvements...
> 

I think it would be out of scope for this improvement but I can look into
it if the series is accepted. I think it would be a lot of churn for fairly
marginal benefit though.

> > @@ -409,8 +445,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
> >  			}
> >  
> >  			if (radix_tree_exceptional_entry(page)) {
> > -				truncate_exceptional_entry(mapping, index,
> > -							   page);
> > +				if (ei != PAGEVEC_SIZE)
> > +					ei = i;
> 
> This should be ei == PAGEVEC_SIZE I think.
> 
> Otherwise the patch looks good to me so feel free to add:
> 

Fixed.

> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
