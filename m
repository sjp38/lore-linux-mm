Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED1716B0269
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:30:38 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id bi5so64370654pad.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:30:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s68si3385501pfi.277.2016.11.09.23.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 23:30:36 -0800 (PST)
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <1478271776-1194-2-git-send-email-akash.goel@intel.com>
 <alpine.LSU.2.11.1611092137360.6221@eggly.anvils>
From: "Goel, Akash" <akash.goel@intel.com>
Message-ID: <5ff5aabf-2efe-7ee3-aab7-6c4b132c523d@intel.com>
Date: Thu, 10 Nov 2016 13:00:33 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611092137360.6221@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>, akash.goels@gmail.com, akash.goel@intel.com



On 11/10/2016 12:09 PM, Hugh Dickins wrote:
> On Fri, 4 Nov 2016, akash.goel@intel.com wrote:
>> From: Chris Wilson <chris@chris-wilson.co.uk>
>>
>> On a long run of more than 2-3 days, physical memory tends to get
>> fragmented severely, which considerably slows down the system. In such a
>> scenario, the shrinker is also unable to help as lack of memory is not
>> the actual problem, since it has been observed that there are enough free
>> pages of 0 order. This also manifests itself when an indiviual zone in
>> the mm runs out of pages and if we cannot migrate pages between zones,
>> the kernel hits an out-of-memory even though there are free pages (and
>> often all of swap) available.
>>
>> To address the issue of external fragementation, kernel does a compaction
>> (which involves migration of pages) but it's efficacy depends upon how
>> many pages are marked as MOVABLE, as only those pages can be migrated.
>>
>> Currently the backing pages for GPU buffers are allocated from shmemfs
>> with GFP_RECLAIMABLE flag, in units of 4KB pages.  In the case of limited
>> swap space, it may not be possible always to reclaim or swap-out pages of
>> all the inactive objects, to make way for free space allowing formation
>> of higher order groups of physically-contiguous pages on compaction.
>>
>> Just marking the GPU pages as MOVABLE will not suffice, as i915.ko has to
>> pin the pages if they are in use by GPU, which will prevent their
>> migration. So the migratepage callback in shmem is also hooked up to get
>> a notification when kernel initiates the page migration. On the
>> notification, i915.ko appropriately unpin the pages.  With this we can
>> effectively mark the GPU pages as MOVABLE and hence mitigate the
>> fragmentation problem.
>>
>> v2:
>>  - Rename the migration routine to gem_shrink_migratepage, move it to the
>>    shrinker file, and use the existing constructs (Chris)
>>  - To cleanup, add a new helper function to encapsulate all page migration
>>    skip conditions (Chris)
>>  - Add a new local helper function in shrinker file, for dropping the
>>    backing pages, and call the same from gem_shrink() also (Chris)
>>
>> v3:
>>  - Fix/invert the check on the return value of unsafe_drop_pages (Chris)
>>
>> v4:
>>  - Minor tidy
>>
>> v5:
>>  - Fix unsafe usage of unsafe_drop_pages()
>>  - Rebase onto vmap-notifier
>>
>> v6:
>> - Remove i915_gem_object_get/put across unsafe_drop_pages() as with
>>   struct_mutex protection object can't disappear. (Chris)
>>
>> Testcase: igt/gem_shrink
>> Bugzilla: (e.g.) https://bugs.freedesktop.org/show_bug.cgi?id=90254
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
>> Signed-off-by: Akash Goel <akash.goel@intel.com>
>> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
>> Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
>> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
>
> I'm confused!  But perhaps it's gone around and around between you all,
> I'm not sure what the rules are then.  I think this sequence implies
> that Sourab wrote it originally, then Akash and Chris passed it on
> with refinements - but then Chris wouldn't add Reviewed-by.
>
Thank you very much for the review and sorry for all the needless confusion.

Chris actually conceived the patches and prepared an initial version of 
them (hence he is the Author).
I & Sourab did the further refinements and fixed issues (all those 
page_private stuff).
Chris then reviewed the final patch and also recently did a rebase for it.

