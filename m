Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C4A5E6B0254
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:17:16 -0400 (EDT)
Received: by wijp11 with SMTP id p11so84971587wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:17:16 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id j6si10188067wjf.167.2015.10.21.02.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 02:17:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 84C2398A8A
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 09:17:14 +0000 (UTC)
Date: Wed, 21 Oct 2015 10:17:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
Message-ID: <20151021091653.GA22902@techsingularity.net>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
 <20151020074700.GB2629@techsingularity.net>
 <20151020135056.GA22383@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20151020135056.GA22383@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 20, 2015 at 09:50:56AM -0400, Johannes Weiner wrote:
> On Tue, Oct 20, 2015 at 08:47:00AM +0100, Mel Gorman wrote:
> > On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> > > mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> > > SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> > > the scan window for vmpressure detection from 2MB to 16MB. Revert.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > This was known at the time but it was not clear what the measurable
> > impact would be. VM Pressure is odd in that it gives strange results at
> > times anyway, particularly on NUMA machines.
> 
> Interesting. Strange how? In terms of reporting random flukes?
> 

I haven't investigated closely myself. What I'm told is that on NUMA
machines that there is a "sawtooth-like" pattern of notifications. At
first, they received low pressure notifications and their application
released some memory. Later they expected more "low" events to be caught
but most times they saw "critical" or "medium" events immediately followed
by multiple critical events, sometimes multiple ones in the same second.
I currently that they are receiving events for one node but freeing on
another but never proved it.

> I'm interested in vmpressure because I think reclaim efficiency would
> be a useful metric to export to other parts of the kernel. We have
> slab shrinkers that export LRU scan rate for ageable caches--the
> keyword being "ageable" here--that are currently used for everything
> that wants to know about memory pressure. But unless you actually age
> and rotate your objects, it does not make sense to shrink your objects
> based on LRU scan rate. There is no reason to drop your costly objects
> if all the VM does is pick up streaming cache pages. In those cases,
> it would make more sense to hook yourself up to be notified when
> reclaim efficiency drops below a certain threshold.
> 

That makes sense but my expectation is that it needs NUMA smarts. It's
nowhere on my radar at the moment. The only thing I had on my plate that
was reclaim-related was to revisit the one-LRU-per-node series if the
atomic reserves and watermark series makes it through.

> > To be honest, it still isn't clear to me what the impact of the
> > patch is. With different base page sizes (e.g. on ppc64 with some
> > configs), the window is still large. At the time, it was left as-is
> > as I could not decide one way or the other but I'm ok with restoring
> > the behaviour so either way;
> > 
> > Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Thanks!
> 
> > Out of curiosity though, what *is* the user-visible impact of the patch
> > though? It's different but I'm having trouble deciding if it's better
> > or worse. I'm curious as to whether the patch is based on a bug report
> > or intuition.
> 
> No, I didn't observe a bug, it just struck me during code review.
> 
> My sole line of reasoning was: the pressure scan window was chosen
> back then to be at a certain point between reliable sample size and
> on-time reporting of detected pressure. Increasing the LRU scan window
> for the purpose of improved TLB batching seems sufficiently unrelated
> that we wouldn't want to change the vmpressure window as a side effect.
> 

That's reasonable and roughly what I expected. The vmpressure stuff was
originally designed with mobile devices in mind. AFAIK, they're reasonably
happy with it so the decisions it uses made sense to some interested user.

> Arguably it should not even reference SWAP_CLUSTER_MAX, but on the
> other hand that value has been pretty static in the past, and it looks
> better than '256' :-)

True. If it was changed, it would be in the context of NUMA smarts with
scaling based on reclaim activity or watermarks. Certainly, it's outside
the scope of what your patch is doing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
