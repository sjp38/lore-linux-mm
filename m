Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7369A6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:25:18 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id x3so16166095pfb.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 01:25:18 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o129si2846021pfo.19.2016.03.23.01.25.17
        for <linux-mm@kvack.org>;
        Wed, 23 Mar 2016 01:25:17 -0700 (PDT)
Subject: Re: [PATCH 2/2] drm/i915: Make pages of GFX allocations movable
References: <1458713384-25688-1-git-send-email-akash.goel@intel.com>
 <1458713384-25688-2-git-send-email-akash.goel@intel.com>
 <20160323075809.GA21952@nuc-i3427.alporthouse.com>
From: "Goel, Akash" <akash.goel@intel.com>
Message-ID: <56F252EA.1020600@intel.com>
Date: Wed, 23 Mar 2016 13:55:14 +0530
MIME-Version: 1.0
In-Reply-To: <20160323075809.GA21952@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Cc: Sourab Gupta <sourab.gupta@intel.com>, akash.goel@intel.com



On 3/23/2016 1:28 PM, Chris Wilson wrote:
> On Wed, Mar 23, 2016 at 11:39:44AM +0530, akash.goel@intel.com wrote:
>> +#ifdef CONFIG_MIGRATION
>> +static int i915_migratepage(struct address_space *mapping,
>> +			    struct page *newpage, struct page *page,
>> +			    enum migrate_mode mode, void *dev_priv_data)
>
> If we move this to i915_gem_shrink_migratepage (i.e. i915_gem_shrink),
> we can
>
>> +	/*
>> +	 * Use trylock here, with a timeout, for struct_mutex as
>> +	 * otherwise there is a possibility of deadlock due to lock
>> +	 * inversion. This path, which tries to migrate a particular
>> +	 * page after locking that page, can race with a path which
>> +	 * truncate/purge pages of the corresponding object (after
>> +	 * acquiring struct_mutex). Since page truncation will also
>> +	 * try to lock the page, a scenario of deadlock can arise.
>> +	 */
>> +	while (!mutex_trylock(&dev->struct_mutex) && --timeout)
>> +		schedule_timeout_killable(1);
>
> replace this with i915_gem_shrinker_lock() and like constructs with the
> other shrinkers.

fine, will rename the function to gem_shrink_migratepage, move it inside 
the gem_shrinker.c file, and use the existing constructs.

 > Any reason for dropping the early
 > if (!page_private(obj)) skip?
 >

Would this sequence be fine ?

	if (!page_private(page))
		goto migrate; /*skip */

	Loop for locking mutex

	obj = (struct drm_i915_gem_object *)page_private(page);

	if (!PageSwapCache(page) && obj) {


> Similarly there are other patterns here that would benefit from
> integration with existing shrinker logic. However, things like tidying
> up the pin_display, unbinding, rpm lock inversion are still only on
> list.

Tidying, like split that one single if condition into multiple if, else 
if blocks ?

Best regards
Akash
> -Chris
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