>> ---
>>  drivers/gpu/drm/i915/i915_drv.h          |   2 +
>>  drivers/gpu/drm/i915/i915_gem.c          |   9 ++-
>>  drivers/gpu/drm/i915/i915_gem_shrinker.c | 132 +++++++++++++++++++++++++++++++
>>  3 files changed, 142 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
>> index 4735b417..7f2717b 100644
>> --- a/drivers/gpu/drm/i915/i915_drv.h
>> +++ b/drivers/gpu/drm/i915/i915_drv.h
>> @@ -1357,6 +1357,8 @@ struct intel_l3_parity {
>>  };
>>
>>  struct i915_gem_mm {
>> +	struct shmem_dev_info shmem_info;
>> +
>>  	/** Memory allocator for GTT stolen memory */
>>  	struct drm_mm stolen;
>>  	/** Protects the usage of the GTT stolen memory allocator. This is
>> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
>> index 1f995ce..f0d4ce7 100644
>> --- a/drivers/gpu/drm/i915/i915_gem.c
>> +++ b/drivers/gpu/drm/i915/i915_gem.c
>> @@ -2164,6 +2164,7 @@ void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj)
>>  		if (obj->mm.madv == I915_MADV_WILLNEED)
>>  			mark_page_accessed(page);
>>
>> +		set_page_private(page, 0);
>>  		put_page(page);
>>  	}
>>  	obj->mm.dirty = false;
>> @@ -2310,6 +2311,7 @@ static unsigned int swiotlb_max_size(void)
>>  			sg->length += PAGE_SIZE;
>>  		}
>>  		last_pfn = page_to_pfn(page);
>> +		set_page_private(page, (unsigned long)obj);
>>
>>  		/* Check that the i965g/gm workaround works. */
>>  		WARN_ON((gfp & __GFP_DMA32) && (last_pfn >= 0x00100000UL));
>> @@ -2334,8 +2336,10 @@ static unsigned int swiotlb_max_size(void)
>>
>>  err_pages:
>>  	sg_mark_end(sg);
>> -	for_each_sgt_page(page, sgt_iter, st)
>> +	for_each_sgt_page(page, sgt_iter, st) {
>> +		set_page_private(page, 0);
>>  		put_page(page);
>> +	}
>>  	sg_free_table(st);
>>  	kfree(st);
>>
>
> I think your page_private() games there and below are correct (and
> I suspect took a few iterations to get right); and we don't currently
> have a use for page_private() in mm/shmem.c that conflicts with what
> you're doing here (of course it's used for swap, but you're already
> careful to exclude that case).
>
> But I'd nonetheless prefer not to give it away to you: you're welcome
> to use mapping->private_data as you have, but I'd rather keep the more
> valuable page_private() available for mm or shmem use.
>
> Would it be reasonable to ask you to rework this with the shmem_dev_info
> in dev_priv replaced by shmem_obj_info in drm_i915_gem_object?  Then,
> IIUC, you can access both it and the object which contains it from
> the page->mapping pointer, without needing page->private.
>
If I understood your suggestion correctly, instead of page_private the 
object pointer can be derived from mapping->private (by having 
shmem_obj_info embedded inside drm_i915_gem_object instead of dev_priv).

Will definitely try to rework the patch as per your suggestions.

> It that's unreasonable to ask of you, would it be reasonable if I
> added a third patch to make that change myself?
>
>> @@ -4185,6 +4189,8 @@ struct drm_i915_gem_object *
>>  		goto fail;
>>
>>  	mask = GFP_HIGHUSER | __GFP_RECLAIMABLE;
>> +	if (IS_ENABLED(MIGRATION))
>> +		mask |= __GFP_MOVABLE;
>
> I was going to suggest just make that unconditional,
>         mask = GFP_HIGHUSER_MOVABLE | __GFP_RECLAIMABLE;
>
> But then I wondered what that __GFP_RECLAIMABLE actually achieves?
> These pages are already __GFP_RECLAIM (inside GFP_HIGHUSER) and on
> the LRU.  It affects gfpflags_to_migratetype(), but I'm not familiar
> with what that different migratetype will end up doing.
>

