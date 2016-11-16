Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7BF36B0329
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 00:13:04 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so15462921wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 21:13:04 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id e8si31564586wjh.217.2016.11.15.21.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 21:13:03 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id g23so7186989wme.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 21:13:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611151438090.1910@eggly.anvils>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <1478271776-1194-2-git-send-email-akash.goel@intel.com> <alpine.LSU.2.11.1611092137360.6221@eggly.anvils>
 <5ff5aabf-2efe-7ee3-aab7-6c4b132c523d@intel.com> <CAK_0AV0+1oizfRMfoJ45FWCRi_4X93W-ZtseY-s-R_wavE3fZQ@mail.gmail.com>
 <alpine.LSU.2.11.1611151438090.1910@eggly.anvils>
From: akash goel <akash.goels@gmail.com>
Date: Wed, 16 Nov 2016 10:43:01 +0530
Message-ID: <CAK_0AV1n6+x3fj7UNPGYG+=eRwUp=SMXe91X5=aZ59tTuZraAw@mail.gmail.com>
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Sourab Gupta <sourab.gupta@intel.com>, akash goel <akash.goels@gmail.com>

On Wed, Nov 16, 2016 at 6:55 AM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 14 Nov 2016, akash goel wrote:
>> On Thu, Nov 10, 2016 at 1:00 PM, Goel, Akash <akash.goel@intel.com> wrote:
>> > On 11/10/2016 12:09 PM, Hugh Dickins wrote:
>> >> On Fri, 4 Nov 2016, akash.goel@intel.com wrote:
>> >>> @@ -4185,6 +4189,8 @@ struct drm_i915_gem_object *
>> >>>
>> >>>         mask = GFP_HIGHUSER | __GFP_RECLAIMABLE;
>> >>> +       if (IS_ENABLED(MIGRATION))
>
> Oh, I knew I'd seen a line like that recently, and it was bugging me
> that I ought to search my mailboxes for it; but now I'm glad to find
> it again.  If that condition stays, it would really need to say
>               if (IS_ENABLED(CONFIG_MIGRATION))
> wouldn't it?
>
Sorry this was a blooper, should have been
             if (IS_ENABLED(CONFIG_MIGRATION))

>> >>> +               mask |= __GFP_MOVABLE;
>> >>
>> >>
>> >> I was going to suggest just make that unconditional,
>> >>         mask = GFP_HIGHUSER_MOVABLE | __GFP_RECLAIMABLE;
>> >>
>> >> But then I wondered what that __GFP_RECLAIMABLE actually achieves?
>> >> These pages are already __GFP_RECLAIM (inside GFP_HIGHUSER) and on
>> >> the LRU.  It affects gfpflags_to_migratetype(), but I'm not familiar
>> >> with what that different migratetype will end up doing.
>> >>
>> >
>> > Will check for this.
>> >
>>
>> The anti-fragmentation technique used by kernel is based on the idea
>> of grouping pages with identical mobility (UNMOVABLE, RECLAIMABLE,
>> MOVABLE) together.
>
> Yes.
>
>> __GFP_RECLAIMABLE, like  __GFP_MOVABLE, specifies the
>> mobility/migration type of the page and serves a different purpose
>> than __GFP_RECLAIM.
>
> Yes, I was wrong to mention __GFP_RECLAIM above: it describes what
> to do when in difficulty allocating a page, but says nothing at all
> about the nature of the page to be allocated.
>
Right, nicely phrased, thanks.

>>
>> Also as per the below snippet from gfpflags_to_migratetype(), looks
>> like __GFP_MOVABLE &  __GFP_RECLAIMABLE can't be used together, which
>> makes sense.
>> /* Convert GFP flags to their corresponding migrate type */
>> #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE | __GFP_MOVABLE)
>> static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>> {
>>         VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
>> .....
>
> You're right, that does exclude them from being used together.  And it
> makes sense inasmuch as they're expected to be appled to quite different
> uses of a page (lru pages versus slab pages).
>
> The comment on __GFP_MOVABLE says "or can be reclaimed"; and
> the comment on __GFP_RECLAIMABLE says "used for slab allocations...".
> Though it does not say "used for allocations not put on a reclaimable
> lru", I think that is the intention; whereas shmem allocations are put
> on a reclaimable lru (though they might need your shrinker to unpin them).
>

As per my understanding both  __GFP_MOVABLE & __GFP_RECLAIMABLE type
pages would get added to the LRU list for reclaiming.
Irrespective of whether a shmem page is allocated as __GFP_MOVABLE
type or  __GFP_RECLAIMABLE type, it will be added to the LRU list.

>>
>> So probably would need to update the mask like this,
>>        mask = GFP_HIGHUSER;
>>        if (IS_ENABLED(MIGRATION))
>>              mask |= __GFP_MOVABLE;
>>        else
>>              mask |=  __GFP_RECLAIMABLE;
>>
>> Please kindly let us know if this looks fine to you or not.
>
> Thanks for looking into it more deeply.  You leave me thinking that
> it should simply say
>
>         mask = GFP_HIGHUSER_MOVABLE;
>
> Which is the default anyway, but it then has the Crestline+Broadwater
> condition to modify the mask further, so it's probably clearest to
> leave the mask = GFP_HIGHUSER_MOVABLE explicit.
>
> GFP_HIGHUSER_MOVABLE is used in many places, and includes __GFP_MOVABLE
> without any condition on CONFIG_MIGRATION - because the migratetype is
> irrelevant if there is no migration, I presume.
>
> Would you lose something by not or'ing in __GFP_RECLAIMABLE when
> CONFIG_MIGRATION=n?  No, because __GFP_RECLAIMABLE is not used for
> anything but the migratetype, and the migratetype is then irrelevant.
> (I didn't study the code closely enough to say whether the grouping
> can still happen even when migration is disabled, but even if it
> does still happen, I can't see that it would have any benefit.)
>
The freelist, for a particular order,  in buddy allocator is always
organized based on the migrate type.
from <mmzone.h>
struct free_area {
       struct list_head free_list[MIGRATE_TYPES];
        unsigned long nr_free;
};
And the page grouping, based on migrate type, is also always done by the kernel.

Its just that when CONFIG_MIGRATION=n, the actual migration does not
take place, leveraging the page grouping, so no compaction effectively
happens.
I think even without the migration, the page grouping could still be
beneficial in limiting the fragmentation to some extent, as at least
the non-movable pages will not be scattered/dispersed randomly.
But yes when CONFIG_MIGRATION=n,  __GFP_MOVABLE & __GFP_RECLAIMABLE
would be equivalent of each other, as then reclaiming is the only way
to facilitate the formation of higher order free page.
So as you suggested looks like we can simply set
              mask = GFP_HIGHUSER_MOVABLE;

Many thanks for all your inputs.

Best regards
Akash

> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
