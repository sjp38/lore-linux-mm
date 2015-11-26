Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 166186B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:40:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so36486406wme.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:40:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 132si4255546wmd.41.2015.11.26.07.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 07:40:25 -0800 (PST)
Date: Thu, 26 Nov 2015 10:40:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151126154016.GA23976@cmpxchg.org>
References: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
 <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
 <20151125190610.GA12238@cmpxchg.org>
 <20151125203102.GJ22980@nuc-i3427.alporthouse.com>
 <20151125204635.GA14536@cmpxchg.org>
 <20151126112514.GG23362@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126112514.GG23362@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Thu, Nov 26, 2015 at 11:25:14AM +0000, Chris Wilson wrote:
> On Wed, Nov 25, 2015 at 03:46:35PM -0500, Johannes Weiner wrote:
> > On Wed, Nov 25, 2015 at 08:31:02PM +0000, Chris Wilson wrote:
> > > On Wed, Nov 25, 2015 at 02:06:10PM -0500, Johannes Weiner wrote:
> > > > On Wed, Nov 25, 2015 at 06:36:56PM +0000, Chris Wilson wrote:
> > > > > +static bool swap_available(void)
> > > > > +{
> > > > > +	return total_swap_pages || frontswap_enabled;
> > > > > +}
> > > > 
> > > > If you use get_nr_swap_pages() instead of total_swap_pages, this will
> > > > also stop scanning objects once the swap space is full. We do that in
> > > > the VM to stop scanning anonymous pages.
> > > 
> > > Thanks. Would EXPORT_SYMBOL_GPL(nr_swap_pages) (or equivalent) be
> > > acceptable?
> > 
> > No opposition from me. Just please add a small comment that this is
> > for shrinkers with swappable objects.
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 58877312cf6b..1c7861f4c43c 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -48,6 +48,14 @@ static sector_t map_swap_entry(swp_entry_t, struct block_device**);
>  DEFINE_SPINLOCK(swap_lock);
>  static unsigned int nr_swapfiles;
>  atomic_long_t nr_swap_pages;
> +/*
> + * Some modules use swappable objects and may try to swap them out under
> + * memory pressure (via the shrinker). Before doing so, they may wish to
> + * check to see if any swap space is available. The shrinker also directly
> + * uses the available swap space to determine whether it can swapout
> + * anon pages in the same manner.
> + */
> +EXPORT_SYMBOL_GPL(nr_swap_pages);
> 
> Something like that, after a couple more edits?

The last sentence isn't necessary IMO, but other than that it looks
good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
