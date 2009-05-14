Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6B3B86B01EF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:58:49 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 6/6] PM/Hibernate: Do not try to allocate too much memory too hard
Date: Thu, 14 May 2009 19:59:53 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905131042.18137.rjw@sisk.pl> <20090514111413.GB8871@elf.ucw.cz>
In-Reply-To: <20090514111413.GB8871@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905141959.53810.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 14 May 2009, Pavel Machek wrote:
> Hi!
> 
> > We want to avoid attempting to free too much memory too hard during
> > hibernation, so estimate the minimum size of the image to use as the
> > lower limit for preallocating memory.
> 
> Why? Is freeing memory too slow?
> 
> It used to be that user controlled image size, so he was able to
> balance "time to save image" vs. "responsiveness of system after
> resume".
> 
> Does this just override user's preference when he chooses too small
> image size?
> 
> > The approach here is based on the (experimental) observation that we
> > can't free more page frames than the sum of:
> > 
> > * global_page_state(NR_SLAB_RECLAIMABLE)
> > * global_page_state(NR_ACTIVE_ANON)
> > * global_page_state(NR_INACTIVE_ANON)
> > * global_page_state(NR_ACTIVE_FILE)
> > * global_page_state(NR_INACTIVE_FILE)
> > 
> > and even that is usually impossible to free in practice, because some
> > of the pages reported as global_page_state(NR_SLAB_RECLAIMABLE) can't
> > in fact be freed.  It turns out, however, that if the sum of the
> > above numbers is subtracted from the number of saveable pages in the
> > system and the result is multiplied by 1.25, we get a suitable
> > estimate of the minimum size of the image.
> 
> 
> 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > ---
> >  kernel/power/snapshot.c |   56 ++++++++++++++++++++++++++++++++++++++++++++----
> >  1 file changed, 52 insertions(+), 4 deletions(-)
> 
> 
> >  /**
> > + * minimum_image_size - Estimate the minimum acceptable size of an image
> > + * @saveable: The total number of saveable pages in the system.
> > + *
> > + * We want to avoid attempting to free too much memory too hard, so estimate the
> > + * minimum acceptable size of a hibernation image to use as the lower limit for
> > + * preallocating memory.
> 
> I don't get it. If user sets image size as 0, we should free as much
> memory as we can. I just don't see why "we want to avoid... it".

The "as much memory as we can" is not well defined.

Patches [4/6] and [5/6] make hibernation use memory allocations to force some
memory to be freed.  However, it is not really reasonable to try to allocate
until the allocation fails, because that stresses the memory management
subsystem too much.  It is better to predict when it fails and stop allocating
at that point, which is what the patch does.

The prediction is not very precise, but I think it need not be.  Even if it
leaves a few pages more in memory, that won't be a disaster.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
