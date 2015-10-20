Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id ECCB982F64
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 09:51:04 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so46757079wic.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 06:51:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j4si29250490wib.40.2015.10.20.06.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 06:51:03 -0700 (PDT)
Date: Tue, 20 Oct 2015 09:50:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
Message-ID: <20151020135056.GA22383@cmpxchg.org>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
 <20151020074700.GB2629@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151020074700.GB2629@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 20, 2015 at 08:47:00AM +0100, Mel Gorman wrote:
> On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> > mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> > SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> > the scan window for vmpressure detection from 2MB to 16MB. Revert.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This was known at the time but it was not clear what the measurable
> impact would be. VM Pressure is odd in that it gives strange results at
> times anyway, particularly on NUMA machines.

Interesting. Strange how? In terms of reporting random flukes?

I'm interested in vmpressure because I think reclaim efficiency would
be a useful metric to export to other parts of the kernel. We have
slab shrinkers that export LRU scan rate for ageable caches--the
keyword being "ageable" here--that are currently used for everything
that wants to know about memory pressure. But unless you actually age
and rotate your objects, it does not make sense to shrink your objects
based on LRU scan rate. There is no reason to drop your costly objects
if all the VM does is pick up streaming cache pages. In those cases,
it would make more sense to hook yourself up to be notified when
reclaim efficiency drops below a certain threshold.

> To be honest, it still isn't clear to me what the impact of the
> patch is. With different base page sizes (e.g. on ppc64 with some
> configs), the window is still large. At the time, it was left as-is
> as I could not decide one way or the other but I'm ok with restoring
> the behaviour so either way;
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks!

> Out of curiosity though, what *is* the user-visible impact of the patch
> though? It's different but I'm having trouble deciding if it's better
> or worse. I'm curious as to whether the patch is based on a bug report
> or intuition.

No, I didn't observe a bug, it just struck me during code review.

My sole line of reasoning was: the pressure scan window was chosen
back then to be at a certain point between reliable sample size and
on-time reporting of detected pressure. Increasing the LRU scan window
for the purpose of improved TLB batching seems sufficiently unrelated
that we wouldn't want to change the vmpressure window as a side effect.

Arguably it should not even reference SWAP_CLUSTER_MAX, but on the
other hand that value has been pretty static in the past, and it looks
better than '256' :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
