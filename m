Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id A26C16B0073
	for <linux-mm@kvack.org>; Fri,  8 May 2015 19:18:59 -0400 (EDT)
Received: by qcvo8 with SMTP id o8so20779986qcv.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 16:18:59 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id dh6si6740622qcb.15.2015.05.08.16.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 08 May 2015 16:18:58 -0700 (PDT)
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 8 May 2015 19:18:58 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 945916E8045
	for <linux-mm@kvack.org>; Fri,  8 May 2015 19:10:43 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t48NItMS54198444
	for <linux-mm@kvack.org>; Fri, 8 May 2015 23:18:55 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t48NIrxl032520
	for <linux-mm@kvack.org>; Fri, 8 May 2015 19:18:54 -0400
Date: Fri, 8 May 2015 16:18:52 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-ID: <20150508231852.GA53489@linux.vnet.ibm.com>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
 <5515BAF7.6070604@intel.com>
 <20150327222350.GA22887@linux.vnet.ibm.com>
 <20150331094829.GE9589@dhcp22.suse.cz>
 <551E47EF.5030800@suse.cz>
 <20150403174556.GF32318@linux.vnet.ibm.com>
 <20150505220913.GC32719@linux.vnet.ibm.com>
 <5549DEAC.6080709@suse.cz>
 <20150508154726.9969933e6b5ebbb42e65ffae@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150508154726.9969933e6b5ebbb42e65ffae@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 08.05.2015 [15:47:26 -0700], Andrew Morton wrote:
> On Wed, 06 May 2015 11:28:12 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > On 05/06/2015 12:09 AM, Nishanth Aravamudan wrote:
> > > On 03.04.2015 [10:45:56 -0700], Nishanth Aravamudan wrote:
> > >>> What I find somewhat worrying though is that we could potentially
> > >>> break the pfmemalloc_watermark_ok() test in situations where
> > >>> zone_reclaimable_pages(zone) == 0 is a transient situation (and not
> > >>> a permanently allocated hugepage). In that case, the throttling is
> > >>> supposed to help system recover, and we might be breaking that
> > >>> ability with this patch, no?
> > >>
> > >> Well, if it's transient, we'll skip it this time through, and once there
> > >> are reclaimable pages, we should notice it again.
> > >>
> > >> I'm not familiar enough with this logic, so I'll read through the code
> > >> again soon to see if your concern is valid, as best I can.
> > >
> > > In reviewing the code, I think that transiently unreclaimable zones will
> > > lead to some higher direct reclaim rates and possible contention, but
> > > shouldn't cause any major harm. The likelihood of that situation, as
> > > well, in a non-reserved memory setup like the one I described, seems
> > > exceedingly low.
> > 
> > OK, I guess when a reasonably configured system has nothing to reclaim, 
> > it's already busted and throttling won't change much.
> > 
> > Consider the patch Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> OK, thanks, I'll move this patch into the queue for 4.2-rc1.

Thank you!

> Or is it important enough to merge into 4.1?

I think 4.2 is sufficient, but I wonder now if I should have included a
stable tag? The issue has been around for a while and there's a
relatively easily workaround (use the per-node sysfs files to manually
round-robin around the exhausted node) in older kernels, so I had
decided against it before.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
