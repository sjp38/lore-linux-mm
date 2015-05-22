Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC9582997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 05:33:19 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so12184207wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:33:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df4si7844930wib.111.2015.05.22.02.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 May 2015 02:33:18 -0700 (PDT)
Date: Fri, 22 May 2015 10:33:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150522093313.GZ2462@suse.de>
References: <1431597783.26797.1@cpanel21.proisp.no>
 <1432276201.11133.1@cpanel21.proisp.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1432276201.11133.1@cpanel21.proisp.no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nzimmer <nzimmer@sgi.com>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Fri, May 22, 2015 at 02:30:01PM +0800, Daniel J Blueman wrote:
> On Thu, May 14, 2015 at 6:03 PM, Daniel J Blueman
> <daniel@numascale.com> wrote:
> >On Thu, May 14, 2015 at 12:31 AM, Mel Gorman <mgorman@suse.de> wrote:
> >>On Wed, May 13, 2015 at 10:53:33AM -0500, nzimmer wrote:
> >>> I am just noticed a hang on my largest box.
> >>> I can only reproduce with large core counts, if I turn down the
> >>> number of cpus it doesn't have an issue.
> >>>
> >>
> >>Odd. The number of core counts should make little a difference
> >>as only
> >>one CPU per node should be in use. Does sysrq+t give any
> >>indication how
> >>or where it is hanging?
> >
> >I was seeing the same behaviour of 1000ms increasing to 5500ms
> >[1]; this suggests either lock contention or O(n) behaviour.
> >
> >Nathan, can you check with this ordering of patches from Andrew's
> >cache [2]? I was getting hanging until I a found them all.
> >
> >I'll follow up with timing data.
> 
> 7TB over 216 NUMA nodes, 1728 cores, from kernel 4.0.4 load to login:
> 
> 1. 2086s with patches 01-19 [1]
> 
> 2. 2026s adding "Take into account that large system caches scale
> linearly with memory", which has:
> min(2UL << (30 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 3));
> 
> 3. 2442s fixing to:
> max(2UL << (30 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 3));
> 
> 4. 2064s adjusting minimum and shift to:
> max(512UL << (20 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 8));
> 
> 5. 1934s adjusting minimum and shift to:
> max(128UL << (20 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 8));
> 
> 6. 930s #5 with the non-temporal PMD init patch I had earlier
> proposed (I'll pursue separately)
> 
> The scaling patch isn't in -mm.

That patch was superceded by "mm: meminit: finish
initialisation of struct pages before basic setup" and
"mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix"
so that's ok.

FWIW, I think you should still go ahead with the non-temporal patches because
there is potential benefit there other than the initialisation.  If there
was an arch-optional implementation of a non-termporal clear then it would
also be worth considering if __GFP_ZERO should use non-temporal stores.
At a greater stretch it would be worth considering if kswapd freeing should
zero pages to avoid a zero on the allocation side in the general case as
it would be more generally useful and a stepping stone towards what the
series "Sanitizing freed pages" attempts.

> #5 tests out nice on a bunch of
> other AMD systems, 64GB and up, so: Tested-by: Daniel J Blueman
> <daniel@numascale.com>.
> 

Thanks very much Daniel, much appreciated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
