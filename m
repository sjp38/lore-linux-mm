Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 792B528026C
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 09:53:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l66so20575728pfl.7
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 06:53:11 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b190si16647612pfa.34.2016.11.04.06.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 06:53:10 -0700 (PDT)
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
References: <1476976532.3002.6.camel@linux.intel.com>
 <1478263706-24783-1-git-send-email-akash.goel@intel.com>
 <1478263706-24783-2-git-send-email-akash.goel@intel.com>
 <20161104133747.GB20322@nuc-i3427.alporthouse.com>
From: "Goel, Akash" <akash.goel@intel.com>
Message-ID: <806a1044-c67b-9030-31c9-eb35f5a83fa4@intel.com>
Date: Fri, 4 Nov 2016 19:23:05 +0530
MIME-Version: 1.0
In-Reply-To: <20161104133747.GB20322@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Cc: Sourab Gupta <sourab.gupta@intel.com>, akash.goels@gmail.com, akash.goel@intel.com



On 11/4/2016 7:07 PM, Chris Wilson wrote:
> Best if we send these as a new series to unconfuse CI.
>
Okay will send as a new series.

> On Fri, Nov 04, 2016 at 06:18:26PM +0530, akash.goel@intel.com wrote:
>> +static int do_migrate_page(struct drm_i915_gem_object *obj)
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
>> +	i915_gem_object_get(obj);
>> +	if (!unsafe_drop_pages(obj))
>> +		ret = -EBUSY;
>> +	i915_gem_object_put(obj);
>
> Since the object release changes, we can now do this without the
> i915_gem_object_get / i915_gem_object_put (as we are guarded by the BKL
> struct_mutex).
Fine will remove object_get/put as with struct_mutex protection object 
can't disappear across unsafe_drop_pages().

Best regards
Akash


> -Chris
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
