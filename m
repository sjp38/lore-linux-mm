Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id BC4036B0071
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 11:44:21 -0400 (EDT)
Received: by wiun10 with SMTP id n10so65056937wiu.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:44:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei3si8812503wjd.20.2015.04.15.08.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 08:44:20 -0700 (PDT)
Date: Wed, 15 Apr 2015 16:44:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150415154415.GH14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <552E6486.6070705@hp.com>
 <20150415133826.GF14842@suse.de>
 <552E7AC5.3020703@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <552E7AC5.3020703@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 10:50:45AM -0400, Waiman Long wrote:
> On 04/15/2015 09:38 AM, Mel Gorman wrote:
> >On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
> >>><SNIP>
> >>>Patches are against 4.0-rc7.
> >>>
> >>>  Documentation/kernel-parameters.txt |   8 +
> >>>  arch/ia64/mm/numa.c                 |  19 +-
> >>>  arch/x86/Kconfig                    |   2 +
> >>>  include/linux/memblock.h            |  18 ++
> >>>  include/linux/mm.h                  |   8 +-
> >>>  include/linux/mmzone.h              |  37 +++-
> >>>  init/main.c                         |   1 +
> >>>  mm/Kconfig                          |  29 +++
> >>>  mm/bootmem.c                        |   6 +-
> >>>  mm/internal.h                       |  23 ++-
> >>>  mm/memblock.c                       |  34 ++-
> >>>  mm/mm_init.c                        |   9 +-
> >>>  mm/nobootmem.c                      |   7 +-
> >>>  mm/page_alloc.c                     | 398 +++++++++++++++++++++++++++++++-----
> >>>  mm/vmscan.c                         |   6 +-
> >>>  15 files changed, 507 insertions(+), 98 deletions(-)
> >>>
> >>I had included your patch with the 4.0 kernel and booted up a
> >>16-socket 12-TB machine. I measured the elapsed time from the elilo
> >>prompt to the availability of ssh login. Without the patch, the
> >>bootup time was 404s. It was reduced to 298s with the patch. So
> >>there was about 100s reduction in bootup time (1/4 of the total).
> >>
> >Cool, thanks for testing. Would you be able to state if this is really
> >important or not? Does booting 100s second faster on a 12TB machine really
> >matter? I can then add that justification to the changelog to avoid a
> >conversation with Andrew that goes something like
> >
> >Andrew: Why are we doing this?
> >Mel:    Because we can and apparently people might want it.
> >Andrew: What's the maintenance cost of this?
> >Mel:    Magic beans
> >
> >I prefer talking to Andrew when it's harder to predict what he'll say.
> 
> Booting 100s faster is certainly something that is nice to have.
> Right now, more time is spent in the firmware POST portion of the
> bootup process than in the OS boot.

I'm not surprised. On two different 1TB machines, I've seen a post time
of 2 minutes and one of 35. No idea what it's doing for 35 minutes....
plotting world domination probably.

> So I would say this patch isn't
> really critical right now as machines with that much memory are
> relatively rare. However, if we look forward to the near future,
> some new memory technology like persistent memory is coming and
> machines with large amount of memory (whether persistent or not)
> will become more common. This patch will certainly be useful if we
> look forward into the future.
> 

Whether persistent memory needs struct pages or not is up in the air and
I'm not getting stuck in that can of worms. 100 seconds off kernel init
time is a starting point. I can try pushing it on on that basis but I
really would like to see SGI and Intel people also chime in on how it
affects their really large machines.

> >>However, there were 2 bootup problems in the dmesg log that needed
> >>to be addressed.
> >>1. There were 2 vmalloc allocation failures:
> >>[    2.284686] vmalloc: allocation failure, allocated 16578404352 of
> >>17179873280 bytes
> >>[   10.399938] vmalloc: allocation failure, allocated 7970922496 of
> >>8589938688 bytes
> >>
> >>2. There were 2 soft lockup warnings:
> >>[   57.319453] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s!
> >>[swapper/0:1]
> >>[   85.409263] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s!
> >>[swapper/0:1]
> >>
> >>Once those problems are fixed, the patch should be in a pretty good
> >>shape. I have attached the dmesg log for your reference.
> >>
> >The obvious conclusion is that initialising 1G per node is not enough for
> >really large machines. Can you try this on top? It's untested but should
> >work. The low value was chosen because it happened to work and I wanted
> >to get test coverage on common hardware but broke is broke.
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index f2c96d02662f..6b3bec304e35 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -276,9 +276,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
> >  	if (pgdat->first_deferred_pfn != ULONG_MAX)
> >  		return false;
> >
> >-	/* Initialise at least 1G per zone */
> >+	/* Initialise at least 32G per node */
> >  	(*nr_initialised)++;
> >-	if (*nr_initialised>  (1UL<<  (30 - PAGE_SHIFT))&&
> >+	if (*nr_initialised>  (32UL<<  (30 - PAGE_SHIFT))&&
> >  	(pfn&  (PAGES_PER_SECTION - 1)) == 0) {
> >  		pgdat->first_deferred_pfn = pfn;
> >  		return false;
> 
> I will try this out when I can get hold of the 12-TB machine again.
> 

Thanks.

> The vmalloc allocation failures were for the following hash tables:
> - Dentry cache hash table entries
> - Inode-cache hash table entries
> 
> Those hash tables scale linearly with the amount of memory available
> in the system. So instead of hardcoding a certain value, why don't
> we make it a certain % of the total memory but bottomed out to 1G at
> the low end?
> 

Because then it becomes what percentage is the right percentage and what
happens if it's a percentage of total memory but the NUMA nodes are not
all the same size?. I want to start simple until there is more data on
what these really large machines look like and if it ever fails in the
field, there is the command-line switch until a patch is available.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
