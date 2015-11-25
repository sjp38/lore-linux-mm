Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4966B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 15:31:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so85544617wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:31:10 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id o14si8040884wmg.93.2015.11.25.12.31.09
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 12:31:09 -0800 (PST)
Date: Wed, 25 Nov 2015 20:31:02 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151125203102.GJ22980@nuc-i3427.alporthouse.com>
References: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
 <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
 <20151125190610.GA12238@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125190610.GA12238@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Wed, Nov 25, 2015 at 02:06:10PM -0500, Johannes Weiner wrote:
> On Wed, Nov 25, 2015 at 06:36:56PM +0000, Chris Wilson wrote:
> > If the system has no available swap pages, we cannot make forward
> > progress in the shrinker by releasing active pages, only by releasing
> > purgeable pages which are immediately reaped. Take total_swap_pages into
> > account when counting up available objects to be shrunk and subsequently
> > shrinking them. By doing so, we avoid unbinding objects that cannot be
> > shrunk and so wasting CPU cycles flushing those objects from the GPU to
> > the system and then immediately back again (as they will more than
> > likely be reused shortly after).
> > 
> > Based on a patch by Akash Goel.
> > 
> > v2: Check for frontswap without physical swap (or dedicated swap space).
> > If frontswap is available, we may be able to compress the GPU pages
> > instead of swapping out to disk. In this case, we do want to shrink GPU
> > objects and so make them available for compressing.
> 
> Frontswap always sits on top of an active swap device. It's enough to
> check for available swap space.
> 
> > +static bool swap_available(void)
> > +{
> > +	return total_swap_pages || frontswap_enabled;
> > +}
> 
> If you use get_nr_swap_pages() instead of total_swap_pages, this will
> also stop scanning objects once the swap space is full. We do that in
> the VM to stop scanning anonymous pages.

Thanks. Would EXPORT_SYMBOL_GPL(nr_swap_pages) (or equivalent) be
acceptable?
-Chris
 
-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
