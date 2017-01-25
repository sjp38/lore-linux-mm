Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E27CB6B0272
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:15:37 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so40787261wme.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:15:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si5649139wru.73.2017.01.25.13.15.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 13:15:36 -0800 (PST)
Subject: Re: [ATTEND] many topics
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
 <20170125203617.GB970@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2b4a19de-3878-3d76-a04e-5ab7f920432a@suse.cz>
Date: Wed, 25 Jan 2017 22:15:33 +0100
MIME-Version: 1.0
In-Reply-To: <20170125203617.GB970@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: NeilBrown <neilb@suse.com>, Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 01/25/2017 09:36 PM, Matthew Wilcox wrote:
> On Wed, Jan 25, 2017 at 03:36:15PM +0100, Vlastimil Babka wrote:
>> On 01/23/2017 08:34 PM, NeilBrown wrote:
>> > Because "TEMPORARY" implies a limit to the amount of time, and sleeping
>> > is the thing that causes a process to take a large amount of time.  It
>> > seems like an obvious connection to me.
>>
>> There's no simple connection to time, it depends on the larger picture -
>> what's the state of the allocator and what other allocations/free's are
>> happening around this one. Perhaps let me try to explain what the flag does
>> and what benefits are expected.
>
> The explanations of what GFP_TEMPORARY /does/ keep getting better and
> better.  And thank you for that, it really is interesting.  But what
> we're asking for is guidelines for the user of this interface; what is
> the contract between the caller and the MM system?
>
> So far, I think we've answered a few questions:
>
>  - Using GFP_TEMPORARY in calls to kmalloc() is not currently supported
>    because slab will happily allocate non-TEMPORARY allocations from the
>    same page.

Sounds right, AFAIK there's no smarts in slab about this.

>  - GFP_TEMPORARY allocations may be held on to for a considerable length
>    of time; certainly seconds and maybe minutes.

I'd agree.

>  - The advantage of marking one's allocation as TEMPORARY is twofold:
>    - This allocation is more likely to succeed due to being allowed to
>      access more memory.

There's no such provision in the current implementation.

>    - Other higher-order allocations are more likely to succeed due to
>      the segregation of short and long lived allocations from each other.

Right.

> I'd like to see us add a tmalloc() / tmalloc_atomic() / tfree() API
> for allocating temporary memory, then hook that up to SLAB as a way to
> allocate small amounts of memory (... although maybe we shouldn't try
> too hard to allocate multiple objects from a single page if they're all
> temporary ...)

Before doing things like that, we should evaluate whether the benefits are 
really worth it. I only know how the mobility grouping and related heuristics 
work, but haven't measured or seen some results wrt GFP_TEMPORARY. Also are 
there some large potential users you have in mind? If there's always some 
constant small amount of temporary allocations in the system, then the benefits 
should be rather small as that amount will be effectively non-defragmentable in 
any given point of time. I would expect the most benefit when there are some 
less frequent but large bursts of temporary allocations concurrently with 
long-term unmovable allocations that will result in permanently polluting new 
pageblocks.

> In any case, we need to ensure that GFP_TEMPORARY is not accepted by
> slab ... that's not as straightforward as adding __GFP_RECLAIMABLE to
> GFP_SLAB_BUG_MASK because SLAB_RECLAIMABLE slabs will reasonable add
> __GFP_RECLAIMABLE before the check.  So a good place to check it is ...
> kmalloc_slab()?  That hits all three slab allocators.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
