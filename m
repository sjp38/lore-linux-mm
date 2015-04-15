Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B7CCB6B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 09:38:34 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so47305304wgy.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:38:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si8217489wjs.46.2015.04.15.06.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 06:38:32 -0700 (PDT)
Date: Wed, 15 Apr 2015 14:38:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150415133826.GF14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <552E6486.6070705@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <552E6486.6070705@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
> > <SNIP>
> >Patches are against 4.0-rc7.
> >
> >  Documentation/kernel-parameters.txt |   8 +
> >  arch/ia64/mm/numa.c                 |  19 +-
> >  arch/x86/Kconfig                    |   2 +
> >  include/linux/memblock.h            |  18 ++
> >  include/linux/mm.h                  |   8 +-
> >  include/linux/mmzone.h              |  37 +++-
> >  init/main.c                         |   1 +
> >  mm/Kconfig                          |  29 +++
> >  mm/bootmem.c                        |   6 +-
> >  mm/internal.h                       |  23 ++-
> >  mm/memblock.c                       |  34 ++-
> >  mm/mm_init.c                        |   9 +-
> >  mm/nobootmem.c                      |   7 +-
> >  mm/page_alloc.c                     | 398 +++++++++++++++++++++++++++++++-----
> >  mm/vmscan.c                         |   6 +-
> >  15 files changed, 507 insertions(+), 98 deletions(-)
> >
> 
> I had included your patch with the 4.0 kernel and booted up a
> 16-socket 12-TB machine. I measured the elapsed time from the elilo
> prompt to the availability of ssh login. Without the patch, the
> bootup time was 404s. It was reduced to 298s with the patch. So
> there was about 100s reduction in bootup time (1/4 of the total).
> 

Cool, thanks for testing. Would you be able to state if this is really
important or not? Does booting 100s second faster on a 12TB machine really
matter? I can then add that justification to the changelog to avoid a
conversation with Andrew that goes something like

Andrew: Why are we doing this?
Mel:    Because we can and apparently people might want it.
Andrew: What's the maintenance cost of this?
Mel:    Magic beans

I prefer talking to Andrew when it's harder to predict what he'll say.

> However, there were 2 bootup problems in the dmesg log that needed
> to be addressed.
> 1. There were 2 vmalloc allocation failures:
> [    2.284686] vmalloc: allocation failure, allocated 16578404352 of
> 17179873280 bytes
> [   10.399938] vmalloc: allocation failure, allocated 7970922496 of
> 8589938688 bytes
> 
> 2. There were 2 soft lockup warnings:
> [   57.319453] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s!
> [swapper/0:1]
> [   85.409263] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s!
> [swapper/0:1]
> 
> Once those problems are fixed, the patch should be in a pretty good
> shape. I have attached the dmesg log for your reference.
> 

The obvious conclusion is that initialising 1G per node is not enough for
really large machines. Can you try this on top? It's untested but should
work. The low value was chosen because it happened to work and I wanted
to get test coverage on common hardware but broke is broke.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f2c96d02662f..6b3bec304e35 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -276,9 +276,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	if (pgdat->first_deferred_pfn != ULONG_MAX)
 		return false;
 
-	/* Initialise at least 1G per zone */
+	/* Initialise at least 32G per node */
 	(*nr_initialised)++;
-	if (*nr_initialised > (1UL << (30 - PAGE_SHIFT)) &&
+	if (*nr_initialised > (32UL << (30 - PAGE_SHIFT)) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		pgdat->first_deferred_pfn = pfn;
 		return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
