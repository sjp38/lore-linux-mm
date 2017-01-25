Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 073666B025E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:36:24 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k15so193850706qtg.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:36:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g57si16389146qta.157.2017.01.25.12.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 12:36:23 -0800 (PST)
Date: Wed, 25 Jan 2017 12:36:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170125203617.GB970@bombadil.infradead.org>
References: <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
 <20170121131644.zupuk44p5jyzu5c5@thunk.org>
 <87ziijem9e.fsf@notabene.neil.brown.name>
 <20170123060544.GA12833@bombadil.infradead.org>
 <20170123170924.ubx2honzxe7g34on@thunk.org>
 <87mvehd0ze.fsf@notabene.neil.brown.name>
 <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: NeilBrown <neilb@suse.com>, Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 25, 2017 at 03:36:15PM +0100, Vlastimil Babka wrote:
> On 01/23/2017 08:34 PM, NeilBrown wrote:
> > Because "TEMPORARY" implies a limit to the amount of time, and sleeping
> > is the thing that causes a process to take a large amount of time.  It
> > seems like an obvious connection to me.
> 
> There's no simple connection to time, it depends on the larger picture -
> what's the state of the allocator and what other allocations/free's are
> happening around this one. Perhaps let me try to explain what the flag does
> and what benefits are expected.

The explanations of what GFP_TEMPORARY /does/ keep getting better and
better.  And thank you for that, it really is interesting.  But what
we're asking for is guidelines for the user of this interface; what is
the contract between the caller and the MM system?

So far, I think we've answered a few questions:

 - Using GFP_TEMPORARY in calls to kmalloc() is not currently supported
   because slab will happily allocate non-TEMPORARY allocations from the
   same page.
 - GFP_TEMPORARY allocations may be held on to for a considerable length
   of time; certainly seconds and maybe minutes.
 - The advantage of marking one's allocation as TEMPORARY is twofold:
   - This allocation is more likely to succeed due to being allowed to
     access more memory.
   - Other higher-order allocations are more likely to succeed due to
     the segregation of short and long lived allocations from each other.

I'd like to see us add a tmalloc() / tmalloc_atomic() / tfree() API
for allocating temporary memory, then hook that up to SLAB as a way to
allocate small amounts of memory (... although maybe we shouldn't try
too hard to allocate multiple objects from a single page if they're all
temporary ...)

In any case, we need to ensure that GFP_TEMPORARY is not accepted by
slab ... that's not as straightforward as adding __GFP_RECLAIMABLE to
GFP_SLAB_BUG_MASK because SLAB_RECLAIMABLE slabs will reasonable add
__GFP_RECLAIMABLE before the check.  So a good place to check it is ...
kmalloc_slab()?  That hits all three slab allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
