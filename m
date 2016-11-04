Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2468828027E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 09:38:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p190so17122328wmp.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 06:38:04 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id dt17si15175147wjb.192.2016.11.04.06.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 06:38:00 -0700 (PDT)
Date: Fri, 4 Nov 2016 13:37:47 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
Message-ID: <20161104133747.GB20322@nuc-i3427.alporthouse.com>
References: <1476976532.3002.6.camel@linux.intel.com>
 <1478263706-24783-1-git-send-email-akash.goel@intel.com>
 <1478263706-24783-2-git-send-email-akash.goel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478263706-24783-2-git-send-email-akash.goel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akash.goel@intel.com
Cc: intel-gfx@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>

Best if we send these as a new series to unconfuse CI.

On Fri, Nov 04, 2016 at 06:18:26PM +0530, akash.goel@intel.com wrote:
> +static int do_migrate_page(struct drm_i915_gem_object *obj)
> +{
> +	struct drm_i915_private *dev_priv = to_i915(obj->base.dev);
> +	int ret = 0;
> +
> +	if (!can_migrate_page(obj))
> +		return -EBUSY;
> +
> +	/* HW access would be required for a GGTT bound object, for which
> +	 * device has to be kept awake. But a deadlock scenario can arise if
> +	 * the attempt is made to resume the device, when either a suspend
> +	 * or a resume operation is already happening concurrently from some
> +	 * other path and that only also triggers compaction. So only unbind
> +	 * if the device is currently awake.
> +	 */
> +	if (!intel_runtime_pm_get_if_in_use(dev_priv))
> +		return -EBUSY;
> +
> +	i915_gem_object_get(obj);
> +	if (!unsafe_drop_pages(obj))
> +		ret = -EBUSY;
> +	i915_gem_object_put(obj);

Since the object release changes, we can now do this without the
i915_gem_object_get / i915_gem_object_put (as we are guarded by the BKL
struct_mutex).
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