Will check for this.

>>  	if (IS_CRESTLINE(dev_priv) || IS_BROADWATER(dev_priv)) {
>>  		/* 965gm cannot relocate objects above 4GiB. */
>>  		mask &= ~__GFP_HIGHMEM;
>> @@ -4193,6 +4199,7 @@ struct drm_i915_gem_object *
>>
>>  	mapping = obj->base.filp->f_mapping;
>>  	mapping_set_gfp_mask(mapping, mask);
>> +	shmem_set_dev_info(mapping, &dev_priv->mm.shmem_info);
>>
>>  	i915_gem_object_init(obj, &i915_gem_object_ops);
>>
>> diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
>> index a6fc1bd..051135ac 100644
>> --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
>> +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
>> @@ -24,6 +24,7 @@
>>
>>  #include <linux/oom.h>
>>  #include <linux/shmem_fs.h>
>> +#include <linux/migrate.h>
>>  #include <linux/slab.h>
>>  #include <linux/swap.h>
>>  #include <linux/pci.h>
>> @@ -473,6 +474,132 @@ struct shrinker_lock_uninterruptible {
>>  	return NOTIFY_DONE;
>>  }
>>
>> +#ifdef CONFIG_MIGRATION
>> +static bool can_migrate_page(struct drm_i915_gem_object *obj)
>> +{
>> +	/* Avoid the migration of page if being actively used by GPU */
>> +	if (i915_gem_object_is_active(obj))
>> +		return false;
>> +
>> +	/* Skip the migration for purgeable objects otherwise there
>> +	 * will be a deadlock when shmem will try to lock the page for
>> +	 * truncation, which is already locked by the caller before
>> +	 * migration.
>> +	 */
>> +	if (obj->mm.madv == I915_MADV_DONTNEED)
>> +		return false;
>> +
>> +	/* Skip the migration for a pinned object */
>> +	if (atomic_read(&obj->mm.pages_pin_count) > obj->bind_count)
>> +		return false;
>> +
>> +	if (any_vma_pinned(obj))
>> +		return false;
>> +
>> +	return true;
>> +}
>> +
>> +static int do_migrate_page(struct drm_i915_gem_object *obj)
>
> do_migrate_page()?  But it does not.  Maybe prepare_for_migrate_page()?
>
fine..

>> +{
>> +	struct drm_i915_private *dev_priv = to_i915(obj->base.dev);
>> +	int ret = 0;
>> +
>> +	if (!can_migrate_page(obj))
>> +		return -EBUSY;
>> +
>> +	/* HW access would be required for a GGTT bound object, for which
>> +	 * device has to be kept awake. But a deadlock scenario can arise if
>> +	 * the attempt is made to resume the device, when either a suspend
>> +	 * or a resume operation is already happening concurrently from some
>> +	 * other path and that only also triggers compaction. So only unbind
>> +	 * if the device is currently awake.
>> +	 */
>> +	if (!intel_runtime_pm_get_if_in_use(dev_priv))
>> +		return -EBUSY;
>> +
>> +	if (!unsafe_drop_pages(obj))
>> +		ret = -EBUSY;
>> +
>> +	intel_runtime_pm_put(dev_priv);
>> +	return ret;
>> +}
>> +
>> +static int i915_gem_shrinker_migratepage(struct address_space *mapping,
>> +					 struct page *newpage,
>> +					 struct page *page,
>> +					 enum migrate_mode mode,
>> +					 void *dev_priv_data)
>> +{
>> +	struct drm_i915_private *dev_priv = dev_priv_data;
>> +	struct shrinker_lock_uninterruptible slu;
>> +	int ret;
>> +
>> +	/*
>> +	 * Clear the private field of the new target page as it could have a
>> +	 * stale value in the private field. Otherwise later on if this page
>> +	 * itself gets migrated, without getting referred by the Driver
>> +	 * in between, the stale value would cause the i915_migratepage
>> +	 * function to go for a toss as object pointer is derived from it.
>> +	 * This should be safe since at the time of migration, private field
>> +	 * of the new page (which is actually an independent free 4KB page now)
>> +	 * should be like a don't care for the kernel.
>> +	 */
>> +	set_page_private(newpage, 0);
>> +
>> +	if (!page_private(page))
>> +		goto migrate;
>> +
>> +	/*
>> +	 * Check the page count, if Driver also has a reference then it should
>> +	 * be more than 2, as shmem will have one reference and one reference
>> +	 * would have been taken by the migration path itself. So if reference
>> +	 * is <=2, we can directly invoke the migration function.
>> +	 */
>> +	if (page_count(page) <= 2)
>> +		goto migrate;
>> +
>> +	/*
>> +	 * Use trylock here, with a timeout, for struct_mutex as
>> +	 * otherwise there is a possibility of deadlock due to lock
>> +	 * inversion. This path, which tries to migrate a particular
>> +	 * page after locking that page, can race with a path which
>> +	 * truncate/purge pages of the corresponding object (after
>> +	 * acquiring struct_mutex). Since page truncation will also
>> +	 * try to lock the page, a scenario of deadlock can arise.
>> +	 */
>> +	if (!i915_gem_shrinker_lock_uninterruptible(dev_priv, &slu, 10))
>> +		return -EBUSY;
>> +
>> +	ret = 0;
>> +	if (!PageSwapCache(page) && page_private(page)) {
>> +		struct drm_i915_gem_object *obj =
>> +			(struct drm_i915_gem_object *)page_private(page);
>> +
>> +		ret = do_migrate_page(obj);
>> +	}
>> +
>> +	i915_gem_shrinker_unlock_uninterruptible(dev_priv, &slu);
>> +	if (ret)
>> +		return ret;
>> +
>> +	/*
>> +	 * Ideally here we don't expect the page count to be > 2, as driver
>> +	 * would have dropped its reference, but occasionally it has been seen
>> +	 * coming as 3 & 4. This leads to a situation of unexpected page count,
>> +	 * causing migration failure, with -EGAIN error. This then leads to
>
> s/EGAIN/EAGAIN/
Fine.
>
>> +	 * multiple attempts by the kernel to migrate the same set of pages.
>> +	 * And sometimes the repeated attempts proves detrimental for stability.
>> +	 * Also since we don't know who is the other owner, and for how long its
>> +	 * gonna keep the reference, its better to return -EBUSY.
>
> Fair enough, I know those 10 repeats can be quite a waste.  And you've
> got a potential 10ms timeout above, which you don't want to multiply by 10.
> I can't get too sniffy about your timeout, we have other sources of delay
> in there, but it is always sad to add latency to MIGRATE_ASYNC mode.
>
>> +	 */
>> +	if (page_count(page) > 2)
>> +		return -EBUSY;
>> +
>> +migrate:
>> +	return migrate_page(mapping, newpage, page, mode);
>> +}
>> +#endif
>> +
>>  /**
>>   * i915_gem_shrinker_init - Initialize i915 shrinker
>>   * @dev_priv: i915 device
>> @@ -491,6 +618,11 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
>>
>>  	dev_priv->mm.vmap_notifier.notifier_call = i915_gem_shrinker_vmap;
>>  	WARN_ON(register_vmap_purge_notifier(&dev_priv->mm.vmap_notifier));
>> +
>> +	dev_priv->mm.shmem_info.private_data = dev_priv;
>> +#ifdef CONFIG_MIGRATION
>> +	dev_priv->mm.shmem_info.migratepage = i915_gem_shrinker_migratepage;
>> +#endif
>
> If we avoid playing with page_private(), this initialization would go
> away, but the equivalent be done near the call to i915_gem_object_init().
>
Agree.

Best regards
Akash

>>  }
>>
>>  /**
>> --
>> 1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
