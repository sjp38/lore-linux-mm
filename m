Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 000D36B006E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 20:13:18 -0500 (EST)
Message-Id: <b94cdc$7i2bv3@fmsmga001.fm.intel.com>
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 17/19] drivers: convert shrinkers to new count/scan API
In-Reply-To: <1354058086-27937-18-git-send-email-david@fromorbit.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-18-git-send-email-david@fromorbit.com>
Date: Wed, 28 Nov 2012 01:13:11 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Wed, 28 Nov 2012 10:14:44 +1100, Dave Chinner <david@fromorbit.com> wrote:
> +/*
> + * XXX: (dchinner) This is one of the worst cases of shrinker abuse I've seen.
> + *
> + * i915_gem_purge() expects a byte count to be passed, and the minimum object
> + * size is PAGE_SIZE.

No, purge() expects a count of pages to be freed. Each pass of the
shrinker therefore tries to free a minimum of 128 pages.

> The shrinker doesn't work on bytes - it works on
> + * *objects*.

And I thought you were reviewing the shrinker API to be useful where a
single object may range between 4K and 4G.

> So it passes a nr_to_scan of 128 objects, which is interpreted
> + * here to mean "free 128 bytes". That means a single object will be freed, as
> + * the minimum object size is a page.
> + *
> + * But the craziest part comes when i915_gem_purge() has walked all the objects
> + * and can't free any memory. That results in i915_gem_shrink_all() being
> + * called, which idles the GPU and frees everything the driver has in it's
> + * active and inactive lists. It's basically hitting the driver with a great big
> + * hammer because it was busy doing stuff when something else generated memory
> + * pressure. This doesn't seem particularly wise...
> + */

As opposed to triggering an OOM? The choice was between custom code for
a hopefully rare code path in a situation of last resort, or first
implementing the simplest code that stopped i915 from starving the
system of memory.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
