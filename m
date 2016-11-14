Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E172A6B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:57:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so22857837wme.5
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:57:27 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id ju1si22554255wjc.128.2016.11.13.23.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Nov 2016 23:57:26 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id a20so12954617wme.2
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:57:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5ff5aabf-2efe-7ee3-aab7-6c4b132c523d@intel.com>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <1478271776-1194-2-git-send-email-akash.goel@intel.com> <alpine.LSU.2.11.1611092137360.6221@eggly.anvils>
 <5ff5aabf-2efe-7ee3-aab7-6c4b132c523d@intel.com>
From: akash goel <akash.goels@gmail.com>
Date: Mon, 14 Nov 2016 13:27:25 +0530
Message-ID: <CAK_0AV0+1oizfRMfoJ45FWCRi_4X93W-ZtseY-s-R_wavE3fZQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, akash goel <akash.goels@gmail.com>, Sourab Gupta <sourab.gupta@intel.com>

On Thu, Nov 10, 2016 at 1:00 PM, Goel, Akash <akash.goel@intel.com> wrote:
>
>
> On 11/10/2016 12:09 PM, Hugh Dickins wrote:
>>
>> On Fri, 4 Nov 2016, akash.goel@intel.com wrote:
>>>
>>> From: Chris Wilson <chris@chris-wilson.co.uk>
>>>
>>> On a long run of more than 2-3 days, physical memory tends to get
>>> fragmented severely, which considerably slows down the system. In such a
>>> scenario, the shrinker is also unable to help as lack of memory is not
>>> the actual problem, since it has been observed that there are enough free
>>> pages of 0 order. This also manifests itself when an indiviual zone in
>>> the mm runs out of pages and if we cannot migrate pages between zones,
>>> the kernel hits an out-of-memory even though there are free pages (and
>>> often all of swap) available.
>>>
>>> To address the issue of external fragementation, kernel does a compaction
>>> (which involves migration of pages) but it's efficacy depends upon how
>>> many pages are marked as MOVABLE, as only those pages can be migrated.
>>>
>>> Currently the backing pages for GPU buffers are allocated from shmemfs
>>> with GFP_RECLAIMABLE flag, in units of 4KB pages.  In the case of limited
>>> swap space, it may not be possible always to reclaim or swap-out pages of
>>> all the inactive objects, to make way for free space allowing formation
>>> of higher order groups of physically-contiguous pages on compaction.
>>>
>>> Just marking the GPU pages as MOVABLE will not suffice, as i915.ko has to
>>> pin the pages if they are in use by GPU, which will prevent their
>>> migration. So the migratepage callback in shmem is also hooked up to get
>>> a notification when kernel initiates the page migration. On the
>>> notification, i915.ko appropriately unpin the pages.  With this we can
>>> effectively mark the GPU pages as MOVABLE and hence mitigate the
>>> fragmentation problem.
>>>
>>> v2:
>>>  - Rename the migration routine to gem_shrink_migratepage, move it to the
>>>    shrinker file, and use the existing constructs (Chris)
>>>  - To cleanup, add a new helper function to encapsulate all page
>>> migration
>>>    skip conditions (Chris)
>>>  - Add a new local helper function in shrinker file, for dropping the
>>>    backing pages, and call the same from gem_shrink() also (Chris)
>>>
>>> v3:
>>>  - Fix/invert the check on the return value of unsafe_drop_pages (Chris)
>>>
>>> v4:
>>>  - Minor tidy
>>>
>>> v5:
>>>  - Fix unsafe usage of unsafe_drop_pages()
>>>  - Rebase onto vmap-notifier
>>>
>>> v6:
>>> - Remove i915_gem_object_get/put across unsafe_drop_pages() as with
>>>   struct_mutex protection object can't disappear. (Chris)
>>>
>>> Testcase: igt/gem_shrink
>>> Bugzilla: (e.g.) https://bugs.freedesktop.org/show_bug.cgi?id=90254
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: linux-mm@kvack.org
>>> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
>>> Signed-off-by: Akash Goel <akash.goel@intel.com>
>>> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
>>> Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
>>> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
>>
>>
>> I'm confused!  But perhaps it's gone around and around between you all,
>> I'm not sure what the rules are then.  I think this sequence implies
>> that Sourab wrote it originally, then Akash and Chris passed it on
>> with refinements - but then Chris wouldn't add Reviewed-by.
>>
> Thank you very much for the review and sorry for all the needless confusion.
>
> Chris actually conceived the patches and prepared an initial version of them
> (hence he is the Author).
> I & Sourab did the further refinements and fixed issues (all those
> page_private stuff).
> Chris then reviewed the final patch and also recently did a rebase for it.
>
>
>>> ---
>>>  drivers/gpu/drm/i915/i915_drv.h          |   2 +
>>>  drivers/gpu/drm/i915/i915_gem.c          |   9 ++-
>>>  drivers/gpu/drm/i915/i915_gem_shrinker.c | 132
>>> +++++++++++++++++++++++++++++++
>>>  3 files changed, 142 insertions(+), 1 deletion(-)
>>>
snip
>>
>>> @@ -4185,6 +4189,8 @@ struct drm_i915_gem_object *
>>>                 goto fail;
>>>
>>>         mask = GFP_HIGHUSER | __GFP_RECLAIMABLE;
>>> +       if (IS_ENABLED(MIGRATION))
>>> +               mask |= __GFP_MOVABLE;
>>
>>
>> I was going to suggest just make that unconditional,
>>         mask = GFP_HIGHUSER_MOVABLE | __GFP_RECLAIMABLE;
>>
>> But then I wondered what that __GFP_RECLAIMABLE actually achieves?
>> These pages are already __GFP_RECLAIM (inside GFP_HIGHUSER) and on
>> the LRU.  It affects gfpflags_to_migratetype(), but I'm not familiar
>> with what that different migratetype will end up doing.
>>
>
> Will check for this.
>

The anti-fragmentation technique used by kernel is based on the idea
of grouping pages with identical mobility (UNMOVABLE, RECLAIMABLE,
MOVABLE) together.
__GFP_RECLAIMABLE, like  __GFP_MOVABLE, specifies the
mobility/migration type of the page and serves a different purpose
than __GFP_RECLAIM.

Also as per the below snippet from gfpflags_to_migratetype(), looks
like __GFP_MOVABLE &  __GFP_RECLAIMABLE can't be used together, which
makes sense.
/* Convert GFP flags to their corresponding migrate type */
#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE | __GFP_MOVABLE)
static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
{
        VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
.....

So probably would need to update the mask like this,
       mask = GFP_HIGHUSER;
       if (IS_ENABLED(MIGRATION))
             mask |= __GFP_MOVABLE;
       else
             mask |=  __GFP_RECLAIMABLE;

Please kindly let us know if this looks fine to you or not.

Best regards
Akash

>
>>>         if (IS_CRESTLINE(dev_priv) || IS_BROADWATER(dev_priv)) {
>>>                 /* 965gm cannot relocate objects above 4GiB. */
>>>                 mask &= ~__GFP_HIGHMEM;
>>> @@ -4193,6 +4199,7 @@ struct drm_i915_gem_object *
>>>
>>>         mapping = obj->base.filp->f_mapping;
>>>         mapping_set_gfp_mask(mapping, mask);
>>> +       shmem_set_dev_info(mapping, &dev_priv->mm.shmem_info);
>>>
>>>         i915_gem_object_init(obj, &i915_gem_object_ops);
>>>
>>>  }
>>>
>>>  /**
>>> --
>>> 1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
