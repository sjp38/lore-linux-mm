Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D4BE76B019C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:14:08 -0400 (EDT)
Date: Thu, 14 May 2009 13:14:13 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 6/6] PM/Hibernate: Do not try to allocate too much
	memory too hard
Message-ID: <20090514111413.GB8871@elf.ucw.cz>
References: <200905070040.08561.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl> <200905131032.53624.rjw@sisk.pl> <200905131042.18137.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905131042.18137.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> We want to avoid attempting to free too much memory too hard during
> hibernation, so estimate the minimum size of the image to use as the
> lower limit for preallocating memory.

Why? Is freeing memory too slow?

It used to be that user controlled image size, so he was able to
balance "time to save image" vs. "responsiveness of system after
resume".

Does this just override user's preference when he chooses too small
image size?

> The approach here is based on the (experimental) observation that we
> can't free more page frames than the sum of:
> 
> * global_page_state(NR_SLAB_RECLAIMABLE)
> * global_page_state(NR_ACTIVE_ANON)
> * global_page_state(NR_INACTIVE_ANON)
> * global_page_state(NR_ACTIVE_FILE)
> * global_page_state(NR_INACTIVE_FILE)
> 
> and even that is usually impossible to free in practice, because some
> of the pages reported as global_page_state(NR_SLAB_RECLAIMABLE) can't
> in fact be freed.  It turns out, however, that if the sum of the
> above numbers is subtracted from the number of saveable pages in the
> system and the result is multiplied by 1.25, we get a suitable
> estimate of the minimum size of the image.



> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
>  kernel/power/snapshot.c |   56 ++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 52 insertions(+), 4 deletions(-)


>  /**
> + * minimum_image_size - Estimate the minimum acceptable size of an image
> + * @saveable: The total number of saveable pages in the system.
> + *
> + * We want to avoid attempting to free too much memory too hard, so estimate the
> + * minimum acceptable size of a hibernation image to use as the lower limit for
> + * preallocating memory.

I don't get it. If user sets image size as 0, we should free as much
memory as we can. I just don't see why "we want to avoid... it".

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
